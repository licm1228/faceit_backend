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

import java.io.InputStream;
import java.util.concurrent.CompletableFuture;

public interface SpeechRecognitionService {
    /**
     * 同步语音识别
     * @param audioInputStream 音频输入流
     * @param audioFormat 音频格式，如 "wav", "pcm" 等
     * @param sampleRate 采样率，如 16000
     * @param language 语言，如 "zh_cn", "en_us" 等
     * @return 识别结果文本
     */
    String recognize(InputStream audioInputStream, String audioFormat, int sampleRate, String language);

    /**
     * 异步语音识别
     * @param audioInputStream 音频输入流
     * @param audioFormat 音频格式，如 "wav", "pcm" 等
     * @param sampleRate 采样率，如 16000
     * @param language 语言，如 "zh_cn", "en_us" 等
     * @return 包含识别结果的CompletableFuture
     */
    CompletableFuture<String> recognizeAsync(InputStream audioInputStream, String audioFormat, int sampleRate, String language);
}

