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

import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.concurrent.CompletableFuture;

@Component
@ConditionalOnMissingBean(SpeechRecognitionService.class)
public class NoopSpeechRecognitionService implements SpeechRecognitionService {

    private static final String MESSAGE = "语音识别服务未配置，请先设置讯飞语音识别密钥";

    @Override
    public String recognize(InputStream audioInputStream, String audioFormat, int sampleRate, String language) {
        throw new UnsupportedOperationException(MESSAGE);
    }

    @Override
    public CompletableFuture<String> recognizeAsync(InputStream audioInputStream, String audioFormat, int sampleRate, String language) {
        return CompletableFuture.failedFuture(new UnsupportedOperationException(MESSAGE));
    }
}
