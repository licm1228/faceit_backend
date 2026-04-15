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

package com.nageoffer.ai.ragent.mcp.executor;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.nageoffer.ai.ragent.mcp.core.MCPToolDefinition;
import com.nageoffer.ai.ragent.mcp.core.MCPToolExecutor;
import com.nageoffer.ai.ragent.mcp.core.MCPToolRequest;
import com.nageoffer.ai.ragent.mcp.core.MCPToolResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Component
public class InterviewSelectQuestionMCPExecutor implements MCPToolExecutor {

    private static final String TOOL_ID = "interview-select-question";

    private final Gson gson = new Gson();

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${faceit.backend.base-url:http://localhost:9090/api/ragent}")
    private String backendBaseUrl;

    @Override
    public MCPToolDefinition getToolDefinition() {
        Map<String, MCPToolDefinition.ParameterDef> parameters = new LinkedHashMap<>();
        parameters.put("positionId", MCPToolDefinition.ParameterDef.builder()
                .description("岗位ID，例如 pos_java_001、pos_python_001、pos_web_001")
                .type("string")
                .required(true)
                .build());
        parameters.put("difficulty", MCPToolDefinition.ParameterDef.builder()
                .description("题目难度，1 到 5，可选")
                .type("integer")
                .required(false)
                .build());

        return MCPToolDefinition.builder()
                .toolId(TOOL_ID)
                .description("根据岗位选择一条模拟面试题目，并返回题目与相关知识片段，适合发起 Java、Python 算法、前端模拟面试")
                .parameters(parameters)
                .requireUserId(false)
                .build();
    }

    @Override
    public MCPToolResponse execute(MCPToolRequest request) {
        String positionId = request.getStringParameter("positionId");
        Number difficulty = request.getParameter("difficulty");
        if (positionId == null || positionId.isBlank()) {
            return MCPToolResponse.error(TOOL_ID, "INVALID_PARAMS", "请提供岗位ID positionId");
        }

        try {
            String url = UriComponentsBuilder.fromHttpUrl(backendBaseUrl)
                    .path("/mcp/interview/select-question")
                    .queryParam("positionId", positionId)
                    .queryParamIfPresent("difficulty", difficulty == null ? java.util.Optional.empty() : java.util.Optional.of(difficulty))
                    .toUriString();

            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                return MCPToolResponse.error(TOOL_ID, "REMOTE_ERROR", "面试题检索接口调用失败");
            }

            JsonObject root = gson.fromJson(response.getBody(), JsonObject.class);
            JsonObject data = root != null && root.has("data") && root.get("data").isJsonObject()
                    ? root.getAsJsonObject("data")
                    : null;
            if (data == null) {
                return MCPToolResponse.error(TOOL_ID, "INVALID_RESPONSE", "面试题检索接口返回为空");
            }
            if (data.has("error")) {
                return MCPToolResponse.error(
                        TOOL_ID,
                        "BUSINESS_ERROR",
                        getAsString(data, "error") + " " + getAsString(data, "message")
                );
            }

            String text = formatResponse(data);
            Map<String, Object> structuredData = new LinkedHashMap<>();
            structuredData.put("positionId", positionId);
            structuredData.put("difficulty", difficulty);
            structuredData.put("raw", gson.fromJson(data, Map.class));
            return MCPToolResponse.success(TOOL_ID, text, structuredData);
        } catch (RestClientException e) {
            log.error("调用面试题 MCP 后端接口失败, positionId={}", positionId, e);
            return MCPToolResponse.error(TOOL_ID, "REMOTE_ERROR", "调用面试题服务失败: " + e.getMessage());
        } catch (Exception e) {
            log.error("处理面试题 MCP 响应失败, positionId={}", positionId, e);
            return MCPToolResponse.error(TOOL_ID, "EXECUTION_ERROR", "处理面试题结果失败: " + e.getMessage());
        }
    }

    private String formatResponse(JsonObject data) {
        JsonObject question = data.has("question") && data.get("question").isJsonObject()
                ? data.getAsJsonObject("question")
                : null;
        JsonArray relatedContent = data.has("relatedContent") && data.get("relatedContent").isJsonArray()
                ? data.getAsJsonArray("relatedContent")
                : new JsonArray();

        StringBuilder sb = new StringBuilder();
        sb.append("【模拟面试题】\n\n");
        if (question != null) {
            sb.append("岗位ID: ").append(getAsString(question, "positionId")).append("\n");
            sb.append("难度: ").append(getAsString(question, "difficulty")).append("\n");
            sb.append("题目: ").append(getAsString(question, "questionText")).append("\n");
            String referenceAnswer = getAsString(question, "referenceAnswer");
            if (!referenceAnswer.isBlank()) {
                sb.append("\n【参考答案】\n").append(referenceAnswer).append("\n");
            }
        }

        if (!relatedContent.isEmpty()) {
            sb.append("\n【相关知识片段】\n");
            int index = 1;
            for (JsonElement element : relatedContent) {
                if (!element.isJsonObject()) {
                    continue;
                }
                JsonObject item = element.getAsJsonObject();
                String content = getAsString(item, "content");
                String score = getAsString(item, "score");
                if (content.isBlank()) {
                    continue;
                }
                sb.append(index++).append(". ");
                if (!score.isBlank()) {
                    sb.append("(score=").append(score).append(") ");
                }
                sb.append(content).append("\n");
            }
        }

        return sb.toString().trim();
    }

    private String getAsString(JsonObject jsonObject, String key) {
        if (jsonObject == null || !jsonObject.has(key) || jsonObject.get(key).isJsonNull()) {
            return "";
        }
        return jsonObject.get(key).getAsString();
    }
}
