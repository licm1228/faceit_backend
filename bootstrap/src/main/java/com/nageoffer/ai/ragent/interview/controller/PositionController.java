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