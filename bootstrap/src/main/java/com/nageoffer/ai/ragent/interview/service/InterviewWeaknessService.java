package com.nageoffer.ai.ragent.interview.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nageoffer.ai.ragent.interview.entity.InterviewWeaknessEntity;
import com.nageoffer.ai.ragent.interview.mapper.InterviewWeaknessMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewWeaknessService {

    private final InterviewWeaknessMapper interviewWeaknessMapper;

    public List<InterviewWeaknessEntity> getWeaknessesByUserId(String userId) {
        LambdaQueryWrapper<InterviewWeaknessEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(InterviewWeaknessEntity::getUserId, userId)
                .eq(InterviewWeaknessEntity::getDeleted, 0)
                .orderByDesc(InterviewWeaknessEntity::getWeaknessLevel)
                .orderByDesc(InterviewWeaknessEntity::getCreateTime);
        return interviewWeaknessMapper.selectList(wrapper);
    }

    @Transactional
    public InterviewWeaknessEntity createWeakness(InterviewWeaknessEntity entity) {
        entity.setCreateTime(LocalDateTime.now());
        entity.setUpdateTime(LocalDateTime.now());
        entity.setDeleted(0);
        interviewWeaknessMapper.insert(entity);
        return entity;
    }

    @Transactional
    public void deleteWeakness(String id) {
        InterviewWeaknessEntity entity = new InterviewWeaknessEntity();
        entity.setId(id);
        entity.setDeleted(1);
        entity.setUpdateTime(LocalDateTime.now());
        interviewWeaknessMapper.updateById(entity);
    }
}
