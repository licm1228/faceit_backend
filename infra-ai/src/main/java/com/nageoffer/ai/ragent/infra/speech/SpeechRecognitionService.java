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

