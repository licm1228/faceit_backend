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

package com.nageoffer.ai.ragent.interview.controller;

import com.nageoffer.ai.ragent.framework.convention.Result;
import com.nageoffer.ai.ragent.framework.web.Results;
import com.nageoffer.ai.ragent.interview.controller.request.InterviewChatConfigResolveRequest;
import com.nageoffer.ai.ragent.interview.controller.request.InterviewChatStartRequest;
import com.nageoffer.ai.ragent.interview.controller.request.InterviewChatTurnRequest;
import com.nageoffer.ai.ragent.interview.service.InterviewChatService;
import com.nageoffer.ai.ragent.rag.controller.request.ConversationUpdateRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;

@RestController
@RequestMapping("/interview/chat")
@RequiredArgsConstructor
public class InterviewChatController {

    private final InterviewChatService interviewChatService;

    @PostMapping("/resolve-config")
    public Result<Map<String, Object>> resolveConfig(@RequestBody InterviewChatConfigResolveRequest request) {
        return Results.success(interviewChatService.resolveConfig(request.getContent()));
    }

    @PostMapping("/start")
    public Result<Map<String, Object>> start(@RequestBody InterviewChatStartRequest request) {
        return Results.success(interviewChatService.startInterview(request));
    }

    @PostMapping("/sessions/{sessionId}/turn")
    public Result<Map<String, Object>> turn(@PathVariable String sessionId, @RequestBody InterviewChatTurnRequest request) {
        return Results.success(interviewChatService.submitTurn(sessionId, request.getContent()));
    }

    @PostMapping(value = "/sessions/{sessionId}/turn/stream", produces = "text/event-stream;charset=UTF-8")
    public SseEmitter streamTurn(@PathVariable String sessionId, @RequestBody InterviewChatTurnRequest request) {
        SseEmitter emitter = new SseEmitter(0L);
        interviewChatService.streamTurn(sessionId, request.getContent(), emitter);
        return emitter;
    }

    @GetMapping("/sessions/{sessionId}")
    public Result<Map<String, Object>> getSession(@PathVariable String sessionId) {
        return Results.success(interviewChatService.getSessionState(sessionId));
    }

    @GetMapping("/sessions/{sessionId}/report")
    public Result<Map<String, Object>> getReport(@PathVariable String sessionId) {
        return Results.success(interviewChatService.getReport(sessionId));
    }

    @PutMapping("/sessions/{sessionId}")
    public Result<Void> rename(@PathVariable String sessionId, @RequestBody ConversationUpdateRequest request) {
        interviewChatService.renameSession(sessionId, request.getTitle());
        return Results.success();
    }

    @DeleteMapping("/sessions/{sessionId}")
    public Result<Void> delete(@PathVariable String sessionId) {
        interviewChatService.deleteSession(sessionId);
        return Results.success();
    }
}
