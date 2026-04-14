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

package com.nageoffer.ai.ragent.rag.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nageoffer.ai.ragent.framework.convention.ChatMessage;
import com.nageoffer.ai.ragent.framework.convention.ChatRequest;
import com.nageoffer.ai.ragent.framework.convention.RetrievedChunk;
import com.nageoffer.ai.ragent.interview.entity.PositionEntity;
import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.interview.mapper.PositionMapper;
import com.nageoffer.ai.ragent.interview.service.PositionProfileService;
import com.nageoffer.ai.ragent.interview.service.QuestionService;
import com.nageoffer.ai.ragent.knowledge.controller.vo.KnowledgeDocumentSearchVO;
import com.nageoffer.ai.ragent.knowledge.service.KnowledgeDocumentService;
import com.nageoffer.ai.ragent.rag.core.retrieve.PreferredKnowledgeBaseResolver;
import com.nageoffer.ai.ragent.rag.dto.RetrievalContext;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class StudyModeService {

    private static final String PAYLOAD_PREFIX = "\n\n<!--FACEIT_STUDY_PAYLOAD_BEGIN\n";
    private static final String PAYLOAD_SUFFIX = "\nFACEIT_STUDY_PAYLOAD_END-->";

    private final QuestionService questionService;
    private final PositionMapper positionMapper;
    private final PositionProfileService positionProfileService;
    private final PreferredKnowledgeBaseResolver preferredKnowledgeBaseResolver;
    private final KnowledgeDocumentService knowledgeDocumentService;
    private final ObjectMapper objectMapper;

    public StudyContext buildStudyContext(String question,
                                          List<ChatMessage> history,
                                          RetrievalContext retrievalContext,
                                          String preferredModelId) {
        StudyPayload payload = buildPayload(question, retrievalContext);
        ChatRequest request = buildStudyStreamRequest(question, history, retrievalContext, payload, preferredModelId);
        return new StudyContext(request, encodePayload(payload));
    }

    private StudyPayload buildPayload(String question, RetrievalContext retrievalContext) {
        PositionEntity position = resolvePosition(question);
        List<QuestionEntity> practiceQuestions = resolvePracticeQuestions(question, position);
        List<Map<String, Object>> resources = buildRelatedResources(question, retrievalContext);
        String topic = extractLearningTopic(question, position, practiceQuestions, retrievalContext);
        List<String> focusKeywords = extractFocusKeywords(topic, retrievalContext, practiceQuestions);

        String positionName = position == null ? "通用技术学习" : position.getName();
        List<Map<String, Object>> practiceItems = practiceQuestions.stream()
                .map(questionEntity -> buildPracticeItem(questionEntity, topic, focusKeywords))
                .toList();
        List<String> nextActions = buildNextActions(positionName, topic, practiceItems);

        return new StudyPayload(
                "study",
                positionName,
                focusKeywords,
                practiceItems,
                nextActions,
                resources
        );
    }

    private ChatRequest buildStudyStreamRequest(String question,
                                                List<ChatMessage> history,
                                                RetrievalContext retrievalContext,
                                                StudyPayload payload,
                                                String preferredModelId) {
        String kbContext = StrUtil.blankToDefault(retrievalContext == null ? null : retrievalContext.getKbContext(), "暂无直接命中的知识库上下文。");
        String practiceSummary = payload.practiceQuestions().isEmpty()
                ? "当前题库没有完全匹配的练习题，请先按讲解部分做口头复述。"
                : payload.practiceQuestions().stream()
                .map(item -> "- " + item.get("questionText"))
                .collect(Collectors.joining("\n"));
        String resourceSummary = payload.relatedResources().isEmpty()
                ? "暂无直接命中的资料片段。"
                : payload.relatedResources().stream()
                .map(item -> "- " + item.getOrDefault("title", "知识资料") + "：" + item.getOrDefault("snippet", ""))
                .collect(Collectors.joining("\n"));

        List<ChatMessage> messages = new ArrayList<>();
        messages.add(ChatMessage.system("""
                你是 Face It 的学习教练。你的任务是把用户问题组织成一段适合技术面试准备的学习讲解。
                请严格使用以下 Markdown 结构：
                ## 学习目标
                ## 核心讲解
                ## 关键点
                ## 常见误区
                ## 练习建议
                ## 答题骨架
                ## 下一步

                要求：
                1. 正文是主内容，写自然、连贯、可朗读，不要像后台数据回显。
                2. 不要原样输出知识库中的文件名、标题层级、适用知识库、标签等元信息。
                3. 如果用户像是在回答上一轮练习题，先点评回答，再继续给建议。
                4. 练习建议要聚焦当前主题，不要泛化到不相关基础题。
                5. 关键点、误区、答题骨架尽量各 2-3 条。
                """));
        messages.add(ChatMessage.user(buildPrompt(question, history, kbContext, practiceSummary, resourceSummary, payload)));

        return ChatRequest.builder()
                .messages(messages)
                .preferredModelId(preferredModelId)
                .thinking(false)
                .temperature(0.3D)
                .topP(0.8D)
                .build();
    }

    private String buildPrompt(String question,
                               List<ChatMessage> history,
                               String kbContext,
                               String practiceSummary,
                               String resourceSummary,
                               StudyPayload payload) {
        String historyText = history == null ? "" : history.stream()
                .filter(Objects::nonNull)
                .map(message -> {
                    String role = message.getRole() == ChatMessage.Role.ASSISTANT ? "教练" : "用户";
                    return role + "：" + stripStudyPayload(message.getContent());
                })
                .filter(StrUtil::isNotBlank)
                .skip(Math.max(0, (history == null ? 0 : history.size()) - 6L))
                .collect(Collectors.joining("\n"));
        return """
                【当前问题】
                %s

                【近期对话】
                %s

                【知识库上下文】
                %s

                【推荐练习题】
                %s

                【相关资料片段】
                %s

                【建议答题骨架】
                %s
                """.formatted(
                question,
                StrUtil.blankToDefault(historyText, "无"),
                kbContext,
                practiceSummary,
                resourceSummary,
                buildFrameworkHint(payload.focusTags())
        );
    }

    private PositionEntity resolvePosition(String question) {
        List<PositionEntity> positions = positionMapper.selectList(
                Wrappers.lambdaQuery(PositionEntity.class)
                        .eq(PositionEntity::getDeleted, 0)
        );
        if (positions == null || positions.isEmpty()) {
            return null;
        }
        String normalized = StrUtil.blankToDefault(question, "").toLowerCase(Locale.ROOT);
        return positions.stream()
                .map(positionProfileService::enrich)
                .filter(Objects::nonNull)
                .max(Comparator.comparingInt(position -> positionMatchScore(position, normalized)))
                .filter(position -> positionMatchScore(position, normalized) > 0)
                .orElseGet(() -> resolveByPreferredCollection(positions, normalized));
    }

    private PositionEntity resolveByPreferredCollection(List<PositionEntity> positions, String normalizedQuestion) {
        List<String> preferredCollections = preferredKnowledgeBaseResolver.resolvePreferredCollections(normalizedQuestion);
        if (preferredCollections.isEmpty()) {
            return null;
        }
        return positions.stream()
                .map(positionProfileService::enrich)
                .filter(position -> position != null && position.getPreferredKnowledgeCollections() != null)
                .filter(position -> position.getPreferredKnowledgeCollections().stream().anyMatch(preferredCollections::contains))
                .findFirst()
                .orElse(null);
    }

    private int positionMatchScore(PositionEntity position, String question) {
        if (position == null || StrUtil.isBlank(question)) {
            return 0;
        }
        int score = 0;
        String positionName = StrUtil.blankToDefault(position.getName(), "").toLowerCase(Locale.ROOT);
        String skills = StrUtil.blankToDefault(position.getRequiredSkills(), "").toLowerCase(Locale.ROOT);
        String focus = StrUtil.blankToDefault(position.getInterviewFocus(), "").toLowerCase(Locale.ROOT);
        if (question.contains(positionName)) {
            score += 4;
        }
        for (String token : List.of("java", "python", "前端", "web", "算法", "redis", "spring", "react", "vue", "mysql")) {
            if (question.contains(token) && (positionName.contains(token) || skills.contains(token) || focus.contains(token))) {
                score += 2;
            }
        }
        return score;
    }

    private List<QuestionEntity> resolvePracticeQuestions(String question, PositionEntity position) {
        List<QuestionEntity> candidates = position == null
                ? List.of()
                : questionService.getQuestionsByPosition(position.getId());
        if (candidates.isEmpty()) {
            return List.of();
        }
        Set<String> tokens = extractQuestionTokens(question);
        String topic = extractLearningTopic(question, position, candidates, null).toLowerCase(Locale.ROOT);
        return candidates.stream()
                .sorted(Comparator
                        .comparingInt((QuestionEntity item) -> practiceMatchScore(item, tokens, topic)).reversed()
                        .thenComparingInt(item -> Math.abs(Optional.ofNullable(item.getDifficulty()).orElse(3) - 3)))
                .limit(3)
                .toList();
    }

    private int practiceMatchScore(QuestionEntity question, Set<String> tokens, String topic) {
        int score = 0;
        String questionText = StrUtil.blankToDefault(question.getQuestionText(), "").toLowerCase(Locale.ROOT);
        String type = StrUtil.blankToDefault(question.getQuestionType(), "").toLowerCase(Locale.ROOT);
        if (question.getKeywordList() != null) {
            for (String keyword : question.getKeywordList()) {
                if (tokens.contains(keyword.toLowerCase(Locale.ROOT))) {
                    score += 3;
                }
                if (topic.contains(keyword.toLowerCase(Locale.ROOT))) {
                    score += 4;
                }
            }
        }
        for (String token : tokens) {
            if (questionText.contains(token)) {
                score += 1;
            }
        }
        if (questionText.contains(topic)) {
            score += 8;
        }
        if (topic.contains("工程化")) {
            if (type.contains("项目") || type.contains("project")) {
                score += 8;
            }
            if (containsAny(questionText, "架构", "组件", "状态", "性能", "协作", "规范", "工程")) {
                score += 6;
            }
            if (containsAny(questionText, "跨域", "渲染")) {
                score -= 2;
            }
        }
        return score;
    }

    private Set<String> extractQuestionTokens(String question) {
        String normalized = StrUtil.blankToDefault(question, "")
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^\\p{IsAlphabetic}\\p{IsIdeographic}0-9]+", " ");
        return Arrays.stream(normalized.split("\\s+"))
                .map(String::trim)
                .filter(token -> token.length() >= 2)
                .collect(Collectors.toCollection(LinkedHashSet::new));
    }

    private List<Map<String, Object>> buildRelatedResources(String question, RetrievalContext retrievalContext) {
        Map<String, Map<String, Object>> resources = new LinkedHashMap<>();
        List<String> queries = extractFocusKeywords(extractLearningTopic(question, null, List.of(), retrievalContext), retrievalContext, List.of());
        if (queries.isEmpty()) {
            queries = List.of(extractLearningTopic(question, null, List.of(), retrievalContext));
        }

        for (String query : queries.stream().filter(StrUtil::isNotBlank).distinct().limit(4).toList()) {
            RetrievedChunk matchedChunk = findBestChunkForQuery(query, retrievalContext);
            try {
                for (KnowledgeDocumentSearchVO document : knowledgeDocumentService.search(query, 2)) {
                    if (document == null || StrUtil.isBlank(document.getId())) {
                        continue;
                    }
                    Map<String, Object> item = resources.computeIfAbsent(document.getId(), ignored -> {
                        Map<String, Object> map = new LinkedHashMap<>();
                        map.put("id", document.getId());
                        map.put("title", document.getDocName());
                        map.put("knowledgeBaseName", document.getKbName());
                        map.put("matchedKeyword", query);
                        map.put("resourceType", "知识库资料");
                        return map;
                    });
                    if (matchedChunk != null) {
                        item.put("snippet", toSnippet(matchedChunk.getText(), 140));
                        item.put("score", roundScore(matchedChunk.getScore()));
                    }
                    item.put("recommendationReason", "这份资料与当前学习主题“" + query + "”直接相关，适合先扫一遍再答题。");
                    if (resources.size() >= 3) {
                        return new ArrayList<>(resources.values());
                    }
                }
            } catch (Exception ex) {
                log.debug("学习模式关联资料失败, query={}", query, ex);
            }
        }

        if (resources.isEmpty()) {
            int index = 0;
            for (RetrievedChunk chunk : flattenChunks(retrievalContext).stream().limit(3).toList()) {
                String snippet = cleanSnippet(chunk.getText());
                if (StrUtil.isBlank(snippet)) {
                    continue;
                }
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("id", "chunk-" + index++);
                item.put("title", "知识库命中片段");
                item.put("resourceType", "命中片段");
                item.put("snippet", toSnippet(snippet, 140));
                item.put("score", roundScore(chunk.getScore()));
                item.put("recommendationReason", "这段内容与当前问题高度相关，建议结合练习题一起复述。");
                resources.put(String.valueOf(item.get("id")), item);
            }
        }
        return new ArrayList<>(resources.values());
    }

    private List<String> extractFocusKeywords(String topic,
                                              RetrievalContext retrievalContext,
                                              List<QuestionEntity> practiceQuestions) {
        LinkedHashSet<String> keywords = new LinkedHashSet<>();
        keywords.add(topic);
        for (RetrievedChunk chunk : flattenChunks(retrievalContext).stream().limit(3).toList()) {
            String snippet = cleanSnippet(chunk.getText());
            snippet = toSnippet(snippet, 24);
            if (StrUtil.isNotBlank(snippet)) {
                keywords.add(snippet);
            }
        }
        for (QuestionEntity practiceQuestion : practiceQuestions) {
            if (practiceQuestion.getKeywordList() != null) {
                keywords.addAll(practiceQuestion.getKeywordList().stream().limit(2).toList());
            }
        }
        return keywords.stream()
                .filter(StrUtil::isNotBlank)
                .limit(4)
                .toList();
    }

    private List<RetrievedChunk> flattenChunks(RetrievalContext retrievalContext) {
        if (retrievalContext == null || retrievalContext.getIntentChunks() == null) {
            return List.of();
        }
        return retrievalContext.getIntentChunks().values().stream()
                .filter(Objects::nonNull)
                .flatMap(List::stream)
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing((RetrievedChunk chunk) -> Optional.ofNullable(chunk.getScore()).orElse(0F)).reversed())
                .limit(5)
                .toList();
    }

    private Map<String, Object> buildPracticeItem(QuestionEntity question, String topic, List<String> focusKeywords) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", question.getId());
        item.put("questionText", question.getQuestionText());
        item.put("difficulty", question.getDifficulty());
        item.put("questionType", positionProfileService.resolveQuestionTypeDisplayName(question.getQuestionType()));
        item.put("focus", StrUtil.isBlank(topic) ? (focusKeywords.isEmpty() ? "核心概念复述" : focusKeywords.get(0)) : topic);
        item.put("referenceAnswerPreview", question.getReferenceAnswerPreview());
        item.put("suggestion", buildPracticeSuggestion(question, topic));
        item.put("source", "question_bank");
        return item;
    }
    private List<String> buildNextActions(String positionName,
                                          String topic,
                                          List<Map<String, Object>> practiceItems) {
        List<String> actions = new ArrayList<>();
        actions.add("先复述一次本轮讲解，控制在 60-90 秒内。");
        if (!practiceItems.isEmpty()) {
            actions.add("从推荐练习里先做第 1 题，答完后检查自己有没有把背景、判断和收益讲完整。");
        }
        actions.add("再找一条“" + (StrUtil.isBlank(topic) ? positionName : topic) + "”相关资料片段，补一个例子或反例。");
        return actions;
    }

    private String toSnippet(String text, int maxLength) {
        String normalized = StrUtil.blankToDefault(text, "")
                .replaceAll("\\s+", " ")
                .trim();
        if (normalized.length() <= maxLength) {
            return normalized;
        }
        return normalized.substring(0, maxLength) + "...";
    }

    private Double roundScore(Float score) {
        if (score == null) {
            return null;
        }
        return Math.round(score * 1000d) / 1000d;
    }

    private String encodePayload(StudyPayload payload) {
        try {
            return PAYLOAD_PREFIX + objectMapper.writeValueAsString(payload) + PAYLOAD_SUFFIX;
        } catch (JsonProcessingException ex) {
            log.warn("学习模式 payload 序列化失败", ex);
            return "";
        }
    }

    private String stripStudyPayload(String content) {
        if (StrUtil.isBlank(content)) {
            return "";
        }
        int markerIndex = content.indexOf("<!--FACEIT_STUDY_PAYLOAD_BEGIN");
        if (markerIndex < 0) {
            return content;
        }
        return content.substring(0, markerIndex).trim();
    }

    private RetrievedChunk findBestChunkForQuery(String query, RetrievalContext retrievalContext) {
        String normalizedQuery = StrUtil.blankToDefault(query, "").toLowerCase(Locale.ROOT);
        return flattenChunks(retrievalContext).stream()
                .sorted(Comparator.comparingInt((RetrievedChunk chunk) -> {
                    String cleaned = cleanSnippet(chunk.getText()).toLowerCase(Locale.ROOT);
                    int score = cleaned.contains(normalizedQuery) ? 10 : 0;
                    score += containsAny(cleaned, "工程化", "架构", "组件", "状态", "性能", "规范", "协作") ? 3 : 0;
                    return score;
                }).reversed())
                .findFirst()
                .orElse(null);
    }

    private String extractLearningTopic(String question,
                                        PositionEntity position,
                                        List<QuestionEntity> practiceQuestions,
                                        RetrievalContext retrievalContext) {
        String normalized = StrUtil.blankToDefault(question, "").trim();
        for (String topic : List.of("前端工程化", "性能优化", "状态管理", "组件拆分", "页面架构", "接口协作", "项目深挖")) {
            if (normalized.contains(topic)) {
                return topic;
            }
        }
        if (containsAny(normalized.toLowerCase(Locale.ROOT), "工程化", "vite", "webpack", "eslint", "ci", "组件", "状态", "性能")) {
            return "前端工程化";
        }
        if (practiceQuestions != null) {
            for (QuestionEntity practiceQuestion : practiceQuestions) {
                if (practiceQuestion.getKeywordList() != null) {
                    for (String keyword : practiceQuestion.getKeywordList()) {
                        if (StrUtil.isNotBlank(keyword) && normalized.contains(keyword)) {
                            return keyword;
                        }
                    }
                }
            }
        }
        if (retrievalContext != null) {
            for (RetrievedChunk chunk : flattenChunks(retrievalContext)) {
                String cleaned = cleanSnippet(chunk.getText());
                if (containsAny(cleaned, "工程化", "状态管理", "性能优化", "组件拆分", "项目深挖")) {
                    for (String topic : List.of("前端工程化", "状态管理", "性能优化", "组件拆分", "项目深挖")) {
                        if (cleaned.contains(topic)) {
                            return topic;
                        }
                    }
                }
            }
        }
        if (position != null && StrUtil.isNotBlank(position.getName())) {
            return position.getName();
        }
        return normalized.length() <= 12 ? normalized : normalized.substring(0, 12);
    }

    private String cleanSnippet(String text) {
        if (StrUtil.isBlank(text)) {
            return "";
        }
        String cleaned = text.replaceAll("(?m)^#+\\s*", "")
                .replaceAll("(?m)^[-*]\\s*", "")
                .replaceAll("(?m)^适用知识库.*$", "")
                .replaceAll("(?m)^建议文件名.*$", "")
                .replaceAll("(?m)^主题标签.*$", "")
                .replaceAll("(?m)^高频问题.*$", "")
                .replaceAll("(?m)^问题\\d+.*$", "")
                .replaceAll("(?m)^难度\\s*\\d+.*$", "")
                .replaceAll("(?m)^类型.*$", "")
                .replaceAll("\\s+", " ")
                .trim();
        if (cleaned.startsWith("web/") || cleaned.startsWith("Web 前端项目深挖与追问")) {
            cleaned = cleaned.replaceFirst("^Web 前端项目深挖与追问", "").trim();
        }
        return cleaned;
    }

    private String buildPracticeSuggestion(QuestionEntity question, String topic) {
        String type = StrUtil.blankToDefault(question.getQuestionType(), "").toLowerCase(Locale.ROOT);
        if (type.contains("项目") || type.contains("project")) {
            return "先讲业务背景，再讲技术判断、取舍和最终收益。";
        }
        if (StrUtil.blankToDefault(topic, "").contains("工程化")) {
            return "先讲问题，再讲为什么这么设计，最后补落地收益。";
        }
        return "先用 1 分钟讲结论，再补关键依据和边界条件。";
    }

    private String buildFrameworkHint(List<String> focusTags) {
        String topic = focusTags == null || focusTags.isEmpty() ? "当前主题" : focusTags.get(0);
        return "先定义“" + topic + "”解决什么问题，再讲设计判断和取舍，最后补收益与复盘。";
    }

    private boolean containsAny(String text, String... tokens) {
        if (text == null) {
            return false;
        }
        for (String token : tokens) {
            if (text.contains(token)) {
                return true;
            }
        }
        return false;
    }

    private record StudyPayload(
            String kind,
            String positionName,
            List<String> focusTags,
            List<Map<String, Object>> practiceQuestions,
            List<String> nextActions,
            List<Map<String, Object>> relatedResources
    ) {
    }

    public record StudyContext(
            ChatRequest request,
            String payloadSuffix
    ) {
    }
}
