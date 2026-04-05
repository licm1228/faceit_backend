package com.nageoffer.ai.ragent.interview.service;

import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.infra.chat.LLMService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AIEvaluationService {

    private final LLMService llmService;

    /**
     * 评估学生回答
     * @param question 题目信息
     * @param userAnswer 学生回答
     * @return 评估结果
     */
    public Map<String, Object> evaluateAnswer(QuestionEntity question, String userAnswer) {
        // 构建评估提示词
        String prompt = buildEvaluationPrompt(question, userAnswer);

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

    /**
     * 生成追问
     * @param question 原题目
     * @param userAnswer 用户回答
     * @return 追问题目
     */
    public QuestionEntity generateFollowUpQuestion(QuestionEntity question, String userAnswer) {
        // 构建追问提示词
        String prompt = buildFollowUpPrompt(question, userAnswer);

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

    private String buildEvaluationPrompt(QuestionEntity question, String userAnswer) {
        return "你是一位专业的技术面试官，请评估以下学生的回答：\n" +
                "题目：" + question.getQuestionText() + "\n" +
                "参考答案：" + question.getReferenceAnswer() + "\n" +
                "学生回答：" + userAnswer + "\n" +
                "请从以下几个方面进行评估：\n" +
                "1. 技术准确性（0-30分）\n" +
                "2. 表达能力（0-25分）\n" +
                "3. 逻辑清晰度（0-25分）\n" +
                "4. 知识覆盖度（0-20分）\n" +
                "总分为各项之和（0-100分）\n" +
                "同时提供详细的反馈和改进建议。\n" +
                "请按照以下格式输出：\n" +
                "评分：[总分]\n" +
                "技术准确性：[分数]\n" +
                "表达能力：[分数]\n" +
                "逻辑清晰度：[分数]\n" +
                "知识覆盖度：[分数]\n" +
                "反馈：[详细反馈]\n" +
                "建议：[改进建议]";
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

    private String buildFollowUpPrompt(QuestionEntity question, String userAnswer) {
        return "你是一位专业的技术面试官，根据以下题目和学生回答，生成一个相关的追问：\n" +
                "题目：" + question.getQuestionText() + "\n" +
                "学生回答：" + userAnswer + "\n" +
                "要求：\n" +
                "1. 追问应该针对学生回答中的薄弱环节或需要进一步澄清的地方\n" +
                "2. 追问应该与原题目相关，能够深入了解学生的技术水平\n" +
                "3. 追问应该简洁明了，直击问题核心\n" +
                "4. 只输出追问内容，不要添加任何其他说明";
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
                    // 提取数字部分
                    scoreStr = scoreStr.replaceAll("[^0-9]", "");
                    if (!scoreStr.isEmpty()) {
                        evaluation.put("score", Integer.parseInt(scoreStr));
                    }
                } catch (NumberFormatException e) {
                    evaluation.put("score", 0);
                }
            }

            // 提取各维度评分
            extractScore(result, "技术准确性：", "technicalScore", evaluation);
            extractScore(result, "表达能力：", "expressionScore", evaluation);
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
                String suggestions = result.substring(suggestionsIndex + 3).trim();
                evaluation.put("suggestions", suggestions);
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
                scoreStr = scoreStr.replaceAll("[^0-9]", "");
                if (!scoreStr.isEmpty()) {
                    evaluation.put(key, Integer.parseInt(scoreStr));
                }
            } catch (NumberFormatException e) {
                evaluation.put(key, 0);
            }
        }
    }
}
