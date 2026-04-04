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

import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.interview.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/question")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    /**
     * 获取所有题目
     */
    @GetMapping("/list")
    public Map<String, Object> list() {
        List<QuestionEntity> list = questionService.getAllQuestions();
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", list);
        return result;
    }

    /**
     * 根据岗位获取题目
     */
    @GetMapping("/by-position/{positionId}")
    public Map<String, Object> getByPosition(@PathVariable String positionId) {
        List<QuestionEntity> list = questionService.getQuestionsByPosition(positionId);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", list);
        return result;
    }

    /**
     * 获取题目详情
     */
    @GetMapping("/{id}")
    public Map<String, Object> getById(@PathVariable String id) {
        QuestionEntity entity = questionService.getQuestionById(id);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", entity);
        return result;
    }

    /**
     * 随机选题
     */
    @GetMapping("/random")
    public Map<String, Object> random(@RequestParam String positionId, @RequestParam(required = false) Integer difficulty) {
        QuestionEntity entity = questionService.selectRandomQuestion(positionId, difficulty);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", entity);
        return result;
    }

    /**
     * 新增题目
     */
    @PostMapping("/create")
    public Map<String, Object> create(@RequestBody QuestionEntity entity) {
        QuestionEntity result = questionService.createQuestion(entity);
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "创建成功");
        response.put("data", result);
        return response;
    }

    /**
     * 更新题目
     */
    @PutMapping("/update")
    public Map<String, Object> update(@RequestBody QuestionEntity entity) {
        QuestionEntity result = questionService.updateQuestion(entity);
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "更新成功");
        response.put("data", result);
        return response;
    }

    /**
     * 删除题目（软删除）
     */
    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable String id) {
        questionService.deleteQuestion(id);
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "删除成功");
        return response;
    }

    /**
     * 按类型筛选题目
     */
    @GetMapping("/by-type")
    public Map<String, Object> getByType(@RequestParam String positionId, @RequestParam String questionType) {
        List<QuestionEntity> list = questionService.getQuestionsByType(positionId, questionType);
        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", list);
        return result;
    }
}