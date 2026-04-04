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