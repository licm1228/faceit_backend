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
import com.nageoffer.ai.ragent.infra.chat.LLMService;
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

    private final LLMService llmService;
    private final QuestionService questionService;
    private final PositionMapper positionMapper;
    private final PositionProfileService positionProfileService;
    private final PreferredKnowledgeBaseResolver preferredKnowledgeBaseResolver;
    private final KnowledgeDocumentService knowledgeDocumentService;
    private final ObjectMapper objectMapper;

    public String buildStudyReply(String question,
                                  List<ChatMessage> history,
                                  RetrievalContext retrievalContext,
                                  String preferredModelId) {
        StudyPayload payload = buildPayload(question, retrievalContext);
        String markdown = buildMarkdownWithModel(question, history, retrievalContext, payload, preferredModelId);
        return markdown + encodePayload(payload);
    }

    private StudyPayload buildPayload(String question, RetrievalContext retrievalContext) {
        PositionEntity position = resolvePosition(question);
        List<QuestionEntity> practiceQuestions = resolvePracticeQuestions(question, position);
        List<Map<String, Object>> resources = buildRelatedResources(question, retrievalContext);
        List<String> focusKeywords = extractFocusKeywords(question, retrievalContext, practiceQuestions);

        String positionName = position == null ? "通用技术学习" : position.getName();
        String learningSummary = "本轮学习聚焦“" + summarizeTopic(question) + "”，目标是先讲清核心概念，再过一轮面试化练习。";
        String conceptExplanation = buildConceptExplanation(question, retrievalContext);
        List<String> keyPoints = buildKeyPoints(question, retrievalContext, practiceQuestions);
        List<String> commonMistakes = buildCommonMistakes(question, focusKeywords);
        List<Map<String, Object>> practiceItems = practiceQuestions.stream()
                .map(questionEntity -> buildPracticeItem(questionEntity, focusKeywords))
                .toList();
        List<String> answerFramework = buildAnswerFramework(question, focusKeywords);
        List<String> nextActions = buildNextActions(positionName, focusKeywords, practiceItems);

        return new StudyPayload(
                "study",
                positionName,
                learningSummary,
                conceptExplanation,
                keyPoints,
                commonMistakes,
                practiceItems,
                answerFramework,
                nextActions,
                resources
        );
    }

    private String buildMarkdownWithModel(String question,
                                          List<ChatMessage> history,
                                          RetrievalContext retrievalContext,
                                          StudyPayload payload,
                                          String preferredModelId) {
        try {
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
                    你是 Face It 的学习教练。你的任务是把用户问题组织成“学练闭环”的学习输出。
                    请严格使用以下 Markdown 结构：
                    ## 学习目标
                    ## 核心讲解
                    ## 关键点
                    ## 常见误区
                    ## 练习建议
                    ## 答题骨架
                    ## 下一步

                    要求：
                    1. 内容必须贴合用户问题与给定资料，不要编造资料来源。
                    2. 风格简洁直接，偏技术面试辅导，不要空泛鼓励。
                    3. 关键点、误区、答题骨架尽量使用 3 条以内的短列表。
                    4. 如果用户看起来是在回答上一轮练习题，先点评回答，再继续给下一步建议。
                    """));
            messages.add(ChatMessage.user(buildPrompt(question, history, kbContext, practiceSummary, resourceSummary, payload)));

            ChatRequest request = ChatRequest.builder()
                    .messages(messages)
                    .preferredModelId(preferredModelId)
                    .thinking(false)
                    .temperature(0.3D)
                    .topP(0.8D)
                    .build();
            String content = llmService.chat(request);
            if (StrUtil.isNotBlank(content)) {
                return content.trim();
            }
        } catch (Exception ex) {
            log.warn("学习模式调用模型生成讲解失败，使用本地兜底内容", ex);
        }
        return buildFallbackMarkdown(payload);
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

                【学习摘要】
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
                payload.learningSummary(),
                kbContext,
                practiceSummary,
                resourceSummary,
                String.join("；", payload.answerFramework())
        );
    }

    private String buildFallbackMarkdown(StudyPayload payload) {
        return """
                ## 学习目标
                %s

                ## 核心讲解
                %s

                ## 关键点
                %s

                ## 常见误区
                %s

                ## 练习建议
                %s

                ## 答题骨架
                %s

                ## 下一步
                %s
                """.formatted(
                payload.learningSummary(),
                payload.conceptExplanation(),
                toMarkdownList(payload.keyPoints()),
                toMarkdownList(payload.commonMistakes()),
                toMarkdownList(payload.practiceQuestions().stream()
                        .map(item -> String.valueOf(item.get("questionText")))
                        .toList()),
                toMarkdownList(payload.answerFramework()),
                toMarkdownList(payload.nextActions())
        ).trim();
    }

    private String toMarkdownList(List<String> lines) {
        if (lines == null || lines.isEmpty()) {
            return "- 暂无";
        }
        return lines.stream()
                .filter(StrUtil::isNotBlank)
                .map(line -> "- " + line)
                .collect(Collectors.joining("\n"));
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
        return candidates.stream()
                .sorted(Comparator
                        .comparingInt((QuestionEntity item) -> practiceMatchScore(item, tokens)).reversed()
                        .thenComparingInt(item -> Math.abs(Optional.ofNullable(item.getDifficulty()).orElse(3) - 3)))
                .limit(3)
                .toList();
    }

    private int practiceMatchScore(QuestionEntity question, Set<String> tokens) {
        int score = 0;
        String questionText = StrUtil.blankToDefault(question.getQuestionText(), "").toLowerCase(Locale.ROOT);
        if (question.getKeywordList() != null) {
            for (String keyword : question.getKeywordList()) {
                if (tokens.contains(keyword.toLowerCase(Locale.ROOT))) {
                    score += 3;
                }
            }
        }
        for (String token : tokens) {
            if (questionText.contains(token)) {
                score += 1;
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
        List<String> queries = extractFocusKeywords(question, retrievalContext, List.of());
        if (queries.isEmpty()) {
            queries = List.of(summarizeTopic(question));
        }

        for (String query : queries.stream().filter(StrUtil::isNotBlank).distinct().limit(4).toList()) {
            List<RetrievedChunk> chunks = flattenChunks(retrievalContext).stream().limit(2).toList();
            RetrievedChunk matchedChunk = chunks.isEmpty() ? null : chunks.get(0);
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
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("id", "chunk-" + index++);
                item.put("title", "知识库命中片段");
                item.put("resourceType", "命中片段");
                item.put("snippet", toSnippet(chunk.getText(), 140));
                item.put("score", roundScore(chunk.getScore()));
                item.put("recommendationReason", "这段内容与当前问题高度相关，建议结合练习题一起复述。");
                resources.put(String.valueOf(item.get("id")), item);
            }
        }
        return new ArrayList<>(resources.values());
    }

    private List<String> extractFocusKeywords(String question,
                                              RetrievalContext retrievalContext,
                                              List<QuestionEntity> practiceQuestions) {
        LinkedHashSet<String> keywords = new LinkedHashSet<>();
        keywords.add(summarizeTopic(question));
        for (RetrievedChunk chunk : flattenChunks(retrievalContext).stream().limit(3).toList()) {
            String snippet = toSnippet(chunk.getText(), 36);
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

    private Map<String, Object> buildPracticeItem(QuestionEntity question, List<String> focusKeywords) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", question.getId());
        item.put("questionText", question.getQuestionText());
        item.put("difficulty", question.getDifficulty());
        item.put("questionType", positionProfileService.resolveQuestionTypeDisplayName(question.getQuestionType()));
        item.put("focus", focusKeywords.isEmpty() ? "核心概念复述" : focusKeywords.get(0));
        item.put("referenceAnswerPreview", question.getReferenceAnswerPreview());
        item.put("suggestion", "先用 1 分钟讲结论，再补关键依据和边界条件。");
        item.put("source", "question_bank");
        return item;
    }

    private String buildConceptExplanation(String question, RetrievalContext retrievalContext) {
        List<RetrievedChunk> chunks = flattenChunks(retrievalContext);
        if (!chunks.isEmpty()) {
            return "知识库命中内容显示，“" + summarizeTopic(question) + "”相关重点主要集中在：" + toSnippet(chunks.get(0).getText(), 120);
        }
        return "当前知识库没有直接命中完整资料，本轮先按题型拆出核心概念、判断条件和常见追问，帮助你建立答题主线。";
    }

    private List<String> buildKeyPoints(String question, RetrievalContext retrievalContext, List<QuestionEntity> practiceQuestions) {
        LinkedHashSet<String> items = new LinkedHashSet<>();
        for (RetrievedChunk chunk : flattenChunks(retrievalContext)) {
            String snippet = toSnippet(chunk.getText(), 60);
            if (StrUtil.isNotBlank(snippet)) {
                items.add(snippet);
            }
            if (items.size() >= 3) {
                break;
            }
        }
        if (items.isEmpty()) {
            items.add("先用一句话定义“" + summarizeTopic(question) + "”，不要直接进入细节。");
            items.add("回答时补上适用场景、复杂度/代价，避免只说概念。");
        }
        if (!practiceQuestions.isEmpty()) {
            items.add("结合练习题把知识点转成“结论 + 依据 + 边界”的口头表达。");
        }
        return new ArrayList<>(items).stream().limit(3).toList();
    }

    private List<String> buildCommonMistakes(String question, List<String> focusKeywords) {
        List<String> mistakes = new ArrayList<>();
        mistakes.add("只会背定义，但说不清适用条件、代价或边界。");
        mistakes.add("回答没有结构，容易在追问时跳步骤。");
        if (!focusKeywords.isEmpty()) {
            mistakes.add("提到“" + focusKeywords.get(0) + "”时没有结合具体例子或典型场景。");
        }
        return mistakes.stream().limit(3).toList();
    }

    private List<String> buildAnswerFramework(String question, List<String> focusKeywords) {
        String focus = focusKeywords.isEmpty() ? summarizeTopic(question) : focusKeywords.get(0);
        return List.of(
                "先用一句话定义“" + focus + "”和它解决的问题。",
                "再讲 2-3 个关键机制或判断步骤，最好带上复杂度、约束或 trade-off。",
                "最后补一个典型场景或常见误区，方便扛住追问。"
        );
    }

    private List<String> buildNextActions(String positionName,
                                          List<String> focusKeywords,
                                          List<Map<String, Object>> practiceItems) {
        List<String> actions = new ArrayList<>();
        actions.add("先复述一次本轮讲解，控制在 60-90 秒内。");
        if (!practiceItems.isEmpty()) {
            actions.add("从推荐练习里先做第 1 题，答完再回来看答题骨架缺了哪一步。");
        }
        actions.add("再找一条“" + (focusKeywords.isEmpty() ? positionName : focusKeywords.get(0)) + "”相关资料片段，补一个例子或反例。");
        return actions;
    }

    private String summarizeTopic(String question) {
        String trimmed = StrUtil.blankToDefault(question, "").trim();
        if (trimmed.length() <= 20) {
            return trimmed;
        }
        return trimmed.substring(0, 20) + "...";
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

    private record StudyPayload(
            String kind,
            String positionName,
            String learningSummary,
            String conceptExplanation,
            List<String> keyPoints,
            List<String> commonMistakes,
            List<Map<String, Object>> practiceQuestions,
            List<String> answerFramework,
            List<String> nextActions,
            List<Map<String, Object>> relatedResources
    ) {
    }
}
