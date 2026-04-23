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

package com.nageoffer.ai.ragent.infra.rerank;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.nageoffer.ai.ragent.framework.convention.RetrievedChunk;
import com.nageoffer.ai.ragent.infra.config.AIModelProperties;
import com.nageoffer.ai.ragent.infra.enums.ModelCapability;
import com.nageoffer.ai.ragent.infra.enums.ModelProvider;
import com.nageoffer.ai.ragent.infra.http.HttpMediaTypes;
import com.nageoffer.ai.ragent.infra.http.ModelClientErrorType;
import com.nageoffer.ai.ragent.infra.http.ModelClientException;
import com.nageoffer.ai.ragent.infra.http.ModelUrlResolver;
import com.nageoffer.ai.ragent.infra.model.ModelTarget;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
public class SiliconFlowRerankClient implements RerankClient {

    private final Gson gson = new Gson();
    private final OkHttpClient httpClient;

    @Override
    public String provider() {
        return ModelProvider.SILICON_FLOW.getId();
    }

    @Override
    public List<RetrievedChunk> rerank(String query, List<RetrievedChunk> candidates, int topN, ModelTarget target) {
        if (candidates == null || candidates.isEmpty()) {
            return List.of();
        }

        List<RetrievedChunk> dedup = deduplicate(candidates);
        if (topN <= 0) {
            return List.of();
        }
        if (dedup.size() <= topN) {
            return dedup;
        }

        return doRerank(query, dedup, topN, target);
    }

    private List<RetrievedChunk> doRerank(String query, List<RetrievedChunk> candidates, int topN, ModelTarget target) {
        AIModelProperties.ProviderConfig provider = requireProvider(target);

        JsonObject body = new JsonObject();
        body.addProperty("model", requireModel(target));
        body.addProperty("query", query == null ? "" : query);
        body.addProperty("top_n", topN);
        body.addProperty("return_documents", true);

        JsonArray documents = new JsonArray();
        for (RetrievedChunk each : candidates) {
            documents.add(each.getText() == null ? "" : each.getText());
        }
        body.add("documents", documents);

        Request request = new Request.Builder()
                .url(resolveUrl(provider, target))
                .post(RequestBody.create(body.toString(), HttpMediaTypes.JSON))
                .addHeader("Content-Type", HttpMediaTypes.JSON_UTF8_HEADER)
                .addHeader("Authorization", "Bearer " + provider.getApiKey())
                .build();

        JsonObject root;
        try (Response response = httpClient.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                String errBody = readBody(response.body());
                log.warn("SiliconFlow rerank 请求失败: status={}, body={}", response.code(), errBody);
                throw new ModelClientException(
                        "SiliconFlow rerank 请求失败: HTTP " + response.code(),
                        classifyStatus(response.code()),
                        response.code()
                );
            }
            root = parseJsonBody(response.body());
        } catch (IOException e) {
            throw new ModelClientException("SiliconFlow rerank 请求失败: " + e.getMessage(), ModelClientErrorType.NETWORK_ERROR, null, e);
        }

        JsonArray results = root == null ? null : root.getAsJsonArray("results");
        if (results == null || results.isEmpty()) {
            throw new ModelClientException("SiliconFlow rerank results 为空", ModelClientErrorType.INVALID_RESPONSE, null);
        }

        List<RetrievedChunk> reranked = new ArrayList<>();
        for (JsonElement element : results) {
            if (!element.isJsonObject()) {
                continue;
            }
            JsonObject item = element.getAsJsonObject();
            if (!item.has("index")) {
                continue;
            }
            int index = item.get("index").getAsInt();
            if (index < 0 || index >= candidates.size()) {
                continue;
            }

            RetrievedChunk source = candidates.get(index);
            float score = item.has("relevance_score") && !item.get("relevance_score").isJsonNull()
                    ? item.get("relevance_score").getAsFloat()
                    : source.getScore();
            reranked.add(new RetrievedChunk(source.getId(), source.getText(), score));
            if (reranked.size() >= topN) {
                break;
            }
        }

        if (reranked.size() < topN) {
            appendFallbackCandidates(candidates, reranked, topN);
        }
        return reranked.stream()
                .sorted(Comparator.comparing(RetrievedChunk::getScore, Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(topN)
                .toList();
    }

    private List<RetrievedChunk> deduplicate(List<RetrievedChunk> candidates) {
        List<RetrievedChunk> dedup = new ArrayList<>(candidates.size());
        Set<String> seen = new HashSet<>();
        for (RetrievedChunk candidate : candidates) {
            String key = candidate.getId() == null ? candidate.getText() : candidate.getId();
            if (seen.add(key)) {
                dedup.add(candidate);
            }
        }
        return dedup;
    }

    private void appendFallbackCandidates(List<RetrievedChunk> candidates, List<RetrievedChunk> reranked, int topN) {
        Set<String> seen = new HashSet<>();
        for (RetrievedChunk chunk : reranked) {
            seen.add(chunk.getId() == null ? chunk.getText() : chunk.getId());
        }
        for (RetrievedChunk candidate : candidates) {
            String key = candidate.getId() == null ? candidate.getText() : candidate.getId();
            if (seen.add(key)) {
                reranked.add(candidate);
            }
            if (reranked.size() >= topN) {
                break;
            }
        }
    }

    private AIModelProperties.ProviderConfig requireProvider(ModelTarget target) {
        if (target == null || target.provider() == null) {
            throw new IllegalStateException("SiliconFlow rerank provider config is missing");
        }
        return target.provider();
    }

    private String requireModel(ModelTarget target) {
        if (target == null || target.candidate() == null || target.candidate().getModel() == null) {
            throw new IllegalStateException("SiliconFlow rerank model name is missing");
        }
        return target.candidate().getModel();
    }

    private String resolveUrl(AIModelProperties.ProviderConfig provider, ModelTarget target) {
        return ModelUrlResolver.resolveUrl(provider, target.candidate(), ModelCapability.RERANK);
    }

    private JsonObject parseJsonBody(ResponseBody body) throws IOException {
        if (body == null) {
            throw new ModelClientException("SiliconFlow rerank 响应为空", ModelClientErrorType.INVALID_RESPONSE, null);
        }
        return gson.fromJson(body.string(), JsonObject.class);
    }

    private String readBody(ResponseBody body) throws IOException {
        if (body == null) {
            return "";
        }
        return new String(body.bytes(), StandardCharsets.UTF_8);
    }

    private ModelClientErrorType classifyStatus(int status) {
        if (status == 401 || status == 403) {
            return ModelClientErrorType.UNAUTHORIZED;
        }
        if (status == 429) {
            return ModelClientErrorType.RATE_LIMITED;
        }
        if (status >= 500) {
            return ModelClientErrorType.SERVER_ERROR;
        }
        return ModelClientErrorType.CLIENT_ERROR;
    }
}
