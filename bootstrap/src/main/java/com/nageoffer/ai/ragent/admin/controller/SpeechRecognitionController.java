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

package com.nageoffer.ai.ragent.admin.controller;

import com.nageoffer.ai.ragent.framework.convention.Result;
import com.nageoffer.ai.ragent.framework.web.Results;
import com.nageoffer.ai.ragent.infra.speech.SpeechRecognitionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;

@RestController
@RequiredArgsConstructor
public class SpeechRecognitionController {

    private final SpeechRecognitionService speechRecognitionService;

    @PostMapping("/speech/recognize")
    public Result<String> recognize(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "format", defaultValue = "pcm") String format,
            @RequestParam(value = "sampleRate", defaultValue = "16000") int sampleRate,
            @RequestParam(value = "language", defaultValue = "zh_cn") String language) throws IOException {
        return Results.success(speechRecognitionService.recognize(file.getInputStream(), format, sampleRate, language));
    }

    @PostMapping("/speech/recognize/base64")
    public Result<String> recognizeBase64(
            @RequestParam("audio") String audioBase64,
            @RequestParam(value = "format", defaultValue = "pcm") String format,
            @RequestParam(value = "sampleRate", defaultValue = "16000") int sampleRate,
            @RequestParam(value = "language", defaultValue = "zh_cn") String language) throws IOException {
        byte[] audioBytes = java.util.Base64.getDecoder().decode(audioBase64);
        ByteArrayInputStream inputStream = new ByteArrayInputStream(audioBytes);
        String result = speechRecognitionService.recognize(inputStream, format, sampleRate, language);
        return Results.success(result);
    }
}
