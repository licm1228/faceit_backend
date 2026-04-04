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
