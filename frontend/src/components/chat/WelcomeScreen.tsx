import * as React from "react";
import { ArrowUpRight, Brain, Braces, Code2, Cpu, Lightbulb, Mic, MicOff, Send, Square } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";

import { FaceItMark } from "@/components/common/FaceItMark";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { cn } from "@/lib/utils";
import { recognizeSpeechBase64 } from "@/services/interviewService";
import { useChatStore } from "@/stores/chatStore";

type JobPreset = {
  id: string;
  title: string;
  description: string;
  icon: React.ComponentType<{ className?: string }>;
  positionKeywords: string[];
};

type InterviewPresetState = {
  positionKeywords: string[];
  difficulty: number;
  timeLimitMinutes: number;
  questionLimit: number;
};

const JOB_PRESETS: JobPreset[] = [
  {
    id: "web-frontend",
    title: "Web前端开发",
    description: "偏重 React、工程化、性能优化与浏览器基础",
    icon: Braces,
    positionKeywords: ["web前端", "前端", "react", "vue", "javascript", "typescript"]
  },
  {
    id: "java-backend",
    title: "Java后端开发",
    description: "覆盖 Java、Spring、数据库、并发与系统设计",
    icon: Code2,
    positionKeywords: ["java后端", "java", "后端", "spring", "spring boot"]
  },
  {
    id: "python-algorithm",
    title: "Python算法开发",
    description: "聚焦 Python、数据结构、算法思维与编码实现",
    icon: Cpu,
    positionKeywords: ["python算法", "python", "算法", "机器学习", "数据"]
  }
];

interface WelcomeScreenProps {
  disabled?: boolean;
}

export function WelcomeScreen({ disabled = false }: WelcomeScreenProps) {
  const navigate = useNavigate();
  const [value, setValue] = React.useState("");
  const [isFocused, setIsFocused] = React.useState(false);
  const [isRecording, setIsRecording] = React.useState(false);
  const [isRecognizingSpeech, setIsRecognizingSpeech] = React.useState(false);
  const [selectedJob, setSelectedJob] = React.useState<JobPreset | null>(null);
  const [interviewOptions, setInterviewOptions] = React.useState({
    difficulty: 3,
    timeLimitMinutes: 20,
    questionLimit: 5
  });
  const isComposingRef = React.useRef(false);
  const textareaRef = React.useRef<HTMLTextAreaElement | null>(null);
  const mediaRecorderRef = React.useRef<MediaRecorder | null>(null);
  const { sendMessage, isStreaming, cancelGeneration, deepThinkingEnabled, setDeepThinkingEnabled } =
    useChatStore();
  const isMediaRecorderSupported = React.useMemo(
    () => typeof window !== "undefined" && "MediaRecorder" in window,
    []
  );
  const isVoiceBusy = isRecording || isRecognizingSpeech;

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

  const handleSubmit = async () => {
    if (disabled) return;
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

  const hasContent = value.trim().length > 0;

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
        await recognizeSpeech(base64Audio);

        stream.getTracks().forEach((track) => track.stop());
        audioContext.close();
      };

      mediaRecorder.start();
      setIsRecording(true);
    } catch (error) {
      console.error("无法访问麦克风:", error);
      alert("无法访问麦克风，请检查权限设置");
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

  const blobToBase64 = React.useCallback(
    (blob: Blob) =>
      new Promise<string>((resolve, reject) => {
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
      }),
    []
  );

  const encodeWav = React.useCallback((samples: Float32Array, sampleRate: number) => {
    const buffer = new ArrayBuffer(44 + samples.length * 2);
    const view = new DataView(buffer);
    const writeString = (offset: number, chunk: string) => {
      for (let i = 0; i < chunk.length; i += 1) {
        view.setUint8(offset + i, chunk.charCodeAt(i));
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
    console.log("开始识别WAV语音，Base64长度:", base64Audio.length);

    setIsRecognizingSpeech(true);
    try {
      const text = await recognizeSpeechBase64(base64Audio, "wav", 16000, "zh_cn");
      console.log("识别结果:", text);

      if (text) {
        setValue((prev) => {
          const current = prev.trim();
          return current ? `${current} ${text}` : text;
        });
        focusInput();
      } else {
        alert("未识别到语音内容，请重试");
      }
    } catch (error) {
      console.error("语音识别错误:", error);
      alert("语音识别失败，请重试");
    } finally {
      setIsRecognizingSpeech(false);
    }
  };

  const openInterviewDialog = React.useCallback(
    (job: JobPreset) => {
      if (disabled) return;
      setSelectedJob(job);
    },
    [disabled]
  );

  const startPresetInterview = React.useCallback(() => {
    if (!selectedJob) return;
    const state: InterviewPresetState = {
      positionKeywords: selectedJob.positionKeywords,
      difficulty: interviewOptions.difficulty,
      timeLimitMinutes: interviewOptions.timeLimitMinutes,
      questionLimit: interviewOptions.questionLimit
    };
    setSelectedJob(null);
    navigate("/interview", { state });
  }, [interviewOptions.difficulty, interviewOptions.questionLimit, interviewOptions.timeLimitMinutes, navigate, selectedJob]);

  return (
    <div className="relative flex min-h-full items-center justify-center overflow-hidden px-4 py-16 sm:px-6">
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-0 bg-gradient-to-br from-[#F8FAFC] via-white to-[#EFF6FF]"
      />
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-0 bg-grid-pattern opacity-40 [background-size:40px_40px]"
      />
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -top-32 right-[-40px] h-72 w-72 rounded-full bg-gradient-radial from-[#BFDBFE]/60 via-transparent to-transparent blur-3xl animate-float"
      />
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -bottom-36 left-[-80px] h-80 w-80 rounded-full bg-gradient-radial from-[#FDE68A]/40 via-transparent to-transparent blur-3xl animate-float"
      />

      <div className="relative w-full max-w-[920px]">
        <div className="text-center opacity-0 animate-fade-up" style={{ animationFillMode: "both" }}>
          <span className="font-poppins inline-flex items-center gap-2 rounded-full border border-white/70 bg-white/70 px-3 py-1 text-xs font-medium text-[#2563EB] shadow-sm">
            <FaceItMark className="h-3.5 w-3.5" />
            Face It Assistant 智能助手
          </span>
          <h1 className="font-poppins mt-4 text-4xl font-semibold leading-tight tracking-tight text-[#111827] sm:text-5xl md:text-6xl">
            把问题变成
            <span className="text-gradient"> clear answers</span>
          </h1>
          <p className="mt-4 text-base text-[#4B5563] sm:text-lg">
            {disabled
              ? "Preview the chat experience first. 登录后即可发送消息、保存会话并使用完整能力。"
              : "结构化提问、知识检索与深度思考，在一个更专注的 workspace 里完成。"}
          </p>
        </div>

        <div className="mt-10 opacity-0 animate-fade-up" style={{ animationDelay: "80ms", animationFillMode: "both" }}>
          <div
            className={cn(
              "relative flex flex-col rounded-3xl border border-white/70 bg-white/80 px-5 pt-4 pb-3 shadow-soft backdrop-blur-xl transition-all duration-200",
              isFocused ? "border-[#BFDBFE] shadow-glow" : "hover:border-[#D4D4D4]"
            )}
          >
            <div className="relative">
              <textarea
                ref={textareaRef}
                value={value}
                onChange={(event) => setValue(event.target.value)}
                placeholder={
                  disabled
                    ? "Guest mode preview only. Please login to start chatting..."
                    : isRecognizingSpeech
                      ? "语音识别中，请稍候..."
                      : deepThinkingEnabled
                        ? "输入更需要深入分析的问题..."
                        : "输入你的问题，Ask anything..."
                }
                className="max-h-40 min-h-[52px] w-full resize-none border-0 bg-transparent px-2 pt-2 pb-2 text-[15px] text-[#1F2937] placeholder:text-[#9CA3AF] focus:outline-none sm:text-base"
                rows={1}
                disabled={disabled || isRecognizingSpeech}
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
              {isRecognizingSpeech ? <div className="pointer-events-none absolute inset-0 rounded-3xl bg-white/55" /> : null}
              <div className="pointer-events-none absolute bottom-0 left-0 right-0 h-[10px] bg-gradient-to-b from-white/0 via-white/40 to-white/90" />
            </div>
            <div className="mt-3 flex flex-wrap items-center gap-3">
              <button
                type="button"
                onClick={() => setDeepThinkingEnabled(!deepThinkingEnabled)}
                disabled={disabled || isStreaming || isRecognizingSpeech}
                aria-pressed={deepThinkingEnabled}
                className={cn(
                  "rounded-full border px-3 py-1.5 text-xs font-medium transition-all",
                  deepThinkingEnabled
                    ? "border-[#BFDBFE] bg-[#DBEAFE] text-[#2563EB]"
                    : "border-transparent bg-[#F5F5F5] text-[#6B7280] hover:bg-[#EEEEEE]",
                  (disabled || isStreaming || isRecognizingSpeech) && "cursor-not-allowed opacity-60"
                )}
              >
                <span className="inline-flex items-center gap-2">
                  <Brain className={cn("h-3.5 w-3.5", deepThinkingEnabled && "text-[#3B82F6]")} />
                  深度思考
                  {deepThinkingEnabled ? <span className="h-2 w-2 rounded-full bg-[#3B82F6] animate-pulse" /> : null}
                </span>
              </button>
              <div className="ml-auto flex items-center gap-2">
                {isMediaRecorderSupported && (
                  <button
                    type="button"
                    onClick={isRecording ? stopRecording : startRecording}
                    disabled={disabled || isStreaming || isRecognizingSpeech}
                    aria-label={isRecording ? "停止录音" : isRecognizingSpeech ? "语音识别中" : "开始录音"}
                    className={cn(
                      "rounded-full p-2.5 transition-all duration-200",
                      isVoiceBusy
                        ? "bg-[#DCFCE7] text-[#16A34A] hover:bg-[#BBF7D0]"
                        : "bg-[#F5F5F5] text-[#666666] hover:bg-[#EEEEEE]",
                      (disabled || isStreaming || isRecognizingSpeech) && "cursor-not-allowed opacity-60"
                    )}
                  >
                    {isRecognizingSpeech ? (
                      <span className="inline-flex h-4 items-end gap-0.5" aria-hidden="true">
                        {[0, 1, 2].map((index) => (
                          <span
                            key={index}
                            className="w-1 rounded-full bg-current animate-pulse"
                            style={{ height: `${10 + index * 2}px`, animationDelay: `${index * 140}ms` }}
                          />
                        ))}
                      </span>
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
                  disabled={disabled || (!hasContent && !isStreaming) || isRecognizingSpeech}
                  aria-label={isStreaming ? "停止生成" : "发送消息"}
                  className={cn(
                    "rounded-full p-2.5 transition-all duration-200",
                    isStreaming
                      ? "bg-[#FEE2E2] text-[#EF4444] hover:bg-[#FECACA]"
                      : hasContent
                        ? "bg-[#3B82F6] text-white hover:bg-[#2563EB]"
                        : "bg-[#F5F5F5] text-[#CCCCCC]",
                    (disabled || (!hasContent && !isStreaming) || isRecognizingSpeech) && "cursor-not-allowed"
                  )}
                >
                  {isStreaming ? <Square className="h-4 w-4" /> : <Send className="h-4 w-4" />}
                </button>
              </div>
            </div>
          </div>
          {disabled ? (
            <div className="mt-4 flex flex-wrap items-center justify-center gap-3">
              <Link
                to="/login"
                className="rounded-full bg-[#2563EB] px-4 py-2 text-sm font-medium text-white transition hover:bg-[#1D4ED8]"
              >
                Login
              </Link>
              <Link
                to="/login?mode=register"
                className="rounded-full border border-[#BFDBFE] bg-[#EFF6FF] px-4 py-2 text-sm font-medium text-[#2563EB] transition hover:bg-[#DBEAFE]"
              >
                Register
              </Link>
            </div>
          ) : null}
          {isRecognizingSpeech ? (
            <p className="mt-4 text-center text-sm text-[#16A34A]">
              <span className="inline-flex items-center gap-2">
                <span className="inline-flex items-end gap-0.5" aria-hidden="true">
                  {[0, 1, 2].map((index) => (
                    <span
                      key={index}
                      className="w-1 rounded-full bg-current animate-pulse"
                      style={{ height: `${10 + index * 2}px`, animationDelay: `${index * 140}ms` }}
                    />
                  ))}
                </span>
                语音识别中，请稍候...
              </span>
            </p>
          ) : null}
          {deepThinkingEnabled ? (
            <p className="mt-3 text-xs text-[#2563EB]">
              <span className="inline-flex items-center gap-1.5">
                <Lightbulb className="h-3.5 w-3.5" />
                深度思考模式已开启，AI将进行更深入的分析推理
              </span>
            </p>
          ) : null}
          <p className="mt-3 text-center text-xs text-[#94A3B8]">
            <kbd className="rounded bg-white/80 px-1.5 py-0.5 text-[#6B7280] shadow-sm">Enter</kbd> 发送
            <span className="px-1.5">·</span>
            <kbd className="rounded bg-white/80 px-1.5 py-0.5 text-[#6B7280] shadow-sm">Shift + Enter</kbd> 换行
            {isStreaming ? <span className="ml-2 animate-pulse-soft">生成中...</span> : null}
          </p>
        </div>

        <div className="mt-10 opacity-0 animate-fade-up" style={{ animationDelay: "160ms", animationFillMode: "both" }}>
          <div className="flex items-center justify-center gap-2 text-xs uppercase tracking-[0.24em] text-[#94A3B8]">
            <span className="h-px w-8 bg-[#E5E7EB]" />
            面试这些岗位
            <span className="h-px w-8 bg-[#E5E7EB]" />
          </div>
          <div className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {JOB_PRESETS.map((preset) => {
              const Icon = preset.icon;
              const isActive = selectedJob?.id === preset.id;
              return (
                <button
                  key={preset.id}
                  type="button"
                  onClick={() => openInterviewDialog(preset)}
                  disabled={disabled}
                  aria-pressed={isActive}
                  className={cn(
                    "group rounded-[26px] border p-5 text-left transition-all duration-200",
                    disabled
                      ? "cursor-not-allowed border-[#DBEAFE] bg-[#F8FBFF] opacity-60"
                      : isActive
                        ? "border-[#93C5FD] bg-[#EFF6FF] shadow-[0_18px_40px_rgba(59,130,246,0.16)]"
                        : "border-[#DBEAFE] bg-[#F8FBFF] shadow-[0_12px_28px_rgba(37,99,235,0.08)] hover:-translate-y-1 hover:border-[#93C5FD] hover:bg-[#F0F7FF] hover:shadow-[0_20px_42px_rgba(37,99,235,0.14)]"
                  )}
                >
                  <div className="flex items-start gap-3">
                    <span className="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#DBEAFE] text-[#2563EB] shadow-[inset_0_0_0_1px_rgba(147,197,253,0.35)]">
                      <Icon className="h-5 w-5" />
                    </span>
                    <div className="min-w-0 flex-1">
                      <p className="text-base font-semibold text-[#0F172A]">{preset.title}</p>
                      <p className="mt-1 text-sm leading-6 text-[#475569]">{preset.description}</p>
                    </div>
                  </div>
                  <div className="mt-5 flex items-center justify-between">
                    <span className="rounded-full border border-[#BFDBFE] bg-white px-3 py-1 text-xs font-medium text-[#2563EB]">
                      点击配置面试参数
                    </span>
                    <ArrowUpRight
                      className={cn(
                        "h-4 w-4 transition-colors",
                        isActive ? "text-[#2563EB]" : "text-[#94A3B8] group-hover:text-[#2563EB]"
                      )}
                    />
                  </div>
                </button>
              );
            })}
          </div>
        </div>
      </div>

      <Dialog
        open={Boolean(selectedJob)}
        onOpenChange={(open) => {
          if (!open) {
            setSelectedJob(null);
          }
        }}
      >
        <DialogContent className="max-w-xl border border-[#DBEAFE] bg-[#F8FBFF] p-0 shadow-[0_24px_60px_rgba(37,99,235,0.16)]">
          {selectedJob ? (
            <div className="p-6 sm:p-7">
                <DialogHeader>
                  <DialogTitle className="text-xl text-[#0F172A]">{selectedJob.title}</DialogTitle>
                  <DialogDescription className="text-sm leading-6 text-[#64748B]">
                    选择本次模拟面试参数，进入后会自动带入岗位、难度、时长和题量。
                  </DialogDescription>
                </DialogHeader>

                <div className="mt-5 grid gap-4 sm:grid-cols-3">
                  <label className="flex flex-col gap-2 text-sm text-[#475569]">
                    难度
                    <select
                      value={interviewOptions.difficulty}
                      onChange={(event) =>
                        setInterviewOptions((prev) => ({
                          ...prev,
                          difficulty: Number(event.target.value)
                        }))
                      }
                      className="h-11 rounded-2xl border border-[#BFDBFE] bg-white px-3 text-sm text-[#0F172A] outline-none transition-colors focus:border-[#60A5FA] focus:bg-[#F8FBFF]"
                    >
                      {[1, 2, 3, 4, 5].map((level) => (
                        <option key={level} value={level}>
                          {level}
                        </option>
                      ))}
                    </select>
                  </label>

                  <label className="flex flex-col gap-2 text-sm text-[#475569]">
                    时长
                    <select
                      value={interviewOptions.timeLimitMinutes}
                      onChange={(event) =>
                        setInterviewOptions((prev) => ({
                          ...prev,
                          timeLimitMinutes: Number(event.target.value)
                        }))
                      }
                      className="h-11 rounded-2xl border border-[#BFDBFE] bg-white px-3 text-sm text-[#0F172A] outline-none transition-colors focus:border-[#60A5FA] focus:bg-[#F8FBFF]"
                    >
                      {[10, 15, 20, 30, 45].map((minute) => (
                        <option key={minute} value={minute}>
                          {minute} 分钟
                        </option>
                      ))}
                    </select>
                  </label>

                  <label className="flex flex-col gap-2 text-sm text-[#475569]">
                    题量
                    <select
                      value={interviewOptions.questionLimit}
                      onChange={(event) =>
                        setInterviewOptions((prev) => ({
                          ...prev,
                          questionLimit: Number(event.target.value)
                        }))
                      }
                      className="h-11 rounded-2xl border border-[#BFDBFE] bg-white px-3 text-sm text-[#0F172A] outline-none transition-colors focus:border-[#60A5FA] focus:bg-[#F8FBFF]"
                    >
                      {[3, 5, 8, 10].map((count) => (
                        <option key={count} value={count}>
                          {count} 题
                        </option>
                      ))}
                    </select>
                  </label>
                </div>

                <div className="mt-5 rounded-2xl border border-[#DBEAFE] bg-[#EFF6FF] px-4 py-3 text-sm text-[#475569]">
                  当前配置：难度 {interviewOptions.difficulty}，时长 {interviewOptions.timeLimitMinutes} 分钟，题量 {interviewOptions.questionLimit} 题。
                </div>

                <DialogFooter className="mt-6 flex-col-reverse gap-3 sm:flex-row sm:justify-end">
                  <button
                    type="button"
                    className="h-11 rounded-2xl border border-[#BFDBFE] bg-white px-4 text-sm font-medium text-[#475569] transition-colors hover:bg-[#EFF6FF]"
                    onClick={() => setSelectedJob(null)}
                  >
                    取消
                  </button>
                  <button
                    type="button"
                    className="h-11 rounded-2xl bg-[#60A5FA] px-5 text-sm font-medium text-white transition-colors hover:bg-[#3B82F6]"
                    onClick={startPresetInterview}
                  >
                    去模拟面试
                  </button>
                </DialogFooter>
            </div>
          ) : null}
        </DialogContent>
      </Dialog>
    </div>
  );
}
