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

import com.nageoffer.ai.ragent.interview.entity.InterviewAnswerEntity;
import com.nageoffer.ai.ragent.interview.entity.InterviewSessionEntity;
import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.interview.service.AIEvaluationService;
import com.nageoffer.ai.ragent.interview.service.InterviewAnswerService;
import com.nageoffer.ai.ragent.interview.service.InterviewRetrieveService;
import com.nageoffer.ai.ragent.interview.service.InterviewSessionService;
import com.nageoffer.ai.ragent.interview.service.QuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.time.LocalDateTime;

@RestController
@RequestMapping("/interview")
@RequiredArgsConstructor
public class InterviewController {

    private final QuestionService questionService;
    private final InterviewRetrieveService interviewRetrieveService;
    private final InterviewSessionService interviewSessionService;
    private final InterviewAnswerService interviewAnswerService;
    private final AIEvaluationService aiEvaluationService;

    /**
     * 创建面试会话
     * @param userId 用户ID
     * @param positionId 岗位ID
     * @return 会话信息
     */
    @PostMapping("/create-session")
    public Map<String, Object> createSession(
            @RequestParam String userId,
            @RequestParam String positionId) {

        InterviewSessionEntity session = interviewSessionService.createSession(userId, positionId);

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", session);
        return result;
    }

    /**
     * 创建面试会话（带时间限制和题目数量）
     * @param userId 用户ID
     * @param positionId 岗位ID
     * @param timeLimit 时间限制（分钟）
     * @param totalQuestions 题目数量
     * @return 会话信息
     */
    @PostMapping("/create-session-with-options")
    public Map<String, Object> createSessionWithOptions(
            @RequestParam String userId,
            @RequestParam String positionId,
            @RequestParam(required = false) Integer timeLimit,
            @RequestParam(required = false) Integer totalQuestions) {

        InterviewSessionEntity session = interviewSessionService.createSession(userId, positionId, timeLimit, totalQuestions);

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", session);
        return result;
    }

    /**
     * 开始面试
     * @param sessionId 会话ID
     * @return 会话信息
     */
    @PostMapping("/start-session")
    public Map<String, Object> startSession(
            @RequestParam String sessionId) {

        InterviewSessionEntity session = interviewSessionService.startSession(sessionId);

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", session);
        return result;
    }

    /**
     * 获取面试题目
     * @param sessionId 会话ID
     * @param difficulty 难度（可选，1-5）
     * @return 题目信息
     */
    @GetMapping("/get-question")
    public Map<String, Object> getQuestion(
            @RequestParam String sessionId,
            @RequestParam(required = false) Integer difficulty) {

        InterviewSessionEntity session = interviewSessionService.getSessionById(sessionId);
        if (session == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("code", 404);
            result.put("message", "面试会话不存在");
            return result;
        }
        if ("completed".equals(session.getStatus())) {
            Map<String, Object> result = new HashMap<>();
            result.put("code", 400);
            result.put("message", "面试已结束，无法继续获取题目");
            return result;
        }
        if (session.getTotalQuestions() != null
                && session.getCurrentQuestionCount() != null
                && session.getCurrentQuestionCount() >= session.getTotalQuestions()) {
            Map<String, Object> result = new HashMap<>();
            result.put("code", 400);
            result.put("message", "已达到题量上限，请结束面试查看报告");
            return result;
        }
        if (session.getTimeLimit() != null
                && session.getStartTime() != null
                && LocalDateTime.now().isAfter(session.getStartTime().plusMinutes(session.getTimeLimit()))) {
            Map<String, Object> result = new HashMap<>();
            result.put("code", 400);
            result.put("message", "面试已超时，请结束当前会话");
            return result;
        }
        QuestionEntity question = questionService.selectRandomQuestion(session.getPositionId(), difficulty);

        // 增加题目计数
        interviewSessionService.incrementQuestionCount(sessionId);

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", question);
        return result;
    }

    /**
     * 提交回答并评估
     * @param sessionId 会话ID
     * @param questionId 题目ID
     * @param userAnswer 学生回答
     * @return 评估结果
     */
    @PostMapping("/submit-answer")
    public Map<String, Object> submitAnswer(
            @RequestParam String sessionId,
            @RequestParam String questionId,
            @RequestBody String userAnswer) {

        // 保存回答
        InterviewAnswerEntity answer = interviewAnswerService.saveAnswer(sessionId, questionId, userAnswer);

        // 获取题目信息
        QuestionEntity question = questionService.getQuestionById(questionId);

        // AI评估回答
        Map<String, Object> evaluation = aiEvaluationService.evaluateAnswer(question, userAnswer);

        // 更新评估结果
        interviewAnswerService.evaluateAnswer(answer.getId(),
                (Integer) evaluation.get("score"),
                (Integer) evaluation.get("technicalScore"),
                (Integer) evaluation.get("expressionScore"),
                (Integer) evaluation.get("logicScore"),
                (Integer) evaluation.get("knowledgeScore"),
                (String) evaluation.get("feedback"),
                (String) evaluation.get("suggestions"));

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", evaluation);
        return result;
    }

    /**
     * 生成追问
     * @param sessionId 会话ID
     * @param questionId 原题目ID
     * @param userAnswer 用户回答
     * @return 追问题目
     */
    @PostMapping("/ask-follow-up")
    public Map<String, Object> askFollowUp(
            @RequestParam String sessionId,
            @RequestParam String questionId,
            @RequestBody String userAnswer) {

        // 获取原题目
        QuestionEntity originalQuestion = questionService.getQuestionById(questionId);

        // 生成追问
        QuestionEntity followUpQuestion = aiEvaluationService.generateFollowUpQuestion(originalQuestion, userAnswer);

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", followUpQuestion);
        return result;
    }

    /**
     * 完成面试并生成报告
     * @param sessionId 会话ID
     * @return 评估报告
     */
    @PostMapping("/complete-session")
    public Map<String, Object> completeSession(
            @RequestParam String sessionId) {

        // 获取所有回答
        List<InterviewAnswerEntity> answers = interviewAnswerService.getAnswersBySessionId(sessionId);

        // 计算平均分，报告页和成长曲线按 0-100 分展示。
        int totalScore = 0;
        List<Map<String, Object>> answerEvaluations = new ArrayList<>();
        for (InterviewAnswerEntity answer : answers) {
            totalScore += answer.getScore() == null ? 0 : answer.getScore();
            Map<String, Object> eval = new HashMap<>();
            eval.put("score", answer.getScore());
            eval.put("technicalScore", answer.getTechnicalScore());
            eval.put("expressionScore", answer.getExpressionScore());
            eval.put("logicScore", answer.getLogicScore());
            eval.put("knowledgeScore", answer.getKnowledgeScore());
            eval.put("feedback", answer.getFeedback());
            eval.put("suggestions", answer.getSuggestions());
            answerEvaluations.add(eval);
        }
        int averageScore = answers.isEmpty() ? 0 : Math.round((float) totalScore / answers.size());

        // 生成评估报告
        String evaluationReport = aiEvaluationService.generateEvaluationReport(
                sessionId,
                answerEvaluations.toArray(new Map[0])
        );

        // 完成会话
        InterviewSessionEntity session = interviewSessionService.completeSession(
                sessionId,
                averageScore,
                evaluationReport
        );

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", session);
        return result;
    }

    /**
     * 获取用户面试历史
     * @param userId 用户ID
     * @return 面试历史列表
     */
    @GetMapping("/history")
    public Map<String, Object> getInterviewHistory(
            @RequestParam String userId) {

        List<InterviewSessionEntity> sessions = interviewSessionService.getSessionsByUserId(userId);

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        result.put("data", sessions);
        return result;
    }

    /**
     * 获取面试详情和评估报告
     * @param sessionId 会话ID
     * @return 面试详情
     */
    @GetMapping("/session-detail")
    public Map<String, Object> getSessionDetail(
            @RequestParam String sessionId) {

        InterviewSessionEntity session = interviewSessionService.getSessionById(sessionId);
        List<InterviewAnswerEntity> answers = interviewAnswerService.getAnswersBySessionId(sessionId);
        List<Map<String, Object>> answerDetails = new ArrayList<>();
        for (InterviewAnswerEntity answer : answers) {
            QuestionEntity question = questionService.getQuestionById(answer.getQuestionId());
            Map<String, Object> answerDetail = new HashMap<>();
            answerDetail.put("id", answer.getId());
            answerDetail.put("sessionId", answer.getSessionId());
            answerDetail.put("questionId", answer.getQuestionId());
            answerDetail.put("questionText", question == null ? null : question.getQuestionText());
            answerDetail.put("userAnswer", answer.getUserAnswer());
            answerDetail.put("score", answer.getScore());
            answerDetail.put("technicalScore", answer.getTechnicalScore());
            answerDetail.put("expressionScore", answer.getExpressionScore());
            answerDetail.put("logicScore", answer.getLogicScore());
            answerDetail.put("knowledgeScore", answer.getKnowledgeScore());
            answerDetail.put("feedback", answer.getFeedback());
            answerDetail.put("suggestions", answer.getSuggestions());
            answerDetails.add(answerDetail);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("code", 200);
        Map<String, Object> data = new HashMap<>();
        data.put("session", session);
        data.put("answers", answerDetails);
        result.put("data", data);
        return result;
    }

    /**
     * AI 面试官选题（保留原有接口）
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
     * AI 面试官选题并检索相关知识库内容（保留原有接口）
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
}
