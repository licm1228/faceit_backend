import * as React from "react";
import { Brain, Lightbulb, Send, Square, Mic, MicOff, FileText, PlayCircle } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";

import { VoiceEqualizerIcon } from "@/components/common/VoiceInputVisual";
import { Textarea } from "@/components/ui/textarea";
import { cn } from "@/lib/utils";
import { listPositions, recognizeSpeechBase64, type Position, type SpeechAnalysis } from "@/services/interviewService";
import { useChatStore } from "@/stores/chatStore";
import { feedback } from "@/stores/useFeedbackStore";
import { analyzeSpeechFromSamples } from "@/utils/speechAnalysis";

declare global {
  interface Window {
    MediaRecorder: typeof MediaRecorder;
  }
}

export function ChatInput() {
  const navigate = useNavigate();
  const [value, setValue] = React.useState("");
  const [isFocused, setIsFocused] = React.useState(false);
  const [isRecording, setIsRecording] = React.useState(false);
  const [isRecognizingSpeech, setIsRecognizingSpeech] = React.useState(false);
  const [positions, setPositions] = React.useState<Position[]>([]);
  const isComposingRef = React.useRef(false);
  const textareaRef = React.useRef<HTMLTextAreaElement | null>(null);
  const mediaRecorderRef = React.useRef<MediaRecorder | null>(null);
  const pendingSpeechAnalysisRef = React.useRef<SpeechAnalysis | null>(null);
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
    inputFocusKey,
    currentSessionType,
    currentInterviewState,
    interviewDraftConfig,
    setInterviewDraftConfig,
    startInterviewSession
  } = useChatStore();

  React.useEffect(() => {
    listPositions()
      .then((items) => setPositions(items))
      .catch(() => setPositions([]));
  }, []);

  React.useEffect(() => {
    if (!interviewDraftConfig.positionId && positions.length > 0) {
      setInterviewDraftConfig({ positionId: positions[0].id });
    }
  }, [interviewDraftConfig.positionId, positions, setInterviewDraftConfig]);

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
    await sendMessage(next, pendingSpeechAnalysisRef.current);
    pendingSpeechAnalysisRef.current = null;
    focusInput();
  };

  const handleStartInterview = async () => {
    if (!interviewDraftConfig.positionId) {
      feedback.error("请先选择岗位");
      return;
    }
    try {
      const sessionId = await startInterviewSession(interviewDraftConfig);
      navigate(`/chat/${sessionId}`);
    } catch {
      return;
    }
  };

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

      let mimeType = "audio/webm";
      const types = [
        "audio/webm;codecs=opus",
        "audio/webm",
        "audio/ogg;codecs=opus",
        "audio/ogg",
        "audio/wav"
      ];

      for (const type of types) {
        if (MediaRecorder.isTypeSupported(type)) {
          mimeType = type;
          break;
        }
      }

      const audioContext = new AudioContext({ sampleRate: 16000 });
      const source = audioContext.createMediaStreamSource(stream);
      const processor = audioContext.createScriptProcessor(4096, 1, 1);
      const pcmDataRef: Float32Array[] = [];

      processor.onaudioprocess = (event) => {
        const inputData = event.inputBuffer.getChannelData(0);
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
        source.disconnect();
        processor.disconnect();

        const totalLength = pcmDataRef.reduce((sum, data) => sum + data.length, 0);
        const mergedData = new Float32Array(totalLength);
        let offset = 0;
        for (const data of pcmDataRef) {
          mergedData.set(data, offset);
          offset += data.length;
        }

        const wavBlob = encodeWav(mergedData, audioContext.sampleRate);
        const base64Audio = await blobToBase64(wavBlob);
        await recognizeSpeech(base64Audio, pcmDataRef, audioContext.sampleRate);

        stream.getTracks().forEach((track) => track.stop());
        audioContext.close();
      };

      mediaRecorder.start();
      setIsRecording(true);
    } catch (error) {
      console.error("无法访问麦克风:", error);
      feedback.error("无法访问麦克风，请检查权限设置");
      setIsRecording(false);
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && mediaRecorderRef.current.state === "recording") {
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

  const recognizeSpeech = async (base64Audio: string, samples?: Float32Array[], sampleRate = 16000) => {
    setIsRecognizingSpeech(true);
    try {
      const text = await recognizeSpeechBase64(base64Audio, "wav", 16000, "zh_cn");
      if (text) {
        pendingSpeechAnalysisRef.current = samples ? analyzeSpeechFromSamples(samples, sampleRate, text) : null;
        setValue((prev) => {
          const current = prev.trim();
          return current ? `${current} ${text}` : text;
        });
        focusInput();
      } else {
        feedback.error("未识别到语音内容，请重试");
      }
    } catch (error) {
      console.error("语音识别错误:", error);
      feedback.error("语音识别失败，请重试");
    } finally {
      setIsRecognizingSpeech(false);
    }
  };

  const hasContent = value.trim().length > 0;
  const showInterviewLauncher = currentSessionType !== "interview" || currentInterviewState?.status === "completed";
  const showActiveInterviewBanner =
    currentSessionType === "interview" &&
    currentInterviewState !== null &&
    currentInterviewState.status !== "completed";
  const showReportLink = currentSessionType === "interview" && currentInterviewState?.status === "completed";

  return (
    <div className="space-y-4">
      {showInterviewLauncher ? (
        <div className="rounded-2xl border border-[#DBEAFE] bg-[#F8FBFF] p-3">
          <div className="mb-3 flex items-center justify-between gap-3">
            <div>
              <p className="text-sm font-semibold text-[#0F172A]">聊天式模拟面试</p>
              <p className="text-xs text-[#64748B]">在聊天区直接开始面试，AI 会先给即时反馈，再决定是否继续追问，单题最多追问 3 次。</p>
            </div>
            <button
              type="button"
              onClick={handleStartInterview}
              disabled={isStreaming || !interviewDraftConfig.positionId}
              className="inline-flex h-10 items-center gap-2 rounded-xl bg-[#2563EB] px-4 text-sm font-medium text-white transition hover:bg-[#1D4ED8] disabled:cursor-not-allowed disabled:opacity-60"
            >
              <PlayCircle className="h-4 w-4" />
              开始面试
            </button>
          </div>
          <div className="grid gap-3 md:grid-cols-4">
            <select
              value={interviewDraftConfig.positionId}
              onChange={(event) => setInterviewDraftConfig({ positionId: event.target.value })}
              className="h-10 rounded-xl border border-[#D6E4FF] bg-white px-3 text-sm text-[#0F172A] outline-none"
            >
              <option value="">选择岗位</option>
              {positions.map((position) => (
                <option key={position.id} value={position.id}>
                  {position.name}
                </option>
              ))}
            </select>
            <select
              value={interviewDraftConfig.difficulty}
              onChange={(event) => setInterviewDraftConfig({ difficulty: Number(event.target.value) })}
              className="h-10 rounded-xl border border-[#D6E4FF] bg-white px-3 text-sm text-[#0F172A] outline-none"
            >
              {[1, 2, 3, 4, 5].map((level) => (
                <option key={level} value={level}>
                  难度 {level}
                </option>
              ))}
            </select>
            <select
              value={interviewDraftConfig.questionLimit}
              onChange={(event) => setInterviewDraftConfig({ questionLimit: Number(event.target.value) })}
              className="h-10 rounded-xl border border-[#D6E4FF] bg-white px-3 text-sm text-[#0F172A] outline-none"
            >
              {[3, 5, 8, 10].map((count) => (
                <option key={count} value={count}>
                  {count} 题
                </option>
              ))}
            </select>
            <select
              value={interviewDraftConfig.timeLimitMinutes}
              onChange={(event) => setInterviewDraftConfig({ timeLimitMinutes: Number(event.target.value) })}
              className="h-10 rounded-xl border border-[#D6E4FF] bg-white px-3 text-sm text-[#0F172A] outline-none"
            >
              {[10, 15, 20, 30, 45].map((minutes) => (
                <option key={minutes} value={minutes}>
                  {minutes} 分钟
                </option>
              ))}
            </select>
          </div>
        </div>
      ) : null}

      {showActiveInterviewBanner ? (
        <div className="flex items-center justify-between rounded-2xl border border-[#E5E7EB] bg-[#FAFAFA] px-4 py-3 text-sm">
          <div>
            <p className="font-semibold text-[#111827]">
              正在进行 {currentInterviewState.positionName || "模拟面试"}
            </p>
              <p className="text-[#6B7280]">
              当前难度 {currentInterviewState.difficulty} · {currentInterviewState.questionLimit} 题 · {currentInterviewState.timeLimitMinutes} 分钟
            </p>
          </div>
          <span className="rounded-full bg-[#DBEAFE] px-3 py-1 text-xs font-medium text-[#2563EB]">
            第 {currentInterviewState.runtime?.questionIndex || currentInterviewState.currentQuestionCount || 1} 题进行中
          </span>
        </div>
      ) : null}

      {showReportLink && currentInterviewState?.id ? (
        <div className="flex items-center justify-between rounded-2xl border border-[#DBEAFE] bg-[#EFF6FF] px-4 py-3">
          <div>
            <p className="text-sm font-semibold text-[#0F172A]">本场面试已结束</p>
            <p className="text-xs text-[#64748B]">查看结构化评估报告与推荐练习。</p>
          </div>
          <Link
            to={`/interview-report/${currentInterviewState.id}`}
            className="inline-flex h-10 items-center gap-2 rounded-xl bg-white px-4 text-sm font-medium text-[#2563EB] shadow-sm transition hover:bg-[#F8FAFC]"
          >
            <FileText className="h-4 w-4" />
            查看报告
          </Link>
        </div>
      ) : null}

      <p className="text-center text-xs text-[#999999]">
        <kbd className="rounded bg-[#F5F5F5] px-1.5 py-0.5 text-[#666666]">Enter</kbd> 发送
        <span className="px-1.5">·</span>
        <kbd className="rounded bg-[#F5F5F5] px-1.5 py-0.5 text-[#666666]">Shift + Enter</kbd> 换行
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
            onChange={(event) => {
              pendingSpeechAnalysisRef.current = null;
              setValue(event.target.value);
            }}
            placeholder={
              isRecognizingSpeech
                ? "语音识别中，请稍候..."
                : currentSessionType === "interview" && currentInterviewState?.status !== "completed"
                  ? "直接回答当前问题，AI 会先给简短反馈，再决定追问或进入下一题..."
                  : deepThinkingEnabled
                    ? "输入更需要深入分析的问题，或直接说出你的面试要求..."
                    : "输入你的问题，或者直接说“来一场 Java 后端 30 分钟 5 题的面试”..."
            }
            className="max-h-40 min-h-[52px] w-full resize-none border-0 bg-transparent px-0 pt-2 pb-2 text-[15px] text-[#1F2937] placeholder:text-[#9CA3AF] focus:outline-none sm:text-base"
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
            aria-label="发送消息"
          />
        </div>
        <div className="mt-3 flex items-center gap-2">
          <button
            type="button"
            onClick={() => setDeepThinkingEnabled(!deepThinkingEnabled)}
            disabled={isStreaming || isRecognizingSpeech || currentSessionType === "interview"}
            aria-pressed={deepThinkingEnabled}
            className={cn(
              "rounded-full border px-3 py-1.5 text-xs font-medium transition-all",
              deepThinkingEnabled
                ? "border-[#BFDBFE] bg-[#DBEAFE] text-[#2563EB]"
                : "border-transparent bg-[#F5F5F5] text-[#6B7280] hover:bg-[#EEEEEE]",
              (isStreaming || isRecognizingSpeech || currentSessionType === "interview") && "cursor-not-allowed opacity-60"
            )}
          >
            <span className="inline-flex items-center gap-2">
              <Brain className={cn("h-3.5 w-3.5", deepThinkingEnabled && "text-[#3B82F6]")} />
              深度思考
            </span>
          </button>
          <div className="ml-auto flex items-center gap-2">
            {isMediaRecorderSupported ? (
              <button
                type="button"
                onClick={isRecording ? stopRecording : startRecording}
                disabled={isStreaming || isRecognizingSpeech}
                aria-label={isRecording ? "停止录音" : "开始录音"}
                className={cn(
                  "inline-flex h-10 w-10 items-center justify-center rounded-full transition-all duration-200",
                  isRecording || isRecognizingSpeech
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
            ) : null}
            <button
              type="button"
              onClick={handleSubmit}
              disabled={(!hasContent && !isStreaming) || isRecognizingSpeech}
              aria-label={isStreaming ? "停止生成" : "发送消息"}
              className={cn(
                "inline-flex h-10 w-10 items-center justify-center rounded-full transition-all duration-200",
                isStreaming
                  ? "bg-[#FEE2E2] text-[#EF4444] hover:bg-[#FECACA]"
                  : hasContent
                    ? "bg-[#3B82F6] text-white hover:bg-[#2563EB]"
                    : "bg-[#F5F5F5] text-[#CCCCCC]"
              )}
            >
              {isStreaming ? <Square className="h-4 w-4" /> : <Send className="h-4 w-4" />}
            </button>
          </div>
        </div>
      </div>

      {deepThinkingEnabled && currentSessionType !== "interview" ? (
        <p className="text-xs text-[#2563EB]">
          <span className="inline-flex items-center gap-1.5">
            <Lightbulb className="h-3.5 w-3.5" />
            深度思考模式已开启，普通问答会使用更深入的分析推理。
          </span>
        </p>
      ) : null}
    </div>
  );
}
