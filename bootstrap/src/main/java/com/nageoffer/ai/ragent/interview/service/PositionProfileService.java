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

import com.nageoffer.ai.ragent.interview.entity.PositionEntity;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class PositionProfileService {

    public PositionEntity enrich(PositionEntity entity) {
        if (entity == null) {
            return null;
        }
        PositionDefaults defaults = resolveDefaults(entity.getId(), entity.getName());
        entity.setRequiredSkills(toDisplaySkills(entity.getRequiredSkills(), defaults.requiredSkills()));
        if (isBlank(entity.getInterviewFocus())) {
            entity.setInterviewFocus(defaults.interviewFocus());
        }
        entity.setEvaluationWeights(defaults.evaluationWeights());
        entity.setQuestionTypePlan(defaults.questionTypePlan());
        entity.setPreferredKnowledgeCollections(defaults.preferredKnowledgeCollections());
        return entity;
    }

    public Map<String, Integer> resolveEvaluationWeights(String positionId, String positionName) {
        return resolveDefaults(positionId, positionName).evaluationWeights();
    }

    public String resolveInterviewFocus(String positionId, String positionName, String fallback) {
        if (!isBlank(fallback)) {
            return fallback;
        }
        return resolveDefaults(positionId, positionName).interviewFocus();
    }

    public List<String> resolveQuestionTypePlan(String positionId, String positionName) {
        return resolveDefaults(positionId, positionName).questionTypePlan();
    }

    public List<String> resolvePreferredKnowledgeCollections(String positionId, String positionName) {
        return resolveDefaults(positionId, positionName).preferredKnowledgeCollections();
    }

    public List<String> resolveLearningResourceTopics(String positionId, String positionName) {
        return resolveDefaults(positionId, positionName).learningResourceTopics();
    }

    public String resolvePositionCode(String positionId, String positionName) {
        return resolveDefaults(positionId, positionName).positionCode();
    }

    public String resolveQuestionTypeDisplayName(String questionType) {
        String normalized = normalizeToken(questionType);
        return switch (normalized) {
            case "technical", "技术题", "技术问题" -> "技术知识";
            case "scenario", "场景题" -> "场景题";
            case "project", "项目题" -> "项目深挖";
            case "behavior", "行为题" -> "行为题";
            case "algorithm", "算法题" -> "算法题";
            case "advanced" -> "综合进阶";
            default -> isBlank(questionType) ? "综合题" : questionType;
        };
    }

    private PositionDefaults resolveDefaults(String positionId, String positionName) {
        String normalizedId = positionId == null ? "" : positionId.toLowerCase();
        String normalizedName = positionName == null ? "" : positionName.toLowerCase();
        if (normalizedId.contains("java") || normalizedName.contains("java")) {
            return new PositionDefaults(
                    "java-backend",
                    "Java, Spring Boot, MySQL, Redis, 并发编程, JVM, 系统设计",
                    "重点关注基础扎实度、并发与 JVM 原理、数据库与缓存设计、项目中的取舍表达，题型按技术题、场景题、项目深挖、行为题推进。",
                    orderedWeights(35, 20, 25, 20),
                    List.of("technical", "scenario", "project", "behavior", "technical"),
                    List.of("javabackend"),
                    List.of("Java 基础与 JVM", "Spring 与数据库设计", "并发场景排障", "项目表达与行为沟通")
            );
        }
        if (normalizedId.contains("python") || normalizedName.contains("python") || normalizedName.contains("算法")) {
            return new PositionDefaults(
                    "python-algorithm",
                    "Python, 数据结构, 算法复杂度, NumPy, Pandas, 机器学习, 特征工程",
                    "重点关注算法思路、复杂度分析、数据处理细节和业务落地能力，优先使用算法题、场景题和项目题形成清晰岗位画像。",
                    orderedWeights(25, 20, 20, 35),
                    List.of("algorithm", "algorithm", "scenario", "project", "behavior"),
                    List.of("python"),
                    List.of("算法与复杂度分析", "Python 数据结构实现", "模型评估与特征工程", "算法项目复盘表达")
            );
        }
        if (normalizedId.contains("web") || normalizedName.contains("前端")) {
            return new PositionDefaults(
                    "web-frontend",
                    "HTML5, CSS3, JavaScript, React, Vue, 浏览器原理, 性能优化",
                    "重点关注页面工程化、浏览器与渲染原理、性能优化、跨端兼容与交互表达，题型按技术基础、性能场景、项目深挖、行为题切换。",
                    orderedWeights(30, 25, 20, 25),
                    List.of("technical", "scenario", "project", "behavior", "technical"),
                    List.of("web"),
                    List.of("浏览器原理与渲染", "React/Vue 工程化", "前端性能优化", "复杂交互项目表达")
            );
        }
        return new PositionDefaults(
                "general",
                "计算机基础, 数据结构, 项目经验, 问题分析",
                "重点关注核心基础、项目匹配度和沟通逻辑",
                orderedWeights(30, 25, 20, 25),
                List.of("technical", "project", "scenario", "behavior", "technical"),
                List.of("rag_default_store"),
                List.of("计算机基础", "项目表达", "问题分析")
        );
    }

    private Map<String, Integer> orderedWeights(int technical, int positionMatch, int logic, int knowledge) {
        Map<String, Integer> weights = new LinkedHashMap<>();
        weights.put("technical", technical);
        weights.put("positionMatch", positionMatch);
        weights.put("logic", logic);
        weights.put("knowledge", knowledge);
        return weights;
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private String normalizeToken(String value) {
        return value == null ? "" : value.trim().toLowerCase(Locale.ROOT);
    }

    private String toDisplaySkills(String rawSkills, String fallback) {
        String source = isBlank(rawSkills) ? fallback : rawSkills;
        if (isBlank(source)) {
            return "";
        }
        if (!source.trim().startsWith("[")) {
            return source;
        }
        return source.replace("[", "")
                .replace("]", "")
                .replace("\"", "")
                .replace("'", "")
                .replaceAll("\\s+", " ")
                .trim();
    }

    private record PositionDefaults(
            String positionCode,
            String requiredSkills,
            String interviewFocus,
            Map<String, Integer> evaluationWeights,
            List<String> questionTypePlan,
            List<String> preferredKnowledgeCollections,
            List<String> learningResourceTopics
    ) {
    }
}
