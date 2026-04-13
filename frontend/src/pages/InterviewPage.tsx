import * as React from "react";
import { Mic, MicOff, Timer } from "lucide-react";
import ReactMarkdown from "react-markdown";
import { useLocation, useNavigate } from "react-router-dom";
import { feedback } from "@/stores/useFeedbackStore";
import { CartesianGrid, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

import { Button } from "@/components/ui/button";
import { VoiceEqualizerIcon } from "@/components/common/VoiceInputVisual";
import { useTypewriterText } from "@/hooks/useTypewriterText";
import { MainLayout } from "@/components/layout/MainLayout";
import { recognizeSpeechBase64, type Position } from "@/services/interviewService";
import { useAuthStore } from "@/stores/authStore";
import { useInterviewStore } from "@/stores/interviewStore";

const QUESTION_LIMIT = 5;
const QUESTION_TIME_LIMIT_SECONDS = 180;

type SpeechRecognitionAlternative = {
  transcript: string;
};

type SpeechRecognitionResult = {
  0: SpeechRecognitionAlternative;
};

type SpeechRecognitionEvent = {
  resultIndex: number;
  results: SpeechRecognitionResult[];
};

type SpeechRecognitionLike = {
  lang: string;
  continuous: boolean;
  interimResults: boolean;
  onresult: ((event: SpeechRecognitionEvent) => void) | null;
  onerror: (() => void) | null;
  onend: (() => void) | null;
  start: () => void;
  stop: () => void;
};

type SpeechRecognitionCtor = new () => SpeechRecognitionLike;

type SpeechWindow = Window & {
  SpeechRecognition?: SpeechRecognitionCtor;
  webkitSpeechRecognition?: SpeechRecognitionCtor;
};

type RecordingMode = "backend" | "browser" | null;

type InterviewPresetState = {
  positionId?: string;
  positionKeywords?: string[];
  difficulty?: number;
  timeLimitMinutes?: number;
  questionLimit?: number;
  autoStart?: boolean;
};

type PendingAutoStartPreset = {
  key: string;
  positionId: string;
  timeLimitMinutes?: number;
  questionLimit?: number;
};

const RECORDING_SAMPLE_RATE = 16000;

function getSessionStatusLabel(status?: string) {
  switch ((status || "").toLowerCase()) {
    case "completed":
      return "已结束";
    case "in_progress":
      return "进行中";
    case "pending":
      return "未开始";
    default:
      return status || "未开始";
  }
}

function getSessionTitle(sessionId: string) {
  const suffix = sessionId?.slice(-6) || sessionId;
  return `面试 #${suffix}`;
}

function matchPositionKeywords(position: Position, keywords: string[]) {
  if (keywords.length === 0) {
    return false;
  }
  const searchText = [
    position.name,
    position.description,
    position.requiredSkills,
    position.interviewFocus
  ]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();

  return keywords.some((keyword) => searchText.includes(keyword));
}

function TypewriterCursor() {
  return <span className="ml-1 inline-block h-4 w-1.5 animate-pulse rounded-sm bg-current align-middle" />;
}

export function InterviewPage() {
  const location = useLocation();
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const {
    positions,
    history,
    currentSession,
    currentQuestion,
    currentEvaluation,
    followUpQuestion,
    sessionDetail,
    profile,
    growthCurve,
    recommendation,
    difficulty,
    loading,
    submitting,
    isStreamingEvaluation,
    isStreamingFollowUp,
    isStreamingReport,
    streamingFeedback,
    streamingSuggestions,
    streamingFollowUpText,
    streamingReport,
    fetchPositions,
    fetchHistory,
    createAndStartSession,
    fetchQuestion,
    submitAnswer,
    generateFollowUp,
    completeSession,
    fetchSessionDetail,
    fetchProfileData,
    setDifficulty,
    cancelStreaming,
    resetCurrentFlow
  } = useInterviewStore();
  const [selectedPositionId, setSelectedPositionId] = React.useState("");
  const [answerText, setAnswerText] = React.useState("");
  const [questionIndex, setQuestionIndex] = React.useState(0);
  const [secondsLeft, setSecondsLeft] = React.useState(QUESTION_TIME_LIMIT_SECONDS);
  const [timeLimitMinutes, setTimeLimitMinutes] = React.useState(20);
  const [questionLimit, setQuestionLimit] = React.useState(QUESTION_LIMIT);
  const [answerRecords, setAnswerRecords] = React.useState<
    Array<{ questionText: string; score: number; feedback: string; suggestions: string }>
  >([]);
  const [isRecording, setIsRecording] = React.useState(false);
  const [isProcessingSpeech, setIsProcessingSpeech] = React.useState(false);
  const reportRef = React.useRef<HTMLDivElement | null>(null);
  const recognitionRef = React.useRef<SpeechRecognitionLike | null>(null);
  const recordingModeRef = React.useRef<RecordingMode>(null);
  const mediaStreamRef = React.useRef<MediaStream | null>(null);
  const audioContextRef = React.useRef<AudioContext | null>(null);
  const sourceNodeRef = React.useRef<MediaStreamAudioSourceNode | null>(null);
  const processorNodeRef = React.useRef<ScriptProcessorNode | null>(null);
  const pcmChunksRef = React.useRef<Float32Array[]>([]);
  const appliedPresetRef = React.useRef<string | null>(null);
  const autoStartedPresetRef = React.useRef<string | null>(null);
  const pendingAutoStartPresetRef = React.useRef<PendingAutoStartPreset | null>(null);

  React.useEffect(() => {
    fetchPositions().catch(() => null);
  }, [fetchPositions]);

  React.useEffect(() => {
    if (!user?.userId) return;
    fetchHistory(user.userId).catch(() => null);
    fetchProfileData().catch(() => null);
  }, [fetchHistory, fetchProfileData, user?.userId]);

  const startInterviewWithPosition = React.useCallback(async (
    positionId: string,
    options?: { timeLimitMinutes?: number; questionLimit?: number }
  ) => {
    if (!user?.userId || !positionId) return;
    setAnswerText("");
    setQuestionIndex(1);
    setSecondsLeft(QUESTION_TIME_LIMIT_SECONDS);
    setAnswerRecords([]);
    await createAndStartSession(user.userId, positionId, {
      timeLimit: options?.timeLimitMinutes ?? timeLimitMinutes,
      totalQuestions: options?.questionLimit ?? questionLimit
    });
  }, [createAndStartSession, questionLimit, timeLimitMinutes, user?.userId]);

  React.useEffect(() => {
    if (positions.length === 0) {
      return;
    }

    const preset = location.state as InterviewPresetState | null;
    const presetKey = JSON.stringify(preset ?? {});
    const hasPreset = Boolean(preset && Object.keys(preset).length > 0);

    if (hasPreset && appliedPresetRef.current !== presetKey) {
      const keywords = (preset?.positionKeywords ?? []).map((keyword) => keyword.trim().toLowerCase());
      const matchedPositionById = preset?.positionId
        ? positions.find((position) => position.id === preset.positionId)
        : null;
      const matchedPositionByKeywords = positions.find((position) => matchPositionKeywords(position, keywords));
      const matchedPosition = matchedPositionById ?? matchedPositionByKeywords ?? positions[0];

      setSelectedPositionId(matchedPosition.id);

      if (typeof preset?.difficulty === "number") {
        setDifficulty(preset.difficulty);
      }
      if (typeof preset?.timeLimitMinutes === "number") {
        setTimeLimitMinutes(preset.timeLimitMinutes);
      }
      if (typeof preset?.questionLimit === "number") {
        setQuestionLimit(preset.questionLimit);
      }

      appliedPresetRef.current = presetKey;

      if (preset?.autoStart && autoStartedPresetRef.current !== presetKey) {
        pendingAutoStartPresetRef.current = {
          key: presetKey,
          positionId: matchedPosition.id,
          timeLimitMinutes: preset.timeLimitMinutes,
          questionLimit: preset.questionLimit
        };
      }

      navigate(location.pathname, { replace: true, state: null });
      return;
    }

    if (!selectedPositionId) {
      setSelectedPositionId(positions[0].id);
    }
  }, [
    location.pathname,
    location.state,
    navigate,
    positions,
    selectedPositionId,
    setDifficulty,
    startInterviewWithPosition,
    user?.userId
  ]);

  React.useEffect(() => {
    const pendingPreset = pendingAutoStartPresetRef.current;
    if (!pendingPreset || !user?.userId) {
      return;
    }
    if (autoStartedPresetRef.current === pendingPreset.key) {
      pendingAutoStartPresetRef.current = null;
      return;
    }

    autoStartedPresetRef.current = pendingPreset.key;
    pendingAutoStartPresetRef.current = null;

    startInterviewWithPosition(pendingPreset.positionId, {
      timeLimitMinutes: pendingPreset.timeLimitMinutes,
      questionLimit: pendingPreset.questionLimit
    }).catch(() => {
      autoStartedPresetRef.current = null;
    });
  }, [startInterviewWithPosition, user?.userId]);

  const startInterview = React.useCallback(async () => {
    if (!selectedPositionId) return;
    await startInterviewWithPosition(selectedPositionId);
  }, [selectedPositionId, startInterviewWithPosition]);

  const handleSubmitAnswer = React.useCallback(async () => {
    const next = answerText.trim();
    if (!next) return;
    await submitAnswer(next);
  }, [answerText, submitAnswer]);

  const handleNextQuestion = React.useCallback(async () => {
    if (questionIndex >= questionLimit) {
      feedback.info("已达到题量上限，请结束面试并查看报告");
      return;
    }
    setAnswerText("");
    setSecondsLeft(QUESTION_TIME_LIMIT_SECONDS);
    setQuestionIndex((prev) => prev + 1);
    await fetchQuestion();
  }, [fetchQuestion, questionIndex, questionLimit]);

  React.useEffect(() => {
    if (!currentSession || currentSession.status === "completed") {
      return;
    }
    const timer = window.setInterval(() => {
      setSecondsLeft((prev) => {
        if (prev <= 1) {
          window.clearInterval(timer);
          feedback.warning("当前题目作答时间已到，请提交或进入下一题");
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => window.clearInterval(timer);
  }, [currentQuestion?.id, currentSession]);

  React.useEffect(() => {
    if (!currentEvaluation || !currentQuestion) return;
    setAnswerRecords((prev) => [
      ...prev,
      {
        questionText: currentQuestion.questionText,
        score: currentEvaluation.score,
        feedback: currentEvaluation.feedback,
        suggestions: currentEvaluation.suggestions
      }
    ]);
  }, [currentEvaluation, currentQuestion]);

  React.useEffect(() => {
    return () => {
      if (recognitionRef.current) {
        recognitionRef.current.stop();
      }
      stopBackendRecording();
    };
  }, []);

  React.useEffect(() => {
    if (currentSession?.status === "completed") {
      reportRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  }, [currentSession?.status]);

  const stopBackendRecording = React.useCallback(async () => {
    const sampleRate = audioContextRef.current?.sampleRate ?? RECORDING_SAMPLE_RATE;
    const chunks = [...pcmChunksRef.current];
    processorNodeRef.current?.disconnect();
    sourceNodeRef.current?.disconnect();
    mediaStreamRef.current?.getTracks().forEach((track) => track.stop());
    processorNodeRef.current = null;
    sourceNodeRef.current = null;
    mediaStreamRef.current = null;
    if (audioContextRef.current) {
      await audioContextRef.current.close();
      audioContextRef.current = null;
    }
    pcmChunksRef.current = [];
    return { sampleRate, chunks };
  }, []);

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

  const mergePcmChunks = React.useCallback((chunks: Float32Array[]) => {
    const totalLength = chunks.reduce((sum, chunk) => sum + chunk.length, 0);
    const merged = new Float32Array(totalLength);
    let offset = 0;
    chunks.forEach((chunk) => {
      merged.set(chunk, offset);
      offset += chunk.length;
    });
    return merged;
  }, []);

  const downsampleBuffer = React.useCallback((buffer: Float32Array, sourceRate: number, targetRate: number) => {
    if (targetRate >= sourceRate) {
      return buffer;
    }
    const ratio = sourceRate / targetRate;
    const newLength = Math.round(buffer.length / ratio);
    const result = new Float32Array(newLength);
    let offsetResult = 0;
    let offsetBuffer = 0;
    while (offsetResult < result.length) {
      const nextOffsetBuffer = Math.round((offsetResult + 1) * ratio);
      let accum = 0;
      let count = 0;
      for (let i = offsetBuffer; i < nextOffsetBuffer && i < buffer.length; i += 1) {
        accum += buffer[i];
        count += 1;
      }
      result[offsetResult] = count > 0 ? accum / count : 0;
      offsetResult += 1;
      offsetBuffer = nextOffsetBuffer;
    }
    return result;
  }, []);

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

  const transcribeBackendAudio = React.useCallback(async (chunks: Float32Array[], sourceSampleRate: number) => {
    const merged = mergePcmChunks(chunks);
    if (merged.length === 0) {
      feedback.info("未识别到有效语音内容");
      return;
    }
    const downsampled = downsampleBuffer(merged, sourceSampleRate, RECORDING_SAMPLE_RATE);
    const wavBlob = encodeWav(downsampled, RECORDING_SAMPLE_RATE);
    const audioBase64 = await blobToBase64(wavBlob);
    const transcript = await recognizeSpeechBase64(audioBase64, "wav", RECORDING_SAMPLE_RATE, "zh_cn");
    if (transcript?.trim()) {
      setAnswerText((prev) => `${prev}${prev ? " " : ""}${transcript.trim()}`);
      feedback.success("语音识别完成");
      return;
    }
    feedback.info("未识别到有效语音内容");
  }, [blobToBase64, downsampleBuffer, encodeWav, mergePcmChunks]);

  const stopCurrentRecording = React.useCallback(async () => {
    const mode = recordingModeRef.current;
    recordingModeRef.current = null;
    setIsRecording(false);
    if (mode === "browser") {
      setIsProcessingSpeech(true);
      recognitionRef.current?.stop();
      return;
    }
    if (mode === "backend") {
      setIsProcessingSpeech(true);
      try {
        const { sampleRate, chunks } = await stopBackendRecording();
        await transcribeBackendAudio(chunks, sampleRate);
      } finally {
        setIsProcessingSpeech(false);
      }
    }
  }, [stopBackendRecording, transcribeBackendAudio]);

  const startBrowserSpeechRecognition = React.useCallback((ctor: SpeechRecognitionCtor) => {
    const recognition = new ctor();
    recognition.lang = "zh-CN";
    recognition.continuous = true;
    recognition.interimResults = true;
    recognition.onresult = (event: SpeechRecognitionEvent) => {
      let transcript = "";
      for (let i = event.resultIndex; i < event.results.length; i += 1) {
        transcript += event.results[i][0].transcript || "";
      }
      if (transcript.trim()) {
        setAnswerText((prev) => `${prev}${prev ? " " : ""}${transcript.trim()}`);
      }
    };
    recognition.onerror = () => {
      setIsRecording(false);
      setIsProcessingSpeech(false);
      recordingModeRef.current = null;
      feedback.error("语音识别失败，请重试");
    };
    recognition.onend = () => {
      setIsRecording(false);
      setIsProcessingSpeech(false);
      recordingModeRef.current = null;
    };
    recognitionRef.current = recognition;
    recognition.start();
    recordingModeRef.current = "browser";
    setIsRecording(true);
    feedback.info("已切换为浏览器语音识别");
  }, []);

  const startBackendRecording = React.useCallback(async () => {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    const audioContext = new AudioContext();
    const source = audioContext.createMediaStreamSource(stream);
    const processor = audioContext.createScriptProcessor(4096, 1, 1);
    pcmChunksRef.current = [];

    processor.onaudioprocess = (event) => {
      const channelData = event.inputBuffer.getChannelData(0);
      pcmChunksRef.current.push(new Float32Array(channelData));
    };

    source.connect(processor);
    processor.connect(audioContext.destination);

    mediaStreamRef.current = stream;
    audioContextRef.current = audioContext;
    sourceNodeRef.current = source;
    processorNodeRef.current = processor;
    recordingModeRef.current = "backend";
    setIsRecording(true);
    feedback.info("开始录音，再次点击后将调用后端语音识别");
  }, []);

  const toggleRecording = React.useCallback(async () => {
    const speechWindow = window as SpeechWindow;
    const ctor = speechWindow.SpeechRecognition || speechWindow.webkitSpeechRecognition;
    if (isProcessingSpeech) {
      return;
    }
    if (isRecording) {
      await stopCurrentRecording();
      return;
    }

    try {
      if (
        navigator.mediaDevices &&
        typeof navigator.mediaDevices.getUserMedia === "function"
      ) {
        await startBackendRecording();
        return;
      }
    } catch (error) {
      if (!ctor) {
        feedback.error((error as Error).message || "无法访问麦克风，请检查权限");
        return;
      }
      feedback.warning("后端语音录音不可用，已降级到浏览器语音识别");
    }

    if (!ctor) {
      feedback.error("当前环境不支持语音识别，请检查麦克风权限或浏览器能力");
      return;
    }
    startBrowserSpeechRecognition(ctor);
  }, [isProcessingSpeech, isRecording, startBackendRecording, startBrowserSpeechRecognition, stopCurrentRecording]);

  const sessionQuestionLimit = currentSession?.totalQuestions ?? questionLimit;
  const sessionQuestionIndex = currentSession?.currentQuestionCount ?? Math.max(questionIndex, 1);
  const hasActiveSession = Boolean(currentSession && currentSession.status !== "completed");
  const progressValue = hasActiveSession ? sessionQuestionIndex : Math.max(questionIndex, 1);
  const progressPercent = Math.min(100, Math.round((progressValue / sessionQuestionLimit) * 100));
  const currentEvaluationMetrics = [
    { label: "技术", value: currentEvaluation?.technicalScore ?? 0, max: 30 },
    { label: "表达", value: currentEvaluation?.expressionScore ?? 0, max: 25 },
    { label: "逻辑", value: currentEvaluation?.logicScore ?? 0, max: 25 },
    { label: "知识", value: currentEvaluation?.knowledgeScore ?? 0, max: 20 }
  ];
  const minutePart = String(Math.floor(secondsLeft / 60)).padStart(2, "0");
  const secondPart = String(secondsLeft % 60).padStart(2, "0");
  const trendData = React.useMemo(() => {
    const source = growthCurve.length > 0
      ? growthCurve.map((item) => ({
        createTime: item.time,
        totalScore: item.score
      }))
      : history;
    return [...source]
      .filter((item) => typeof item.totalScore === "number")
      .sort((a, b) => new Date(a.createTime || 0).getTime() - new Date(b.createTime || 0).getTime())
      .map((item, index) => ({
        index: index + 1,
        score: item.totalScore as number
      }));
  }, [growthCurve, history]);
  const typedQuestionText = useTypewriterText({
    text: currentQuestion?.questionText,
    enabled: Boolean(currentQuestion?.questionText),
    resetKey: currentQuestion?.id ?? currentSession?.id ?? "question"
  });
  const typedFeedbackText = useTypewriterText({
    text: currentEvaluation?.feedback,
    enabled: Boolean(currentEvaluation?.feedback) && !streamingFeedback,
    resetKey: currentQuestion?.id ? `${currentQuestion.id}-feedback` : "feedback"
  });
  const typedSuggestionsText = useTypewriterText({
    text: currentEvaluation?.suggestions,
    enabled: Boolean(currentEvaluation?.suggestions) && !streamingSuggestions,
    resetKey: currentQuestion?.id ? `${currentQuestion.id}-suggestions` : "suggestions"
  });
  const typedFollowUpText = useTypewriterText({
    text: followUpQuestion?.questionText,
    enabled: Boolean(followUpQuestion?.questionText) && !streamingFollowUpText,
    resetKey: followUpQuestion?.id ?? followUpQuestion?.questionText ?? "follow-up"
  });
  const typedReportText = useTypewriterText({
    text: currentSession?.evaluationReport,
    enabled: Boolean(currentSession?.evaluationReport) && !streamingReport,
    resetKey: currentSession?.id ? `${currentSession.id}-report` : "report"
  });
  const visibleFeedbackText = streamingFeedback || typedFeedbackText.displayText;
  const visibleSuggestionsText = streamingSuggestions || typedSuggestionsText.displayText;
  const visibleFollowUpText = streamingFollowUpText || typedFollowUpText.displayText;
  const visibleReportText = streamingReport || typedReportText.displayText;

  return (
    <MainLayout>
      <div className="h-full overflow-y-auto bg-[#FAFAFA] px-4 py-4 lg:px-6">
        <div className="mx-auto grid w-full max-w-[1240px] gap-4 lg:grid-cols-[1.15fr_0.85fr]">
          <section className="rounded-2xl border border-[#E8EDF3] bg-white p-4 shadow-sm lg:p-5">
            <div className="flex flex-wrap items-center gap-3">
              <h1 className="text-lg font-semibold text-[#1F2937]">面试模式</h1>
              {currentSession ? (
                <span className="rounded-full bg-[#EEF6FF] px-3 py-1 text-xs font-semibold text-[#2563EB]">
                  状态：{getSessionStatusLabel(currentSession.status)}
                </span>
              ) : null}
              {hasActiveSession ? (
                <span className="rounded-full bg-[#ECFDF5] px-3 py-1 text-xs font-semibold text-[#059669]">
                  进度：{progressValue}/{sessionQuestionLimit}
                </span>
              ) : null}
            </div>
            {hasActiveSession ? (
              <div className="mt-3">
                <div className="h-2.5 w-full rounded-full bg-[#E5E7EB]">
                  <div
                    className="h-2.5 rounded-full bg-[#3B82F6] transition-all"
                    style={{ width: `${progressPercent}%` }}
                  />
                </div>
              </div>
            ) : null}

            <div className="mt-4 grid gap-3 md:grid-cols-3">
              <label className="flex flex-col gap-1.5 text-sm text-[#4B5563]">
                岗位
                <select
                  className="h-10 rounded-xl border border-[#D9E3EF] bg-white px-3 text-sm text-[#111827] outline-none transition-colors focus:border-[#60A5FA]"
                  value={selectedPositionId}
                  onChange={(event) => setSelectedPositionId(event.target.value)}
                  disabled={hasActiveSession}
                >
                  {positions.map((position) => (
                    <option key={position.id} value={position.id}>
                      {position.name}
                    </option>
                  ))}
                </select>
              </label>

              <label className="flex flex-col gap-1.5 text-sm text-[#4B5563]">
                难度
                <select
                  className="h-10 rounded-xl border border-[#D9E3EF] bg-white px-3 text-sm text-[#111827] outline-none transition-colors focus:border-[#60A5FA]"
                  value={difficulty}
                  onChange={(event) => setDifficulty(Number(event.target.value))}
                  disabled={hasActiveSession}
                >
                  {[1, 2, 3, 4, 5].map((level) => (
                    <option key={level} value={level}>
                      {level}
                    </option>
                  ))}
                </select>
              </label>

              <label className="flex flex-col gap-1.5 text-sm text-[#4B5563]">
                题量
                <select
                  className="h-10 rounded-xl border border-[#D9E3EF] bg-white px-3 text-sm text-[#111827] outline-none transition-colors focus:border-[#60A5FA]"
                  value={questionLimit}
                  onChange={(event) => setQuestionLimit(Number(event.target.value))}
                  disabled={hasActiveSession}
                >
                  {[3, 5, 8, 10].map((count) => (
                    <option key={count} value={count}>
                      {count}
                    </option>
                  ))}
                </select>
              </label>

              <label className="flex flex-col gap-1.5 text-sm text-[#4B5563]">
                时长（分钟）
                <select
                  className="h-10 rounded-xl border border-[#D9E3EF] bg-white px-3 text-sm text-[#111827] outline-none transition-colors focus:border-[#60A5FA]"
                  value={timeLimitMinutes}
                  onChange={(event) => setTimeLimitMinutes(Number(event.target.value))}
                  disabled={hasActiveSession}
                >
                  {[10, 15, 20, 30, 45].map((minute) => (
                    <option key={minute} value={minute}>
                      {minute}
                    </option>
                  ))}
                </select>
              </label>

              <div className="flex items-end gap-2 md:flex-col md:items-stretch">
                {hasActiveSession ? (
                  <div className="mb-2 flex items-center gap-1 rounded-xl border border-[#FDE68A] bg-[#FFFBEB] px-2.5 py-2 text-xs text-[#92400E]">
                    <Timer className="h-3.5 w-3.5" />
                    本题剩余 {minutePart}:{secondPart}
                  </div>
                ) : null}
                {!hasActiveSession ? (
                  <Button
                    type="button"
                    className="h-10 w-full rounded-xl"
                    onClick={() => {
                      startInterview().catch(() => null);
                    }}
                    disabled={loading || !selectedPositionId}
                  >
                    {currentSession?.status === "completed" ? "开始新面试" : "开始面试"}
                  </Button>
                ) : (
                  <Button
                    type="button"
                    variant="outline"
                    className="h-10 w-full rounded-xl border-[#FECACA] text-[#B91C1C] hover:bg-[#FEF2F2]"
                    onClick={() => {
                      completeSession().catch(() => null);
                    }}
                    disabled={loading}
                  >
                    结束面试
                  </Button>
                )}
              </div>
            </div>

            {currentQuestion ? (
              <div className="mt-5 rounded-2xl border border-[#E6EEF6] bg-[#FCFEFF] p-4">
                <p className="text-xs font-medium text-[#64748B]">当前题目</p>
                <p className="mt-2 whitespace-pre-wrap text-sm leading-6 text-[#1E293B]">
                  {typedQuestionText.displayText}
                  {typedQuestionText.isAnimating ? <TypewriterCursor /> : null}
                </p>
                <div className="mt-2 text-xs text-[#64748B]">
                  难度：{currentQuestion.difficulty ?? difficulty}
                </div>
              </div>
            ) : (
              <div className="mt-5 rounded-2xl border border-dashed border-[#D9E3EF] bg-[#FAFCFF] p-4 text-sm text-[#64748B]">
                {currentSession ? "暂无题目，点击“下一题”重试。" : "请选择岗位后开始面试。"}
              </div>
            )}

            {currentSession ? (
              <div className="mt-4">
                <label className="mb-2 block text-sm font-medium text-[#374151]">你的回答</label>
                <textarea
                  value={answerText}
                  onChange={(event) => setAnswerText(event.target.value)}
                  placeholder={
                    isProcessingSpeech
                      ? "语音解析中..."
                      : hasActiveSession
                        ? "请输入你的回答..."
                        : "当前面试已结束，请开始新面试。"
                  }
                  className="min-h-[148px] w-full rounded-2xl border border-[#D9E3EF] bg-white px-3 py-3 text-sm leading-6 text-[#1F2937] outline-none transition-colors focus:border-[#60A5FA]"
                  disabled={!hasActiveSession || isProcessingSpeech}
                />
                {isProcessingSpeech ? (
                  <div className="mt-3 flex items-center rounded-2xl border border-[#FDE7B2] bg-[#FFF8E8] px-3 py-2 text-sm text-[#9A5B16]">
                    <VoiceEqualizerIcon className="mr-2 text-current" />
                    语音解析中，结果会自动填入回答框
                  </div>
                ) : (
                  <div className="mt-3 flex flex-wrap gap-2">
                    <Button
                      type="button"
                      variant="outline"
                      className="h-10 rounded-xl"
                      onClick={toggleRecording}
                      disabled={currentSession.status === "completed"}
                    >
                      {isRecording ? (
                        <MicOff className="mr-1 h-4 w-4" />
                      ) : (
                        <Mic className="mr-1 h-4 w-4" />
                      )}
                      {isRecording ? "停止语音输入" : "语音输入"}
                    </Button>
                    <Button
                      type="button"
                      className="h-10 rounded-xl"
                      onClick={() => {
                        handleSubmitAnswer().catch(() => null);
                      }}
                      disabled={submitting || isStreamingEvaluation || !hasActiveSession || !answerText.trim()}
                    >
                      {submitting || isStreamingEvaluation ? "提交中..." : "提交回答并评估"}
                    </Button>
                    <Button
                      type="button"
                      variant="secondary"
                      className="h-10 rounded-xl"
                      onClick={() => {
                        handleNextQuestion().catch(() => null);
                      }}
                      disabled={loading || submitting || isStreamingEvaluation || isStreamingFollowUp || isStreamingReport || !hasActiveSession || progressValue >= sessionQuestionLimit}
                    >
                      下一题
                    </Button>
                    <Button
                      type="button"
                      variant="outline"
                      className="h-10 rounded-xl"
                      onClick={() => {
                        generateFollowUp(answerText).catch(() => null);
                      }}
                      disabled={loading || submitting || isStreamingEvaluation || isStreamingFollowUp || isStreamingReport || !answerText.trim() || currentSession.status === "completed"}
                    >
                      生成追问
                    </Button>
                    <Button
                      type="button"
                      variant="ghost"
                      className="h-10 rounded-xl"
                      onClick={() => {
                        cancelStreaming();
                        resetCurrentFlow();
                        setAnswerText("");
                        setQuestionIndex(0);
                        setSecondsLeft(QUESTION_TIME_LIMIT_SECONDS);
                        setAnswerRecords([]);
                      }}
                    >
                      重置流程
                    </Button>
                  </div>
                )}
              </div>
            ) : null}

            {currentEvaluation || isStreamingEvaluation || visibleFeedbackText || visibleSuggestionsText ? (
              <div className="mt-4 rounded-2xl border border-[#D9F99D] bg-[#F7FEE7] p-4">
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <p className="text-sm font-semibold text-[#3F6212]">本题评分：{currentEvaluation?.score ?? "--"}</p>
                  <span className="rounded-full bg-white/70 px-2.5 py-1 text-xs font-medium text-[#4D7C0F]">
                    {isStreamingEvaluation ? "评估生成中" : "已完成本题评估"}
                  </span>
                </div>
                <div className="mt-3 grid gap-2 sm:grid-cols-4">
                  {currentEvaluationMetrics.map((item) => (
                    <div key={item.label} className="rounded-xl border border-[#D9F99D] bg-white/80 p-3">
                      <p className="text-xs text-[#4D7C0F]">{item.label}</p>
                      <p className="mt-1 text-lg font-semibold text-[#365314]">
                        {item.value}
                        <span className="ml-1 text-xs font-normal text-[#65A30D]">/ {item.max}</span>
                      </p>
                    </div>
                  ))}
                </div>
                <div className="mt-3 rounded-xl bg-white/70 p-3">
                  <p className="text-xs font-semibold text-[#4D7C0F]">反馈</p>
                  <p className="mt-1 whitespace-pre-wrap text-sm leading-6 text-[#3F6212]">
                    {visibleFeedbackText || "暂无反馈"}
                    {isStreamingEvaluation || (!streamingFeedback && currentEvaluation.feedback && typedFeedbackText.isAnimating) ? <TypewriterCursor /> : null}
                  </p>
                </div>
                <div className="mt-3 rounded-xl bg-white/70 p-3">
                  <p className="text-xs font-semibold text-[#4D7C0F]">改进建议</p>
                  <p className="mt-1 whitespace-pre-wrap text-sm leading-6 text-[#3F6212]">
                    {visibleSuggestionsText || "暂无建议"}
                    {isStreamingEvaluation || (!streamingSuggestions && currentEvaluation.suggestions && typedSuggestionsText.isAnimating) ? <TypewriterCursor /> : null}
                  </p>
                </div>
              </div>
            ) : null}

            {followUpQuestion || isStreamingFollowUp || visibleFollowUpText ? (
              <div className="mt-4 rounded-2xl border border-[#FDE68A] bg-[#FFFBEB] p-4">
                <p className="text-sm font-semibold text-[#92400E]">追问建议</p>
                <p className="mt-2 whitespace-pre-wrap text-sm leading-6 text-[#92400E]">
                  {visibleFollowUpText || "追问生成中..."}
                  {isStreamingFollowUp || (!streamingFollowUpText && typedFollowUpText.isAnimating) ? <TypewriterCursor /> : null}
                </p>
              </div>
            ) : null}

            {currentSession?.status === "completed" || isStreamingReport ? (
              <div ref={reportRef} className="mt-4 rounded-2xl border border-[#DBEAFE] bg-[#EFF6FF] p-4">
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <p className="text-sm font-semibold text-[#1D4ED8]">
                    面试总分：{currentSession?.totalScore ?? "--"}
                  </p>
                  <span className="rounded-full bg-white/70 px-2.5 py-1 text-xs font-medium text-[#1D4ED8]">
                    综合报告
                  </span>
                </div>
                <div className="mt-3 max-h-[360px] overflow-auto rounded-xl bg-white/80 p-4 text-sm leading-6 text-[#1E3A8A]">
                  {visibleReportText ? (
                    <div className="prose prose-sm max-w-none prose-headings:text-[#1E40AF] prose-p:text-[#1E3A8A] prose-strong:text-[#1D4ED8] prose-li:text-[#1E3A8A]">
                      <ReactMarkdown>{visibleReportText}</ReactMarkdown>
                      {isStreamingReport || (!streamingReport && typedReportText.isAnimating) ? <TypewriterCursor /> : null}
                    </div>
                  ) : (
                    <p>报告生成中...</p>
                  )}
                </div>
              </div>
            ) : null}
          </section>

          <section className="rounded-2xl border border-[#E8EDF3] bg-white p-4 shadow-sm lg:p-5">
            <h2 className="text-base font-semibold text-[#1F2937]">面试历史</h2>
            {history.length === 0 ? (
              <p className="mt-3 text-sm text-[#6B7280]">暂无历史记录</p>
            ) : (
              <div className="mt-3 space-y-2">
                {history.map((item) => (
                  <button
                    key={item.id}
                    type="button"
                    className="w-full rounded-xl border border-[#E5E7EB] p-3 text-left transition-colors hover:border-[#BFDBFE] hover:bg-[#F8FAFF]"
                    onClick={() => {
                      fetchSessionDetail(item.id).catch(() => null);
                    }}
                  >
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-medium text-[#111827]">{getSessionTitle(item.id)}</span>
                      <span className="text-xs text-[#6B7280]">{getSessionStatusLabel(item.status)}</span>
                    </div>
                    <p className="mt-1 text-xs text-[#6B7280]">
                      得分：{item.totalScore ?? "-"} · 创建时间：{item.createTime || "-"}
                    </p>
                  </button>
                ))}
              </div>
            )}

            {sessionDetail ? (
              <div className="mt-4 rounded-2xl border border-[#E5E7EB] bg-[#FAFAFA] p-3">
                <p className="text-sm font-semibold text-[#1F2937]">会话详情</p>
                <p className="mt-1 text-xs text-[#6B7280]">
                  得分：{sessionDetail.session.totalScore ?? "-"} · 状态：{getSessionStatusLabel(sessionDetail.session.status)}
                </p>
                <div className="mt-3 max-h-[320px] space-y-2 overflow-y-auto">
                  {sessionDetail.answers.map((answer) => (
                    <div key={answer.id} className="rounded-xl border border-[#E5E7EB] bg-white p-2.5">
                      <p className="text-xs font-medium text-[#374151]">
                        题目：{answer.questionText || `题目ID：${answer.questionId}`}
                      </p>
                      <p className="mt-1 text-xs text-[#6B7280] line-clamp-3">回答：{answer.userAnswer}</p>
                      <p className="mt-1 text-xs text-[#1D4ED8]">总分：{answer.score ?? "-"}</p>
                      <p className="mt-1 text-[11px] text-[#6B7280]">
                        技术 {answer.technicalScore ?? "-"} · 表达 {answer.expressionScore ?? "-"} · 逻辑 {answer.logicScore ?? "-"} · 知识 {answer.knowledgeScore ?? "-"}
                      </p>
                      {answer.feedback ? (
                        <p className="mt-1 line-clamp-2 text-[11px] text-[#2563EB]">反馈：{answer.feedback}</p>
                      ) : null}
                    </div>
                  ))}
                </div>
              </div>
            ) : null}
            {trendData.length > 0 ? (
              <div className="mt-4 rounded-2xl border border-[#E5E7EB] bg-white p-3">
                <p className="text-sm font-semibold text-[#1F2937]">成长趋势（历史总分）</p>
                <div className="mt-3 h-[220px] w-full">
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={trendData}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                      <XAxis dataKey="index" tick={{ fill: "#6B7280", fontSize: 12 }} />
                      <YAxis domain={[0, 100]} tick={{ fill: "#6B7280", fontSize: 12 }} />
                      <Tooltip />
                      <Line type="monotone" dataKey="score" stroke="#2563EB" strokeWidth={2} dot={{ r: 3 }} />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              </div>
            ) : null}
            {profile ? (
              <div className="mt-4 rounded-2xl border border-[#E5E7EB] bg-white p-3">
                <p className="text-sm font-semibold text-[#1F2937]">能力档案</p>
                <div className="mt-2 grid grid-cols-2 gap-2 text-xs text-[#6B7280]">
                  <p>总会话：{profile.totalSessions}</p>
                  <p>完成会话：{profile.completedSessions}</p>
                  <p>平均分：{profile.averageScore?.toFixed?.(1) ?? profile.averageScore}</p>
                  <p>最近得分：{profile.lastScore ?? "-"}</p>
                </div>
                {recommendation ? (
                  <div className="mt-2 rounded-lg bg-[#F8FAFF] p-2.5 text-xs text-[#1E40AF]">
                    <p className="font-medium">{recommendation.summary}</p>
                    <p className="mt-1">下一步：{recommendation.nextStep}</p>
                  </div>
                ) : null}
              </div>
            ) : null}
            {answerRecords.length > 0 ? (
              <div className="mt-4 rounded-2xl border border-[#E5E7EB] bg-white p-3">
                <p className="text-sm font-semibold text-[#1F2937]">当前会话答题记录</p>
                <div className="mt-3 max-h-[320px] space-y-2 overflow-y-auto">
                  {answerRecords.map((item, index) => (
                    <div key={`${item.questionText}-${index}`} className="rounded-xl border border-[#E5E7EB] bg-[#FAFAFA] p-2.5">
                      <p className="text-xs font-medium text-[#374151]">第 {index + 1} 题 · 得分 {item.score}</p>
                      <p className="mt-1 line-clamp-2 text-xs text-[#6B7280]">{item.questionText}</p>
                      <p className="mt-1 line-clamp-2 text-xs text-[#2563EB]">反馈：{item.feedback}</p>
                    </div>
                  ))}
                </div>
              </div>
            ) : null}
          </section>
        </div>
      </div>
    </MainLayout>
  );
}
