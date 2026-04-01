package com.nageoffer.ai.ragent.interview.controller;

import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.interview.service.InterviewRetrieveService;
import com.nageoffer.ai.ragent.interview.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/interview")
@RequiredArgsConstructor
public class InterviewController {

    private final QuestionService questionService;
    private final InterviewRetrieveService interviewRetrieveService;

    /**
     * AI 面试官选题
     * @param positionId 岗位ID
     * @param difficulty 难度（可选，1-5）
     * @return 题目信息
     */
    @GetMapping("/select-question")
    public Map<String, Object> selectQuestion(
            @RequestParam String positionId,
            @RequestParam(required = false) Integer difficulty) {

        QuestionEntity question = questionService.selectRandomQuestion(positionId, difficulty);

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", question);
        return result;
    }

    /**
     * AI 面试官选题并检索相关知识库内容
     * @param positionId 岗位ID
     * @param difficulty 难度（可选，1-5）
     * @return 题目信息和相关知识库内容
     */
    @GetMapping("/select-question-with-retrieve")
    public Map<String, Object> selectQuestionWithRetrieve(
            @RequestParam String positionId,
            @RequestParam(required = false) Integer difficulty) {

        Map<String, Object> result = interviewRetrieveService.selectQuestionAndRetrieve(positionId, difficulty);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("data", result);
        return response;
    }

    /**
     * 评估学生回答（模拟）
     */
    @PostMapping("/evaluate")
    public Map<String, Object> evaluate(
            @RequestParam String questionId,
            @RequestBody String userAnswer) {

        QuestionEntity question = questionService.getQuestionById(questionId);

        // TODO: 调用 AI 评估回答质量
        // 这里先返回模拟数据
        Map<String, Object> evaluation = new HashMap<>();
        evaluation.put("score", 85);
        evaluation.put("feedback", "回答不错，技术点覆盖全面");
        evaluation.put("suggestions", "可以再深入讲解一下红黑树");

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", evaluation);
        return result;
    }
}