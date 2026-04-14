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

package com.nageoffer.ai.ragent.interview.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nageoffer.ai.ragent.framework.context.UserContext;
import com.nageoffer.ai.ragent.framework.exception.ClientException;
import com.nageoffer.ai.ragent.framework.web.SseEmitterSender;
import com.nageoffer.ai.ragent.interview.controller.request.SpeechAnalysisRequest;
import com.nageoffer.ai.ragent.interview.controller.request.InterviewChatStartRequest;
import com.nageoffer.ai.ragent.interview.entity.InterviewAnswerEntity;
import com.nageoffer.ai.ragent.interview.entity.InterviewSessionEntity;
import com.nageoffer.ai.ragent.interview.entity.PositionEntity;
import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.interview.mapper.PositionMapper;
import com.nageoffer.ai.ragent.infra.config.AIModelProperties;
import com.nageoffer.ai.ragent.rag.dao.entity.ConversationDO;
import com.nageoffer.ai.ragent.rag.dao.mapper.ConversationMapper;
import com.nageoffer.ai.ragent.rag.dao.mapper.ConversationMessageMapper;
import com.nageoffer.ai.ragent.rag.dao.mapper.ConversationSummaryMapper;
import com.nageoffer.ai.ragent.rag.dto.CompletionPayload;
import com.nageoffer.ai.ragent.rag.dto.MessageDelta;
import com.nageoffer.ai.ragent.rag.enums.SSEEventType;
import com.nageoffer.ai.ragent.rag.service.ConversationMessageService;
import com.nageoffer.ai.ragent.rag.service.bo.ConversationMessageBO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.time.LocalDateTime;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class InterviewChatService {

    private static final List<String> QUIZ_STYLE_PHRASES = List.of(
            "请完整列举",
            "请分别说明",
            "请详细说明以下",
            "请从以下几个方面",
            "请依次回答",
            "请全面分析"
    );
    private static final List<String> LOW_SIGNAL_PHRASES = List.of(
            "不知道",
            "不会",
            "不太清楚",
            "不清楚",
            "不了解",
            "没了解过",
            "答不上来"
    );
    private static final int DEFAULT_DIFFICULTY = 3;
    private static final int DEFAULT_TIME_LIMIT_MINUTES = 20;
    private static final int DEFAULT_QUESTION_LIMIT = 5;
    private static final int MAX_FOLLOW_UPS = 3;
    private static final Pattern QUESTION_LIMIT_PATTERN = Pattern.compile("(\\d{1,2})\\s*(题|道)");
    private static final Pattern TIME_LIMIT_PATTERN = Pattern.compile("(\\d{1,3})\\s*(分钟|min|mins)");

    private final InterviewSessionService interviewSessionService;
    private final InterviewAnswerService interviewAnswerService;
    private final QuestionService questionService;
    private final PositionProfileService positionProfileService;
    private final PositionMapper positionMapper;
    private final AIEvaluationService aiEvaluationService;
    private final ConversationMapper conversationMapper;
    private final ConversationMessageMapper conversationMessageMapper;
    private final ConversationSummaryMapper conversationSummaryMapper;
    private final ConversationMessageService conversationMessageService;
    private final ObjectMapper objectMapper;
    private final AIModelProperties aiModelProperties;
    private final TransactionTemplate transactionTemplate;
    @Qualifier("memorySummaryThreadPoolExecutor")
    private final Executor reportExecutor;
    @Qualifier("modelStreamExecutor")
    private final Executor modelStreamExecutor;

    public Map<String, Object> resolveConfig(String content) {
        String normalized = StrUtil.blankToDefault(content, "").trim().toLowerCase(Locale.ROOT);
        Map<String, Object> result = new LinkedHashMap<>();
        PositionEntity position = resolvePosition(normalized);
        boolean matched = normalized.contains("面试")
                || normalized.contains("interview")
                || normalized.contains("mock")
                || normalized.contains("模拟")
                || normalized.contains("岗位");
        result.put("matched", matched && position != null);
        result.put("positionId", position == null ? null : position.getId());
        result.put("positionName", position == null ? null : position.getName());
        result.put("difficulty", resolveDifficulty(normalized));
        result.put("timeLimitMinutes", resolveTimeLimit(normalized));
        result.put("questionLimit", resolveQuestionLimit(normalized));
        return result;
    }

    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> startInterview(InterviewChatStartRequest request) {
        String userId = requireUserId();
        if (StrUtil.isBlank(request.getPositionId())) {
            throw new ClientException("请选择岗位");
        }
        PositionEntity position = requirePosition(request.getPositionId());
        Integer difficulty = normalizeDifficulty(request.getDifficulty());
        Integer timeLimitMinutes = normalizeTimeLimit(request.getTimeLimitMinutes());
        Integer questionLimit = normalizeQuestionLimit(request.getQuestionLimit());

        InterviewSessionEntity session = interviewSessionService.createSession(userId, position.getId(), timeLimitMinutes, questionLimit);
        session = interviewSessionService.startSession(session.getId());

        List<String> questionTypePlan = positionProfileService.resolveQuestionTypePlan(position.getId(), position.getName());
        QuestionEntity question = questionService.selectRandomQuestionExcluding(
                position.getId(),
                difficulty,
                resolvePreferredQuestionTypes(questionTypePlan, 1),
                List.of()
        );
        if (question == null) {
            throw new ClientException("当前岗位暂无可用题目");
        }

        interviewSessionService.incrementQuestionCount(session.getId());
        RuntimeState runtimeState = new RuntimeState();
        runtimeState.setPositionId(position.getId());
        runtimeState.setPositionName(position.getName());
        runtimeState.setDifficulty(difficulty);
        runtimeState.setQuestionLimit(questionLimit);
        runtimeState.setTimeLimitMinutes(timeLimitMinutes);
        runtimeState.setCurrentMainQuestionId(question.getId());
        runtimeState.setCurrentQuestionId(question.getId());
        runtimeState.setCurrentQuestionText(question.getQuestionText());
        runtimeState.setQuestionIndex(1);
        runtimeState.setFollowUpCount(0);
        runtimeState.setAskedQuestionIds(new ArrayList<>(List.of(question.getId())));
        interviewSessionService.updateEvaluationReport(session.getId(), toRuntimePayload(runtimeState));

        ensureConversation(session.getId(), userId, "面试 · " + position.getName());
        addAssistantMessage(session.getId(), userId, buildOpeningMessage(position.getName(), difficulty, timeLimitMinutes, questionLimit));
        addAssistantMessage(session.getId(), userId, buildQuestionMessage(runtimeState.getQuestionIndex(), question.getQuestionText()));

        InterviewSessionEntity latest = interviewSessionService.getSessionById(session.getId());
        return buildStartResponse(latest, runtimeState);
    }

    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> submitTurn(String sessionId, String content, SpeechAnalysisRequest speechAnalysis) {
        String userId = requireUserId();
        if (StrUtil.isBlank(content)) {
            throw new ClientException("请输入回答内容");
        }
        InterviewSessionEntity session = requireOwnedSession(sessionId, userId);
        if ("completed".equalsIgnoreCase(session.getStatus())) {
            throw new ClientException("本场面试已结束");
        }
        RuntimeState runtimeState = readRuntimeState(session);
        ensureRuntimeStateDefaults(runtimeState);
        if (StrUtil.isBlank(runtimeState.getCurrentQuestionId())) {
            throw new ClientException("当前面试缺少题目状态，请重新开始");
        }

        addUserMessage(sessionId, userId, content.trim());
        QuestionEntity question = questionService.getQuestionById(runtimeState.getCurrentQuestionId());
        if (question == null) {
            throw new ClientException("当前题目不存在");
        }

        InterviewAnswerEntity answer = interviewAnswerService.saveOrUpdateAnswer(sessionId, question.getId(), content.trim());
        Map<String, Object> evaluation = aiEvaluationService.evaluateAnswer(
                question,
                content.trim(),
                speechAnalysis,
                runtimeState.getFollowUpCount(),
                runtimeState.getLastFollowUpIntent(),
                runtimeState.getLastFollowUpFocus(),
                runtimeState.getFollowUpHistory()
        );
        interviewAnswerService.evaluateAnswer(
                answer.getId(),
                (Integer) evaluation.get("score"),
                (Integer) evaluation.get("technicalScore"),
                (Integer) evaluation.get("expressionScore"),
                (Integer) evaluation.get("logicScore"),
                (Integer) evaluation.get("knowledgeScore"),
                (String) evaluation.get("feedback"),
                (String) evaluation.get("suggestions")
        );
        addAssistantMessage(sessionId, userId, buildInstantFeedbackMessage(evaluation));

        String answerSignal = normalizeAnswerSignal(Objects.toString(evaluation.get("answerSignal"), ""));
        String feedbackMode = normalizeFeedbackMode(Objects.toString(evaluation.get("feedbackMode"), ""));
        boolean lowSignalAnswer = isLowSignalAnswer(content, answerSignal);
        boolean timeoutReached = isTimeoutReached(session);
        boolean shouldAskFollowUp = !timeoutReached
                && runtimeState.getFollowUpCount() < MAX_FOLLOW_UPS
                && shouldAskFollowUp(evaluation, runtimeState, lowSignalAnswer, feedbackMode);
        if (shouldAskFollowUp) {
            String followUpIntent = normalizeIntent((String) evaluation.get("followUpIntent"));
            String followUpFocus = normalizeFocus((String) evaluation.get("followUpFocus"));
            String followUpQuestionText = normalizeFollowUpQuestion((String) evaluation.get("followUpQuestion"));
            if (lowSignalAnswer && StrUtil.isBlank(followUpIntent)) {
                followUpIntent = "clarify_definition";
            }
            if (lowSignalAnswer && StrUtil.isBlank(followUpFocus)) {
                followUpFocus = "当前题目的最小关键概念";
            }
            if (StrUtil.isBlank(followUpQuestionText)) {
                QuestionEntity followUpQuestion = aiEvaluationService.generateFollowUpQuestion(
                        question,
                        content.trim(),
                        runtimeState.getFollowUpCount(),
                        followUpIntent,
                        followUpFocus,
                        runtimeState.getFollowUpHistory()
                );
                followUpQuestionText = followUpQuestion == null ? "" : normalizeFollowUpQuestion(followUpQuestion.getQuestionText());
            }
            if (shouldRewriteFollowUp(runtimeState, followUpIntent, followUpFocus, followUpQuestionText)) {
                String rewrittenFollowUp = aiEvaluationService.rewriteFollowUpQuestion(
                        question,
                        content.trim(),
                        followUpQuestionText,
                        runtimeState.getFollowUpCount(),
                        followUpIntent,
                        followUpFocus,
                        runtimeState.getFollowUpHistory()
                );
                followUpQuestionText = normalizeFollowUpQuestion(rewrittenFollowUp);
            }
            if (shouldUseFollowUp(runtimeState, followUpIntent, followUpFocus, followUpQuestionText)) {
                runtimeState.setFollowUpCount(runtimeState.getFollowUpCount() + 1);
                runtimeState.setLastFollowUpIntent(followUpIntent);
                runtimeState.setLastFollowUpFocus(followUpFocus);
                runtimeState.getFollowUpHistory().add(buildFollowUpHistoryEntry(followUpIntent, followUpFocus, followUpQuestionText));
                interviewSessionService.updateEvaluationReport(sessionId, toRuntimePayload(runtimeState));
                addAssistantMessage(sessionId, userId, followUpQuestionText);
                return buildTurnResponse(interviewSessionService.getSessionById(sessionId), runtimeState);
            }
        }

        Integer currentQuestionCount = session.getCurrentQuestionCount() == null ? 0 : session.getCurrentQuestionCount();
        Integer totalQuestions = session.getTotalQuestions() == null ? DEFAULT_QUESTION_LIMIT : session.getTotalQuestions();
        boolean limitReached = currentQuestionCount >= totalQuestions;
        runtimeState.setDifficulty(adjustDifficulty(runtimeState.getDifficulty(), evaluation));

        if (timeoutReached || limitReached) {
            interviewSessionService.updateEvaluationReport(sessionId, toRuntimePayload(runtimeState));
            completeInterview(session, runtimeState, userId);
            return buildTurnResponse(interviewSessionService.getSessionById(sessionId), runtimeState);
        }

        QuestionEntity nextQuestion = questionService.selectRandomQuestionExcluding(
                session.getPositionId(),
                runtimeState.getDifficulty(),
                resolvePreferredQuestionTypes(
                        positionProfileService.resolveQuestionTypePlan(runtimeState.getPositionId(), runtimeState.getPositionName()),
                        runtimeState.getQuestionIndex() + 1
                ),
                runtimeState.getAskedQuestionIds()
        );
        if (nextQuestion == null) {
            completeInterview(session, runtimeState, userId);
            return buildTurnResponse(interviewSessionService.getSessionById(sessionId), runtimeState);
        }

        interviewSessionService.incrementQuestionCount(sessionId);
        runtimeState.getAskedQuestionIds().add(nextQuestion.getId());
        runtimeState.setCurrentMainQuestionId(nextQuestion.getId());
        runtimeState.setCurrentQuestionId(nextQuestion.getId());
        runtimeState.setCurrentQuestionText(nextQuestion.getQuestionText());
        runtimeState.setQuestionIndex(runtimeState.getQuestionIndex() + 1);
        runtimeState.setFollowUpCount(0);
        runtimeState.setLastFollowUpIntent("");
        runtimeState.setLastFollowUpFocus("");
        runtimeState.setFollowUpHistory(new ArrayList<>());
        interviewSessionService.updateEvaluationReport(sessionId, toRuntimePayload(runtimeState));

        addAssistantMessage(sessionId, userId, buildNextQuestionTransition(runtimeState));
        addAssistantMessage(sessionId, userId, buildQuestionMessage(runtimeState.getQuestionIndex(), nextQuestion.getQuestionText()));
        return buildTurnResponse(interviewSessionService.getSessionById(sessionId), runtimeState);
    }

    public void streamTurn(String sessionId, String content, SpeechAnalysisRequest speechAnalysis, SseEmitter emitter) {
        CompletableFuture.runAsync(() -> doStreamTurn(sessionId, content, speechAnalysis, emitter), modelStreamExecutor);
    }

    private void doStreamTurn(String sessionId, String content, SpeechAnalysisRequest speechAnalysis, SseEmitter emitter) {
        SseEmitterSender sender = new SseEmitterSender(emitter);
        try {
            String userId = requireUserId();
            List<Map<String, Object>> beforeMessages = buildMessages(sessionId, userId);
            Map<String, Object> response = transactionTemplate.execute(status -> submitTurn(sessionId, content, speechAnalysis));
            List<String> assistantMessages = extractNewAssistantMessages(beforeMessages, response);

            if (isGptEnabled()) {
                streamAssistantMessages(sender, assistantMessages);
            } else {
                sendAssistantMessagesOnce(sender, assistantMessages);
            }

            sender.sendEvent(SSEEventType.FINISH.value(), new CompletionPayload(null, null));
            sender.sendEvent(SSEEventType.DONE.value(), "[DONE]");
            sender.complete();
        } catch (Exception ex) {
            sender.fail(ex);
        }
    }

    public Map<String, Object> getSessionState(String sessionId) {
        String userId = requireUserId();
        InterviewSessionEntity session = requireOwnedSession(sessionId, userId);
        RuntimeState runtimeState = readRuntimeState(session);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("session", buildSessionMap(session, runtimeState));
        result.put("reportAvailable", isReportReady(session));
        result.put("runtime", buildRuntimeMap(runtimeState));
        return result;
    }

    public Map<String, Object> getReport(String sessionId) {
        String userId = requireUserId();
        InterviewSessionEntity session = requireOwnedSession(sessionId, userId);
        if (!"completed".equalsIgnoreCase(session.getStatus())) {
            throw new ClientException("面试尚未结束，暂无报告");
        }
        if (isReportPending(session)) {
            return Map.of(
                    "reportStatus", "pending",
                    "overallScore", Optional.ofNullable(session.getTotalScore()).orElse(0)
            );
        }
        return readReportPayload(session);
    }

    @Transactional(rollbackFor = Exception.class)
    public void renameSession(String sessionId, String title) {
        String userId = requireUserId();
        requireOwnedSession(sessionId, userId);
        ConversationDO conversation = conversationMapper.selectOne(
                Wrappers.lambdaQuery(ConversationDO.class)
                        .eq(ConversationDO::getConversationId, sessionId)
                        .eq(ConversationDO::getUserId, userId)
                        .eq(ConversationDO::getDeleted, 0)
        );
        if (conversation == null) {
            throw new ClientException("面试会话不存在");
        }
        conversation.setTitle(StrUtil.blankToDefault(title, conversation.getTitle()).trim());
        conversationMapper.updateById(conversation);
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteSession(String sessionId) {
        String userId = requireUserId();
        requireOwnedSession(sessionId, userId);
        interviewSessionService.deleteSession(sessionId);
        interviewAnswerService.deleteAnswersBySessionId(sessionId);
        conversationMessageMapper.delete(
                Wrappers.lambdaQuery(com.nageoffer.ai.ragent.rag.dao.entity.ConversationMessageDO.class)
                        .eq(com.nageoffer.ai.ragent.rag.dao.entity.ConversationMessageDO::getConversationId, sessionId)
                        .eq(com.nageoffer.ai.ragent.rag.dao.entity.ConversationMessageDO::getUserId, userId)
                        .eq(com.nageoffer.ai.ragent.rag.dao.entity.ConversationMessageDO::getDeleted, 0)
        );
        conversationSummaryMapper.delete(
                Wrappers.lambdaQuery(com.nageoffer.ai.ragent.rag.dao.entity.ConversationSummaryDO.class)
                        .eq(com.nageoffer.ai.ragent.rag.dao.entity.ConversationSummaryDO::getConversationId, sessionId)
                        .eq(com.nageoffer.ai.ragent.rag.dao.entity.ConversationSummaryDO::getUserId, userId)
                        .eq(com.nageoffer.ai.ragent.rag.dao.entity.ConversationSummaryDO::getDeleted, 0)
        );
        ConversationDO conversation = conversationMapper.selectOne(
                Wrappers.lambdaQuery(ConversationDO.class)
                        .eq(ConversationDO::getConversationId, sessionId)
                        .eq(ConversationDO::getUserId, userId)
                        .eq(ConversationDO::getDeleted, 0)
        );
        if (conversation != null) {
            conversationMapper.deleteById(conversation.getId());
        }
    }

    private void completeInterview(InterviewSessionEntity session, RuntimeState runtimeState, String userId) {
        List<InterviewAnswerEntity> answers = interviewAnswerService.getAnswersBySessionId(session.getId());
        Map<String, Object> baseReport = buildBaseReport(session, runtimeState, answers);
        int overallScore = ((Number) baseReport.getOrDefault("overallScore", 0)).intValue();
        interviewSessionService.completeSession(session.getId(), overallScore, toPendingReportPayload(baseReport));
        addAssistantMessage(session.getId(), userId, buildCompletionMessage(session.getId(), overallScore));
        generateReportAsync(session.getId(), session.getUserId(), runtimeState, answers, baseReport);
    }

    private Map<String, Object> buildStartResponse(InterviewSessionEntity session, RuntimeState runtimeState) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("session", buildSessionMap(session, runtimeState));
        result.put("messages", buildMessages(session.getId(), requireUserId()));
        result.put("runtime", buildRuntimeMap(runtimeState));
        return result;
    }

    private Map<String, Object> buildTurnResponse(InterviewSessionEntity session, RuntimeState runtimeState) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("session", buildSessionMap(session, runtimeState));
        result.put("messages", buildMessages(session.getId(), requireUserId()));
        result.put("reportAvailable", isReportReady(session));
        result.put("runtime", buildRuntimeMap(runtimeState));
        if (isReportReady(session)) {
            result.put("report", readReportPayload(session));
        }
        return result;
    }

    private List<String> extractNewAssistantMessages(List<Map<String, Object>> beforeMessages, Map<String, Object> response) {
        Set<String> existingIds = beforeMessages.stream()
                .map(item -> Objects.toString(item.get("id"), ""))
                .collect(Collectors.toSet());
        Object messagesObj = response == null ? null : response.get("messages");
        if (!(messagesObj instanceof List<?> messages)) {
            return List.of();
        }
        return messages.stream()
                .filter(Map.class::isInstance)
                .map(Map.class::cast)
                .filter(item -> "assistant".equals(Objects.toString(item.get("role"), "")))
                .filter(item -> !existingIds.contains(Objects.toString(item.get("id"), "")))
                .map(item -> Objects.toString(item.get("content"), ""))
                .filter(StrUtil::isNotBlank)
                .collect(Collectors.toList());
    }

    private void sendAssistantMessagesOnce(SseEmitterSender sender, List<String> assistantMessages) {
        if (assistantMessages == null || assistantMessages.isEmpty()) {
            return;
        }
        sender.sendEvent(
                SSEEventType.MESSAGE.value(),
                new MessageDelta("response", String.join("\n\n", assistantMessages))
        );
    }

    private void streamAssistantMessages(SseEmitterSender sender, List<String> assistantMessages) {
        if (assistantMessages == null || assistantMessages.isEmpty()) {
            return;
        }
        int chunkSize = Math.max(1, Optional.ofNullable(aiModelProperties.getStream())
                .map(AIModelProperties.Stream::getMessageChunkSize)
                .orElse(5));
        String content = String.join("\n\n", assistantMessages);
        int idx = 0;
        int count = 0;
        StringBuilder buffer = new StringBuilder();
        while (idx < content.length()) {
            int codePoint = content.codePointAt(idx);
            buffer.appendCodePoint(codePoint);
            idx += Character.charCount(codePoint);
            count++;
            if (count >= chunkSize) {
                sender.sendEvent(SSEEventType.MESSAGE.value(), new MessageDelta("response", buffer.toString()));
                buffer.setLength(0);
                count = 0;
            }
        }
        if (!buffer.isEmpty()) {
            sender.sendEvent(SSEEventType.MESSAGE.value(), new MessageDelta("response", buffer.toString()));
        }
    }

    private boolean isGptEnabled() {
        return Optional.ofNullable(aiModelProperties.getFeatures())
                .map(AIModelProperties.Features::getUseGpt)
                .orElse(false);
    }

    private List<Map<String, Object>> buildMessages(String conversationId, String userId) {
        return conversationMessageService.listMessages(conversationId, userId, null, null).stream().map(item -> {
            Map<String, Object> message = new LinkedHashMap<>();
            message.put("id", String.valueOf(item.getId()));
            message.put("conversationId", item.getConversationId());
            message.put("role", item.getRole());
            message.put("content", item.getContent());
            message.put("vote", item.getVote());
            message.put("createTime", item.getCreateTime());
            return message;
        }).collect(Collectors.toList());
    }

    private Map<String, Object> buildSessionMap(InterviewSessionEntity session, RuntimeState runtimeState) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", session.getId());
        data.put("status", session.getStatus());
        data.put("positionId", session.getPositionId());
        data.put("positionName", runtimeState.getPositionName());
        data.put("difficulty", runtimeState.getDifficulty());
        data.put("timeLimitMinutes", runtimeState.getTimeLimitMinutes());
        data.put("questionLimit", runtimeState.getQuestionLimit());
        data.put("currentQuestionCount", session.getCurrentQuestionCount());
        data.put("totalScore", session.getTotalScore());
        data.put("startTime", session.getStartTime());
        data.put("endTime", session.getEndTime());
        return data;
    }

    private Map<String, Object> buildRuntimeMap(RuntimeState runtimeState) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("positionId", runtimeState.getPositionId());
        data.put("positionName", runtimeState.getPositionName());
        data.put("difficulty", runtimeState.getDifficulty());
        data.put("timeLimitMinutes", runtimeState.getTimeLimitMinutes());
        data.put("questionLimit", runtimeState.getQuestionLimit());
        data.put("currentQuestionId", runtimeState.getCurrentQuestionId());
        data.put("currentQuestionText", runtimeState.getCurrentQuestionText());
        data.put("questionIndex", runtimeState.getQuestionIndex());
        data.put("followUpCount", runtimeState.getFollowUpCount());
        data.put("askedQuestionIds", runtimeState.getAskedQuestionIds());
        return data;
    }

    private List<String> resolvePreferredQuestionTypes(List<String> questionTypePlan, int questionIndex) {
        if (questionTypePlan == null || questionTypePlan.isEmpty() || questionIndex <= 0) {
            return List.of();
        }
        int index = Math.floorMod(questionIndex - 1, questionTypePlan.size());
        String preferredType = questionTypePlan.get(index);
        if (StrUtil.isBlank(preferredType)) {
            return List.of();
        }
        return List.of(preferredType);
    }

    private Map<String, Object> buildBaseReport(InterviewSessionEntity session, RuntimeState runtimeState, List<InterviewAnswerEntity> answers) {
        List<InterviewAnswerEntity> validAnswers = answers == null ? List.of() : answers;
        int overallScore = average(validAnswers.stream().map(InterviewAnswerEntity::getScore).toList());
        int technicalScore = average(validAnswers.stream().map(InterviewAnswerEntity::getTechnicalScore).toList());
        int knowledgeScore = average(validAnswers.stream().map(InterviewAnswerEntity::getKnowledgeScore).toList());
        int logicScore = average(validAnswers.stream().map(InterviewAnswerEntity::getLogicScore).toList());
        int expressionScore = average(validAnswers.stream().map(InterviewAnswerEntity::getExpressionScore).toList());
        int positionMatchScore = Math.max(0, Math.min(100, overallScore - technicalScore - logicScore - knowledgeScore));

        List<Map<String, Object>> recommendedPractices = buildRecommendedPractices(session, runtimeState, validAnswers);

        List<String> highlights = validAnswers.stream()
                .sorted(Comparator.comparing(answer -> Optional.ofNullable(answer.getScore()).orElse(0), Comparator.reverseOrder()))
                .filter(answer -> Optional.ofNullable(answer.getScore()).orElse(0) >= 70)
                .limit(3)
                .map(answer -> summarize("亮点", answer.getFeedback(), "回答展现出较好的知识掌握与表达"))
                .collect(Collectors.toList());
        if (highlights.isEmpty()) {
            highlights = List.of("整体作答较为完整，已经具备继续打磨表达和深度的基础。");
        }

        List<String> weaknesses = validAnswers.stream()
                .sorted(Comparator.comparing(answer -> Optional.ofNullable(answer.getScore()).orElse(0)))
                .limit(3)
                .map(answer -> summarize("不足", answer.getFeedback(), "部分回答仍缺少关键细节与论证支撑"))
                .collect(Collectors.toList());
        if (weaknesses.isEmpty()) {
            weaknesses = List.of("当前缺少足够答题记录，建议继续完成更多模拟面试。");
        }

        List<String> improvementSuggestions = validAnswers.stream()
                .sorted(Comparator.comparing(answer -> Optional.ofNullable(answer.getScore()).orElse(0)))
                .limit(3)
                .map(answer -> summarize("建议", answer.getSuggestions(), "建议围绕核心概念、实现细节和业务取舍继续练习"))
                .collect(Collectors.toList());
        if (improvementSuggestions.isEmpty()) {
            improvementSuggestions = List.of("继续按照岗位核心能力维度进行专项训练。");
        }

        Map<String, Object> report = new LinkedHashMap<>();
        report.put("reportStatus", "pending");
        report.put("overallScore", overallScore);
        report.put("positionName", runtimeState.getPositionName());
        report.put("questionLimit", runtimeState.getQuestionLimit());
        report.put("timeLimitMinutes", runtimeState.getTimeLimitMinutes());
        report.put("summary", buildFallbackSummary(overallScore));
        report.put("dimensionScores", Map.of(
                "technicalCorrectness", technicalScore,
                "knowledgeDepth", knowledgeScore,
                "logicRigor", logicScore,
                "positionMatch", positionMatchScore,
                "expressionDelivery", expressionScore
        ));
        report.put("expressionSummary", buildExpressionSummary(expressionScore));
        report.put("highlights", highlights);
        report.put("weaknesses", weaknesses);
        report.put("improvementSuggestions", improvementSuggestions);
        report.put("recommendedPractices", recommendedPractices);
        return report;
    }

    private void generateReportAsync(
            String sessionId,
            String userId,
            RuntimeState runtimeState,
            List<InterviewAnswerEntity> answers,
            Map<String, Object> baseReport
    ) {
        CompletableFuture.runAsync(() -> {
            try {
                InterviewSessionEntity latestSession = interviewSessionService.getSessionById(sessionId);
                if (latestSession == null || Integer.valueOf(1).equals(latestSession.getDeleted())) {
                    return;
                }
                Map<String, Object> report = buildFinalReport(runtimeState, answers, baseReport);
                interviewSessionService.updateEvaluationReport(sessionId, toReportPayload(report));
            } catch (Exception ex) {
                log.warn("生成面试报告失败, sessionId={}, userId={}", sessionId, userId, ex);
                Map<String, Object> fallbackReport = new LinkedHashMap<>(baseReport);
                fallbackReport.put("reportStatus", "ready");
                interviewSessionService.updateEvaluationReport(sessionId, toReportPayload(fallbackReport));
            }
        }, reportExecutor);
    }

    private Map<String, Object> buildFinalReport(
            RuntimeState runtimeState,
            List<InterviewAnswerEntity> answers,
            Map<String, Object> baseReport
    ) {
        List<InterviewAnswerEntity> validAnswers = answers == null ? List.of() : answers;
        Map<String, Object> llmReport = aiEvaluationService.generateStructuredEvaluationReport(
                runtimeState.getPositionName(),
                runtimeState.getQuestionLimit(),
                runtimeState.getTimeLimitMinutes(),
                validAnswers.stream().map(answer -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("score", answer.getScore());
                    item.put("technicalScore", answer.getTechnicalScore());
                    int positionMatchScore = Math.max(0, Optional.ofNullable(answer.getScore()).orElse(0)
                            - Optional.ofNullable(answer.getTechnicalScore()).orElse(0)
                            - Optional.ofNullable(answer.getLogicScore()).orElse(0)
                            - Optional.ofNullable(answer.getKnowledgeScore()).orElse(0));
                    item.put("positionMatchScore", positionMatchScore);
                    item.put("expressionScore", answer.getExpressionScore());
                    item.put("logicScore", answer.getLogicScore());
                    item.put("knowledgeScore", answer.getKnowledgeScore());
                    item.put("expressionFeedback", buildExpressionSummary(Optional.ofNullable(answer.getExpressionScore()).orElse(0)));
                    item.put("feedback", answer.getFeedback());
                    item.put("suggestions", answer.getSuggestions());
                    return item;
                }).toArray(Map[]::new)
        );

        Map<String, Object> dimensionScores = readDimensionScores(llmReport.get("dimensionScores"));
        Map<String, Object> baseDimensionScores = readDimensionScores(baseReport.get("dimensionScores"));
        Map<String, Object> report = new LinkedHashMap<>(baseReport);
        report.put("reportStatus", "ready");
        report.put("overallScore", numberOrDefault(llmReport.get("overallScore"), numberOrDefault(baseReport.get("overallScore"), 0)));
        report.put("summary", stringOrDefault(llmReport.get("summary"), stringOrDefault(baseReport.get("summary"), buildFallbackSummary(numberOrDefault(baseReport.get("overallScore"), 0)))));
        report.put("dimensionScores", Map.of(
                "technicalCorrectness", numberOrDefault(dimensionScores.get("technicalCorrectness"), numberOrDefault(baseDimensionScores.get("technicalCorrectness"), 0)),
                "knowledgeDepth", numberOrDefault(dimensionScores.get("knowledgeDepth"), numberOrDefault(baseDimensionScores.get("knowledgeDepth"), 0)),
                "logicRigor", numberOrDefault(dimensionScores.get("logicRigor"), numberOrDefault(baseDimensionScores.get("logicRigor"), 0)),
                "positionMatch", numberOrDefault(dimensionScores.get("positionMatch"), numberOrDefault(baseDimensionScores.get("positionMatch"), 0)),
                "expressionDelivery", numberOrDefault(dimensionScores.get("expressionDelivery"), numberOrDefault(baseDimensionScores.get("expressionDelivery"), 0))
        ));
        report.put("expressionSummary", stringOrDefault(llmReport.get("expressionSummary"), stringOrDefault(baseReport.get("expressionSummary"), buildExpressionSummary(numberOrDefault(baseDimensionScores.get("expressionDelivery"), 0)))));
        report.put("highlights", listOrDefault(llmReport.get("highlights"), listOrDefault(baseReport.get("highlights"), List.of())));
        report.put("weaknesses", listOrDefault(llmReport.get("weaknesses"), listOrDefault(baseReport.get("weaknesses"), List.of())));
        report.put("improvementSuggestions", listOrDefault(llmReport.get("improvementSuggestions"), listOrDefault(baseReport.get("improvementSuggestions"), List.of())));
        return report;
    }

    private RuntimeState readRuntimeState(InterviewSessionEntity session) {
        if (session == null || StrUtil.isBlank(session.getEvaluationReport())) {
            return new RuntimeState();
        }
        try {
            Map<String, Object> payload = objectMapper.readValue(session.getEvaluationReport(), new TypeReference<>() {});
            if (!"runtime".equals(payload.get("kind"))) {
                return new RuntimeState();
            }
            RuntimeState runtimeState = objectMapper.convertValue(payload.get("data"), RuntimeState.class);
            ensureRuntimeStateDefaults(runtimeState);
            return runtimeState;
        } catch (Exception ex) {
            log.warn("解析面试运行态失败, sessionId={}", session.getId(), ex);
            return new RuntimeState();
        }
    }

    private Map<String, Object> readReportPayload(InterviewSessionEntity session) {
        if (session == null || StrUtil.isBlank(session.getEvaluationReport())) {
            return Map.of();
        }
        try {
            Map<String, Object> payload = objectMapper.readValue(session.getEvaluationReport(), new TypeReference<>() {});
            if ("report".equals(payload.get("kind"))) {
                return objectMapper.convertValue(payload.get("data"), new TypeReference<>() {});
            }
            if ("report_pending".equals(payload.get("kind"))) {
                Map<String, Object> data = objectMapper.convertValue(payload.get("data"), new TypeReference<>() {});
                Map<String, Object> mutable = new LinkedHashMap<>(data);
                mutable.put("reportStatus", "pending");
                return mutable;
            }
        } catch (Exception ex) {
            log.warn("解析面试报告失败, sessionId={}", session.getId(), ex);
        }
        return Map.of(
                "reportStatus", "ready",
                "overallScore", Optional.ofNullable(session.getTotalScore()).orElse(0),
                "summary", "历史报告格式为旧版文本，建议重新完成一场聊天式面试以获得更完整的结构化总结。",
                "dimensionScores", Map.of(
                        "technicalCorrectness", 0,
                        "knowledgeDepth", 0,
                        "logicRigor", 0,
                        "positionMatch", 0,
                        "expressionDelivery", 0
                ),
                "expressionSummary", "历史报告格式不包含表达维度，建议重新进行一次语音面试以获得更完整分析。",
                "highlights", List.of("历史报告格式为旧版文本，暂未结构化。"),
                "weaknesses", List.of("建议重新完成一次聊天式面试，以获得完整结构化报告。"),
                "improvementSuggestions", List.of("从当前岗位核心题型开始继续练习。"),
                "recommendedPractices", List.of()
        );
    }

    private String toRuntimePayload(RuntimeState runtimeState) {
        return toPayload("runtime", runtimeState);
    }

    private String toReportPayload(Map<String, Object> report) {
        return toPayload("report", report);
    }

    private String toPendingReportPayload(Map<String, Object> report) {
        return toPayload("report_pending", report);
    }

    private String toPayload(String kind, Object data) {
        try {
            return objectMapper.writeValueAsString(Map.of("kind", kind, "data", data));
        } catch (Exception ex) {
            throw new ClientException("序列化面试数据失败");
        }
    }

    private void ensureConversation(String conversationId, String userId, String title) {
        ConversationDO conversation = conversationMapper.selectOne(
                Wrappers.lambdaQuery(ConversationDO.class)
                        .eq(ConversationDO::getConversationId, conversationId)
                        .eq(ConversationDO::getUserId, userId)
                        .eq(ConversationDO::getDeleted, 0)
        );
        Date now = new Date();
        if (conversation == null) {
            conversation = ConversationDO.builder()
                    .conversationId(conversationId)
                    .userId(userId)
                    .title(title)
                    .lastTime(now)
                    .build();
            conversationMapper.insert(conversation);
            return;
        }
        conversation.setTitle(title);
        conversation.setLastTime(now);
        conversationMapper.updateById(conversation);
    }

    private void addAssistantMessage(String conversationId, String userId, String content) {
        addMessage(conversationId, userId, "assistant", content);
    }

    private void addUserMessage(String conversationId, String userId, String content) {
        addMessage(conversationId, userId, "user", content);
    }

    private void addMessage(String conversationId, String userId, String role, String content) {
        conversationMessageService.addMessage(ConversationMessageBO.builder()
                .conversationId(conversationId)
                .userId(userId)
                .role(role)
                .content(content)
                .build());
        ConversationDO conversation = conversationMapper.selectOne(
                Wrappers.lambdaQuery(ConversationDO.class)
                        .eq(ConversationDO::getConversationId, conversationId)
                        .eq(ConversationDO::getUserId, userId)
                        .eq(ConversationDO::getDeleted, 0)
        );
        if (conversation != null) {
            conversation.setLastTime(new Date());
            conversationMapper.updateById(conversation);
        }
    }

    private boolean isTimeoutReached(InterviewSessionEntity session) {
        if (session == null || session.getTimeLimit() == null || session.getStartTime() == null) {
            return false;
        }
        return LocalDateTime.now().isAfter(session.getStartTime().plusMinutes(session.getTimeLimit()));
    }

    private boolean isReportReady(InterviewSessionEntity session) {
        return "completed".equalsIgnoreCase(session.getStatus()) && !isReportPending(session);
    }

    private boolean isReportPending(InterviewSessionEntity session) {
        if (session == null || StrUtil.isBlank(session.getEvaluationReport())) {
            return false;
        }
        try {
            Map<String, Object> payload = objectMapper.readValue(session.getEvaluationReport(), new TypeReference<>() {});
            return "report_pending".equals(payload.get("kind"));
        } catch (Exception ex) {
            log.warn("解析报告状态失败, sessionId={}", session.getId(), ex);
            return false;
        }
    }

    boolean shouldAskFollowUp(
            Map<String, Object> evaluation,
            RuntimeState runtimeState,
            boolean lowSignalAnswer,
            String feedbackMode
    ) {
        if (evaluation == null) {
            return false;
        }
        if ("move_on".equals(normalizeFeedbackMode(feedbackMode))) {
            return false;
        }
        if (lowSignalAnswer) {
            return runtimeState != null && Optional.ofNullable(runtimeState.getFollowUpCount()).orElse(0) < 1;
        }
        Object explicitDecision = evaluation.get("shouldFollowUp");
        if (explicitDecision instanceof Boolean bool) {
            return bool;
        }
        if (explicitDecision instanceof String text) {
            return text.startsWith("是") || "true".equalsIgnoreCase(text);
        }
        Integer score = evaluation.get("score") instanceof Integer value ? value : null;
        String answerSignal = normalizeAnswerSignal(Objects.toString(evaluation.get("answerSignal"), ""));
        if ("good".equals(answerSignal)) {
            return false;
        }
        if ("partial".equals(answerSignal)) {
            return score == null || score < 70;
        }
        return score == null || score < 60;
    }

    private Integer adjustDifficulty(Integer currentDifficulty, Map<String, Object> evaluation) {
        int current = normalizeDifficulty(currentDifficulty);
        Integer score = evaluation == null ? null : (evaluation.get("score") instanceof Integer value ? value : null);
        if (score == null) {
            return current;
        }
        if (score >= 85) {
            return Math.min(5, current + 1);
        }
        if (score <= 60) {
            return Math.max(1, current - 1);
        }
        return current;
    }

    String buildInstantFeedbackMessage(Map<String, Object> evaluation) {
        if (evaluation == null) {
            return "这题先记到这里，我们继续。";
        }
        String liveFeedback = Objects.toString(evaluation.get("liveFeedback"), "").trim();
        if (StrUtil.isNotBlank(liveFeedback)) {
            return liveFeedback;
        }
        String instantFeedback = Objects.toString(evaluation.get("instantFeedback"), "").trim();
        if (StrUtil.isNotBlank(instantFeedback)) {
            return instantFeedback;
        }
        return "这题先记到这里，我们继续。";
    }

    private void ensureRuntimeStateDefaults(RuntimeState runtimeState) {
        if (runtimeState == null) {
            return;
        }
        if (runtimeState.getFollowUpHistory() == null) {
            runtimeState.setFollowUpHistory(new ArrayList<>());
        }
        if (runtimeState.getAskedQuestionIds() == null) {
            runtimeState.setAskedQuestionIds(new ArrayList<>());
        }
        if (runtimeState.getLastFollowUpIntent() == null) {
            runtimeState.setLastFollowUpIntent("");
        }
        if (runtimeState.getLastFollowUpFocus() == null) {
            runtimeState.setLastFollowUpFocus("");
        }
        if (runtimeState.getCurrentMainQuestionId() == null) {
            runtimeState.setCurrentMainQuestionId(runtimeState.getCurrentQuestionId());
        }
    }

    private boolean shouldUseFollowUp(
            RuntimeState runtimeState,
            String followUpIntent,
            String followUpFocus,
            String followUpQuestionText
    ) {
        if (runtimeState == null || runtimeState.getFollowUpCount() >= MAX_FOLLOW_UPS) {
            return false;
        }
        if (StrUtil.isBlank(followUpQuestionText)) {
            return false;
        }
        if (isQuizStyleFollowUp(followUpQuestionText)) {
            return false;
        }
        if (isRepeatedFollowUp(runtimeState, followUpIntent, followUpFocus, followUpQuestionText)) {
            return false;
        }
        return true;
    }

    private boolean shouldRewriteFollowUp(
            RuntimeState runtimeState,
            String followUpIntent,
            String followUpFocus,
            String followUpQuestionText
    ) {
        if (StrUtil.isBlank(followUpQuestionText)) {
            return false;
        }
        return isQuizStyleFollowUp(followUpQuestionText)
                || isRepeatedFollowUp(runtimeState, followUpIntent, followUpFocus, followUpQuestionText);
    }

    private boolean isRepeatedFollowUp(
            RuntimeState runtimeState,
            String followUpIntent,
            String followUpFocus,
            String followUpQuestionText
    ) {
        String normalizedQuestion = normalizeComparisonText(followUpQuestionText);
        if (StrUtil.isNotBlank(runtimeState.getLastFollowUpIntent())
                && Objects.equals(runtimeState.getLastFollowUpIntent(), followUpIntent)
                && StrUtil.isNotBlank(followUpIntent)) {
            return true;
        }
        if (StrUtil.isNotBlank(runtimeState.getLastFollowUpFocus())
                && Objects.equals(normalizeComparisonText(runtimeState.getLastFollowUpFocus()), normalizeComparisonText(followUpFocus))
                && StrUtil.isNotBlank(followUpFocus)) {
            return true;
        }
        return runtimeState.getFollowUpHistory().stream()
                .map(this::normalizeComparisonText)
                .anyMatch(item -> item.contains(normalizedQuestion) || normalizedQuestion.contains(item));
    }

    private boolean isQuizStyleFollowUp(String followUpQuestionText) {
        String normalized = StrUtil.blankToDefault(followUpQuestionText, "").trim();
        if (normalized.isEmpty()) {
            return false;
        }
        if (QUIZ_STYLE_PHRASES.stream().anyMatch(normalized::contains)) {
            return true;
        }
        return (normalized.contains("并") || normalized.contains("以及"))
                && (normalized.contains("区别") || normalized.contains("说明") || normalized.contains("列举"));
    }

    private String normalizeFollowUpQuestion(String followUpQuestionText) {
        if (StrUtil.isBlank(followUpQuestionText)) {
            return "";
        }
        String normalized = followUpQuestionText
                .replace("继续追问：", "")
                .replace("追问：", "")
                .replace("追问问题：", "")
                .replace("\n", " ")
                .trim();
        normalized = normalized.replaceAll("\\s+", " ");
        if (normalized.startsWith("问题：")) {
            normalized = normalized.substring(3).trim();
        }
        return normalized;
    }

    private String normalizeIntent(String followUpIntent) {
        if (StrUtil.isBlank(followUpIntent)) {
            return "";
        }
        String normalized = followUpIntent.trim().toLowerCase(Locale.ROOT);
        return switch (normalized) {
            case "clarify_definition", "verify_understanding", "scenario", "tradeoff", "implementation_detail" -> normalized;
            case "missing_fact" -> "clarify_definition";
            case "deeper_understanding" -> "verify_understanding";
            case "scenario_application" -> "scenario";
            case "tradeoff_reasoning" -> "tradeoff";
            default -> "";
        };
    }

    private String normalizeFocus(String followUpFocus) {
        if (StrUtil.isBlank(followUpFocus)) {
            return "";
        }
        return followUpFocus.replace("\n", " ").replaceAll("\\s+", " ").trim();
    }

    private String buildFollowUpHistoryEntry(String followUpIntent, String followUpFocus, String followUpQuestionText) {
        List<String> parts = new ArrayList<>();
        if (StrUtil.isNotBlank(followUpIntent)) {
            parts.add(followUpIntent);
        }
        if (StrUtil.isNotBlank(followUpFocus)) {
            parts.add(followUpFocus);
        }
        if (StrUtil.isNotBlank(followUpQuestionText)) {
            parts.add(followUpQuestionText);
        }
        return String.join(" | ", parts);
    }

    private String normalizeComparisonText(String value) {
        return StrUtil.blankToDefault(value, "")
                .toLowerCase(Locale.ROOT)
                .replaceAll("[\\p{Punct}\\s]+", "");
    }

    private PositionEntity resolvePosition(String normalized) {
        List<PositionEntity> positions = positionMapper.selectList(
                Wrappers.lambdaQuery(PositionEntity.class).eq(PositionEntity::getDeleted, 0)
        );
        if (positions == null || positions.isEmpty()) {
            return null;
        }
        if (normalized.contains("java")) {
            return findFirstMatching(positions, List.of("java", "后端"));
        }
        if (normalized.contains("前端") || normalized.contains("react") || normalized.contains("vue") || normalized.contains("web")) {
            return findFirstMatching(positions, List.of("前端", "web", "react", "vue"));
        }
        if (normalized.contains("python") || normalized.contains("算法")) {
            return findFirstMatching(positions, List.of("python", "算法"));
        }
        return positions.stream()
                .filter(item -> normalized.contains(StrUtil.blankToDefault(item.getName(), "").toLowerCase(Locale.ROOT)))
                .findFirst()
                .orElse(null);
    }

    private PositionEntity findFirstMatching(List<PositionEntity> positions, List<String> keywords) {
        return positions.stream().filter(position -> {
            String name = StrUtil.blankToDefault(position.getName(), "").toLowerCase(Locale.ROOT);
            String desc = StrUtil.blankToDefault(position.getDescription(), "").toLowerCase(Locale.ROOT);
            return keywords.stream().anyMatch(keyword -> name.contains(keyword) || desc.contains(keyword));
        }).findFirst().orElse(null);
    }

    private Integer resolveDifficulty(String normalized) {
        if (normalized.contains("简单") || normalized.contains("初级") || normalized.contains("入门")) {
            return 2;
        }
        if (normalized.contains("中等") || normalized.contains("中级")) {
            return 3;
        }
        if (normalized.contains("困难") || normalized.contains("高级") || normalized.contains("资深")) {
            return 4;
        }
        Matcher matcher = Pattern.compile("难度\\s*(\\d)").matcher(normalized);
        if (matcher.find()) {
            return normalizeDifficulty(Integer.parseInt(matcher.group(1)));
        }
        return DEFAULT_DIFFICULTY;
    }

    private Integer resolveTimeLimit(String normalized) {
        Matcher matcher = TIME_LIMIT_PATTERN.matcher(normalized);
        if (matcher.find()) {
            return normalizeTimeLimit(Integer.parseInt(matcher.group(1)));
        }
        return DEFAULT_TIME_LIMIT_MINUTES;
    }

    private Integer resolveQuestionLimit(String normalized) {
        Matcher matcher = QUESTION_LIMIT_PATTERN.matcher(normalized);
        if (matcher.find()) {
            return normalizeQuestionLimit(Integer.parseInt(matcher.group(1)));
        }
        return DEFAULT_QUESTION_LIMIT;
    }

    private Integer normalizeDifficulty(Integer difficulty) {
        if (difficulty == null) {
            return DEFAULT_DIFFICULTY;
        }
        return Math.max(1, Math.min(5, difficulty));
    }

    private Integer normalizeTimeLimit(Integer minutes) {
        if (minutes == null) {
            return DEFAULT_TIME_LIMIT_MINUTES;
        }
        return Math.max(10, Math.min(90, minutes));
    }

    private Integer normalizeQuestionLimit(Integer count) {
        if (count == null) {
            return DEFAULT_QUESTION_LIMIT;
        }
        return Math.max(3, Math.min(10, count));
    }

    private PositionEntity requirePosition(String positionId) {
        PositionEntity position = positionMapper.selectById(positionId);
        if (position == null || Integer.valueOf(1).equals(position.getDeleted())) {
            throw new ClientException("岗位不存在");
        }
        return position;
    }

    private InterviewSessionEntity requireOwnedSession(String sessionId, String userId) {
        InterviewSessionEntity session = interviewSessionService.getSessionById(sessionId);
        if (session == null || Integer.valueOf(1).equals(session.getDeleted()) || !Objects.equals(session.getUserId(), userId)) {
            throw new ClientException("面试会话不存在");
        }
        return session;
    }

    private String requireUserId() {
        String userId = UserContext.getUserId();
        if (StrUtil.isBlank(userId)) {
            throw new ClientException("未登录");
        }
        return userId;
    }

    private String buildOpeningMessage(String positionName, Integer difficulty, Integer timeLimitMinutes, Integer questionLimit) {
        return String.format(
                "你好，我们开始这场 %s 模拟面试。我会按照难度 %d、总计 %d 题、约 %d 分钟的节奏来推进。每道题我都会先听你的回答，先给你简短反馈，再根据你的内容决定是否继续追问，单题最多追问 %d 次。你不用一次说得很满，先按真实面试状态回答就可以。",
                positionName,
                difficulty,
                questionLimit,
                timeLimitMinutes,
                MAX_FOLLOW_UPS
        );
    }

    private String buildQuestionMessage(Integer questionIndex, String questionText) {
        if (questionIndex != null && questionIndex <= 1) {
            return String.format("第 %d 题，我们正式开始。\n\n%s", questionIndex, questionText);
        }
        return String.format("第 %d 题。\n\n%s", questionIndex, questionText);
    }

    private String buildCompletionMessage(String sessionId, Integer score) {
        return String.format("今天这场面试先到这里。结合整场回答，你当前的综合得分是 %d 分。我已经把本次表现、亮点、不足和后续练习建议整理成报告。\n\n[查看面试报告](/interview-report/%s)", score, sessionId);
    }

    String buildNextQuestionTransition(RuntimeState runtimeState) {
        int index = Optional.ofNullable(runtimeState)
                .map(RuntimeState::getQuestionIndex)
                .orElse(0);
        List<String> transitions = List.of(
                "这题先到这里，我们看下一题。",
                "好，换个方向。",
                "这个点我先记下，继续下一题。",
                "先到这里，我们继续。"
        );
        return transitions.get(Math.floorMod(index, transitions.size()));
    }

    boolean isLowSignalAnswer(String userAnswer, String answerSignal) {
        if ("low".equals(normalizeAnswerSignal(answerSignal))) {
            return true;
        }
        String normalized = StrUtil.blankToDefault(userAnswer, "").replaceAll("\\s+", "");
        if (normalized.isBlank() || normalized.length() <= 4) {
            return true;
        }
        String lower = normalized.toLowerCase(Locale.ROOT);
        return LOW_SIGNAL_PHRASES.stream().anyMatch(lower::contains);
    }

    String normalizeAnswerSignal(String value) {
        String normalized = StrUtil.blankToDefault(value, "").trim().toLowerCase(Locale.ROOT);
        return switch (normalized) {
            case "good", "partial", "low" -> normalized;
            default -> "";
        };
    }

    String normalizeFeedbackMode(String value) {
        String normalized = StrUtil.blankToDefault(value, "").trim().toLowerCase(Locale.ROOT);
        return switch (normalized) {
            case "follow_up", "redirect", "move_on" -> normalized;
            default -> "";
        };
    }

    private String buildFallbackSummary(int score) {
        if (score >= 85) {
            return "整体表现较强，回答已经具备较好的技术准确性和表达完整度，继续补强细节与取舍分析会更接近高水平面试表现。";
        }
        if (score >= 70) {
            return "整体表现合格，基础知识和表达框架基本具备，但在深度、细节和面试节奏控制上还有明显提升空间。";
        }
        return "当前表现说明你已经开始建立答题框架，但核心知识点覆盖、表达清晰度和问题拆解能力仍需进一步强化。";
    }

    private String buildExpressionSummary(int expressionScore) {
        if (expressionScore >= 85) {
            return "表达节奏自然，语气稳定，关键信息强调比较到位，已经接近真实面试中的成熟作答状态。";
        }
        if (expressionScore >= 70) {
            return "表达整体清晰，语速和停顿大体稳定，但还可以继续加强重点前置和结论先行。";
        }
        if (expressionScore >= 55) {
            return "表达基本能支撑答题，但节奏控制、停顿分配和自信感还有明显提升空间。";
        }
        return "表达状态偏紧张或不够连贯，建议先降低语速、缩短无效停顿，再强化关键词的清晰输出。";
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> readDimensionScores(Object value) {
        if (value instanceof Map<?, ?> map) {
            return (Map<String, Object>) map;
        }
        return Map.of();
    }

    private int numberOrDefault(Object value, int fallback) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        return fallback;
    }

    private String stringOrDefault(Object value, String fallback) {
        if (value instanceof String text && !text.isBlank()) {
            return text.trim();
        }
        return fallback;
    }

    @SuppressWarnings("unchecked")
    private List<String> listOrDefault(Object value, List<String> fallback) {
        if (!(value instanceof List<?> list)) {
            return fallback;
        }
        List<String> normalized = ((List<Object>) list).stream()
                .map(item -> item == null ? "" : String.valueOf(item).trim())
                .filter(item -> !item.isBlank())
                .toList();
        return normalized.isEmpty() ? fallback : normalized;
    }

    private String summarize(String label, String content, String fallback) {
        String text = StrUtil.blankToDefault(content, fallback).replace("\n", " ").trim();
        if (text.length() > 60) {
            text = text.substring(0, 60) + "...";
        }
        return text;
    }

    private List<Map<String, Object>> buildRecommendedPractices(
            InterviewSessionEntity session,
            RuntimeState runtimeState,
            List<InterviewAnswerEntity> validAnswers
    ) {
        Set<String> weakTypes = new LinkedHashSet<>();
        Set<String> weakKeywords = new LinkedHashSet<>();
        for (InterviewAnswerEntity answer : validAnswers) {
            if (Optional.ofNullable(answer.getScore()).orElse(0) >= 75 || answer.getQuestionId() == null) {
                continue;
            }
            QuestionEntity question = questionService.getQuestionById(answer.getQuestionId());
            if (question == null) {
                continue;
            }
            if (StrUtil.isNotBlank(question.getQuestionType())) {
                weakTypes.add(question.getQuestionType());
            }
            if (question.getKeywordList() != null) {
                weakKeywords.addAll(question.getKeywordList().stream().limit(3).toList());
            }
        }

        return questionService.getQuestionsByPosition(session.getPositionId()).stream()
                .filter(question -> !runtimeState.getAskedQuestionIds().contains(question.getId()))
                .sorted(Comparator.comparingInt((QuestionEntity question) -> recommendationPriority(question, weakTypes, weakKeywords)).reversed())
                .limit(3)
                .map(question -> {
                    question.setRecommendationReason(buildPracticeReason(question, weakTypes, weakKeywords));
                    questionService.enrichQuestion(question);
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("id", question.getId());
                    item.put("questionText", question.getQuestionText());
                    item.put("difficulty", question.getDifficulty());
                    item.put("questionType", question.getQuestionType());
                    item.put("knowledgeTags", question.getKeywordList());
                    item.put("knowledgeSource", question.getKnowledgeSource());
                    item.put("recommendationReason", question.getRecommendationReason());
                    item.put("referenceAnswerPreview", question.getReferenceAnswerPreview());
                    return item;
                })
                .collect(Collectors.toList());
    }

    private int recommendationPriority(QuestionEntity question, Set<String> weakTypes, Set<String> weakKeywords) {
        int score = 0;
        if (question == null) {
            return score;
        }
        if (weakTypes.contains(question.getQuestionType())) {
            score += 4;
        }
        if (question.getKeywordList() != null) {
            for (String keyword : question.getKeywordList()) {
                if (weakKeywords.contains(keyword)) {
                    score += 2;
                }
            }
        }
        score += Math.max(0, 6 - Optional.ofNullable(question.getDifficulty()).orElse(3));
        return score;
    }

    private String buildPracticeReason(QuestionEntity question, Set<String> weakTypes, Set<String> weakKeywords) {
        if (question == null) {
            return "建议继续进行专项训练。";
        }
        if (weakTypes.contains(question.getQuestionType())) {
            return "这道题和你本次表现较弱的题型一致，适合做针对性补强。";
        }
        if (question.getKeywordList() != null) {
            for (String keyword : question.getKeywordList()) {
                if (weakKeywords.contains(keyword)) {
                    return "这道题覆盖了你本次回答中暴露出的薄弱知识点，适合立即复练。";
                }
            }
        }
        return "这道题仍属于当前岗位高频考点，可用于巩固核心知识框架。";
    }

    private int average(List<Integer> values) {
        List<Integer> filtered = values.stream().filter(Objects::nonNull).toList();
        if (filtered.isEmpty()) {
            return 0;
        }
        return Math.round((float) filtered.stream().mapToInt(Integer::intValue).sum() / filtered.size());
    }

    @lombok.Data
    public static class RuntimeState {
        private String positionId;
        private String positionName;
        private Integer difficulty = DEFAULT_DIFFICULTY;
        private Integer timeLimitMinutes = DEFAULT_TIME_LIMIT_MINUTES;
        private Integer questionLimit = DEFAULT_QUESTION_LIMIT;
        private String currentMainQuestionId;
        private String currentQuestionId;
        private String currentQuestionText;
        private Integer questionIndex = 0;
        private Integer followUpCount = 0;
        private String lastFollowUpIntent = "";
        private String lastFollowUpFocus = "";
        private List<String> followUpHistory = new ArrayList<>();
        private List<String> askedQuestionIds = new ArrayList<>();
    }
}
