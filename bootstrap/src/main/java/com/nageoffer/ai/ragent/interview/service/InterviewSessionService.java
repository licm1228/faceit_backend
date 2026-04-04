package com.nageoffer.ai.ragent.interview.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nageoffer.ai.ragent.interview.entity.InterviewSessionEntity;
import com.nageoffer.ai.ragent.interview.mapper.InterviewSessionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewSessionService {

    private final InterviewSessionMapper interviewSessionMapper;

    public List<InterviewSessionEntity> getSessionsByUserId(String userId) {
        LambdaQueryWrapper<InterviewSessionEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(InterviewSessionEntity::getUserId, userId)
                .eq(InterviewSessionEntity::getDeleted, 0)
                .orderByDesc(InterviewSessionEntity::getCreateTime);
        return interviewSessionMapper.selectList(wrapper);
    }

    public InterviewSessionEntity getSessionById(String id) {
        return interviewSessionMapper.selectById(id);
    }

    @Transactional
    public InterviewSessionEntity createSession(String userId, String positionId) {
        InterviewSessionEntity entity = new InterviewSessionEntity();
        entity.setUserId(userId);
        entity.setPositionId(positionId);
        entity.setStatus("pending");
        entity.setCreateTime(LocalDateTime.now());
        entity.setUpdateTime(LocalDateTime.now());
        entity.setDeleted(0);
        interviewSessionMapper.insert(entity);
        return entity;
    }

    @Transactional
    public InterviewSessionEntity startSession(String sessionId) {
        InterviewSessionEntity entity = interviewSessionMapper.selectById(sessionId);
        if (entity != null) {
            entity.setStatus("in_progress");
            entity.setStartTime(LocalDateTime.now());
            entity.setUpdateTime(LocalDateTime.now());
            interviewSessionMapper.updateById(entity);
        }
        return entity;
    }

    @Transactional
    public InterviewSessionEntity completeSession(String sessionId, Integer totalScore, String evaluationReport) {
        InterviewSessionEntity entity = interviewSessionMapper.selectById(sessionId);
        if (entity != null) {
            entity.setStatus("completed");
            entity.setTotalScore(totalScore);
            entity.setEvaluationReport(evaluationReport);
            entity.setEndTime(LocalDateTime.now());
            entity.setUpdateTime(LocalDateTime.now());
            interviewSessionMapper.updateById(entity);
        }
        return entity;
    }

    @Transactional
    public void deleteSession(String id) {
        InterviewSessionEntity entity = new InterviewSessionEntity();
        entity.setId(id);
        entity.setDeleted(1);
        entity.setUpdateTime(LocalDateTime.now());
        interviewSessionMapper.updateById(entity);
    }
}