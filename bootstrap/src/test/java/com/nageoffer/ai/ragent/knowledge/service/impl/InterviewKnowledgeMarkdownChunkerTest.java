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

package com.nageoffer.ai.ragent.knowledge.service.impl;

import com.nageoffer.ai.ragent.core.chunk.VectorChunk;
import com.nageoffer.ai.ragent.knowledge.dao.entity.KnowledgeDocumentDO;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class InterviewKnowledgeMarkdownChunkerTest {

    private final InterviewKnowledgeMarkdownChunker chunker = new InterviewKnowledgeMarkdownChunker();

    @Test
    void shouldRecognizeFaceItInterviewMarkdown() {
        KnowledgeDocumentDO documentDO = KnowledgeDocumentDO.builder()
                .docName("python-函数参数与拷贝.md")
                .sourceLocation("/home/furina/Code/Face It/rag/python/python-函数参数与拷贝.md")
                .build();

        assertTrue(chunker.supports(documentDO, SAMPLE_MARKDOWN));
    }

    @Test
    void shouldBuildStructuredChunksWithoutRepeatingHeaderSections() {
        KnowledgeDocumentDO documentDO = KnowledgeDocumentDO.builder()
                .docName("python-函数参数与拷贝.md")
                .sourceLocation("/home/furina/Code/Face It/rag/python/python-函数参数与拷贝.md")
                .build();

        List<VectorChunk> chunks = chunker.chunk(documentDO, "Python算法", SAMPLE_MARKDOWN);

        assertEquals(5, chunks.size());
        assertTrue(chunks.stream().noneMatch(chunk -> chunk.getContent().contains("## 适用知识库")));
        assertTrue(chunks.stream().noneMatch(chunk -> chunk.getContent().contains("## 建议文件名")));
        assertTrue(chunks.stream().noneMatch(chunk -> chunk.getContent().contains("## 主题标签")));
        assertTrue(chunks.stream().anyMatch(chunk -> "question".equals(chunk.getMetadata().get("sectionType"))));
        assertTrue(chunks.stream().anyMatch(chunk -> "answer".equals(chunk.getMetadata().get("sectionType"))));
        assertTrue(chunks.stream().anyMatch(chunk -> "followup".equals(chunk.getMetadata().get("sectionType"))));

        VectorChunk firstQuestion = chunks.stream()
                .filter(chunk -> "question".equals(chunk.getMetadata().get("sectionType")))
                .findFirst()
                .orElseThrow();
        assertTrue(firstQuestion.getContent().startsWith("主题：Python 函数参数与拷贝"));
        assertFalse(firstQuestion.getContent().contains("适用知识库"));
        assertEquals(1, firstQuestion.getMetadata().get("questionNo"));
        assertEquals("1", firstQuestion.getMetadata().get("difficulty"));
        assertEquals("基础概念", firstQuestion.getMetadata().get("questionType"));
    }

    private static final String SAMPLE_MARKDOWN = """
            # Python 函数参数与拷贝

            ## 适用知识库
            python

            ## 建议文件名
            python/python-函数参数与拷贝.md

            ## 主题标签
            函数参数、args kwargs、默认参数、深浅拷贝

            ## 高频问题

            ### 问题1
            Python 函数中有哪些常见参数类型？

            #### 难度
            1

            #### 类型
            基础概念

            ### 问题2
            `*args` 和 `**kwargs` 的作用是什么？

            #### 难度
            1

            #### 类型
            基础概念

            ## 参考答案

            ### 问题1
            常见参数类型包括位置参数、默认参数、可变位置参数和关键字参数。

            ### 问题2
            `*args` 用于接收任意数量的位置参数，`**kwargs` 用于接收任意数量的关键字参数。

            ## 延伸追问
            - 位置参数和关键字参数的调用顺序是什么？

            ## 检索关键词
            Python参数类型、args kwargs
            """;
}
