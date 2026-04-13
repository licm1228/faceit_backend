/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.nageoffer.ai.ragent.interview.service;

import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.rag.core.retrieve.RetrieveRequest;
import com.nageoffer.ai.ragent.framework.convention.RetrievedChunk;
import com.nageoffer.ai.ragent.rag.core.retrieve.RetrieverService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class InterviewRetrieveService {

    private final QuestionService questionService;
    private final RetrieverService retrieverService;

    /**
     * 选择题目并检索相关知识库内容
     * @param positionId 岗位ID
     * @param difficulty 难度（可选）
     * @return 包含题目和检索结果的Map
     */
    public Map<String, Object> selectQuestionAndRetrieve(String positionId, Integer difficulty) {
        try {
            // 1. 从题库中选择题目
            QuestionEntity question = questionService.selectRandomQuestion(positionId, difficulty);
            if (question == null) {
                // 如果没有找到题目，返回默认题目
                question = createDefaultQuestion(positionId, difficulty);
            }

            // 2. 根据题目内容构建检索请求
            String query = buildRetrieveQuery(question);
            RetrieveRequest retrieveRequest = RetrieveRequest.builder()
                    .query(query)
                    .topK(5) // 默认返回5个相关文档
                    .collectionName("rag_default_store") // 使用默认的collectionName
                    .build();

            // 3. 执行检索
            List<RetrievedChunk> retrievedChunks = retrieverService.retrieve(retrieveRequest);

            // 4. 构建返回结果
            return Map.of(
                    "question", Map.of(
                            "id", question.getId(),
                            "positionId", question.getPositionId(),
                            "questionText", question.getQuestionText(),
                            "referenceAnswer", question.getReferenceAnswer(),
                            "difficulty", question.getDifficulty()
                    ),
                    "relatedContent", retrievedChunks.stream()
                            .map(chunk -> Map.of(
                                    "content", chunk.getText(),
                                    "score", chunk.getScore()
                            ))
                            .collect(Collectors.toList())
            );
        } catch (Exception e) {
            // 记录错误日志
            log.error("选择题目并检索失败", e);
            // 返回错误信息
            return Map.of(
                    "error", "处理面试问题失败",
                    "message", e.getMessage()
            );
        }
    }

    /**
     * 选择多个不同难度的题目
     * @param positionId 岗位ID
     * @param count 题目数量
     * @return 包含多个题目的Map
     */
    public Map<String, Object> selectMultipleQuestions(String positionId, int count) {
        try {
            List<Map<String, Object>> questions = new ArrayList<>();

            // 选择不同难度的题目
            int[] difficulties = {1, 2, 3, 4, 5};
            for (int i = 0; i < count; i++) {
                int difficulty = difficulties[i % difficulties.length];
                QuestionEntity question = questionService.selectRandomQuestion(positionId, difficulty);
                if (question == null) {
                    question = createDefaultQuestion(positionId, difficulty);
                }
                questions.add(Map.of(
                        "id", question.getId(),
                        "positionId", question.getPositionId(),
                        "questionText", question.getQuestionText(),
                        "referenceAnswer", question.getReferenceAnswer(),
                        "difficulty", question.getDifficulty()
                ));
            }

            return Map.of(
                    "questions", questions
            );
        } catch (Exception e) {
            // 记录错误日志
            log.error("选择多个题目失败", e);
            // 返回错误信息
            return Map.of(
                    "error", "处理面试问题失败",
                    "message", e.getMessage()
            );
        }
    }

    /**
     * 根据题目构建检索查询语句
     * @param question 题目实体
     * @return 检索查询语句
     */
    private String buildRetrieveQuery(QuestionEntity question) {
        StringBuilder queryBuilder = new StringBuilder();
        queryBuilder.append(question.getQuestionText());

        // 如果有关键词，也加入查询中
        if (question.getKeywords() != null && !question.getKeywords().isEmpty()) {
            // 处理PostgreSQL数组格式的关键词：{"关键词1", "关键词2"}
            String keywords = question.getKeywords();
            // 移除首尾的大括号
            keywords = keywords.replaceAll("^\\{|\\}$", "");
            // 分割关键词
            String[] keywordArray = keywords.split(",");
            for (String keyword : keywordArray) {
                // 移除引号和空格
                keyword = keyword.replaceAll("['\\\"\\\"]", "").trim();
                if (!keyword.isEmpty()) {
                    queryBuilder.append(" ").append(keyword);
                }
            }
        }

        return queryBuilder.toString().trim();
    }

    /**
     * 创建默认题目
     * @param positionId 岗位ID
     * @param difficulty 难度
     * @return 默认题目
     */
    private QuestionEntity createDefaultQuestion(String positionId, Integer difficulty) {
        QuestionEntity question = new QuestionEntity();
        question.setId("default-" + System.currentTimeMillis());
        question.setPositionId(positionId);
        question.setQuestionType("技术问题");
        question.setDifficulty(difficulty != null ? difficulty : 3);

        // 兼容旧 demo 岗位 ID，并优先适配当前真实岗位 ID
        if (matchesPosition(positionId, "8", "pos_python_001")) {
            question.setQuestionText("请介绍一下Python中的生成器（Generator）是什么，以及它的使用场景？");
            question.setReferenceAnswer("生成器是Python中一种特殊的迭代器，它使用yield语句来产生值，而不是一次性返回所有值。生成器的主要特点：\n1. 惰性求值：只在需要时生成值，节省内存\n2. 状态保存：每次调用next()时，从上次yield的位置继续执行\n3. 语法简洁：使用yield语句，比普通迭代器更简洁\n\n使用场景：\n1. 处理大数据集：避免一次性加载所有数据到内存\n2. 无限序列：如斐波那契数列\n3. 协程：实现简单的协程功能\n4. 管道处理：数据处理的流水线\n\n生成器的优点是内存效率高，缺点是不能随机访问元素，只能顺序遍历。");
            question.setKeywords("{\"Python\", \"生成器\", \"yield\", \"迭代器\"}");
        } else if (matchesPosition(positionId, "1", "pos_java_001")) {
            question.setQuestionText("请介绍一下Java中的线程池，以及它的工作原理？");
            question.setReferenceAnswer("线程池是一种线程管理技术，它通过预先创建一定数量的线程，然后在需要时重用这些线程，而不是每次都创建新线程。线程池的主要优点：\n1. 减少线程创建和销毁的开销\n2. 控制并发线程的数量，避免资源耗尽\n3. 提高响应速度，因为线程已经预先创建\n\nJava中的线程池实现：\n1. ExecutorService：线程池的核心接口\n2. ThreadPoolExecutor：线程池的主要实现类\n3. Executors：提供创建线程池的工厂方法\n\n线程池的工作原理：\n1. 当提交任务时，首先检查核心线程数是否已满\n2. 如果核心线程数未满，创建新线程执行任务\n3. 如果核心线程数已满，将任务放入工作队列\n4. 如果工作队列已满，检查最大线程数是否已满\n5. 如果最大线程数未满，创建新线程执行任务\n6. 如果最大线程数已满，执行拒绝策略");
            question.setKeywords("{\"Java\", \"线程池\", \"ExecutorService\", \"ThreadPoolExecutor\"}");
        } else if (matchesPosition(positionId, "2", "pos_web_001")) {
            question.setQuestionText("请介绍一下前端中的闭包（Closure）是什么，以及它的使用场景？");
            question.setReferenceAnswer("闭包是指有权访问另一个函数作用域中变量的函数。闭包的主要特点：\n1. 可以访问外部函数的变量\n2. 即使外部函数执行完毕，闭包仍然可以访问其变量\n3. 可以保护变量不被外部访问\n\n使用场景：\n1. 数据私有化：创建私有变量和方法\n2. 函数工厂：根据参数创建不同行为的函数\n3. 模块化：实现模块模式，避免全局变量污染\n4. 事件处理：保存事件处理函数的上下文\n5. 异步操作：在异步操作中访问外部变量\n\n闭包的优点是可以创建私有变量和方法，缺点是可能导致内存泄漏，因为闭包会引用外部函数的变量，导致这些变量无法被垃圾回收。");
            question.setKeywords("{\"前端\", \"JavaScript\", \"闭包\", \"作用域\"}");
        } else {
            question.setQuestionText("请介绍一下你对编程的理解，以及你熟悉的编程语言有哪些？");
            question.setReferenceAnswer("编程是使用编程语言编写代码来实现特定功能的过程。我熟悉的编程语言包括：\n1. Java：面向对象的编程语言，广泛用于企业级应用开发\n2. Python：简单易学的编程语言，广泛用于数据科学、人工智能等领域\n3. JavaScript：用于前端开发的脚本语言，也可用于后端开发\n4. C++：高性能的编程语言，广泛用于系统开发、游戏开发等领域\n5. SQL：用于数据库操作的查询语言");
            question.setKeywords("{\"编程\", \"编程语言\", \"软件开发\", \"计算机科学\"}");
        }

        return question;
    }

    private boolean matchesPosition(String positionId, String currentId, String legacyId) {
        return currentId.equals(positionId) || legacyId.equals(positionId);
    }
}
