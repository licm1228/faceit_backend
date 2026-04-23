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
import java.util.Locale;
import java.util.Set;

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
        return selectRandomQuestion(positionId, difficulty, null);
    }

    public QuestionEntity selectRandomQuestion(String positionId, Integer difficulty, List<String> preferredQuestionTypes) {
        return selectRandomQuestionExcluding(positionId, difficulty, preferredQuestionTypes, List.of());
    }

    public QuestionEntity selectRandomQuestionExcluding(String positionId, Integer difficulty, List<String> excludedQuestionIds) {
        return selectRandomQuestionExcluding(positionId, difficulty, null, excludedQuestionIds);
    }

    public QuestionEntity selectRandomQuestionExcluding(
            String positionId,
            Integer difficulty,
            List<String> preferredQuestionTypes,
            List<String> excludedQuestionIds
    ) {
        List<QuestionEntity> exactDifficultyCandidates = selectCandidates(positionId, difficulty);
        List<QuestionEntity> allDifficultyCandidates = difficulty == null ? exactDifficultyCandidates : selectCandidates(positionId, null);

        QuestionEntity question = pickQuestion(exactDifficultyCandidates, preferredQuestionTypes, excludedQuestionIds);
        if (question != null) {
            return question;
        }
        if (difficulty != null) {
            question = pickQuestion(allDifficultyCandidates, preferredQuestionTypes, excludedQuestionIds);
            if (question != null) {
                return question;
            }
        }
        question = pickQuestion(exactDifficultyCandidates, null, excludedQuestionIds);
        if (question != null) {
            return question;
        }
        if (difficulty != null) {
            question = pickQuestion(allDifficultyCandidates, null, excludedQuestionIds);
        }
        return question;
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

    private List<QuestionEntity> selectCandidates(String positionId, Integer difficulty) {
        LambdaQueryWrapper<QuestionEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(QuestionEntity::getPositionId, positionId)
                .eq(QuestionEntity::getDeleted, 0);
        if (difficulty != null) {
            wrapper.eq(QuestionEntity::getDifficulty, difficulty);
        }
        return questionMapper.selectList(wrapper);
    }

    private QuestionEntity pickQuestion(
            List<QuestionEntity> candidates,
            List<String> preferredQuestionTypes,
            List<String> excludedQuestionIds
    ) {
        if (candidates == null || candidates.isEmpty()) {
            return null;
        }
        List<QuestionEntity> filtered = new ArrayList<>(candidates);
        if (preferredQuestionTypes != null && !preferredQuestionTypes.isEmpty()) {
            Set<String> preferredTokens = preferredQuestionTypes.stream()
                    .map(this::normalizeQuestionTypeToken)
                    .filter(token -> !token.isBlank())
                    .collect(java.util.stream.Collectors.toSet());
            filtered.removeIf(item -> !preferredTokens.contains(normalizeQuestionTypeToken(item.getQuestionType())));
        }
        if (excludedQuestionIds != null && !excludedQuestionIds.isEmpty()) {
            filtered.removeIf(item -> excludedQuestionIds.contains(item.getId()));
        }
        if (filtered.isEmpty()) {
            return null;
        }
        Collections.shuffle(filtered);
        return enrichQuestion(filtered.get(0));
    }

    private String normalizeQuestionTypeToken(String questionType) {
        if (questionType == null) {
            return "";
        }
        String normalized = questionType.trim().toLowerCase(Locale.ROOT);
        return switch (normalized) {
            case "technical", "技术题", "技术问题", "技术知识" -> "technical";
            case "scenario", "场景题" -> "scenario";
            case "project", "项目题", "项目深挖" -> "project";
            case "behavior", "行为题" -> "behavior";
            case "algorithm", "算法题" -> "algorithm";
            case "advanced", "综合进阶", "综合题" -> "advanced";
            default -> normalized;
        };
    }
}
