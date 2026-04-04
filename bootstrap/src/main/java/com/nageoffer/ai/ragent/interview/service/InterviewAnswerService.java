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
    public void deleteAnswer(String id) {
        InterviewAnswerEntity entity = new InterviewAnswerEntity();
        entity.setId(id);
        entity.setDeleted(1);
        entity.setUpdateTime(LocalDateTime.now());
        interviewAnswerMapper.updateById(entity);
    }
}