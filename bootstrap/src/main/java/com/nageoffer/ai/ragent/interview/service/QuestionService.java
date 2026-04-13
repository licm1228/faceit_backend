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

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.interview.mapper.QuestionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class QuestionService {

    private final QuestionMapper questionMapper;
    private final PositionProfileService positionProfileService;

    public List<QuestionEntity> getAllQuestions() {
        LambdaQueryWrapper<QuestionEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(QuestionEntity::getDeleted, 0)
                .orderByDesc(QuestionEntity::getCreateTime);
        return questionMapper.selectList(wrapper).stream()
                .map(this::enrichQuestion)
                .toList();
    }

    public List<QuestionEntity> getQuestionsByPosition(String positionId) {
        LambdaQueryWrapper<QuestionEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(QuestionEntity::getPositionId, positionId)
                .eq(QuestionEntity::getDeleted, 0)
                .orderByAsc(QuestionEntity::getDifficulty);
        return questionMapper.selectList(wrapper).stream()
                .map(this::enrichQuestion)
                .toList();
    }

    public List<QuestionEntity> getQuestionsByType(String positionId, String questionType) {
        LambdaQueryWrapper<QuestionEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(QuestionEntity::getPositionId, positionId)
                .eq(QuestionEntity::getQuestionType, questionType)
                .eq(QuestionEntity::getDeleted, 0);
        return questionMapper.selectList(wrapper).stream()
                .map(this::enrichQuestion)
                .toList();
    }

    public QuestionEntity getQuestionById(String id) {
        return enrichQuestion(questionMapper.selectById(id));
    }

    public QuestionEntity selectRandomQuestion(String positionId, Integer difficulty) {
        LambdaQueryWrapper<QuestionEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(QuestionEntity::getPositionId, positionId)
                .eq(QuestionEntity::getDeleted, 0);
        if (difficulty != null) {
            wrapper.eq(QuestionEntity::getDifficulty, difficulty);
        }
        // 不同数据库的随机排序语法不同
        // MySQL使用ORDER BY RAND()
        // PostgreSQL使用ORDER BY RANDOM()
        wrapper.last("ORDER BY RANDOM() LIMIT 1");
        QuestionEntity question = questionMapper.selectOne(wrapper);

        // 如果没有找到题目，尝试不按难度筛选
        if (question == null && difficulty != null) {
            LambdaQueryWrapper<QuestionEntity> fallbackWrapper = new LambdaQueryWrapper<>();
            fallbackWrapper.eq(QuestionEntity::getPositionId, positionId)
                    .eq(QuestionEntity::getDeleted, 0);
            fallbackWrapper.last("ORDER BY RANDOM() LIMIT 1");
            question = questionMapper.selectOne(fallbackWrapper);
        }

        return enrichQuestion(question);
    }

    public QuestionEntity selectRandomQuestionExcluding(String positionId, Integer difficulty, List<String> excludedQuestionIds) {
        LambdaQueryWrapper<QuestionEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(QuestionEntity::getPositionId, positionId)
                .eq(QuestionEntity::getDeleted, 0);
        if (difficulty != null) {
            wrapper.eq(QuestionEntity::getDifficulty, difficulty);
        }
        List<QuestionEntity> candidates = questionMapper.selectList(wrapper);
        if ((candidates == null || candidates.isEmpty()) && difficulty != null) {
            return selectRandomQuestionExcluding(positionId, null, excludedQuestionIds);
        }
        if (candidates == null || candidates.isEmpty()) {
            return null;
        }
        List<QuestionEntity> filtered = new ArrayList<>(candidates);
        if (excludedQuestionIds != null && !excludedQuestionIds.isEmpty()) {
            filtered.removeIf(item -> excludedQuestionIds.contains(item.getId()));
        }
        if (filtered.isEmpty()) {
            filtered = new ArrayList<>(candidates);
        }
        Collections.shuffle(filtered);
        return enrichQuestion(filtered.get(0));
    }

    @Transactional
    public QuestionEntity createQuestion(QuestionEntity entity) {
        entity.setCreateTime(LocalDateTime.now());
        entity.setUpdateTime(LocalDateTime.now());
        entity.setDeleted(0);
        questionMapper.insert(entity);
        return entity;
    }

    @Transactional
    public QuestionEntity updateQuestion(QuestionEntity entity) {
        entity.setUpdateTime(LocalDateTime.now());
        questionMapper.updateById(entity);
        return enrichQuestion(questionMapper.selectById(entity.getId()));
    }

    @Transactional
    public void deleteQuestion(String id) {
        QuestionEntity entity = new QuestionEntity();
        entity.setId(id);
        entity.setDeleted(1);
        entity.setUpdateTime(LocalDateTime.now());
        questionMapper.updateById(entity);
    }

    public QuestionEntity enrichQuestion(QuestionEntity entity) {
        if (entity == null) {
            return null;
        }
        entity.setKeywordList(parseKeywords(entity.getKeywords()));
        entity.setKnowledgeSource(positionProfileService.resolveInterviewFocus(entity.getPositionId(), null, "当前岗位核心知识点"));
        entity.setReferenceAnswerPreview(buildReferenceAnswerPreview(entity.getReferenceAnswer()));
        if (entity.getRecommendationReason() == null || entity.getRecommendationReason().isBlank()) {
            entity.setRecommendationReason("建议围绕当前岗位核心能力继续完成同类型专项训练。");
        }
        return entity;
    }

    private List<String> parseKeywords(String rawKeywords) {
        if (rawKeywords == null || rawKeywords.isBlank()) {
            return List.of();
        }
        String normalized = rawKeywords
                .replace("{", "")
                .replace("}", "")
                .replace("[", "")
                .replace("]", "")
                .replace("\"", "")
                .replace("'", "");
        String[] items = normalized.split("[,，]");
        List<String> keywords = new ArrayList<>();
        for (String item : items) {
            String keyword = item.trim();
            if (!keyword.isEmpty()) {
                keywords.add(keyword);
            }
        }
        return keywords;
    }

    private String buildReferenceAnswerPreview(String referenceAnswer) {
        if (referenceAnswer == null || referenceAnswer.isBlank()) {
            return "";
        }
        String text = referenceAnswer.replace("\n", " ").trim();
        if (text.length() <= 80) {
            return text;
        }
        return text.substring(0, 80) + "...";
    }
}
