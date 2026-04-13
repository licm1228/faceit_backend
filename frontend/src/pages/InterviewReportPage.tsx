import * as React from "react";
import { ArrowLeft, FileText, Target } from "lucide-react";
import { Link, useParams } from "react-router-dom";

import { MainLayout } from "@/components/layout/MainLayout";
import { getInterviewChatReport } from "@/services/interviewChatService";
import type { InterviewReport } from "@/types";

export function InterviewReportPage() {
  const { sessionId } = useParams<{ sessionId: string }>();
  const [report, setReport] = React.useState<InterviewReport | null>(null);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);

  React.useEffect(() => {
    if (!sessionId) return;
    let cancelled = false;
    let timer: number | undefined;

    const loadReport = async () => {
      setLoading(true);
      setError(null);
      try {
        const data = await getInterviewChatReport(sessionId);
        if (cancelled) return;
        setReport(data);
        if (data.reportStatus === "pending") {
          timer = window.setTimeout(() => {
            loadReport().catch(() => null);
          }, 1500);
        }
      } catch (loadError) {
        if (!cancelled) {
          setError((loadError as Error).message || "报告加载失败");
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    loadReport().catch(() => null);
    return () => {
      cancelled = true;
      if (timer) {
        window.clearTimeout(timer);
      }
    };
  }, [sessionId]);

  return (
    <MainLayout>
      <div className="h-full overflow-y-auto bg-[#FAFAFA] px-6 py-8">
        <div className="mx-auto max-w-5xl space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-[#64748B]">Interview Report</p>
              <h1 className="text-3xl font-semibold text-[#0F172A]">面试评估报告</h1>
            </div>
            <Link
              to={sessionId ? `/chat/${sessionId}` : "/chat"}
              className="inline-flex h-10 items-center gap-2 rounded-xl border border-[#D6E4FF] bg-white px-4 text-sm font-medium text-[#2563EB]"
            >
              <ArrowLeft className="h-4 w-4" />
              返回对话
            </Link>
          </div>

          {loading && !report ? (
            <div className="rounded-3xl border border-[#E5E7EB] bg-white p-10 text-center text-[#64748B]">
              报告加载中...
            </div>
          ) : null}

          {report?.reportStatus === "pending" ? (
            <div className="rounded-3xl border border-[#E5E7EB] bg-white p-10 text-center text-[#64748B]">
              <p className="text-base font-medium text-[#0F172A]">报告正在生成</p>
              <p className="mt-2 text-sm leading-6">
                综合得分已经出来了，详细亮点、不足和练习建议正在整理中，页面会自动刷新。
              </p>
              <p className="mt-5 text-4xl font-semibold text-[#2563EB]">{report.overallScore}</p>
            </div>
          ) : null}

          {!loading && error ? (
            <div className="rounded-3xl border border-[#FECACA] bg-white p-10 text-center text-[#B91C1C]">
              {error}
            </div>
          ) : null}

          {!loading && report && report.reportStatus !== "pending" ? (
            <>
              <div className="grid gap-4 md:grid-cols-[1.2fr_1fr]">
                <div className="rounded-3xl bg-[#0F172A] p-6 text-white shadow-[0_20px_50px_rgba(15,23,42,0.18)]">
                  <p className="text-sm text-white/70">{report.positionName || "模拟面试"}</p>
                  <div className="mt-4 flex items-end gap-3">
                    <span className="text-5xl font-semibold">{report.overallScore}</span>
                    <span className="pb-2 text-white/70">/ 100</span>
                  </div>
                  <p className="mt-4 text-sm text-white/70">
                    {report.questionLimit || 0} 题 · {report.timeLimitMinutes || 0} 分钟
                  </p>
                  {report.summary ? (
                    <p className="mt-4 rounded-2xl bg-white/10 px-4 py-3 text-sm leading-6 text-white/85">
                      {report.summary}
                    </p>
                  ) : null}
                </div>
                <div className="rounded-3xl border border-[#E5E7EB] bg-white p-6">
                  <div className="mb-4 flex items-center gap-2 text-[#0F172A]">
                    <Target className="h-5 w-5 text-[#2563EB]" />
                    <p className="font-semibold">维度得分</p>
                  </div>
                  <div className="space-y-3 text-sm text-[#334155]">
                    <div className="flex items-center justify-between rounded-2xl bg-[#F8FAFC] px-4 py-3">
                      <span>技术正确性</span>
                      <span className="font-semibold">{report.dimensionScores.technicalCorrectness}</span>
                    </div>
                    <div className="flex items-center justify-between rounded-2xl bg-[#F8FAFC] px-4 py-3">
                      <span>知识深度</span>
                      <span className="font-semibold">{report.dimensionScores.knowledgeDepth}</span>
                    </div>
                    <div className="flex items-center justify-between rounded-2xl bg-[#F8FAFC] px-4 py-3">
                      <span>逻辑严谨性</span>
                      <span className="font-semibold">{report.dimensionScores.logicRigor}</span>
                    </div>
                    <div className="flex items-center justify-between rounded-2xl bg-[#F8FAFC] px-4 py-3">
                      <span>岗位匹配度</span>
                      <span className="font-semibold">{report.dimensionScores.positionMatch}</span>
                    </div>
                    <div className="flex items-center justify-between rounded-2xl bg-[#F8FAFC] px-4 py-3">
                      <span>表达表现</span>
                      <span className="font-semibold">{report.dimensionScores.expressionDelivery}</span>
                    </div>
                  </div>
                </div>
              </div>

              <div className="rounded-3xl border border-[#E5E7EB] bg-white p-6">
                <div className="mb-4 flex items-center gap-2 text-[#0F172A]">
                  <Target className="h-5 w-5 text-[#2563EB]" />
                  <p className="font-semibold">表达分析</p>
                </div>
                <p className="rounded-2xl bg-[#F8FAFC] px-4 py-4 text-sm leading-6 text-[#334155]">
                  {report.expressionSummary || "本次报告未生成表达分析摘要。"}
                </p>
              </div>

              <div className="grid gap-4 lg:grid-cols-2">
                <SectionCard title="亮点分析" items={report.highlights} />
                <SectionCard title="不足分析" items={report.weaknesses} />
              </div>

              <SectionCard title="改进建议" items={report.improvementSuggestions} />

              <div className="rounded-3xl border border-[#E5E7EB] bg-white p-6">
                <div className="mb-4 flex items-center gap-2 text-[#0F172A]">
                  <FileText className="h-5 w-5 text-[#2563EB]" />
                  <p className="font-semibold">推荐练习</p>
                </div>
                <div className="space-y-3">
                  {report.recommendedPractices.length === 0 ? (
                    <p className="text-sm text-[#64748B]">当前没有更多推荐题目。</p>
                  ) : (
                    report.recommendedPractices.map((practice) => (
                      <div key={practice.id} className="rounded-2xl bg-[#F8FAFC] px-4 py-4">
                        <p className="text-sm font-medium text-[#0F172A]">{practice.questionText}</p>
                        <p className="mt-2 text-xs text-[#64748B]">
                          {practice.questionType || "面试题"} · 难度 {practice.difficulty || "-"}
                        </p>
                        {practice.recommendationReason ? (
                          <p className="mt-2 text-xs leading-5 text-[#334155]">{practice.recommendationReason}</p>
                        ) : null}
                        {practice.knowledgeTags?.length ? (
                          <div className="mt-3 flex flex-wrap gap-2">
                            {practice.knowledgeTags.map((tag) => (
                              <span key={`${practice.id}-${tag}`} className="rounded-full border border-[#D6E4FF] bg-white px-2.5 py-1 text-[11px] text-[#475467]">
                                {tag}
                              </span>
                            ))}
                          </div>
                        ) : null}
                        {practice.knowledgeSource ? (
                          <p className="mt-3 rounded-2xl bg-white px-3 py-3 text-xs leading-5 text-[#475467]">
                            知识来源：{practice.knowledgeSource}
                          </p>
                        ) : null}
                        {practice.referenceAnswerPreview ? (
                          <p className="mt-2 text-xs leading-5 text-[#64748B]">
                            参考答题方向：{practice.referenceAnswerPreview}
                          </p>
                        ) : null}
                      </div>
                    ))
                  )}
                </div>
              </div>
            </>
          ) : null}
        </div>
      </div>
    </MainLayout>
  );
}

function SectionCard({ title, items }: { title: string; items: string[] }) {
  return (
    <div className="rounded-3xl border border-[#E5E7EB] bg-white p-6">
      <p className="mb-4 text-lg font-semibold text-[#0F172A]">{title}</p>
      <div className="space-y-3">
        {items.length === 0 ? (
          <div className="rounded-2xl bg-[#F8FAFC] px-4 py-3 text-sm leading-6 text-[#64748B]">
            暂无内容。
          </div>
        ) : (
          items.map((item, index) => (
            <div key={`${title}-${index}`} className="rounded-2xl bg-[#F8FAFC] px-4 py-3 text-sm leading-6 text-[#334155]">
              {item}
            </div>
          ))
        )}
      </div>
    </div>
  );
}
