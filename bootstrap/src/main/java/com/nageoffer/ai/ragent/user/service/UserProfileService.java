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

package com.nageoffer.ai.ragent.user.service;

import cn.hutool.core.util.StrUtil;
import com.nageoffer.ai.ragent.interview.entity.InterviewAnswerEntity;
import com.nageoffer.ai.ragent.interview.entity.InterviewSessionEntity;
import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.interview.service.InterviewAnswerService;
import com.nageoffer.ai.ragent.interview.service.InterviewSessionService;
import com.nageoffer.ai.ragent.interview.service.PositionProfileService;
import com.nageoffer.ai.ragent.interview.service.QuestionService;
import com.nageoffer.ai.ragent.user.controller.vo.GrowthCurvePointVO;
import com.nageoffer.ai.ragent.user.controller.vo.InterviewHistoryDetailVO;
import com.nageoffer.ai.ragent.user.controller.vo.LearningResourceVO;
import com.nageoffer.ai.ragent.user.controller.vo.PracticePlanItemVO;
import com.nageoffer.ai.ragent.user.controller.vo.RecommendationVO;
import com.nageoffer.ai.ragent.user.controller.vo.RecommendedPracticeVO;
import com.nageoffer.ai.ragent.user.controller.vo.UserProfileVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final InterviewSessionService interviewSessionService;
    private final InterviewAnswerService interviewAnswerService;
    private final QuestionService questionService;
    private final PositionProfileService positionProfileService;

    public UserProfileVO getProfile(String userId) {
        List<InterviewSessionEntity> sessions = interviewSessionService.getSessionsByUserId(userId);
        int totalSessions = sessions.size();
        int completedSessions = 0;
        int scoreSum = 0;
        int scoreCount = 0;
        double totalDurationMinutes = 0;
        int durationCount = 0;
        List<InterviewSessionEntity> completed = new ArrayList<>();

        for (InterviewSessionEntity session : sessions) {
            if (session == null) {
                continue;
            }
            if ("completed".equalsIgnoreCase(session.getStatus()) && session.getTotalScore() != null) {
                completedSessions++;
                scoreSum += session.getTotalScore();
                scoreCount++;
                completed.add(session);
                if (session.getStartTime() != null && session.getEndTime() != null) {
                    totalDurationMinutes += Duration.between(session.getStartTime(), session.getEndTime()).toMinutes();
                    durationCount++;
                }
            }
        }

        double averageScore = scoreCount > 0 ? ((double) scoreSum) / scoreCount : 0D;
        double averageDurationMinutes = durationCount > 0 ? totalDurationMinutes / durationCount : 0D;
        Integer lastScore = completed.stream()
                .sorted(Comparator.comparing(InterviewSessionEntity::getUpdateTime).reversed())
                .map(InterviewSessionEntity::getTotalScore)
                .findFirst()
                .orElse(null);

        List<String> weakTopics = identifyWeakTopics(completed);
        String performanceLevel = buildPerformanceLevel(averageScore);
        String recommendation = buildSummaryRecommendation(averageScore, completedSessions, weakTopics);

        return UserProfileVO.builder()
                .totalSessions(totalSessions)
                .completedSessions(completedSessions)
                .averageScore(averageScore)
                .lastScore(lastScore)
                .averageDurationMinutes(averageDurationMinutes)
                .performanceLevel(performanceLevel)
                .recommendation(recommendation)
                .weakTopics(weakTopics)
                .build();
    }

    public List<GrowthCurvePointVO> getGrowthCurve(String userId, int limit) {
        List<InterviewSessionEntity> sessions = interviewSessionService.getSessionsByUserId(userId);
        return sessions.stream()
                .filter(session -> session != null
                        && "completed".equalsIgnoreCase(session.getStatus())
                        && session.getTotalScore() != null)
                .sorted(Comparator.comparing(session -> session.getEndTime() != null ? session.getEndTime() : session.getCreateTime()))
                .limit(limit)
                .map(this::toCurvePoint)
                .collect(Collectors.toList());
    }

    public RecommendationVO getRecommendation(String userId) {
        UserProfileVO profile = getProfile(userId);
        InterviewSessionEntity latestCompleted = getLatestCompletedSession(userId);
        String positionId = latestCompleted == null ? null : latestCompleted.getPositionId();
        List<String> focusAreas = profile.getWeakTopics();
        if (focusAreas == null || focusAreas.isEmpty()) {
            focusAreas = new ArrayList<>();
            if (profile.getAverageScore() >= 0) {
                focusAreas.add("继续提升题目准确率");
            }
        }
        String summary = profile.getCompletedSessions() == 0
                ? "您还未完成有效面试结果，建议先完成一次完整模拟面试。"
                : String.format("您当前平均得分 %.1f 分，建议优先练习以下方向。", profile.getAverageScore());
        String nextStep = buildNextStep(profile.getAverageScore(), profile.getCompletedSessions());
        List<String> learningSuggestions = buildLearningSuggestions(focusAreas, profile.getAverageScore());
        List<RecommendedPracticeVO> recommendedPractices = buildRecommendedPractices(positionId, focusAreas);
        List<LearningResourceVO> learningResources = buildLearningResources(positionId, focusAreas, profile.getAverageScore());
        List<PracticePlanItemVO> practicePlan = buildPracticePlan(positionId, focusAreas, profile.getAverageScore());

        return RecommendationVO.builder()
                .summary(summary)
                .focusAreas(focusAreas)
                .nextStep(nextStep)
                .averageScore(profile.getAverageScore())
                .completedSessions(profile.getCompletedSessions())
                .learningSuggestions(learningSuggestions)
                .recommendedPractices(recommendedPractices)
                .learningResources(learningResources)
                .practicePlan(practicePlan)
                .build();
    }

    public List<InterviewSessionEntity> getInterviewHistory(String userId) {
        return interviewSessionService.getSessionsByUserId(userId);
    }

    private List<String> identifyWeakTopics(List<InterviewSessionEntity> sessions) {
        Map<String, Integer> weakTypeCount = new HashMap<>();
        for (InterviewSessionEntity session : sessions) {
            if (session == null || session.getId() == null) {
                continue;
            }
            List<InterviewAnswerEntity> answers = interviewAnswerService.getAnswersBySessionId(session.getId());
            if (answers == null) {
                continue;
            }
            for (InterviewAnswerEntity answer : answers) {
                if (answer == null || answer.getScore() == null || answer.getQuestionId() == null) {
                    continue;
                }
                if (answer.getScore() < 60) {
                    QuestionEntity question = questionService.getQuestionById(answer.getQuestionId());
                    String questionType = question != null ? question.getQuestionType() : null;
                    String topic = StrUtil.trimToNull(questionType);
                    if (topic == null) {
                        topic = "综合题";
                    }
                    weakTypeCount.merge(topic, 1, Integer::sum);
                }
            }
        }
        return weakTypeCount.entrySet().stream()
                .sorted(Map.Entry.<String, Integer>comparingByValue(Comparator.reverseOrder()))
                .limit(3)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    private String buildPerformanceLevel(double averageScore) {
        if (averageScore <= 0) {
            return "待测评";
        }
        if (averageScore >= 85) {
            return "高级";
        }
        if (averageScore >= 70) {
            return "中级";
        }
        return "初级";
    }

    private String buildSummaryRecommendation(double averageScore, int completedSessions, List<String> weakTopics) {
        if (completedSessions == 0) {
            return "暂无有效面试结果，请先完成一次模拟面试。";
        }
        if (averageScore < 60) {
            return "当前基础较弱，建议优先复习基础题并加强答题规范。";
        }
        if (averageScore < 75) {
            return "基础已具备，建议侧重中等难度题和弱项知识点的训练。";
        }
        if (averageScore < 85) {
            return "表现良好，建议继续保持并尝试更高难度题目。";
        }
        return "成绩优秀，建议冲刺高难度题目并提升面试表达。";
    }

    private String buildNextStep(double averageScore, int completedSessions) {
        if (completedSessions == 0) {
            return "先完成至少一次模拟面试，获取第一份评估结果。";
        }
        if (averageScore < 60) {
            return "重点练习基础题、总结答题思路，避免低级失误。";
        }
        if (averageScore < 75) {
            return "整理易错题类型，集中攻克中等难度题。";
        }
        return "尝试高难度题并复盘答题过程，提升综合应对能力。";
    }

    private List<String> buildLearningSuggestions(List<String> focusAreas, double averageScore) {
        Set<String> suggestions = new LinkedHashSet<>();
        if (focusAreas != null) {
            for (String area : focusAreas) {
                if (area == null || area.isBlank()) {
                    continue;
                }
                suggestions.add("复盘 " + area + " 的核心概念、常见追问和项目落地场景");
                suggestions.add("针对 " + area + " 做 2-3 道专项题，重点补齐答题结构和细节");
            }
        }
        if (averageScore < 70) {
            suggestions.add("先用中低难度题重建答题框架，再逐步提升到高频中档题");
        } else {
            suggestions.add("在保持准确率的基础上，多练习取舍分析和项目化表达");
        }
        return suggestions.stream().limit(4).toList();
    }

    private List<RecommendedPracticeVO> buildRecommendedPractices(String positionId, List<String> focusAreas) {
        if (positionId == null) {
            return List.of();
        }
        Set<String> focusSet = focusAreas == null ? Set.of() : focusAreas.stream().filter(item -> item != null && !item.isBlank()).collect(Collectors.toSet());
        return questionService.getQuestionsByPosition(positionId).stream()
                .sorted(Comparator.comparingInt((QuestionEntity question) -> practicePriority(question, focusSet)).reversed())
                .limit(3)
                .map(question -> RecommendedPracticeVO.builder()
                        .id(question.getId())
                        .questionText(question.getQuestionText())
                        .questionType(question.getQuestionType())
                        .difficulty(question.getDifficulty())
                        .knowledgeTags(question.getKeywordList())
                        .recommendationReason(buildPracticeReason(question, focusSet))
                        .build())
                .toList();
    }

    private List<LearningResourceVO> buildLearningResources(String positionId, List<String> focusAreas, double averageScore) {
        if (positionId == null) {
            return List.of();
        }
        List<String> topics = new ArrayList<>(positionProfileService.resolveLearningResourceTopics(positionId, null));
        if (focusAreas != null) {
            topics.addAll(focusAreas);
        }
        String positionCode = positionProfileService.resolvePositionCode(positionId, null);
        return topics.stream()
                .filter(item -> item != null && !item.isBlank())
                .distinct()
                .limit(4)
                .map(topic -> LearningResourceVO.builder()
                        .title(topic + " 学习资料")
                        .topic(topic)
                        .resourceType(averageScore < 70 ? "基础巩固" : "专项突破")
                        .description(buildLearningResourceDescription(topic, averageScore))
                        .referencePath(buildKnowledgeDocPath(positionCode, topic))
                        .recommendationReason(buildLearningResourceReason(topic, focusAreas))
                        .build())
                .toList();
    }

    private List<PracticePlanItemVO> buildPracticePlan(String positionId, List<String> focusAreas, double averageScore) {
        if (positionId == null) {
            return List.of();
        }
        List<String> topics = new ArrayList<>(positionProfileService.resolveLearningResourceTopics(positionId, null));
        if (focusAreas != null) {
            topics.addAll(focusAreas);
        }
        List<String> orderedTopics = topics.stream()
                .filter(item -> item != null && !item.isBlank())
                .distinct()
                .limit(3)
                .toList();
        if (orderedTopics.isEmpty()) {
            orderedTopics = List.of("岗位核心考点");
        }
        List<PracticePlanItemVO> plan = new ArrayList<>();
        for (int i = 0; i < orderedTopics.size(); i++) {
            String topic = orderedTopics.get(i);
            plan.add(PracticePlanItemVO.builder()
                    .day(i + 1)
                    .title("Day " + (i + 1) + " · " + topic)
                    .focus(topic)
                    .actions(buildPracticeActions(topic, averageScore, i))
                    .expectedOutcome(buildExpectedOutcome(topic, averageScore))
                    .build());
        }
        return plan;
    }

    private int practicePriority(QuestionEntity question, Set<String> focusAreas) {
        if (question == null) {
            return 0;
        }
        int score = 0;
        if (focusAreas.contains(question.getQuestionType())) {
            score += 4;
        }
        if (question.getKeywordList() != null) {
            for (String keyword : question.getKeywordList()) {
                if (focusAreas.contains(keyword)) {
                    score += 2;
                }
            }
        }
        score += Math.max(0, 6 - (question.getDifficulty() == null ? 3 : question.getDifficulty()));
        return score;
    }

    private String buildPracticeReason(QuestionEntity question, Set<String> focusAreas) {
        if (question == null) {
            return "建议继续完成专项训练。";
        }
        if (focusAreas.contains(question.getQuestionType())) {
            return "这道题与您当前的薄弱题型直接相关，适合优先补强。";
        }
        if (question.getKeywordList() != null) {
            for (String keyword : question.getKeywordList()) {
                if (focusAreas.contains(keyword)) {
                    return "这道题覆盖了您近期需要强化的知识点，适合用于针对性复练。";
                }
            }
        }
        return "这道题属于当前岗位的高频考点，可用于继续稳固核心能力。";
    }

    private InterviewSessionEntity getLatestCompletedSession(String userId) {
        List<InterviewSessionEntity> sessions = interviewSessionService.getSessionsByUserId(userId);
        return sessions.stream()
                .filter(session -> session != null && "completed".equalsIgnoreCase(session.getStatus()))
                .sorted(Comparator.comparing(InterviewSessionEntity::getUpdateTime, Comparator.nullsLast(Comparator.reverseOrder())))
                .findFirst()
                .orElse(null);
    }

    private String buildLearningResourceDescription(String topic, double averageScore) {
        if (averageScore < 60) {
            return "先围绕该主题建立标准答题框架，补齐定义、原理、实现和常见追问。";
        }
        if (averageScore < 75) {
            return "建议将该主题与项目经验结合，练习从原理到落地的完整表达。";
        }
        return "在已有基础上继续提升该主题的细节深度、对比分析和工程取舍表达。";
    }

    private String buildLearningResourceReason(String topic, List<String> focusAreas) {
        if (focusAreas != null && focusAreas.stream().anyMatch(topic::equals)) {
            return "该主题直接来自您近期的薄弱项，优先级最高。";
        }
        return "该主题属于当前岗位画像中的高频能力点，适合作为系统复习主线。";
    }

    private String buildKnowledgeDocPath(String positionCode, String topic) {
        String normalized = topic.toLowerCase();
        String fileName = "common-interview-points.md";
        if (normalized.contains("项目") || normalized.contains("表达") || normalized.contains("沟通")) {
            fileName = "sample-answers.md";
        } else if (normalized.contains("基础") || normalized.contains("原理") || normalized.contains("工程化")
                || normalized.contains("jvm") || normalized.contains("spring") || normalized.contains("浏览器")
                || normalized.contains("算法") || normalized.contains("数据结构")) {
            fileName = "core-tech-stack.md";
        }
        return "submission/knowledge/" + positionCode + "/" + fileName;
    }

    private List<String> buildPracticeActions(String topic, double averageScore, int index) {
        List<String> actions = new ArrayList<>();
        actions.add("复盘 " + topic + " 的核心概念与高频追问");
        actions.add("围绕 " + topic + " 完成 2 道专项题，并记录卡壳点");
        if (index == 0 || averageScore < 70) {
            actions.add("用 STAR 或“定义-原理-方案-取舍”结构口述 1 次答案");
        } else {
            actions.add("将 " + topic + " 和项目案例绑定，补齐数据、复杂度或工程取舍细节");
        }
        return actions;
    }

    private String buildExpectedOutcome(String topic, double averageScore) {
        if (averageScore < 70) {
            return "能够在 2 分钟内结构化说明 " + topic + " 的核心原理和标准解法。";
        }
        return "能够把 " + topic + " 讲到实现细节、风险点和项目落地层面。";
    }

    private GrowthCurvePointVO toCurvePoint(InterviewSessionEntity session) {
        Date time = toDate(session.getEndTime() != null ? session.getEndTime() : session.getCreateTime());
        double duration = 0D;
        if (session.getStartTime() != null && session.getEndTime() != null) {
            duration = Duration.between(session.getStartTime(), session.getEndTime()).toMinutes();
        }
        return GrowthCurvePointVO.builder()
                .time(time)
                .score(session.getTotalScore())
                .status(session.getStatus())
                .durationMinutes(duration)
                .build();
    }

    public List<InterviewHistoryDetailVO> getDetailedInterviewHistory(String userId) {
        List<InterviewSessionEntity> sessions = interviewSessionService.getSessionsByUserId(userId);
        return sessions.stream()
                .map(this::buildInterviewHistoryDetail)
                .collect(Collectors.toList());
    }

    private InterviewHistoryDetailVO buildInterviewHistoryDetail(InterviewSessionEntity session) {
        List<InterviewAnswerEntity> answers = interviewAnswerService.getAnswersBySessionId(session.getId());
        int totalQuestions = answers.size();
        int answeredQuestions = (int) answers.stream().filter(a -> a.getScore() != null).count();
        double averageScore = answers.stream()
                .filter(a -> a.getScore() != null)
                .mapToInt(InterviewAnswerEntity::getScore)
                .average()
                .orElse(0.0);

        return InterviewHistoryDetailVO.builder()
                .session(session)
                .answers(answers)
                .positionName(session.getPositionId()) // 可以后续扩展为岗位名称
                .totalQuestions(totalQuestions)
                .answeredQuestions(answeredQuestions)
                .averageScore(averageScore)
                .build();
    }

    private Date toDate(LocalDateTime localDateTime) {
        return localDateTime == null ? null : Date.from(localDateTime.atZone(ZoneId.systemDefault()).toInstant());
    }
}
