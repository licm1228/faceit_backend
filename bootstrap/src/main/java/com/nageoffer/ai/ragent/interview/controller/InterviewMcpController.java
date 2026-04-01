package com.nageoffer.ai.ragent.interview.controller;

import com.nageoffer.ai.ragent.framework.convention.Result;
import com.nageoffer.ai.ragent.framework.web.Results;
import com.nageoffer.ai.ragent.interview.service.InterviewRetrieveService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 面试MCP工具控制器
 * 用于处理面试相关的MCP请求
 */
@RestController
@RequiredArgsConstructor
public class InterviewMcpController {

    private final InterviewRetrieveService interviewRetrieveService;

    /**
     * 从题库选择题目并检索相关知识库内容
     * @param positionId 岗位ID
     * @param difficulty 难度（可选）
     * @return 题目信息和相关知识库内容
     */
    @GetMapping("/mcp/interview/select-question")
    public Result<Map<String, Object>> selectQuestion(
            @RequestParam String positionId,
            @RequestParam(required = false) Integer difficulty) {

        Map<String, Object> result = interviewRetrieveService.selectQuestionAndRetrieve(positionId, difficulty);
        return Results.success(result);
    }
}