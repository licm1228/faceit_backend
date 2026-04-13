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

package com.nageoffer.ai.ragent.infra.speech;

import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.*;
import okio.ByteString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.SimpleTimeZone;
import java.util.TimeZone;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

@Component
@ConditionalOnProperty(prefix = "ai.providers.iflytek", name = {"app-id", "api-key", "api-secret"})
public class IflytekSpeechRecognitionService implements SpeechRecognitionService {

    private static final Logger logger = LoggerFactory.getLogger(IflytekSpeechRecognitionService.class);
    private static final String CONFIG_MISSING_MESSAGE = "语音识别服务未配置，请先设置讯飞语音识别密钥";

    @Value("${ai.providers.iflytek.app-id}")
    private String appId;

    @Value("${ai.providers.iflytek.api-key}")
    private String apiKey;

    @Value("${ai.providers.iflytek.api-secret}")
    private String apiSecret;

    @Value("${ai.providers.iflytek.url:wss://iat-api.xfyun.cn}")
    private String apiUrl;

    @Value("${ai.providers.iflytek.endpoints.iat:/v2/iat}")
    private String iatEndpoint;

    private final OkHttpClient httpClient;
    private final ObjectMapper objectMapper;

    public IflytekSpeechRecognitionService() {
        this.httpClient = new OkHttpClient.Builder()
                .connectTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
                .readTimeout(60, java.util.concurrent.TimeUnit.SECONDS)
                .writeTimeout(60, java.util.concurrent.TimeUnit.SECONDS)
                .pingInterval(30, java.util.concurrent.TimeUnit.SECONDS)
                .build();
        this.objectMapper = new ObjectMapper();
    }

    @Override
    public String recognize(InputStream audioInputStream, String audioFormat, int sampleRate, String language) {
        try {
            validateConfiguration();
            byte[] originalAudioBytes = audioInputStream.readAllBytes();
            logger.info("Audio data: format={}, sampleRate={}, length={}", audioFormat, sampleRate, originalAudioBytes.length);

            // 如果是WAV格式，需要跳过WAV文件头，提取PCM数据
            byte[] audioBytes;
            if ("wav".equalsIgnoreCase(audioFormat)) {
                // WAV文件头通常是44字节，但我们需要检查实际的偏移量
                // PCM数据从"data"子块开始，"data"子块的前4字节是"data"标识，后4字节是数据长度
                int pcmOffset = findPcmDataOffset(originalAudioBytes);
                if (pcmOffset > 0) {
                    int pcmLength = originalAudioBytes.length - pcmOffset;
                    audioBytes = new byte[pcmLength];
                    System.arraycopy(originalAudioBytes, pcmOffset, audioBytes, 0, pcmLength);
                    logger.info("Extracted PCM data: offset={}, length={}", pcmOffset, pcmLength);
                } else {
                    logger.warn("Failed to find PCM data offset in WAV file, assuming the audio is already in PCM format");
                    audioBytes = originalAudioBytes;
                }
            } else if ("pcm".equalsIgnoreCase(audioFormat)) {
                // 如果是PCM格式，直接使用原始数据
                audioBytes = originalAudioBytes;
                logger.info("Audio is already in PCM format");
            } else {
                // 其他格式，假设是PCM格式
                logger.warn("Unknown audio format: {}, assuming it's PCM format", audioFormat);
                audioBytes = originalAudioBytes;
            }

            // 使用RFC1123格式的日期
            String dateFormat = "EEE, dd MMM yyyy HH:mm:ss z";
            SimpleDateFormat sdf = new SimpleDateFormat(dateFormat, Locale.US);
            sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
            String dateStr = sdf.format(new Date());

            // 构建WebSocket URL
            String authUrl = generateAuthUrl(apiKey, apiSecret, dateStr);
            String wsUrl = apiUrl + iatEndpoint + "?" + authUrl;

            logger.info("WebSocket URL: {}", wsUrl);

            // 用于存储识别结果
            AtomicReference<StringBuilder> resultText = new AtomicReference<>(new StringBuilder());
            // 用于存储每个词的识别结果，key是词的索引，value是词的内容
            Map<Integer, String> wordMap = new HashMap<>();
            CountDownLatch latch = new CountDownLatch(1);

            // 创建WebSocket监听器
            WebSocketListener listener = new WebSocketListener() {
                @Override
                public void onOpen(WebSocket webSocket, Response response) {
                    logger.info("WebSocket connected");
                    try {
                        // 发送音频数据
                        sendAudioData(webSocket, audioBytes, sampleRate, language);
                    } catch (Exception e) {
                        logger.error("Failed to send audio data", e);
                        latch.countDown();
                    }
                }

                @Override
                public void onMessage(WebSocket webSocket, String text) {
                    logger.info("Received message: {}", text);
                    try {
                        Map<String, Object> response = objectMapper.readValue(text, Map.class);
                        Map<String, Object> header = (Map<String, Object>) response.get("header");
                        if (header != null) {
                            Integer code = (Integer) header.get("code");
                            if (code != null && code == 0) {
                                Map<String, Object> payload = (Map<String, Object>) response.get("payload");
                                if (payload != null) {
                                    Map<String, Object> result = (Map<String, Object>) payload.get("result");
                                    if (result != null) {
                                        String textBase64 = (String) result.get("text");
                                        logger.info("Received textBase64: {}", textBase64);
                                        if (textBase64 != null && !textBase64.isEmpty()) {
                                            // 解码base64
                                            byte[] decodedBytes = Base64.getDecoder().decode(textBase64);
                                            String decodedText = new String(decodedBytes, StandardCharsets.UTF_8);
                                            logger.info("Decoded text: {}", decodedText);
                                            // 解析JSON
                                            Map<String, Object> textJson = objectMapper.readValue(decodedText, Map.class);
                                            String pgs = (String) textJson.get("pgs");
                                            @SuppressWarnings("unchecked")
                                            List<Map<String, Object>> wsList = (List<Map<String, Object>>) textJson.get("ws");
                                            if (wsList != null && !wsList.isEmpty()) {
                                                // 获取rg字段，表示替换的范围
                                                @SuppressWarnings("unchecked")
                                                List<Integer> rg = (List<Integer>) textJson.get("rg");

                                                // 如果是替换模式，需要先清除之前的内容
                                                if ("rpl".equals(pgs) && rg != null && rg.size() == 2) {
                                                    int start = rg.get(0);
                                                    int end = rg.get(1);
                                                    // 清除指定范围内的词
                                                    for (int i = start; i <= end; i++) {
                                                        wordMap.remove(i);
                                                    }
                                                }

                                                // 处理每个词
                                                int wordIndex = wordMap.size() + 1;
                                                for (Map<String, Object> ws : wsList) {
                                                    @SuppressWarnings("unchecked")
                                                    List<Map<String, Object>> cwList = (List<Map<String, Object>>) ws.get("cw");
                                                    if (cwList != null && !cwList.isEmpty()) {
                                                        for (Map<String, Object> cw : cwList) {
                                                            String w = (String) cw.get("w");
                                                            // 保存这个词
                                                            wordMap.put(wordIndex++, w);
                                                        }
                                                    }
                                                }

                                                // 构建最终的识别结果
                                                StringBuilder textBuilder = new StringBuilder();
                                                for (int i = 1; i <= wordMap.size(); i++) {
                                                    String word = wordMap.get(i);
                                                    if (word != null) {
                                                        textBuilder.append(word);
                                                    }
                                                }
                                                String finalText = textBuilder.toString();
                                                logger.debug("Final text: {}", finalText);
                                                resultText.get().setLength(0);
                                                resultText.get().append(finalText);
                                            }
                                        }
                                    }
                                }
                            }

                            // 检查是否结束
                            Object statusObj = header.get("status");
                            int status;
                            if (statusObj instanceof String) {
                                status = Integer.parseInt((String) statusObj);
                            } else if (statusObj instanceof Integer) {
                                status = (Integer) statusObj;
                            } else {
                                logger.warn("Unexpected status type: {}", statusObj.getClass().getName());
                                status = 0;
                            }
                            if (status == 2) {
                                webSocket.close(1000, "Normal closure");
                                latch.countDown();
                            }
                        }
                    } catch (Exception e) {
                        logger.error("Failed to parse message", e);
                        latch.countDown();
                    }
                }

                @Override
                public void onClosing(WebSocket webSocket, int code, String reason) {
                    logger.info("WebSocket closing: {} - {}", code, reason);
                    latch.countDown();
                }

                @Override
                public void onFailure(WebSocket webSocket, Throwable t, Response response) {
                    logger.error("WebSocket failed", t);
                    latch.countDown();
                }
            };

            // 创建WebSocket连接
            Request request = new Request.Builder()
                    .url(wsUrl)
                    .build();

            WebSocket ws = httpClient.newWebSocket(request, listener);

            // 等待识别完成
            if (!latch.await(30, TimeUnit.SECONDS)) {
                logger.error("Speech recognition timeout");
                try {
                    ws.close(1000, "Timeout");
                } catch (Exception e) {
                    logger.error("Failed to close WebSocket", e);
                }
                throw new RuntimeException("Speech recognition timeout");
            }

            return resultText.get().toString();


        } catch (Exception e) {
            logger.error("Speech recognition failed", e);
            throw new RuntimeException("Speech recognition failed", e);
        }
    }

    private void validateConfiguration() {
        if (!StringUtils.hasText(appId) || !StringUtils.hasText(apiKey) || !StringUtils.hasText(apiSecret)) {
            throw new UnsupportedOperationException(CONFIG_MISSING_MESSAGE);
        }
    }

    @Override
    public CompletableFuture<String> recognizeAsync(InputStream audioInputStream, String audioFormat, int sampleRate, String language) {
        return CompletableFuture.supplyAsync(() -> recognize(audioInputStream, audioFormat, sampleRate, language));
    }

    /**
     * 查找WAV文件中PCM数据的偏移量
     * @param wavBytes WAV文件字节数组
     * @return PCM数据的偏移量，如果找不到则返回-1
     */
    private int findPcmDataOffset(byte[] wavBytes) {
        // WAV文件头通常是44字节，但我们需要检查实际的偏移量
        // PCM数据从"data"子块开始，"data"子块的前4字节是"data"标识，后4字节是数据长度

        // 检查WAV文件头
        if (wavBytes.length < 12) {
            logger.warn("WAV file is too short");
            return -1;
        }

        // 检查RIFF标识
        if (!new String(wavBytes, 0, 4).equals("RIFF")) {
            logger.warn("Invalid WAV file: missing RIFF header");
            // 尝试查找"data"标识，即使不是标准的WAV文件
            return findDataChunkOffset(wavBytes);
        }

        // 检查WAVE标识
        if (!new String(wavBytes, 8, 4).equals("WAVE")) {
            logger.warn("Invalid WAV file: missing WAVE header");
            // 尝试查找"data"标识，即使不是标准的WAV文件
            return findDataChunkOffset(wavBytes);
        }

        // 查找data子块
        return findDataChunkOffset(wavBytes);
    }

    /**
     * 查找文件中"data"子块的偏移量
     * @param bytes 文件字节数组
     * @return data子块的偏移量，如果找不到则返回-1
     */
    private int findDataChunkOffset(byte[] bytes) {
        // 查找"data"标识
        for (int i = 0; i < bytes.length - 8; i++) {
            if (bytes[i] == 'd' && bytes[i + 1] == 'a' && bytes[i + 2] == 't' && bytes[i + 3] == 'a') {
                return i + 8; // 跳过"data"标识和4字节的长度
            }
        }

        logger.warn("Failed to find data chunk in file");
        return -1;
    }

    /**
     * 发送音频数据
     */
    private void sendAudioData(WebSocket webSocket, byte[] audioBytes, int sampleRate, String language) throws Exception {
        // 分块发送音频数据
        int chunkSize = 1280; // 每次发送1280字节
        int totalChunks = (audioBytes.length + chunkSize - 1) / chunkSize;
        logger.info("Sending audio data: totalChunks={}, audioBytes.length={}", totalChunks, audioBytes.length);

        for (int i = 0; i < totalChunks; i++) {
            int start = i * chunkSize;
            int end = Math.min(start + chunkSize, audioBytes.length);
            byte[] chunk = new byte[end - start];
            System.arraycopy(audioBytes, start, chunk, 0, end - start);

            // 构建请求体
            Map<String, Object> requestBody = new HashMap<>();

            // 构建header
            Map<String, Object> header = new HashMap<>();
            header.put("app_id", appId);
            header.put("status", i == 0 ? 0 : (i == totalChunks - 1 ? 2 : 1)); // 0: 第一帧, 1: 中间帧, 2: 最后一帧
            requestBody.put("header", header);

            // 构建parameter (每一帧都发送)
            Map<String, Object> parameter = new HashMap<>();
            Map<String, Object> iat = new HashMap<>();
            iat.put("language", "zh_cn"); // 固定为zh_cn
            iat.put("domain", "slm"); // 固定为slm
            iat.put("accent", "mandarin");
            iat.put("eos", 6000);
            iat.put("dwa", "wpgs");
            Map<String, Object> result = new HashMap<>();
            result.put("encoding", "utf8");
            result.put("compress", "raw");
            result.put("format", "json");
            iat.put("result", result);
            parameter.put("iat", iat);
            requestBody.put("parameter", parameter);

            // 构建payload
            Map<String, Object> payload = new HashMap<>();
            Map<String, Object> audio = new HashMap<>();
            audio.put("encoding", "raw");
            audio.put("sample_rate", sampleRate);
            audio.put("channels", 1);
            audio.put("bit_depth", 16);
            audio.put("seq", i + 1);
            audio.put("status", i == 0 ? 0 : (i == totalChunks - 1 ? 2 : 1)); // 0: 第一帧, 1: 中间帧, 2: 最后一帧
            audio.put("audio", Base64.getEncoder().encodeToString(chunk));
            payload.put("audio", audio);
            requestBody.put("payload", payload);

            // 发送数据
            String jsonBody = objectMapper.writeValueAsString(requestBody);
            logger.info("Sending chunk {}/{}: {}", i + 1, totalChunks, jsonBody.substring(0, Math.min(200, jsonBody.length())));
            webSocket.send(jsonBody);

            // 短暂延迟，避免发送过快
            Thread.sleep(40);
        }
    }

    /**
     * 生成JWT认证信息
     * 根据讯飞API文档生成JWT token
     */
    private String generateJwtAuthorization(String apiKey, String apiSecret, String timestamp) {
        try {
            // 解析apiKey获取apiId和apiKey
            // String[] apiKeyParts = apiKey.split("\\.");
            // String apiId = apiKeyParts[0];
            // String key = apiKeyParts[1];

            // 构建JWT payload
            Map<String, Object> payload = new HashMap<>();
            payload.put("uid", "system");
            payload.put("exp", System.currentTimeMillis() / 1000 + 3600);
            payload.put("iat", Long.parseLong(timestamp));

            // 构建JWT header
            Map<String, Object> header = new HashMap<>();
            header.put("alg", "HS256");
            header.put("sign_type", "SIGN");

            // Base64URL编码header和payload
            String encodedHeader = base64UrlEncode(objectMapper.writeValueAsBytes(header));
            String encodedPayload = base64UrlEncode(objectMapper.writeValueAsBytes(payload));

            // 生成签名
            String signature = hmacSha256(encodedHeader + "." + encodedPayload, apiSecret);

            return "Bearer " + encodedHeader + "." + encodedPayload + "." + signature;
        } catch (Exception e) {
            logger.error("Generate JWT authorization failed", e);
            throw new RuntimeException("Generate JWT authorization failed", e);
        }
    }

    /**
     * Base64URL编码
     */
    private String base64UrlEncode(byte[] data) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(data);
    }

    /**
     * HMAC-SHA256签名
     */
    private String hmacSha256(String data, String secret) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKeySpec = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(secretKeySpec);
        byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(hash);
    }

    /**
     * 生成认证URL
     */
    private String generateAuthUrl(String apiKey, String apiSecret, String timestamp) throws Exception {
        // 从URL中提取主机名
        String host = apiUrl.replace("wss://", "").replace("ws://", "");

        // 计算签名
        String signatureOrigin = "host: " + host + "\ndate: " + timestamp + "\nGET " + iatEndpoint + " HTTP/1.1";
        String signature = hmacSha256(signatureOrigin, apiSecret);

        // 构建authorizationOrigin
        String authorizationOrigin = "api_key=\"" + apiKey + "\", algorithm=\"hmac-sha256\", headers=\"host date request-line\", signature=\"" + signature + "\"";
        String authorization = Base64.getEncoder().encodeToString(authorizationOrigin.getBytes(StandardCharsets.UTF_8));

        // 构建认证URL
        return "authorization=" + URLEncoder.encode(authorization, "UTF-8") +
                "&date=" + URLEncoder.encode(timestamp, "UTF-8") +
                "&host=" + URLEncoder.encode(host, "UTF-8");
    }
}
