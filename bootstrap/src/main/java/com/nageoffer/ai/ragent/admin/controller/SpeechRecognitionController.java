package com.nageoffer.ai.ragent.web.controller;

import com.nageoffer.ai.ragent.infra.speech.SpeechRecognitionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;

@RestController
public class SpeechRecognitionController {

    @Autowired
    private SpeechRecognitionService speechRecognitionService;

    @PostMapping("/speech/recognize")
    public String recognize(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "format", defaultValue = "pcm") String format,
            @RequestParam(value = "sampleRate", defaultValue = "16000") int sampleRate,
            @RequestParam(value = "language", defaultValue = "zh_cn") String language) throws IOException {
        return speechRecognitionService.recognize(file.getInputStream(), format, sampleRate, language);
    }

    @PostMapping("/speech/recognize/base64")
    public String recognizeBase64(
            @RequestParam("audio") String audioBase64,
            @RequestParam(value = "format", defaultValue = "pcm") String format,
            @RequestParam(value = "sampleRate", defaultValue = "16000") int sampleRate,
            @RequestParam(value = "language", defaultValue = "zh_cn") String language) throws IOException {
        byte[] audioBytes = java.util.Base64.getDecoder().decode(audioBase64);
        ByteArrayInputStream inputStream = new ByteArrayInputStream(audioBytes);
        String result = speechRecognitionService.recognize(inputStream, format, sampleRate, language);
        System.out.println("语音识别结果: " + result);
        return result;
    }
}