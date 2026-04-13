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

import com.nageoffer.ai.ragent.interview.entity.InterviewAnswerEntity;
import com.nageoffer.ai.ragent.interview.mapper.InterviewAnswerMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewAnswerService {

    private final InterviewAnswerMapper interviewAnswerMapper;

    public List<InterviewAnswerEntity> getAnswersBySessionId(String sessionId) {
        return interviewAnswerMapper.getAnswersBySessionId(sessionId);
    }

    public InterviewAnswerEntity getLatestAnswer(String sessionId, String questionId) {
        return interviewAnswerMapper.getLatestAnswer(sessionId, questionId);
    }

    @Transactional
    public InterviewAnswerEntity saveAnswer(String sessionId, String questionId, String userAnswer) {
        InterviewAnswerEntity entity = new InterviewAnswerEntity();
        entity.setSessionId(sessionId);
        entity.setQuestionId(questionId);
        entity.setUserAnswer(userAnswer);
        entity.setCreateTime(LocalDateTime.now());
        entity.setUpdateTime(LocalDateTime.now());
        entity.setDeleted(0);
        interviewAnswerMapper.insert(entity);
        return entity;
    }

    @Transactional
    public InterviewAnswerEntity saveOrUpdateAnswer(String sessionId, String questionId, String userAnswer) {
        InterviewAnswerEntity entity = getLatestAnswer(sessionId, questionId);
        if (entity == null) {
            return saveAnswer(sessionId, questionId, userAnswer);
        }
        String merged = entity.getUserAnswer() == null ? "" : entity.getUserAnswer();
        if (!merged.isBlank()) {
            merged = merged + "\n\n追问补充：" + userAnswer;
        } else {
            merged = userAnswer;
        }
        entity.setUserAnswer(merged);
        entity.setUpdateTime(LocalDateTime.now());
        interviewAnswerMapper.updateById(entity);
        return entity;
    }

    @Transactional
    public InterviewAnswerEntity evaluateAnswer(String answerId, Integer score, String feedback, String suggestions) {
        InterviewAnswerEntity entity = interviewAnswerMapper.selectById(answerId);
        if (entity != null) {
            entity.setScore(score);
            entity.setFeedback(feedback);
            entity.setSuggestions(suggestions);
            entity.setUpdateTime(LocalDateTime.now());
            interviewAnswerMapper.updateById(entity);
        }
        return entity;
    }

    @Transactional
    public InterviewAnswerEntity evaluateAnswer(String answerId, Integer score, Integer technicalScore,
                                              Integer expressionScore, Integer logicScore,
                                              Integer knowledgeScore, String feedback, String suggestions) {
        InterviewAnswerEntity entity = interviewAnswerMapper.selectById(answerId);
        if (entity != null) {
            entity.setScore(score);
            entity.setTechnicalScore(technicalScore);
            entity.setExpressionScore(expressionScore);
            entity.setLogicScore(logicScore);
            entity.setKnowledgeScore(knowledgeScore);
            entity.setFeedback(feedback);
            entity.setSuggestions(suggestions);
            entity.setIsCorrect(score >= 60);
            entity.setUpdateTime(LocalDateTime.now());
            interviewAnswerMapper.updateById(entity);
        }
        return entity;
    }

    @Transactional
    public void deleteAnswer(String id) {
        InterviewAnswerEntity entity = new InterviewAnswerEntity();
        entity.setId(id);
        entity.setDeleted(1);
        entity.setUpdateTime(LocalDateTime.now());
        interviewAnswerMapper.updateById(entity);
    }

    @Transactional
    public void deleteAnswersBySessionId(String sessionId) {
        getAnswersBySessionId(sessionId).forEach(answer -> deleteAnswer(answer.getId()));
    }
}
