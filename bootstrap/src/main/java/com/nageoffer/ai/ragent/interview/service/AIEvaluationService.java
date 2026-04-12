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

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.infra.chat.LLMService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class AIEvaluationService {

    private static final Pattern FIRST_NUMBER_PATTERN = Pattern.compile("\\d+");

    private final LLMService llmService;
    private final ObjectMapper objectMapper;

    /**
     * 评估学生回答
     * @param question 题目信息
     * @param userAnswer 学生回答
     * @return 评估结果
     */
    public Map<String, Object> evaluateAnswer(QuestionEntity question, String userAnswer) {
        return evaluateAnswer(question, userAnswer, 0);
    }

    public Map<String, Object> evaluateAnswer(QuestionEntity question, String userAnswer, int followUpCount) {
        return evaluateAnswer(question, userAnswer, followUpCount, "", "", List.of());
    }

    public Map<String, Object> evaluateAnswer(
            QuestionEntity question,
            String userAnswer,
            int followUpCount,
            String lastFollowUpIntent,
            String lastFollowUpFocus,
            List<String> followUpHistory
    ) {
        // 构建评估提示词
        String prompt = buildEvaluationPrompt(question, userAnswer, followUpCount, lastFollowUpIntent, lastFollowUpFocus, followUpHistory);

        try {
            // 调用LLM服务进行评估
            String evaluationResult = llmService.chat(prompt);
            System.out.println("LLM Evaluation Result: " + evaluationResult);

            // 解析评估结果
            return parseEvaluationResult(evaluationResult);
        } catch (Exception e) {
            System.err.println("Evaluation error: " + e.getMessage());
            // 返回默认评估结果
            Map<String, Object> defaultEvaluation = new HashMap<>();
            defaultEvaluation.put("score", 0);
            defaultEvaluation.put("technicalScore", 0);
            defaultEvaluation.put("expressionScore", 0);
            defaultEvaluation.put("logicScore", 0);
            defaultEvaluation.put("knowledgeScore", 0);
            defaultEvaluation.put("feedback", "评估服务暂时不可用");
            defaultEvaluation.put("suggestions", "请稍后再试");
            defaultEvaluation.put("shouldFollowUp", false);
            defaultEvaluation.put("followUpQuestion", "");
            defaultEvaluation.put("followUpIntent", "");
            defaultEvaluation.put("followUpFocus", "");
            defaultEvaluation.put("answeredPoints", List.of());
            defaultEvaluation.put("missingPoints", List.of());
            defaultEvaluation.put("avoidRepeat", List.of());
            return defaultEvaluation;
        }
    }

    /**
     * 生成面试评估报告
     * @param sessionId 会话ID
     * @param answers 所有回答的评估结果
     * @return 评估报告
     */
    public String generateEvaluationReport(String sessionId, Map<String, Object>[] answers) {
        // 构建报告提示词
        String prompt = buildReportPrompt(answers);

        try {
            // 调用LLM服务生成报告
            return llmService.chat(prompt);
        } catch (Exception e) {
            System.err.println("Report generation error: " + e.getMessage());
            // 返回默认报告
            return "## 面试评估报告\n\n### 总体表现概述\n评估服务暂时不可用，请稍后再试。\n\n### 优势分析\n-\n\n### 不足与改进方向\n-\n\n### 技术能力评估\n-\n\n### 综合建议\n-\n";
        }
    }

    public Map<String, Object> generateStructuredEvaluationReport(
            String positionName,
            Integer questionLimit,
            Integer timeLimitMinutes,
            Map<String, Object>[] answers
    ) {
        String prompt = buildStructuredReportPrompt(positionName, questionLimit, timeLimitMinutes, answers);
        try {
            String result = llmService.chat(prompt);
            return parseStructuredReport(result);
        } catch (Exception e) {
            System.err.println("Structured report generation error: " + e.getMessage());
            return Map.of();
        }
    }

    /**
     * 生成追问
     * @param question 原题目
     * @param userAnswer 用户回答
     * @return 追问题目
     */
    public QuestionEntity generateFollowUpQuestion(QuestionEntity question, String userAnswer) {
        return generateFollowUpQuestion(question, userAnswer, 0, "", "", List.of());
    }

    public QuestionEntity generateFollowUpQuestion(
            QuestionEntity question,
            String userAnswer,
            int followUpCount,
            String followUpIntent,
            String followUpFocus,
            List<String> followUpHistory
    ) {
        // 构建追问提示词
        String prompt = buildFollowUpPrompt(question, userAnswer, followUpCount, followUpIntent, followUpFocus, followUpHistory);

        try {
            // 调用LLM服务生成追问
            String followUpResult = llmService.chat(prompt);
            System.out.println("Follow-up Question: " + followUpResult);

            // 解析追问结果
            QuestionEntity followUpQuestion = new QuestionEntity();
            followUpQuestion.setParentQuestionId(question.getId());
            followUpQuestion.setPositionId(question.getPositionId());
            followUpQuestion.setQuestionType(question.getQuestionType());
            followUpQuestion.setDifficulty(question.getDifficulty());
            followUpQuestion.setQuestionText(followUpResult);
            followUpQuestion.setReferenceAnswer("");
            followUpQuestion.setKeywords(question.getKeywords());
            return followUpQuestion;
        } catch (Exception e) {
            System.err.println("Follow-up generation error: " + e.getMessage());
            return null;
        }
    }

    private String buildEvaluationPrompt(
            QuestionEntity question,
            String userAnswer,
            int followUpCount,
            String lastFollowUpIntent,
            String lastFollowUpFocus,
            List<String> followUpHistory
    ) {
        return "你是一位专业的技术面试官，请评估以下学生的回答：\n" +
                "题目：" + question.getQuestionText() + "\n" +
                "参考答案：" + question.getReferenceAnswer() + "\n" +
                "学生回答：" + userAnswer + "\n" +
                "当前追问轮次：" + followUpCount + "\n" +
                "上一轮追问意图：" + blankDefault(lastFollowUpIntent, "无") + "\n" +
                "上一轮追问聚焦点：" + blankDefault(lastFollowUpFocus, "无") + "\n" +
                "本题历史追问：" + stringifyList(followUpHistory) + "\n" +
                "请从以下几个方面进行评估：\n" +
                "1. 技术准确性（0-30分）\n" +
                "2. 岗位匹配度（0-25分）\n" +
                "3. 逻辑清晰度（0-25分）\n" +
                "4. 知识覆盖度（0-20分）\n" +
                "总分为各项之和（0-100分）\n" +
                "同时提供详细的反馈和改进建议，并判断是否应该继续追问。\n" +
                "你必须像真实技术面试官一样追问，而不是像题库老师出补全题。\n" +
                "追问规则：\n" +
                "1. 每轮最多只追问一个关键点，只能有一个追问意图和一个追问聚焦点。\n" +
                "2. 如果候选人已经提到某个点，不得要求其完整复述或重新列举。\n" +
                "3. 优先顺序：补关键缺口 -> 判断理解是否真实 -> 问场景应用 -> 问取舍原因 -> 问实现细节。\n" +
                "4. 禁止把原题改写成更细的背诵题，禁止出现“请完整列举”“请分别说明”“请详细说明以下几点”等考试式措辞。\n" +
                "5. 如果当前追问轮次已达到 2，默认不要继续追问。\n" +
                "6. 如果上一轮已经围绕某个聚焦点追问，本轮不得重复同一聚焦点，也不得延续同一追问意图。\n" +
                "7. 追问语气必须像口头面试，短、自然、针对性强。\n" +
                "8. 如果回答已经足够完整，就直接进入下一题，不要为了互动而强行追问。\n" +
                "追问意图只能从以下枚举中选择一个：missing_fact, deeper_understanding, scenario_application, tradeoff_reasoning, implementation_detail\n" +
                "请按照以下格式输出：\n" +
                "评分：[总分]\n" +
                "技术准确性：[分数]\n" +
                "岗位匹配度：[分数]\n" +
                "逻辑清晰度：[分数]\n" +
                "知识覆盖度：[分数]\n" +
                "反馈：[详细反馈]\n" +
                "建议：[改进建议]\n" +
                "已覆盖要点：[逗号分隔]\n" +
                "缺失要点：[逗号分隔]\n" +
                "避免重复：[逗号分隔]\n" +
                "继续追问：[是/否]\n" +
                "追问意图：[missing_fact/deeper_understanding/scenario_application/tradeoff_reasoning/implementation_detail，如不追问留空]\n" +
                "追问聚焦点：[只写一个最关键的缺口或主题，如不追问留空]\n" +
                "追问问题：[如需追问则输出具体问题，否则留空]";
    }

    private String buildReportPrompt(Map<String, Object>[] answers) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("你是一位专业的技术面试官，请根据以下面试回答评估结果生成一份综合评估报告：\n\n");

        for (int i = 0; i < answers.length; i++) {
            Map<String, Object> answer = answers[i];
            prompt.append("问题").append(i + 1).append("：\n");
            prompt.append("评分：").append(answer.get("score")).append("\n");
            prompt.append("技术准确性：").append(answer.get("technicalScore")).append("\n");
            prompt.append("表达能力：").append(answer.get("expressionScore")).append("\n");
            prompt.append("逻辑清晰度：").append(answer.get("logicScore")).append("\n");
            prompt.append("知识覆盖度：").append(answer.get("knowledgeScore")).append("\n");
            prompt.append("反馈：").append(answer.get("feedback")).append("\n");
            prompt.append("建议：").append(answer.get("suggestions")).append("\n\n");
        }

        prompt.append("请生成一份详细的评估报告，包括：\n");
        prompt.append("1. 总体表现概述\n");
        prompt.append("2. 优势分析\n");
        prompt.append("3. 不足与改进方向\n");
        prompt.append("4. 技术能力评估\n");
        prompt.append("5. 综合建议\n");
        prompt.append("报告应该专业、客观、详细。");

        return prompt.toString();
    }

    private String buildStructuredReportPrompt(
            String positionName,
            Integer questionLimit,
            Integer timeLimitMinutes,
            Map<String, Object>[] answers
    ) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("你是一位严格但专业的技术面试官，需要为一场模拟面试输出结构化 JSON 报告。");
        prompt.append("岗位：").append(positionName).append("\n");
        prompt.append("题量：").append(questionLimit).append("\n");
        prompt.append("时长：").append(timeLimitMinutes).append("分钟\n\n");

        for (int i = 0; i < answers.length; i++) {
            Map<String, Object> answer = answers[i];
            prompt.append("问题").append(i + 1).append("：\n");
            prompt.append("评分：").append(answer.get("score")).append("\n");
            prompt.append("技术正确性：").append(answer.get("technicalScore")).append("\n");
            prompt.append("岗位匹配度：").append(answer.get("expressionScore")).append("\n");
            prompt.append("逻辑清晰度：").append(answer.get("logicScore")).append("\n");
            prompt.append("知识覆盖度：").append(answer.get("knowledgeScore")).append("\n");
            prompt.append("反馈：").append(answer.get("feedback")).append("\n");
            prompt.append("建议：").append(answer.get("suggestions")).append("\n\n");
        }

        prompt.append("请仅返回合法 JSON，不要输出 Markdown，不要添加解释。");
        prompt.append("字段结构必须为：");
        prompt.append("{");
        prompt.append("\"overallScore\": number,");
        prompt.append("\"summary\": string,");
        prompt.append("\"dimensionScores\": {");
        prompt.append("\"technicalCorrectness\": number,");
        prompt.append("\"knowledgeDepth\": number,");
        prompt.append("\"logicRigor\": number,");
        prompt.append("\"positionMatch\": number");
        prompt.append("},");
        prompt.append("\"highlights\": string[],");
        prompt.append("\"weaknesses\": string[],");
        prompt.append("\"improvementSuggestions\": string[]");
        prompt.append("}");
        prompt.append("所有分数范围为 0 到 100，数组各输出 2 到 4 条，内容具体、像真实面试官。");
        return prompt.toString();
    }

    private String buildFollowUpPrompt(
            QuestionEntity question,
            String userAnswer,
            int followUpCount,
            String followUpIntent,
            String followUpFocus,
            List<String> followUpHistory
    ) {
        return "你是一位专业的技术面试官，根据以下题目和学生回答，生成一个相关的追问：\n" +
                "题目：" + question.getQuestionText() + "\n" +
                "学生回答：" + userAnswer + "\n" +
                "当前追问轮次：" + followUpCount + "\n" +
                "指定追问意图：" + blankDefault(followUpIntent, "deeper_understanding") + "\n" +
                "指定追问聚焦点：" + blankDefault(followUpFocus, "回答中最关键的薄弱点") + "\n" +
                "本题历史追问：" + stringifyList(followUpHistory) + "\n" +
                "要求：\n" +
                "1. 追问应该针对学生回答中的一个薄弱环节或需要进一步澄清的地方，只追一个点\n" +
                "2. 追问应该与原题目相关，能够深入了解学生的技术水平\n" +
                "3. 追问应该简洁明了，像真实口头面试，不要像考试题\n" +
                "4. 禁止出现“请完整列举”“请分别说明”“请详细说明以下几点”等措辞\n" +
                "5. 禁止重复历史追问中的主题\n" +
                "6. 只输出一句追问内容，不要添加任何其他说明";
    }

    private Map<String, Object> parseStructuredReport(String result) {
        if (result == null || result.isBlank()) {
            return Map.of();
        }
        String normalized = result.trim();
        int start = normalized.indexOf("{");
        int end = normalized.lastIndexOf("}");
        if (start < 0 || end <= start) {
            return Map.of();
        }
        try {
            Map<String, Object> payload = objectMapper.readValue(
                    normalized.substring(start, end + 1),
                    new TypeReference<>() {}
            );
            Map<String, Object> dimensionScores = castMap(payload.get("dimensionScores"));
            return Map.of(
                    "overallScore", clampNumber(payload.get("overallScore")),
                    "summary", toSafeText(payload.get("summary"), "本场面试已完成，整体表现具备一定基础，但仍有可优化空间。"),
                    "dimensionScores", Map.of(
                            "technicalCorrectness", clampNumber(dimensionScores.get("technicalCorrectness")),
                            "knowledgeDepth", clampNumber(dimensionScores.get("knowledgeDepth")),
                            "logicRigor", clampNumber(dimensionScores.get("logicRigor")),
                            "positionMatch", clampNumber(dimensionScores.get("positionMatch"))
                    ),
                    "highlights", toStringList(payload.get("highlights")),
                    "weaknesses", toStringList(payload.get("weaknesses")),
                    "improvementSuggestions", toStringList(payload.get("improvementSuggestions"))
            );
        } catch (Exception ex) {
            System.err.println("Structured report parse error: " + ex.getMessage());
            return Map.of();
        }
    }

    private Map<String, Object> parseEvaluationResult(String result) {
        Map<String, Object> evaluation = new HashMap<>();

        // 设置默认值，防止空结果
        evaluation.put("score", 0);
        evaluation.put("technicalScore", 0);
        evaluation.put("expressionScore", 0);
        evaluation.put("logicScore", 0);
        evaluation.put("knowledgeScore", 0);
        evaluation.put("feedback", "");
        evaluation.put("suggestions", "");
        evaluation.put("shouldFollowUp", false);
        evaluation.put("followUpQuestion", "");
        evaluation.put("followUpIntent", "");
        evaluation.put("followUpFocus", "");
        evaluation.put("answeredPoints", List.of());
        evaluation.put("missingPoints", List.of());
        evaluation.put("avoidRepeat", List.of());

        // 检查结果是否为空
        if (result == null || result.isEmpty()) {
            return evaluation;
        }

        // 增强解析逻辑，处理不同格式的返回结果
        try {
            // 尝试提取评分
            int scoreIndex = result.indexOf("评分：");
            if (scoreIndex != -1) {
                int scoreEndIndex = result.indexOf("\n", scoreIndex);
                if (scoreEndIndex == -1) scoreEndIndex = result.length();
                String scoreStr = result.substring(scoreIndex + 3, scoreEndIndex).trim();
                try {
                    evaluation.put("score", clamp(parseFirstNumber(scoreStr), 0, 100));
                } catch (NumberFormatException e) {
                    evaluation.put("score", 0);
                }
            }

            // 提取各维度评分
            extractScore(result, "技术准确性：", "technicalScore", evaluation);
            extractScore(result, "岗位匹配度：", "expressionScore", evaluation);
            extractScore(result, "逻辑清晰度：", "logicScore", evaluation);
            extractScore(result, "知识覆盖度：", "knowledgeScore", evaluation);

            // 尝试提取反馈
            int feedbackIndex = result.indexOf("反馈：");
            if (feedbackIndex != -1) {
                int feedbackEndIndex = result.indexOf("建议：", feedbackIndex);
                if (feedbackEndIndex == -1) feedbackEndIndex = result.length();
                String feedback = result.substring(feedbackIndex + 3, feedbackEndIndex).trim();
                evaluation.put("feedback", feedback);
            }

            // 尝试提取建议
            int suggestionsIndex = result.indexOf("建议：");
            if (suggestionsIndex != -1) {
                int suggestionsEndIndex = result.indexOf("已覆盖要点：", suggestionsIndex);
                if (suggestionsEndIndex == -1) {
                    suggestionsEndIndex = result.length();
                }
                String suggestions = result.substring(suggestionsIndex + 3, suggestionsEndIndex).trim();
                evaluation.put("suggestions", suggestions);
            }

            extractList(result, "已覆盖要点：", "answeredPoints", evaluation);
            extractList(result, "缺失要点：", "missingPoints", evaluation);
            extractList(result, "避免重复：", "avoidRepeat", evaluation);

            int shouldFollowUpIndex = result.indexOf("继续追问：");
            if (shouldFollowUpIndex != -1) {
                int endIndex = result.indexOf("\n", shouldFollowUpIndex);
                if (endIndex == -1) {
                    endIndex = result.length();
                }
                String shouldFollowUp = result.substring(shouldFollowUpIndex + 5, endIndex).trim();
                evaluation.put("shouldFollowUp", shouldFollowUp.startsWith("是"));
            }

            extractText(result, "追问意图：", "followUpIntent", evaluation, "追问聚焦点：");
            extractText(result, "追问聚焦点：", "followUpFocus", evaluation, "追问问题：");

            int followUpQuestionIndex = result.indexOf("追问问题：");
            if (followUpQuestionIndex != -1) {
                String followUpQuestion = result.substring(followUpQuestionIndex + 5).trim();
                evaluation.put("followUpQuestion", followUpQuestion);
            }

            // 如果没有找到任何信息，使用默认值
            if (evaluation.get("feedback").equals("") && evaluation.get("suggestions").equals("")) {
                evaluation.put("feedback", "评估完成");
                evaluation.put("suggestions", "继续努力");
            }
        } catch (Exception e) {
            System.err.println("Parse error: " + e.getMessage());
        }

        return evaluation;
    }

    private void extractScore(String result, String prefix, String key, Map<String, Object> evaluation) {
        int index = result.indexOf(prefix);
        if (index != -1) {
            int endIndex = result.indexOf("\n", index);
            if (endIndex == -1) endIndex = result.length();
            String scoreStr = result.substring(index + prefix.length(), endIndex).trim();
            try {
                evaluation.put(key, clamp(parseFirstNumber(scoreStr), 0, 100));
            } catch (NumberFormatException e) {
                evaluation.put(key, 0);
            }
        }
    }

    private void extractText(String result, String prefix, String key, Map<String, Object> evaluation, String nextPrefix) {
        int index = result.indexOf(prefix);
        if (index == -1) {
            return;
        }
        int endIndex = nextPrefix == null ? -1 : result.indexOf(nextPrefix, index);
        if (endIndex == -1) {
            endIndex = result.indexOf("\n", index);
        }
        if (endIndex == -1) {
            endIndex = result.length();
        }
        String value = result.substring(index + prefix.length(), endIndex).trim();
        evaluation.put(key, value);
    }

    private void extractList(String result, String prefix, String key, Map<String, Object> evaluation) {
        int index = result.indexOf(prefix);
        if (index == -1) {
            return;
        }
        int endIndex = result.indexOf("\n", index);
        if (endIndex == -1) {
            endIndex = result.length();
        }
        String value = result.substring(index + prefix.length(), endIndex).trim();
        evaluation.put(key, splitToList(value));
    }

    private int parseFirstNumber(String value) {
        Matcher matcher = FIRST_NUMBER_PATTERN.matcher(value == null ? "" : value);
        if (!matcher.find()) {
            return 0;
        }
        return Integer.parseInt(matcher.group());
    }

    private int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(max, value));
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> castMap(Object value) {
        if (value instanceof Map<?, ?> map) {
            return (Map<String, Object>) map;
        }
        return Map.of();
    }

    private int clampNumber(Object value) {
        if (value instanceof Number number) {
            return clamp(number.intValue(), 0, 100);
        }
        if (value instanceof String text) {
            return clamp(parseFirstNumber(text), 0, 100);
        }
        return 0;
    }

    private String toSafeText(Object value, String fallback) {
        if (value instanceof String text && !text.isBlank()) {
            return text.trim();
        }
        return fallback;
    }

    private List<String> toStringList(Object value) {
        if (!(value instanceof List<?> list)) {
            return List.of();
        }
        return list.stream()
                .map(item -> item == null ? "" : String.valueOf(item).trim())
                .filter(item -> !item.isBlank())
                .limit(4)
                .toList();
    }

    private List<String> splitToList(String value) {
        if (value == null || value.isBlank() || "无".equals(value.trim())) {
            return List.of();
        }
        return Arrays.stream(value.split("[,，、/\\n]"))
                .map(item -> item == null ? "" : item.trim())
                .filter(item -> !item.isBlank())
                .limit(4)
                .toList();
    }

    private String stringifyList(List<String> items) {
        if (items == null || items.isEmpty()) {
            return "无";
        }
        return String.join("；", items.stream()
                .map(item -> item == null ? "" : item.trim())
                .filter(item -> !item.isBlank())
                .limit(4)
                .toList());
    }

    private String blankDefault(String value, String fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }
        return value.trim();
    }
}
