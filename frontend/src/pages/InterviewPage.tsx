import * as React from "react";

import { Button } from "@/components/ui/button";
import { MainLayout } from "@/components/layout/MainLayout";
import { useAuthStore } from "@/stores/authStore";
import { useInterviewStore } from "@/stores/interviewStore";

export function InterviewPage() {
  const { user } = useAuthStore();
  const {
    positions,
    history,
    currentSession,
    currentQuestion,
    currentEvaluation,
    sessionDetail,
    difficulty,
    loading,
    submitting,
    fetchPositions,
    fetchHistory,
    createAndStartSession,
    fetchQuestion,
    submitAnswer,
    completeSession,
    fetchSessionDetail,
    setDifficulty,
    resetCurrentFlow
  } = useInterviewStore();
  const [selectedPositionId, setSelectedPositionId] = React.useState("");
  const [answerText, setAnswerText] = React.useState("");

  React.useEffect(() => {
    fetchPositions().catch(() => null);
  }, [fetchPositions]);

  React.useEffect(() => {
    if (!user?.userId) return;
    fetchHistory(user.userId).catch(() => null);
  }, [fetchHistory, user?.userId]);

  React.useEffect(() => {
    if (positions.length > 0 && !selectedPositionId) {
      setSelectedPositionId(positions[0].id);
    }
  }, [positions, selectedPositionId]);

  const startInterview = React.useCallback(async () => {
    if (!user?.userId || !selectedPositionId) return;
    setAnswerText("");
    await createAndStartSession(user.userId, selectedPositionId);
  }, [createAndStartSession, selectedPositionId, user?.userId]);

  const handleSubmitAnswer = React.useCallback(async () => {
    const next = answerText.trim();
    if (!next) return;
    await submitAnswer(next);
  }, [answerText, submitAnswer]);

  const handleNextQuestion = React.useCallback(async () => {
    setAnswerText("");
    await fetchQuestion();
  }, [fetchQuestion]);

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
            </div>

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

              <div className="flex items-end gap-2">
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
                    disabled={loading}
                  >
                    下一题
                  </Button>
                  <Button
                    type="button"
                    variant="ghost"
                    className="h-10 rounded-xl"
                    onClick={() => {
                      resetCurrentFlow();
                      setAnswerText("");
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
          </section>
        </div>
      </div>
    </MainLayout>
  );
}
