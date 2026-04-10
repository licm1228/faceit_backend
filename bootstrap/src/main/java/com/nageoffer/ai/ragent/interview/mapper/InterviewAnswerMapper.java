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

package com.nageoffer.ai.ragent.interview.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nageoffer.ai.ragent.interview.entity.InterviewAnswerEntity;
import java.util.List;

public interface InterviewAnswerMapper extends BaseMapper<InterviewAnswerEntity> {
    default List<InterviewAnswerEntity> getAnswersBySessionId(String sessionId) {
        LambdaQueryWrapper<InterviewAnswerEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(InterviewAnswerEntity::getSessionId, sessionId)
                .eq(InterviewAnswerEntity::getDeleted, 0)
                .orderByAsc(InterviewAnswerEntity::getCreateTime);
        return selectList(wrapper);
    }
}
