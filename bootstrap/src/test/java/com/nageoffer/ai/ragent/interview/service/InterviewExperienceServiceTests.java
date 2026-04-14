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

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nageoffer.ai.ragent.interview.entity.QuestionEntity;
import com.nageoffer.ai.ragent.infra.chat.LLMService;
import org.junit.jupiter.api.Test;

import java.util.Map;
import java.util.concurrent.Executor;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class InterviewExperienceServiceTests {

    @Test
    void evaluateAnswerShouldPopulateLiveFeedbackAndLowSignalMode() {
        LLMService llmService = mock(LLMService.class);
        PositionProfileService positionProfileService = mock(PositionProfileService.class);
        when(positionProfileService.resolveInterviewFocus(anyString(), org.mockito.ArgumentMatchers.isNull(), org.mockito.ArgumentMatchers.isNull()))
                .thenReturn("数据结构、算法复杂度、编码实现");
        when(positionProfileService.resolveEvaluationWeights(anyString(), org.mockito.ArgumentMatchers.isNull()))
                .thenReturn(Map.of(
                        "technical", 30,
                        "positionMatch", 25,
                        "logic", 20,
                        "knowledge", 25
                ));
        when(llmService.chat(anyString())).thenReturn(
                "评分：28\n" +
                        "技术准确性：8\n" +
                        "岗位匹配度：6\n" +
                        "逻辑清晰度：7\n" +
                        "知识覆盖度：7\n" +
                        "回答信号：low\n" +
                        "下一步动作：move_on\n" +
                        "即时反馈：这题先记到这里，我们继续下一题。\n" +
                        "实时反馈：这题先记到这里，我们继续下一题。\n" +
                        "反馈：回答信息量很低，暂时看不出你是否真正理解平衡二叉树的判断条件。\n" +
                        "书面反馈：回答信息量很低，核心定义和判断方法都没有建立起来。\n" +
                        "建议：至少先说出高度差不超过 1 这个关键条件，再考虑递归写法。\n" +
                        "已覆盖要点：无\n" +
                        "缺失要点：平衡定义, 高度差, 递归返回值\n" +
                        "避免重复：完整复述参考答案\n" +
                        "继续追问：否"
        );

        AIEvaluationService service = new AIEvaluationService(llmService, new ObjectMapper(), positionProfileService);
        QuestionEntity question = new QuestionEntity();
        question.setPositionId("pos_python_001");
        question.setQuestionText("如何判断一棵树是否是平衡二叉树？");
        question.setReferenceAnswer("自底向上递归，若高度差大于 1 则返回 -1。");

        Map<String, Object> evaluation = service.evaluateAnswer(question, "不知道");

        assertEquals("low", evaluation.get("answerSignal"));
        assertEquals("move_on", evaluation.get("feedbackMode"));
        assertEquals("", evaluation.get("followUpIntent"));
        assertEquals("这题先记到这里，我们继续下一题。", evaluation.get("liveFeedback"));
        assertEquals("回答信息量很低，核心定义和判断方法都没有建立起来。", evaluation.get("writtenFeedback"));
        assertFalse((Boolean) evaluation.get("shouldFollowUp"));
    }

    @Test
    void evaluateAnswerShouldDefaultGoodAnswersToMoveOn() {
        LLMService llmService = mock(LLMService.class);
        PositionProfileService positionProfileService = mock(PositionProfileService.class);
        when(positionProfileService.resolveInterviewFocus(anyString(), org.mockito.ArgumentMatchers.isNull(), org.mockito.ArgumentMatchers.isNull()))
                .thenReturn("数据结构、算法复杂度、编码实现");
        when(positionProfileService.resolveEvaluationWeights(anyString(), org.mockito.ArgumentMatchers.isNull()))
                .thenReturn(Map.of(
                        "technical", 30,
                        "positionMatch", 25,
                        "logic", 20,
                        "knowledge", 25
                ));
        when(llmService.chat(anyString())).thenReturn(
                "评分：88\n" +
                        "技术准确性：26\n" +
                        "岗位匹配度：22\n" +
                        "逻辑清晰度：20\n" +
                        "知识覆盖度：18\n" +
                        "回答信号：good\n" +
                        "下一步动作：move_on\n" +
                        "即时反馈：这个回答主干已经比较完整，我们继续下一题。\n" +
                        "反馈：核心思路、递归返回值和复杂度都回答到了。\n" +
                        "建议：后续可以把提前终止和边界条件说得更顺一点。\n" +
                        "继续追问：否"
        );

        AIEvaluationService service = new AIEvaluationService(llmService, new ObjectMapper(), positionProfileService);
        QuestionEntity question = new QuestionEntity();
        question.setPositionId("pos_python_001");
        question.setQuestionText("如何判断一棵树是否是平衡二叉树？");
        question.setReferenceAnswer("自底向上递归，若高度差大于 1 则返回 -1。");

        Map<String, Object> evaluation = service.evaluateAnswer(question, "可以递归返回高度，发现子树不平衡就返回 -1。");

        assertEquals("good", evaluation.get("answerSignal"));
        assertEquals("move_on", evaluation.get("feedbackMode"));
        assertFalse((Boolean) evaluation.get("shouldFollowUp"));
        assertEquals("这个回答主干已经比较完整，我们继续下一题。", evaluation.get("instantFeedback"));
    }

    @Test
    void interviewChatShouldNotForceFollowUpForLowSignalAnswers() {
        InterviewChatService service = new InterviewChatService(
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                new ObjectMapper(),
                null,
                null,
                directExecutor(),
                directExecutor()
        );

        InterviewChatService.RuntimeState runtimeState = new InterviewChatService.RuntimeState();
        runtimeState.setFollowUpCount(0);

        assertTrue(service.isLowSignalAnswer("不知道", "low"));
        assertFalse(service.shouldAskFollowUp(Map.of("answerSignal", "low", "score", 28), runtimeState, true, "move_on"));
        assertFalse(service.shouldAskFollowUp(Map.of("answerSignal", "low", "score", 28), runtimeState, true, ""));
    }

    @Test
    void evaluateAnswerShouldIgnoreLegacyRedirectModeFromModelOutput() {
        LLMService llmService = mock(LLMService.class);
        PositionProfileService positionProfileService = mock(PositionProfileService.class);
        when(positionProfileService.resolveInterviewFocus(anyString(), org.mockito.ArgumentMatchers.isNull(), org.mockito.ArgumentMatchers.isNull()))
                .thenReturn("数据结构、算法复杂度、编码实现");
        when(positionProfileService.resolveEvaluationWeights(anyString(), org.mockito.ArgumentMatchers.isNull()))
                .thenReturn(Map.of(
                        "technical", 30,
                        "positionMatch", 25,
                        "logic", 20,
                        "knowledge", 25
                ));
        when(llmService.chat(anyString())).thenReturn(
                "评分：28\n" +
                        "技术准确性：8\n" +
                        "岗位匹配度：6\n" +
                        "逻辑清晰度：7\n" +
                        "知识覆盖度：7\n" +
                        "回答信号：low\n" +
                        "下一步动作：redirect\n" +
                        "即时反馈：完全不会，需降阶重问\n" +
                        "实时反馈：完全不会，需降阶重问\n" +
                        "反馈：回答信息量很低。\n" +
                        "建议：建议先补基础。\n" +
                        "继续追问：是\n" +
                        "追问意图：clarify_definition\n" +
                        "追问聚焦点：当前题目的最小关键概念\n" +
                        "追问问题：那你听说过 Proxy 能用来拦截对象操作吗？"
        );

        AIEvaluationService service = new AIEvaluationService(llmService, new ObjectMapper(), positionProfileService);
        QuestionEntity question = new QuestionEntity();
        question.setPositionId("pos_python_001");
        question.setQuestionText("如何判断一棵树是否是平衡二叉树？");
        question.setReferenceAnswer("自底向上递归，若高度差大于 1 则返回 -1。");

        Map<String, Object> evaluation = service.evaluateAnswer(question, "不知道");

        assertEquals("low", evaluation.get("answerSignal"));
        assertEquals("move_on", evaluation.get("feedbackMode"));
        assertFalse((Boolean) evaluation.get("shouldFollowUp"));
        assertEquals("这题我先记到这里，我们继续下一题。", evaluation.get("liveFeedback"));
        assertEquals("这题我先记到这里，我们继续下一题。", evaluation.get("instantFeedback"));
    }

    private Executor directExecutor() {
        return Runnable::run;
    }
}
