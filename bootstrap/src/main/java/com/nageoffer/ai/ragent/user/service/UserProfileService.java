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
import com.nageoffer.ai.ragent.interview.service.QuestionService;
import com.nageoffer.ai.ragent.user.controller.vo.GrowthCurvePointVO;
import com.nageoffer.ai.ragent.user.controller.vo.InterviewHistoryDetailVO;
import com.nageoffer.ai.ragent.user.controller.vo.RecommendationVO;
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
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final InterviewSessionService interviewSessionService;
    private final InterviewAnswerService interviewAnswerService;
    private final QuestionService questionService;

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

        return RecommendationVO.builder()
                .summary(summary)
                .focusAreas(focusAreas)
                .nextStep(nextStep)
                .averageScore(profile.getAverageScore())
                .completedSessions(profile.getCompletedSessions())
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
