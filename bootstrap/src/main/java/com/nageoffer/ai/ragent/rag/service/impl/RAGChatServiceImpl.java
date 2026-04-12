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

package com.nageoffer.ai.ragent.rag.service.impl;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.nageoffer.ai.ragent.framework.context.UserContext;
import com.nageoffer.ai.ragent.framework.convention.ChatMessage;
import com.nageoffer.ai.ragent.framework.convention.ChatRequest;
import com.nageoffer.ai.ragent.framework.trace.RagTraceContext;
import com.nageoffer.ai.ragent.infra.chat.LLMService;
import com.nageoffer.ai.ragent.infra.chat.StreamCallback;
import com.nageoffer.ai.ragent.infra.chat.StreamCancellationHandle;
import com.nageoffer.ai.ragent.infra.config.AIModelProperties;
import com.nageoffer.ai.ragent.rag.aop.ChatRateLimit;
import com.nageoffer.ai.ragent.rag.core.guidance.GuidanceDecision;
import com.nageoffer.ai.ragent.rag.core.guidance.IntentGuidanceService;
import com.nageoffer.ai.ragent.rag.core.intent.IntentResolver;
import com.nageoffer.ai.ragent.rag.core.memory.ConversationMemoryService;
import com.nageoffer.ai.ragent.rag.core.prompt.PromptContext;
import com.nageoffer.ai.ragent.rag.core.prompt.PromptTemplateLoader;
import com.nageoffer.ai.ragent.rag.core.prompt.RAGPromptService;
import com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine;
import com.nageoffer.ai.ragent.rag.core.rewrite.QueryRewriteService;
import com.nageoffer.ai.ragent.rag.core.rewrite.RewriteResult;
import com.nageoffer.ai.ragent.rag.dto.IntentGroup;
import com.nageoffer.ai.ragent.rag.dto.RetrievalContext;
import com.nageoffer.ai.ragent.rag.dto.SubQuestionIntent;
import com.nageoffer.ai.ragent.rag.service.RAGChatService;
import com.nageoffer.ai.ragent.rag.service.handler.StreamCallbackFactory;
import com.nageoffer.ai.ragent.rag.service.handler.StreamTaskManager;
import com.nageoffer.ai.ragent.interview.service.InterviewRetrieveService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static com.nageoffer.ai.ragent.rag.constant.RAGConstant.CHAT_SYSTEM_PROMPT_PATH;
import static com.nageoffer.ai.ragent.rag.constant.RAGConstant.DEFAULT_TOP_K;

/**
 * RAG 对话服务默认实现
 * <p>
 * 核心流程：
 * 记忆加载 -> 改写拆分 -> 意图解析 -> 歧义引导 -> 检索(MCP+KB) -> Prompt 组装 -> 流式输出
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class RAGChatServiceImpl implements RAGChatService {

    private final LLMService llmService;
    private final RAGPromptService promptBuilder;
    private final PromptTemplateLoader promptTemplateLoader;
    private final ConversationMemoryService memoryService;
    private final StreamTaskManager taskManager;
    private final IntentGuidanceService guidanceService;
    private final StreamCallbackFactory callbackFactory;
    private final QueryRewriteService queryRewriteService;
    private final IntentResolver intentResolver;
    private final RetrievalEngine retrievalEngine;
    private final InterviewRetrieveService interviewRetrieveService;
    private final AIModelProperties aiModelProperties;

    @Override
    @ChatRateLimit
    public void streamChat(String question, String conversationId, Boolean deepThinking, SseEmitter emitter) {
        String actualConversationId = StrUtil.isBlank(conversationId) ? IdUtil.getSnowflakeNextIdStr() : conversationId;
        String taskId = StrUtil.isBlank(RagTraceContext.getTaskId())
                ? IdUtil.getSnowflakeNextIdStr()
                : RagTraceContext.getTaskId();
        log.info("开始流式对话，会话ID：{}，任务ID：{}", actualConversationId, taskId);
        boolean thinkingEnabled = Boolean.TRUE.equals(deepThinking);

        StreamCallback callback = callbackFactory.createChatEventHandler(emitter, actualConversationId, taskId);

        String userId = UserContext.getUserId();
        List<ChatMessage> history = memoryService.loadAndAppend(actualConversationId, userId, ChatMessage.user(question));

        RewriteResult rewriteResult = queryRewriteService.rewriteWithSplit(question, history);
        List<SubQuestionIntent> subIntents = intentResolver.resolve(rewriteResult);

        // 检查是否是面试相关问题
        boolean isInterviewQuestion = isInterviewQuestion(rewriteResult.rewrittenQuestion());
        if (isInterviewQuestion) {
            handleInterviewQuestion(rewriteResult.rewrittenQuestion(), callback);
            return;
        }

        // 检查是否是查看答案请求
        boolean isViewAnswers = isViewAnswersRequest(rewriteResult.rewrittenQuestion());
        if (isViewAnswers) {
            handleViewAnswersRequest(rewriteResult.rewrittenQuestion(), callback);
            return;
        }

        GuidanceDecision guidanceDecision = guidanceService.detectAmbiguity(rewriteResult.rewrittenQuestion(), subIntents);
        if (guidanceDecision.isPrompt()) {
            callback.onContent(guidanceDecision.getPrompt());
            callback.onComplete();
            return;
        }

        boolean allSystemOnly = subIntents.stream()
                .allMatch(si -> intentResolver.isSystemOnly(si.nodeScores()));
        if (allSystemOnly) {
            String customPrompt = subIntents.stream()
                    .flatMap(si -> si.nodeScores().stream())
                    .map(ns -> ns.getNode().getPromptTemplate())
                    .filter(StrUtil::isNotBlank)
                    .findFirst()
                    .orElse(null);
            StreamCancellationHandle handle = streamSystemResponse(rewriteResult.rewrittenQuestion(), history, customPrompt, callback);
            taskManager.bindHandle(taskId, handle);
            return;
        }

        RetrievalContext ctx = retrievalEngine.retrieve(subIntents, DEFAULT_TOP_K);
        if (ctx.isEmpty()) {
            String emptyReply = "未检索到与问题相关的文档内容。";
            callback.onContent(emptyReply);
            callback.onComplete();
            return;
        }

        // 聚合所有意图用于 prompt 规划
        IntentGroup mergedGroup = intentResolver.mergeIntentGroup(subIntents);

        StreamCancellationHandle handle = streamLLMResponse(
                rewriteResult,
                ctx,
                mergedGroup,
                history,
                thinkingEnabled,
                callback
        );
        taskManager.bindHandle(taskId, handle);
    }

    @Override
    public void stopTask(String taskId) {
        taskManager.cancel(taskId);
    }

    // ==================== LLM 响应 ====================

    private StreamCancellationHandle streamSystemResponse(String question, List<ChatMessage> history,
                                                          String customPrompt, StreamCallback callback) {
        String systemPrompt = StrUtil.isNotBlank(customPrompt)
                ? customPrompt
                : promptTemplateLoader.load(CHAT_SYSTEM_PROMPT_PATH);

        List<ChatMessage> messages = new ArrayList<>();
        messages.add(ChatMessage.system(systemPrompt));
        if (CollUtil.isNotEmpty(history)) {
            messages.addAll(history.subList(0, history.size() - 1));
        }
        messages.add(ChatMessage.user(question));

        ChatRequest req = ChatRequest.builder()
                .messages(messages)
                .temperature(0.7D)
                .preferredModelId(resolvePreferredStreamModelId())
                .thinking(false)
                .build();
        return llmService.streamChat(req, callback);
    }

    private StreamCancellationHandle streamLLMResponse(RewriteResult rewriteResult, RetrievalContext ctx,
                                                       IntentGroup intentGroup, List<ChatMessage> history,
                                                       boolean deepThinking, StreamCallback callback) {
        PromptContext promptContext = PromptContext.builder()
                .question(rewriteResult.rewrittenQuestion())
                .mcpContext(ctx.getMcpContext())
                .kbContext(ctx.getKbContext())
                .mcpIntents(intentGroup.mcpIntents())
                .kbIntents(intentGroup.kbIntents())
                .intentChunks(ctx.getIntentChunks())
                .build();

        List<ChatMessage> messages = promptBuilder.buildStructuredMessages(
                promptContext,
                history,
                rewriteResult.rewrittenQuestion(),
                rewriteResult.subQuestions()  // 传入子问题列表
        );
        ChatRequest chatRequest = ChatRequest.builder()
                .messages(messages)
                .preferredModelId(resolvePreferredStreamModelId())
                .thinking(deepThinking)
                .temperature(ctx.hasMcp() ? 0.3D : 0D)  // MCP 场景稍微放宽温度
                .topP(ctx.hasMcp() ? 0.8D : 1D)
                .build();

        return llmService.streamChat(chatRequest, callback);
    }

    private String resolvePreferredStreamModelId() {
        AIModelProperties.Features features = aiModelProperties.getFeatures();
        if (features == null || !Boolean.TRUE.equals(features.getUseGpt())) {
            return null;
        }
        return StrUtil.blankToDefault(features.getGptModelId(), null);
    }

    /**
     * 检查是否是面试相关问题
     * @param question 用户问题
     * @return 是否是面试相关问题
     */
    private boolean isInterviewQuestion(String question) {
        String lowerQuestion = question.toLowerCase();
        return lowerQuestion.contains("面试") &&
                (lowerQuestion.contains("python") ||
                        lowerQuestion.contains("java") ||
                        lowerQuestion.contains("前端") ||
                        lowerQuestion.contains("算法"));
    }

    /**
     * 检查是否是查看答案请求
     * @param question 用户问题
     * @return 是否是查看答案请求
     */
    private boolean isViewAnswersRequest(String question) {
        String lowerQuestion = question.toLowerCase();
        return lowerQuestion.contains("查看答案") ||
                lowerQuestion.contains("参考答案") ||
                lowerQuestion.contains("答案");
    }

    /**
     * 处理面试相关问题
     * @param question 用户问题
     * @param callback 回调
     */
    private void handleInterviewQuestion(String question, StreamCallback callback) {
        try {
            // 解析问题，提取岗位信息
            String positionId = extractPositionId(question);
            int questionCount = 4; // 至少4个问题

            // 调用InterviewRetrieveService获取多个不同难度的题目
            Map<String, Object> result = interviewRetrieveService.selectMultipleQuestions(positionId, questionCount);

            // 检查是否有错误
            if (result.containsKey("error")) {
                callback.onContent("处理面试问题失败: " + result.get("message"));
                callback.onComplete();
                return;
            }

            // 构建响应内容
            StringBuilder response = new StringBuilder();
            response.append("根据你的需求，我为你准备了以下").append(questionCount).append("个不同难度的面试题目：\n\n");

            // 添加题目信息（只显示题目，不显示答案）
            List<Map<String, Object>> questions = (List<Map<String, Object>>) result.get("questions");
            if (questions != null && !questions.isEmpty()) {
                for (int i = 0; i < questions.size(); i++) {
                    Map<String, Object> questionInfo = questions.get(i);
                    response.append(i + 1).append(". 题目：").append(questionInfo.get("questionText")).append("\n");
                    response.append("   难度：").append(questionInfo.get("difficulty")).append("\n\n");
                }
            }

            // 提示用户回答完所有问题后获取答案
            response.append("请回答完所有问题后，输入'查看答案'来获取参考答案。\n");

            // 发送响应
            callback.onContent(response.toString());
            callback.onComplete();
        } catch (Exception e) {
            log.error("处理面试问题失败", e);
            callback.onContent("处理面试问题失败，请稍后重试");
            callback.onComplete();
        }
    }

    /**
     * 处理查看答案请求
     * @param question 用户问题
     * @param callback 回调
     */
    private void handleViewAnswersRequest(String question, StreamCallback callback) {
        try {
            // 解析问题，提取岗位信息
            String positionId = extractPositionId(question);
            int questionCount = 4; // 至少4个问题

            // 调用InterviewRetrieveService获取多个不同难度的题目（包含答案）
            Map<String, Object> result = interviewRetrieveService.selectMultipleQuestions(positionId, questionCount);

            // 检查是否有错误
            if (result.containsKey("error")) {
                callback.onContent("处理查看答案请求失败: " + result.get("message"));
                callback.onComplete();
                return;
            }

            // 构建响应内容
            StringBuilder response = new StringBuilder();
            response.append("以下是面试题目的参考答案：\n\n");

            // 添加题目和答案信息
            List<Map<String, Object>> questions = (List<Map<String, Object>>) result.get("questions");
            if (questions != null && !questions.isEmpty()) {
                for (int i = 0; i < questions.size(); i++) {
                    Map<String, Object> questionInfo = questions.get(i);
                    response.append(i + 1).append(". 题目：").append(questionInfo.get("questionText")).append("\n");
                    response.append("   难度：").append(questionInfo.get("difficulty")).append("\n");
                    response.append("   参考答案：").append(questionInfo.get("referenceAnswer")).append("\n\n");
                }
            }

            // 发送响应
            callback.onContent(response.toString());
            callback.onComplete();
        } catch (Exception e) {
            log.error("处理查看答案请求失败", e);
            callback.onContent("处理查看答案请求失败，请稍后重试");
            callback.onComplete();
        }
    }

    /**
     * 从问题中提取岗位ID
     * @param question 用户问题
     * @return 岗位ID
     */
    private String extractPositionId(String question) {
        String lowerQuestion = question.toLowerCase();
        if (lowerQuestion.contains("python") && lowerQuestion.contains("算法")) {
            return "pos_python_001";
        } else if (lowerQuestion.contains("java")) {
            return "pos_java_001";
        } else if (lowerQuestion.contains("前端") || lowerQuestion.contains("web")) {
            return "pos_web_001";
        } else {
            return "pos_java_001";
        }
    }
}
