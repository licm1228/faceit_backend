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

    public List<PositionEntity> getAllPositions() {
        LambdaQueryWrapper<PositionEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PositionEntity::getDeleted, 0)
                .orderByDesc(PositionEntity::getCreateTime);
        return positionMapper.selectList(wrapper);
    }

    public PositionEntity getPositionById(String id) {
        return positionMapper.selectById(id);
    }

    @Transactional
    public PositionEntity createPosition(PositionEntity entity) {
        entity.setCreateTime(LocalDateTime.now());
        entity.setUpdateTime(LocalDateTime.now());
        entity.setDeleted(0);
        positionMapper.insert(entity);
        return entity;
    }

    @Transactional
    public PositionEntity updatePosition(PositionEntity entity) {
        entity.setUpdateTime(LocalDateTime.now());
        positionMapper.updateById(entity);
        return entity;
    }

    @Transactional
    public void deletePosition(String id) {
        PositionEntity entity = new PositionEntity();
        entity.setId(id);
        entity.setDeleted(1);
        entity.setUpdateTime(LocalDateTime.now());
        positionMapper.updateById(entity);
    }
}