package com.nageoffer.ai.ragent.interview.controller;

import com.nageoffer.ai.ragent.interview.entity.PositionEntity;
import com.nageoffer.ai.ragent.interview.service.PositionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/position")
@RequiredArgsConstructor
public class PositionController {

    private final PositionService positionService;

    /**
     * 获取所有岗位
     */
    @GetMapping("/list")
    public Map<String, Object> list() {
        List<PositionEntity> list = positionService.getAllPositions();
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", list);
        return result;
    }

    /**
     * 获取岗位详情
     */
    @GetMapping("/{id}")
    public Map<String, Object> getById(@PathVariable String id) {
        PositionEntity entity = positionService.getPositionById(id);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", entity);
        return result;
    }

    /**
     * 新增岗位
     */
    @PostMapping("/create")
    public Map<String, Object> create(@RequestBody PositionEntity entity) {
        PositionEntity result = positionService.createPosition(entity);
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "创建成功");
        response.put("data", result);
        return response;
    }

    /**
     * 更新岗位
     */
    @PutMapping("/update")
    public Map<String, Object> update(@RequestBody PositionEntity entity) {
        PositionEntity result = positionService.updatePosition(entity);
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "更新成功");
        response.put("data", result);
        return response;
    }

    /**
     * 删除岗位（软删除）
     */
    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable String id) {
        positionService.deletePosition(id);
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "删除成功");
        return response;
    }
}