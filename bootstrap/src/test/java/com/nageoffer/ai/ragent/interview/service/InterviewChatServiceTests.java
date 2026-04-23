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

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nageoffer.ai.ragent.infra.config.AIModelProperties;
import com.nageoffer.ai.ragent.interview.entity.PositionEntity;
import com.nageoffer.ai.ragent.interview.mapper.PositionMapper;
import com.nageoffer.ai.ragent.rag.dao.mapper.ConversationMapper;
import com.nageoffer.ai.ragent.rag.dao.mapper.ConversationMessageMapper;
import com.nageoffer.ai.ragent.rag.dao.mapper.ConversationSummaryMapper;
import com.nageoffer.ai.ragent.rag.core.retrieve.RetrieverService;
import com.nageoffer.ai.ragent.rag.service.ConversationMessageService;
import com.nageoffer.ai.ragent.knowledge.service.KnowledgeDocumentService;
import org.junit.jupiter.api.Test;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;
import java.util.Map;
import java.util.concurrent.Executor;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class InterviewChatServiceTests {

    @Test
    void shouldResolveMinuteAndQuestionExpressionsWithinExpandedRange() {
        PositionMapper positionMapper = mock(PositionMapper.class);
        when(positionMapper.selectList(any())).thenReturn(List.of(position("pos_java_001", "Java后端开发工程师")));

        InterviewChatService service = new InterviewChatService(
                mock(InterviewSessionService.class),
                mock(InterviewAnswerService.class),
                mock(QuestionService.class),
                mock(PositionProfileService.class),
                mock(KnowledgeDocumentService.class),
                mock(RetrieverService.class),
                positionMapper,
                mock(AIEvaluationService.class),
                mock(ConversationMapper.class),
                mock(ConversationMessageMapper.class),
                mock(ConversationSummaryMapper.class),
                mock(ConversationMessageService.class),
                new ObjectMapper(),
                new AIModelProperties(),
                mock(TransactionTemplate.class),
                directExecutor(),
                directExecutor()
        );

        Map<String, Object> result = service.resolveConfig("来一场 Java 后端 45 分 8 题面试");

        assertTrue((Boolean) result.get("matched"));
        assertEquals("pos_java_001", result.get("positionId"));
        assertEquals(45, result.get("timeLimitMinutes"));
        assertEquals(8, result.get("questionLimit"));
    }

    @Test
    void shouldClampResolvedTimeAndQuestionLimitToExpandedBounds() {
        PositionMapper positionMapper = mock(PositionMapper.class);
        when(positionMapper.selectList(any())).thenReturn(List.of(position("pos_python_001", "Python算法工程师")));

        InterviewChatService service = new InterviewChatService(
                mock(InterviewSessionService.class),
                mock(InterviewAnswerService.class),
                mock(QuestionService.class),
                mock(PositionProfileService.class),
                mock(KnowledgeDocumentService.class),
                mock(RetrieverService.class),
                positionMapper,
                mock(AIEvaluationService.class),
                mock(ConversationMapper.class),
                mock(ConversationMessageMapper.class),
                mock(ConversationSummaryMapper.class),
                mock(ConversationMessageService.class),
                new ObjectMapper(),
                new AIModelProperties(),
                mock(TransactionTemplate.class),
                directExecutor(),
                directExecutor()
        );

        Map<String, Object> result = service.resolveConfig("Python算法面试，300 分钟，50 题");

        assertTrue((Boolean) result.get("matched"));
        assertEquals(180, result.get("timeLimitMinutes"));
        assertEquals(20, result.get("questionLimit"));
    }

    private static PositionEntity position(String id, String name) {
        PositionEntity entity = new PositionEntity();
        entity.setId(id);
        entity.setName(name);
        entity.setDeleted(0);
        return entity;
    }

    private static Executor directExecutor() {
        return Runnable::run;
    }
}
