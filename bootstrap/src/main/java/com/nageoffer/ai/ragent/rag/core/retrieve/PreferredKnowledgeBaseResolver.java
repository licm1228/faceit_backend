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

package com.nageoffer.ai.ragent.rag.core.retrieve;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Locale;

/**
 * 基于岗位/技术关键词推断优先检索的知识库 collection。
 * <p>
 * 当前先使用静态规则，不引入额外 schema 依赖，方便先跑通
 * Web / Java / Python 三个岗位的定向检索。
 */
@Component
public class PreferredKnowledgeBaseResolver {

    public List<String> resolvePreferredCollections(String question) {
        if (question == null || question.isBlank()) {
            return List.of();
        }

        String normalized = question.toLowerCase(Locale.ROOT);

        if (matchesAny(normalized, "前端", "web", "react", "vue", "javascript", "typescript", "浏览器")) {
            return List.of("web");
        }

        if (matchesAny(normalized, "java", "spring", "springboot", "spring boot", "jvm", "mysql", "redis", "mq")) {
            return List.of("javabackend");
        }

        if (matchesAny(normalized, "python", "算法", "leetcode", "dp", "动态规划", "二叉树", "链表")) {
            return List.of("python");
        }

        return List.of();
    }

    private boolean matchesAny(String question, String... keywords) {
        for (String keyword : keywords) {
            if (question.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
}
