import * as React from "react";
import { Brain, Lightbulb, Send, Square, Mic, MicOff } from "lucide-react";

import { VoiceEqualizerIcon } from "@/components/common/VoiceInputVisual";
import { Textarea } from "@/components/ui/textarea";
import { cn } from "@/lib/utils";
import { recognizeSpeechBase64 } from "@/services/interviewService";
import { useChatStore } from "@/stores/chatStore";
import { feedback } from "@/stores/useFeedbackStore";

// 为MediaRecorder添加类型声明
declare global {
  interface Window {
    MediaRecorder: typeof MediaRecorder;
  }
}

export function ChatInput() {
  const [value, setValue] = React.useState("");
  const [isFocused, setIsFocused] = React.useState(false);
  const [isRecording, setIsRecording] = React.useState(false);
  const [isRecognizingSpeech, setIsRecognizingSpeech] = React.useState(false);
  const isComposingRef = React.useRef(false);
  const textareaRef = React.useRef<HTMLTextAreaElement | null>(null);
  const mediaRecorderRef = React.useRef<MediaRecorder | null>(null);
  const isMediaRecorderSupported = React.useMemo(
    () => typeof window !== "undefined" && "MediaRecorder" in window,
    []
  );
  
  const {
    sendMessage,
    isStreaming,
    cancelGeneration,
    deepThinkingEnabled,
    setDeepThinkingEnabled,
    inputFocusKey
  } = useChatStore();

  const focusInput = React.useCallback(() => {
    const el = textareaRef.current;
    if (!el) return;
    el.focus({ preventScroll: true });
  }, []);

  const adjustHeight = React.useCallback(() => {
    const el = textareaRef.current;
    if (!el) return;
    el.style.height = "auto";
    const next = Math.min(el.scrollHeight, 160);
    el.style.height = `${next}px`;
  }, []);

  React.useEffect(() => {
    adjustHeight();
  }, [value, adjustHeight]);

  React.useEffect(() => {
    if (!inputFocusKey) return;
    focusInput();
  }, [inputFocusKey, focusInput]);

  const handleSubmit = async () => {
    if (isStreaming) {
      cancelGeneration();
      focusInput();
      return;
    }
    if (isRecognizingSpeech) return;
    if (!value.trim()) return;
    const next = value;
    setValue("");
    focusInput();
    await sendMessage(next);
    focusInput();
  };

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      
      // 尝试使用支持的音频格式
      let mimeType = 'audio/webm';
      const types = [
        'audio/webm;codecs=opus',
        'audio/webm',
        'audio/ogg;codecs=opus',
        'audio/ogg',
        'audio/wav'
      ];
      
      for (const type of types) {
        if (MediaRecorder.isTypeSupported(type)) {
          mimeType = type;
          break;
        }
      }
      
      // 创建AudioContext和ScriptProcessorNode来直接获取PCM数据
      const audioContext = new AudioContext({ sampleRate: 16000 });
      const source = audioContext.createMediaStreamSource(stream);
      const processor = audioContext.createScriptProcessor(4096, 1, 1);
      const pcmDataRef: Float32Array[] = [];

      processor.onaudioprocess = (event) => {
        const inputData = event.inputBuffer.getChannelData(0);
        // 复制数据以避免被覆盖
        const copyData = new Float32Array(inputData.length);
        copyData.set(inputData);
        pcmDataRef.push(copyData);
      };

      source.connect(processor);
      processor.connect(audioContext.destination);

      const mediaRecorder = new MediaRecorder(stream, { mimeType });
      mediaRecorderRef.current = mediaRecorder;

      mediaRecorder.ondataavailable = () => {};

      mediaRecorder.onstop = async () => {
        // 停止处理音频
        source.disconnect();
        processor.disconnect();

        // 合并所有PCM数据
        const totalLength = pcmDataRef.reduce((sum, data) => sum + data.length, 0);
        const mergedData = new Float32Array(totalLength);
        let offset = 0;
        for (const data of pcmDataRef) {
          mergedData.set(data, offset);
          offset += data.length;
        }

        const wavBlob = encodeWav(mergedData, audioContext.sampleRate);
        const base64Audio = await blobToBase64(wavBlob);
        await recognizeSpeech(base64Audio);

        // 关闭媒体流
        stream.getTracks().forEach(track => track.stop());
        audioContext.close();
      };

      mediaRecorder.start();
      setIsRecording(true);
    } catch (error) {
      console.error('无法访问麦克风:', error);
      feedback.error("无法访问麦克风，请检查权限设置");
      setIsRecording(false);
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && mediaRecorderRef.current.state === 'recording') {
      setIsRecognizingSpeech(true);
      mediaRecorderRef.current.stop();
      setIsRecording(false);
    }
  };

  const blobToBase64 = React.useCallback((blob: Blob) => new Promise<string>((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => {
      const result = reader.result;
      if (typeof result !== "string") {
        reject(new Error("音频编码失败"));
        return;
      }
      const base64 = result.split(",")[1];
      if (!base64) {
        reject(new Error("音频编码失败"));
        return;
      }
      resolve(base64);
    };
    reader.onerror = () => reject(new Error("音频编码失败"));
    reader.readAsDataURL(blob);
  }), []);

  const encodeWav = React.useCallback((samples: Float32Array, sampleRate: number) => {
    const buffer = new ArrayBuffer(44 + samples.length * 2);
    const view = new DataView(buffer);
    const writeString = (offset: number, value: string) => {
      for (let i = 0; i < value.length; i += 1) {
        view.setUint8(offset + i, value.charCodeAt(i));
      }
    };

    writeString(0, "RIFF");
    view.setUint32(4, 36 + samples.length * 2, true);
    writeString(8, "WAVE");
    writeString(12, "fmt ");
    view.setUint32(16, 16, true);
    view.setUint16(20, 1, true);
    view.setUint16(22, 1, true);
    view.setUint32(24, sampleRate, true);
    view.setUint32(28, sampleRate * 2, true);
    view.setUint16(32, 2, true);
    view.setUint16(34, 16, true);
    writeString(36, "data");
    view.setUint32(40, samples.length * 2, true);

    let offset = 44;
    for (let i = 0; i < samples.length; i += 1) {
      const sample = Math.max(-1, Math.min(1, samples[i]));
      view.setInt16(offset, sample < 0 ? sample * 0x8000 : sample * 0x7fff, true);
      offset += 2;
    }

    return new Blob([buffer], { type: "audio/wav" });
  }, []);

  const recognizeSpeech = async (base64Audio: string) => {
    console.log('开始识别WAV语音，Base64长度:', base64Audio.length);

    setIsRecognizingSpeech(true);
    try {
      const text = await recognizeSpeechBase64(base64Audio, 'wav', 16000, 'zh_cn');
      console.log('识别结果:', text);

      if (text) {
        setValue((prev) => {
          const current = prev.trim();
          return current ? `${current} ${text}` : text;
        });
        focusInput();
      } else {
        feedback.error("未识别到语音内容，请重试");
      }
    } catch (error) {
      console.error('语音识别错误:', error);
      feedback.error("语音识别失败，请重试");
    } finally {
      setIsRecognizingSpeech(false);
    }
  };

  const hasContent = value.trim().length > 0;

  return (
    <div className="space-y-4">
      <p className="text-center text-xs text-[#999999]">
        <kbd className="rounded bg-[#F5F5F5] px-1.5 py-0.5 text-[#666666]">Enter</kbd> 发送
        <span className="px-1.5">·</span>
        <kbd className="rounded bg-[#F5F5F5] px-1.5 py-0.5 text-[#666666]">
          Shift + Enter
        </kbd>{" "}
        换行
        {isStreaming ? <span className="ml-2 animate-pulse">生成中...</span> : null}
      </p>
      <div
        className={cn(
          "relative flex flex-col rounded-2xl border bg-white px-4 pt-3 pb-2 transition-all duration-200",
          isFocused
            ? "border-[#D4D4D4] shadow-[0_4px_12px_rgba(0,0,0,0.06)]"
            : "border-[#E5E5E5] hover:border-[#D4D4D4]"
        )}
      >
        <div className="relative">
          <Textarea
            ref={textareaRef}
            value={value}
            onChange={(event) => setValue(event.target.value)}
            placeholder={
              isRecognizingSpeech
                ? "语音识别中，请稍候..."
                : deepThinkingEnabled
                  ? "输入需要深度分析的问题..."
                  : "输入你的问题..."
            }
            className="max-h-40 min-h-[44px] w-full resize-none border-0 bg-transparent px-2 pt-2 pb-2 pr-2 text-[15px] text-[#333333] shadow-none placeholder:text-[#999999] focus-visible:ring-0"
            rows={1}
            disabled={isRecognizingSpeech}
            onFocus={() => setIsFocused(true)}
            onBlur={() => setIsFocused(false)}
            onCompositionStart={() => {
              isComposingRef.current = true;
            }}
            onCompositionEnd={() => {
              isComposingRef.current = false;
            }}
            onKeyDown={(event) => {
              if (event.key === "Enter" && !event.shiftKey) {
                const nativeEvent = event.nativeEvent as KeyboardEvent;
                if (nativeEvent.isComposing || isComposingRef.current || nativeEvent.keyCode === 229) {
                  return;
                }
                event.preventDefault();
                handleSubmit();
              }
            }}
            aria-label="聊天输入框"
          />
          {isRecognizingSpeech ? (
            <div className="pointer-events-none absolute inset-0 rounded-2xl bg-white/55" />
          ) : null}
          <div className="pointer-events-none absolute bottom-0 left-0 right-0 h-[10px] bg-gradient-to-b from-white/0 via-white/40 to-white/90" />
        </div>
        <div className="relative mt-2 flex items-center justify-between">
          <button
            type="button"
            onClick={() => setDeepThinkingEnabled(!deepThinkingEnabled)}
            disabled={isStreaming || isRecognizingSpeech}
            aria-pressed={deepThinkingEnabled}
            className={cn(
              "rounded-lg border px-3 py-1.5 text-xs font-medium transition-all",
              deepThinkingEnabled
                ? "border-[#BFDBFE] bg-[#DBEAFE] text-[#2563EB]"
                : "border-transparent bg-[#F5F5F5] text-[#999999] hover:bg-[#EEEEEE]",
              (isStreaming || isRecognizingSpeech) && "cursor-not-allowed opacity-60"
            )}
          >
            <span className="inline-flex items-center gap-2">
              <Brain className={cn("h-3.5 w-3.5", deepThinkingEnabled && "text-[#3B82F6]")} />
              深度思考
              {deepThinkingEnabled ? <span className="h-2 w-2 rounded-full bg-[#3B82F6] animate-pulse" /> : null}
            </span>
          </button>
          <div className="flex items-center gap-2">
            {isMediaRecorderSupported && (
              <button
                type="button"
                onClick={isRecording ? stopRecording : startRecording}
                disabled={isStreaming || isRecognizingSpeech}
                aria-label={isRecording ? "停止录音" : isRecognizingSpeech ? "语音识别中" : "开始录音"}
                className={cn(
                  "inline-flex h-10 w-10 items-center justify-center rounded-full transition-all duration-200",
                  isRecording
                    ? "bg-[#DCFCE7] text-[#16A34A] hover:bg-[#BBF7D0]"
                    : "bg-[#F5F5F5] text-[#666666] hover:bg-[#EEEEEE]",
                  (isStreaming || isRecognizingSpeech) && "cursor-not-allowed opacity-60"
                )}
              >
                {isRecognizingSpeech ? (
                  <VoiceEqualizerIcon className="text-current" />
                ) : isRecording ? (
                  <MicOff className="h-4 w-4" />
                ) : (
                  <Mic className="h-4 w-4" />
                )}
              </button>
            )}
            <button
              type="button"
              onClick={handleSubmit}
              disabled={(!hasContent && !isStreaming) || isRecognizingSpeech}
              aria-label={isStreaming ? "停止生成" : "发送消息"}
              className={cn(
                "ml-auto inline-flex h-10 w-10 items-center justify-center rounded-full transition-all duration-200",
                isStreaming
                  ? "bg-[#FEE2E2] text-[#EF4444] hover:bg-[#FECACA]"
                  : hasContent
                    ? "bg-[#3B82F6] text-white hover:bg-[#2563EB]"
                    : "bg-[#F5F5F5] text-[#CCCCCC]",
                ((!hasContent && !isStreaming) || isRecognizingSpeech) && "cursor-not-allowed"
              )}
            >
              {isStreaming ? <Square className="h-4 w-4" /> : <Send className="h-4 w-4" />}
            </button>
          </div>
        </div>
      </div>
      {deepThinkingEnabled ? (
        <p className="text-xs text-[#2563EB]">
          <span className="inline-flex items-center gap-1.5">
            <Lightbulb className="h-3.5 w-3.5" />
            深度思考模式已开启，AI将进行更深入的分析推理
          </span>
        </p>
      ) : null}
      {isRecognizingSpeech ? (
        <p className="text-xs text-[#16A34A]">
          <span className="inline-flex items-center gap-2">
            <VoiceEqualizerIcon className="text-current" />
            语音识别中，请稍候...
          </span>
        </p>
      ) : null}
    </div>
  );
}
