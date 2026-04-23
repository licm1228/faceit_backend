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
import com.nageoffer.ai.ragent.interview.entity.PositionEntity;
import com.nageoffer.ai.ragent.interview.mapper.PositionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PositionService {

    private final PositionMapper positionMapper;
    private final PositionProfileService positionProfileService;

    public List<PositionEntity> getAllPositions() {
        LambdaQueryWrapper<PositionEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PositionEntity::getDeleted, 0)
                .orderByAsc(PositionEntity::getId);
        return positionMapper.selectList(wrapper).stream()
                .map(positionProfileService::enrich)
                .toList();
    }

    public PositionEntity getPositionById(String id) {
        return positionProfileService.enrich(positionMapper.selectById(id));
    }

    @Transactional
    public PositionEntity createPosition(PositionEntity entity) {
        normalizePersistFields(entity);
        entity.setCreateTime(LocalDateTime.now());
        entity.setUpdateTime(LocalDateTime.now());
        entity.setDeleted(0);
        positionMapper.insert(entity);
        return positionProfileService.enrich(entity);
    }

    @Transactional
    public PositionEntity updatePosition(PositionEntity entity) {
        normalizePersistFields(entity);
        entity.setUpdateTime(LocalDateTime.now());
        positionMapper.updateById(entity);
        return positionProfileService.enrich(positionMapper.selectById(entity.getId()));
    }

    @Transactional
    public void deletePosition(String id) {
        PositionEntity entity = new PositionEntity();
        entity.setId(id);
        entity.setDeleted(1);
        entity.setUpdateTime(LocalDateTime.now());
        positionMapper.updateById(entity);
    }

    private void normalizePersistFields(PositionEntity entity) {
        if (entity == null) {
            return;
        }
        entity.setRequiredSkills(normalizeSkillsJson(entity.getRequiredSkills()));
    }

    private String normalizeSkillsJson(String rawSkills) {
        if (rawSkills == null || rawSkills.isBlank()) {
            return rawSkills;
        }
        String trimmed = rawSkills.trim();
        if (trimmed.startsWith("[")) {
            return trimmed;
        }
        String[] items = trimmed.split("[,，]");
        StringBuilder builder = new StringBuilder("[");
        boolean first = true;
        for (String item : items) {
            String normalized = item.trim();
            if (normalized.isEmpty()) {
                continue;
            }
            if (!first) {
                builder.append(',');
            }
            builder.append('"').append(normalized.replace("\"", "\\\"")).append('"');
            first = false;
        }
        builder.append(']');
        return first ? null : builder.toString();
    }
}
