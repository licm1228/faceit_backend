import * as React from "react";
import { Brain, Lightbulb, Send, Square, Mic, MicOff } from "lucide-react";

import { Textarea } from "@/components/ui/textarea";
import { cn } from "@/lib/utils";
import { recognizeSpeechBase64 } from "@/services/interviewService";
import { useChatStore } from "@/stores/chatStore";

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
  const isComposingRef = React.useRef(false);
  const textareaRef = React.useRef<HTMLTextAreaElement | null>(null);
  const mediaRecorderRef = React.useRef<MediaRecorder | null>(null);
  const audioChunksRef = React.useRef<Blob[]>([]);
  
  // 检测浏览器是否支持MediaRecorder API
  const isMediaRecorderSupported = React.useMemo(() => {
    const supported = typeof window !== 'undefined' && 'MediaRecorder' in window;
    console.log('MediaRecorder support:', supported);
    return supported;
  }, []);
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
      audioChunksRef.current = [];

      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          audioChunksRef.current.push(event.data);
        }
      };

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

        // 将Float32转换为Int16
        const int16Data = new Int16Array(mergedData.length);
        for (let i = 0; i < mergedData.length; i++) {
          let s = Math.max(-1, Math.min(1, mergedData[i]));
          int16Data[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
        }

        // 将Int16数据转换为Base64
        const uint8Data = new Uint8Array(int16Data.buffer);
        let binary = '';
        const len = uint8Data.byteLength;
        for (let i = 0; i < len; i++) {
          binary += String.fromCharCode(uint8Data[i]);
        }
        const base64Audio = btoa(binary);

        // 直接发送PCM数据
        await recognizeSpeechPCM(base64Audio);

        // 关闭媒体流
        stream.getTracks().forEach(track => track.stop());
        audioContext.close();
      };

      mediaRecorder.start();
      setIsRecording(true);
    } catch (error) {
      console.error('无法访问麦克风:', error);
      alert('无法访问麦克风，请检查权限设置');
      setIsRecording(false);
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && mediaRecorderRef.current.state === 'recording') {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
    }
  };

  const recognizeSpeech = async (audioBlob: Blob, mimeType: string) => {
    console.log('开始识别语音，音频大小:', audioBlob.size, '字节，MIME类型:', mimeType);
    
    // 将音频转换为PCM格式
    try {
      const audioContext = new AudioContext({ sampleRate: 16000 });
      const arrayBuffer = await audioBlob.arrayBuffer();
      const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
      
      // 获取单声道音频数据
      const numberOfChannels = audioBuffer.numberOfChannels;
      const length = audioBuffer.length;
      const sampleRate = audioBuffer.sampleRate;
      
      console.log('音频信息:', { numberOfChannels, length, sampleRate });
      
      // 创建PCM数据
      const pcmData = new Float32Array(length * numberOfChannels);
      for (let channel = 0; channel < numberOfChannels; channel++) {
        const channelData = audioBuffer.getChannelData(channel);
        for (let i = 0; i < length; i++) {
          pcmData[i * numberOfChannels + channel] = channelData[i];
        }
      }

      // 打印前10个样本值，用于调试
      console.log('前10个样本值:', Array.from(pcmData.slice(0, 10)));
      
      // 将Float32转换为Int16
      const int16Data = new Int16Array(pcmData.length);
      for (let i = 0; i < pcmData.length; i++) {
        let s = Math.max(-1, Math.min(1, pcmData[i]));
        int16Data[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
      }
      
      // 打印前10个Int16值，用于调试
      console.log('前10个Int16值:', Array.from(int16Data.slice(0, 10)));
      console.log('PCM数据大小:', int16Data.length * 2, '字节');
      
      // 将PCM数据转换为Base64
      // 使用Uint8Array来正确处理二进制数据
      const uint8Data = new Uint8Array(int16Data.buffer);
      let binary = '';
      const len = uint8Data.byteLength;
      for (let i = 0; i < len; i++) {
        binary += String.fromCharCode(uint8Data[i]);
      }
      const base64Audio = btoa(binary);
      console.log('音频Base64编码完成，长度:', base64Audio.length);

        
        const text = await recognizeSpeechBase64(base64Audio, 'pcm', 16000, 'zh_cn');
        console.log('识别结果:', text);
        
        if (text) {
          setValue(text);
          focusInput();
        } else {
          alert('未识别到语音内容，请重试');
        }
    } catch (error) {
      console.error('语音识别错误:', error);
      alert('语音识别失败，请重试');
    }
  };

  const recognizeSpeechPCM = async (base64Audio: string) => {
    console.log('开始识别PCM语音，Base64长度:', base64Audio.length);

    try {
      const text = await recognizeSpeechBase64(base64Audio, 'pcm', 16000, 'zh_cn');
      console.log('识别结果:', text);
      console.log('识别结果类型:', typeof text);
      console.log('识别结果长度:', text.length);
      console.log('识别结果前100个字符:', text.substring(0, 100));

      if (text) {
        setValue(text);
        focusInput();
      } else {
        alert('未识别到语音内容，请重试');
      }
    } catch (error) {
      console.error('语音识别错误:', error);
      alert('语音识别失败，请重试');
    }
  };

  const hasContent = value.trim().length > 0;

  return (
      <div className="space-y-4">
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
                placeholder={deepThinkingEnabled ? "输入需要深度分析的问题..." : "输入你的问题..."}
                className="max-h-40 min-h-[44px] w-full resize-none border-0 bg-transparent px-2 pt-2 pb-2 pr-2 text-[15px] text-[#333333] shadow-none placeholder:text-[#999999] focus-visible:ring-0"
                rows={1}
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
            <div className="pointer-events-none absolute bottom-0 left-0 right-0 h-[10px] bg-gradient-to-b from-white/0 via-white/40 to-white/90" />
          </div>
          <div className="relative mt-2 flex items-center justify-between">
            <button
                type="button"
                onClick={() => setDeepThinkingEnabled(!deepThinkingEnabled)}
                disabled={isStreaming}
                aria-pressed={deepThinkingEnabled}
                className={cn(
                    "rounded-lg border px-3 py-1.5 text-xs font-medium transition-all",
                    deepThinkingEnabled
                        ? "border-[#BFDBFE] bg-[#DBEAFE] text-[#2563EB]"
                        : "border-transparent bg-[#F5F5F5] text-[#999999] hover:bg-[#EEEEEE]",
                    isStreaming && "cursor-not-allowed opacity-60"
                )}
            >
            <span className="inline-flex items-center gap-2">
              <Brain className={cn("h-3.5 w-3.5", deepThinkingEnabled && "text-[#3B82F6]")} />
              深度思考
              {deepThinkingEnabled ? (
                  <span className="h-2 w-2 rounded-full bg-[#3B82F6] animate-pulse" />
              ) : null}
            </span>
            </button>
            <div className="flex items-center gap-2">
              {isMediaRecorderSupported && (
                <button
                    type="button"
                    onClick={isRecording ? stopRecording : startRecording}
                    disabled={isStreaming}
                    aria-label={isRecording ? "停止录音" : "开始录音"}
                    className={cn(
                        "rounded-full p-2.5 transition-all duration-200",
                        isRecording
                            ? "bg-[#FEE2E2] text-[#EF4444] hover:bg-[#FECACA]"
                            : "bg-[#F5F5F5] text-[#666666] hover:bg-[#EEEEEE]"
                    )}
                >
                  {isRecording ? <MicOff className="h-4 w-4" /> : <Mic className="h-4 w-4" />}
                </button>
              )}
            <button
                type="button"
                onClick={handleSubmit}
                disabled={!hasContent && !isStreaming}
                aria-label={isStreaming ? "停止生成" : "发送消息"}
                className={cn(
                    "ml-auto rounded-full p-2.5 transition-all duration-200",
                    isStreaming
                        ? "bg-[#FEE2E2] text-[#EF4444] hover:bg-[#FECACA]"
                        : hasContent
                            ? "bg-[#3B82F6] text-white hover:bg-[#2563EB]"
                            : "cursor-not-allowed bg-[#F5F5F5] text-[#CCCCCC]"
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
        <p className="text-center text-xs text-[#999999]">
          <kbd className="rounded bg-[#F5F5F5] px-1.5 py-0.5 text-[#666666]">Enter</kbd> 发送
          <span className="px-1.5">·</span>
          <kbd className="rounded bg-[#F5F5F5] px-1.5 py-0.5 text-[#666666]">
            Shift + Enter
          </kbd>{" "}
          换行
          {isStreaming ? <span className="ml-2 animate-pulse">生成中...</span> : null}
        </p>
      </div>
  );
}
