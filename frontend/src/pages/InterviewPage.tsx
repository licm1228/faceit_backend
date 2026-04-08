import * as React from "react";
import { Mic, MicOff, Timer } from "lucide-react";
import { toast } from "sonner";
import { CartesianGrid, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

import { Button } from "@/components/ui/button";
import { MainLayout } from "@/components/layout/MainLayout";
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

export function InterviewPage() {
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
  const recognitionRef = React.useRef<SpeechRecognitionLike | null>(null);

  React.useEffect(() => {
    fetchPositions().catch(() => null);
  }, [fetchPositions]);

  React.useEffect(() => {
    if (!user?.userId) return;
    fetchHistory(user.userId).catch(() => null);
    fetchProfileData().catch(() => null);
  }, [fetchHistory, fetchProfileData, user?.userId]);

  React.useEffect(() => {
    if (positions.length > 0 && !selectedPositionId) {
      setSelectedPositionId(positions[0].id);
    }
  }, [positions, selectedPositionId]);

  const startInterview = React.useCallback(async () => {
    if (!user?.userId || !selectedPositionId) return;
    setAnswerText("");
    setQuestionIndex(1);
    setSecondsLeft(QUESTION_TIME_LIMIT_SECONDS);
    setAnswerRecords([]);
    await createAndStartSession(user.userId, selectedPositionId, {
      timeLimit: timeLimitMinutes,
      totalQuestions: questionLimit
    });
  }, [createAndStartSession, questionLimit, selectedPositionId, timeLimitMinutes, user?.userId]);

  const handleSubmitAnswer = React.useCallback(async () => {
    const next = answerText.trim();
    if (!next) return;
    await submitAnswer(next);
  }, [answerText, submitAnswer]);

  const handleNextQuestion = React.useCallback(async () => {
    if (questionIndex >= questionLimit) {
      toast.info("已达到题量上限，请结束面试并查看报告");
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
          toast.warning("当前题目作答时间已到，请提交或进入下一题");
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
    };
  }, []);

  const toggleRecording = React.useCallback(() => {
    const speechWindow = window as SpeechWindow;
    const ctor = speechWindow.SpeechRecognition || speechWindow.webkitSpeechRecognition;
    if (!ctor) {
      toast.error("当前浏览器不支持语音识别，请使用 Chrome 或 Edge");
      return;
    }
    if (isRecording) {
      recognitionRef.current?.stop();
      setIsRecording(false);
      return;
    }

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
      toast.error("语音识别失败，请重试");
    };
    recognition.onend = () => {
      setIsRecording(false);
    };
    recognitionRef.current = recognition;
    recognition.start();
    setIsRecording(true);
  }, [isRecording]);

  const progressPercent = Math.min(100, Math.round((Math.max(questionIndex, 1) / questionLimit) * 100));
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

  return (
    <MainLayout>
      <div className="h-full overflow-y-auto bg-[#FAFAFA] px-4 py-4 lg:px-6">
        <div className="mx-auto grid w-full max-w-[1240px] gap-4 lg:grid-cols-[1.15fr_0.85fr]">
          <section className="rounded-2xl border border-[#E8EDF3] bg-white p-4 shadow-sm lg:p-5">
            <div className="flex flex-wrap items-center gap-3">
              <h1 className="text-lg font-semibold text-[#1F2937]">面试模式</h1>
              {currentSession ? (
                <span className="rounded-full bg-[#EEF6FF] px-3 py-1 text-xs font-semibold text-[#2563EB]">
                  状态：{currentSession.status || "in_progress"}
                </span>
              ) : null}
              {currentSession && currentSession.status !== "completed" ? (
                  <span className="rounded-full bg-[#ECFDF5] px-3 py-1 text-xs font-semibold text-[#059669]">
                  进度：{Math.max(questionIndex, 1)}/{questionLimit}
                </span>
              ) : null}
            </div>
            {currentSession && currentSession.status !== "completed" ? (
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
                  disabled={Boolean(currentSession)}
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
                  disabled={Boolean(currentSession)}
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
                  disabled={Boolean(currentSession)}
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
                  disabled={Boolean(currentSession)}
                >
                  {[10, 15, 20, 30, 45].map((minute) => (
                    <option key={minute} value={minute}>
                      {minute}
                    </option>
                  ))}
                </select>
              </label>

              <div className="flex items-end gap-2 md:flex-col md:items-stretch">
                {currentSession && currentSession.status !== "completed" ? (
                  <div className="mb-2 flex items-center gap-1 rounded-xl border border-[#FDE68A] bg-[#FFFBEB] px-2.5 py-2 text-xs text-[#92400E]">
                    <Timer className="h-3.5 w-3.5" />
                    本题剩余 {minutePart}:{secondPart}
                  </div>
                ) : null}
                {!currentSession ? (
                  <Button
                    type="button"
                    className="h-10 w-full rounded-xl"
                    onClick={() => {
                      startInterview().catch(() => null);
                    }}
                    disabled={loading || !selectedPositionId}
                  >
                    开始面试
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
                  {currentQuestion.questionText}
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
                  placeholder="请输入你的回答..."
                  className="min-h-[148px] w-full rounded-2xl border border-[#D9E3EF] bg-white px-3 py-3 text-sm leading-6 text-[#1F2937] outline-none transition-colors focus:border-[#60A5FA]"
                />
                <div className="mt-3 flex flex-wrap gap-2">
                  <Button
                    type="button"
                    variant="outline"
                    className="h-10 rounded-xl"
                    onClick={toggleRecording}
                    disabled={currentSession.status === "completed"}
                  >
                    {isRecording ? <MicOff className="mr-1 h-4 w-4" /> : <Mic className="mr-1 h-4 w-4" />}
                    {isRecording ? "停止语音输入" : "语音输入"}
                  </Button>
                  <Button
                    type="button"
                    className="h-10 rounded-xl"
                    onClick={() => {
                      handleSubmitAnswer().catch(() => null);
                    }}
                    disabled={submitting || !answerText.trim()}
                  >
                    {submitting ? "提交中..." : "提交回答并评估"}
                  </Button>
                  <Button
                    type="button"
                    variant="secondary"
                    className="h-10 rounded-xl"
                    onClick={() => {
                      handleNextQuestion().catch(() => null);
                    }}
                    disabled={loading || questionIndex >= questionLimit}
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
                    disabled={!answerText.trim() || currentSession.status === "completed"}
                  >
                    生成追问
                  </Button>
                  <Button
                    type="button"
                    variant="ghost"
                    className="h-10 rounded-xl"
                    onClick={() => {
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
              </div>
            ) : null}

            {currentEvaluation ? (
              <div className="mt-4 rounded-2xl border border-[#D9F99D] bg-[#F7FEE7] p-4">
                <p className="text-sm font-semibold text-[#3F6212]">本题评分：{currentEvaluation.score}</p>
                <p className="mt-2 whitespace-pre-wrap text-sm leading-6 text-[#3F6212]">
                  反馈：{currentEvaluation.feedback}
                </p>
                <p className="mt-2 whitespace-pre-wrap text-sm leading-6 text-[#3F6212]">
                  建议：{currentEvaluation.suggestions}
                </p>
              </div>
            ) : null}

            {followUpQuestion ? (
              <div className="mt-4 rounded-2xl border border-[#FDE68A] bg-[#FFFBEB] p-4">
                <p className="text-sm font-semibold text-[#92400E]">追问建议</p>
                <p className="mt-2 whitespace-pre-wrap text-sm leading-6 text-[#92400E]">
                  {followUpQuestion.questionText}
                </p>
              </div>
            ) : null}

            {currentSession?.status === "completed" ? (
              <div className="mt-4 rounded-2xl border border-[#DBEAFE] bg-[#EFF6FF] p-4">
                <p className="text-sm font-semibold text-[#1D4ED8]">
                  面试总分：{currentSession.totalScore ?? 0}
                </p>
                <pre className="mt-2 max-h-[260px] overflow-auto whitespace-pre-wrap text-sm leading-6 text-[#1E3A8A]">
                  {currentSession.evaluationReport || "报告生成中..."}
                </pre>
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
                      <span className="text-sm font-medium text-[#111827]">会话 {item.id}</span>
                      <span className="text-xs text-[#6B7280]">{item.status}</span>
                    </div>
                    <p className="mt-1 text-xs text-[#6B7280]">
                      分数：{item.totalScore ?? "-"} · 创建时间：{item.createTime || "-"}
                    </p>
                  </button>
                ))}
              </div>
            )}

            {sessionDetail ? (
              <div className="mt-4 rounded-2xl border border-[#E5E7EB] bg-[#FAFAFA] p-3">
                <p className="text-sm font-semibold text-[#1F2937]">会话详情</p>
                <p className="mt-1 text-xs text-[#6B7280]">
                  总分：{sessionDetail.session.totalScore ?? "-"} · 状态：{sessionDetail.session.status}
                </p>
                <div className="mt-3 max-h-[320px] space-y-2 overflow-y-auto">
                  {sessionDetail.answers.map((answer) => (
                    <div key={answer.id} className="rounded-xl border border-[#E5E7EB] bg-white p-2.5">
                      <p className="text-xs text-[#374151]">题目ID：{answer.questionId}</p>
                      <p className="mt-1 text-xs text-[#6B7280] line-clamp-3">{answer.userAnswer}</p>
                      <p className="mt-1 text-xs text-[#1D4ED8]">分数：{answer.score ?? "-"}</p>
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
