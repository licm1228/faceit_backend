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

import com.nageoffer.ai.ragent.interview.entity.PositionEntity;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PositionProfileServiceTests {

    private final PositionProfileService service = new PositionProfileService();

    @Test
    void shouldEnrichPythonAlgorithmProfile() {
        PositionEntity entity = new PositionEntity();
        entity.setId("pos_python_001");
        entity.setName("Python算法工程师");

        PositionEntity enriched = service.enrich(entity);

        assertTrue(enriched.getRequiredSkills().contains("Python"));
        assertEquals("python", enriched.getPreferredKnowledgeCollections().get(0));
        assertEquals("algorithm", enriched.getQuestionTypePlan().get(0));
        assertFalse(service.resolveLearningResourceTopics(entity.getId(), entity.getName()).isEmpty());
    }

    @Test
    void shouldResolveQuestionTypeDisplayName() {
        assertEquals("技术知识", service.resolveQuestionTypeDisplayName("technical"));
        assertEquals("项目深挖", service.resolveQuestionTypeDisplayName("project"));
        assertEquals("算法题", service.resolveQuestionTypeDisplayName("算法题"));
    }
}
