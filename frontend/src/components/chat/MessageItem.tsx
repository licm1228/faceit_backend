import * as React from "react";
import { Brain, ChevronDown, FileText, ArrowRight } from "lucide-react";
import { Link } from "react-router-dom";

import { FeedbackButtons } from "@/components/chat/FeedbackButtons";
import { ThinkingIndicator } from "@/components/chat/ThinkingIndicator";
import { cn } from "@/lib/utils";
import { useChatStore } from "@/stores/chatStore";
import { feedback } from "@/stores/useFeedbackStore";
import type { Message } from "@/types";
import { parseStudyMessage, type StudyPayload } from "@/utils/studyPayload";

const MarkdownRenderer = React.lazy(() =>
  import("@/components/chat/MarkdownRenderer").then((mod) => ({ default: mod.MarkdownRenderer }))
);

interface MessageItemProps {
  message: Message;
  isLast?: boolean;
}

const REPORT_LINK_PATTERN = /\[查看面试报告\]\((\/interview-report\/[^)]+)\)/;

function stripReportLink(content: string) {
  return content.replace(REPORT_LINK_PATTERN, "").trim();
}

function buildInterviewTranscript(messages: Message[], options?: { positionName?: string; score?: number; reportPath?: string }) {
  const lines: string[] = ["# Face It 面试记录", ""];

  if (options?.positionName) {
    lines.push(`- 岗位：${options.positionName}`);
  }
  if (typeof options?.score === "number") {
    lines.push(`- 综合得分：${options.score} 分`);
  }
  lines.push(`- 导出时间：${new Date().toLocaleString("zh-CN")}`);
  if (options?.reportPath && typeof window !== "undefined") {
    lines.push(`- 面试报告：${new URL(options.reportPath, window.location.origin).toString()}`);
  }
  lines.push("", "---", "");

  messages.forEach((item, index) => {
    const content = stripReportLink(item.content);
    if (!content) return;

    lines.push(`## ${index + 1}. ${item.role === "user" ? "候选人" : "面试官"}`);
    lines.push("");
    lines.push(content);
    lines.push("");
  });

  return lines.join("\n").trim();
}

function downloadTextFile(content: string, filename: string, mimeType: string) {
  const blob = new Blob([content], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.setTimeout(() => URL.revokeObjectURL(url), 0);
}

export const MessageItem = React.memo(function MessageItem({ message, isLast }: MessageItemProps) {
  const isUser = message.role === "user";
  const messages = useChatStore((state) => state.messages);
  const currentInterviewState = useChatStore((state) => state.currentInterviewState);
  const parsedStudyMessage = React.useMemo(() => parseStudyMessage(message.content), [message.content]);
  const displayContent = parsedStudyMessage.displayContent;
  const studyPayload = parsedStudyMessage.studyPayload;
  const showFeedback =
    message.role === "assistant" &&
    message.status !== "streaming" &&
    message.id &&
    !message.id.startsWith("assistant-");
  const isThinking = Boolean(message.isThinking);
  const [thinkingExpanded, setThinkingExpanded] = React.useState(false);
  const hasThinking = Boolean(message.thinking && message.thinking.trim().length > 0);
  const hasContent = displayContent.trim().length > 0;
  const isWaiting = message.status === "streaming" && !isThinking && !hasContent;
  const reportMatch = displayContent.match(REPORT_LINK_PATTERN);

  const interviewTranscript = React.useMemo(() => {
    if (!reportMatch) return "";
    return buildInterviewTranscript(messages, {
      positionName: currentInterviewState?.positionName,
      score: currentInterviewState?.totalScore,
      reportPath: reportMatch[1]
    });
  }, [currentInterviewState?.positionName, currentInterviewState?.totalScore, messages, reportMatch]);

  const exportFileName = React.useMemo(() => {
    const sessionId = reportMatch?.[1]?.split("/").pop() || currentInterviewState?.id || "interview";
    return `faceit-interview-${sessionId}.md`;
  }, [currentInterviewState?.id, reportMatch]);

  const handleCopyTranscript = React.useCallback(async () => {
    try {
      await navigator.clipboard.writeText(interviewTranscript);
      feedback.success("面试记录已复制");
    } catch {
      feedback.error("复制失败，请检查浏览器权限");
    }
  }, [interviewTranscript]);

  const handleDownloadTranscript = React.useCallback(() => {
    try {
      downloadTextFile(interviewTranscript, exportFileName, "text/markdown;charset=utf-8");
      feedback.success("面试记录已下载");
    } catch {
      feedback.error("下载失败，请稍后重试");
    }
  }, [exportFileName, interviewTranscript]);

  const handleShareTranscript = React.useCallback(async () => {
    if (!reportMatch || typeof navigator === "undefined" || typeof navigator.share !== "function") {
      feedback.error("当前浏览器不支持系统分享");
      return;
    }

    const reportUrl = new URL(reportMatch[1], window.location.origin).toString();
    const shareData: ShareData = {
      title: "Face It 面试记录",
      text: interviewTranscript,
      url: reportUrl
    };

    try {
      await navigator.share(shareData);
    } catch (error) {
      if ((error as Error).name !== "AbortError") {
        feedback.error("分享失败，请稍后重试");
      }
    }
  }, [interviewTranscript, reportMatch]);

  if (isUser) {
    return (
      <div className="flex">
        <div className="user-message">
          <p className="whitespace-pre-wrap break-words">{message.content}</p>
        </div>
      </div>
    );
  }

  const thinkingDuration = message.thinkingDuration ? `${message.thinkingDuration}秒` : "";
  const renderMarkdown = (content: string) => (
    <React.Suspense
      fallback={<div className="whitespace-pre-wrap break-words text-[15px] leading-7 text-[#0F172A]">{content}</div>}
    >
      <MarkdownRenderer content={content} />
    </React.Suspense>
  );

  return (
    <div className="group flex">
      <div className="min-w-0 flex-1 space-y-4">
        {isThinking ? (
          <ThinkingIndicator content={message.thinking} duration={message.thinkingDuration} />
        ) : null}
        {!isThinking && hasThinking ? (
          <div className="overflow-hidden rounded-lg border border-[#BFDBFE] bg-[#DBEAFE]">
            <button
              type="button"
              onClick={() => setThinkingExpanded((prev) => !prev)}
              className="flex w-full items-center gap-2 px-4 py-3 text-left transition-colors hover:bg-[#BFDBFE]/30"
            >
              <div className="flex flex-1 items-center gap-2">
                <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#BFDBFE]">
                  <Brain className="h-4 w-4 text-[#2563EB]" />
                </div>
                <span className="text-sm font-medium text-[#2563EB]">深度思考</span>
                {thinkingDuration ? (
                  <span className="rounded-full bg-[#BFDBFE] px-2 py-0.5 text-xs text-[#2563EB]">
                    {thinkingDuration}
                  </span>
                ) : null}
              </div>
              <ChevronDown
                className={cn(
                  "h-4 w-4 text-[#3B82F6] transition-transform",
                  thinkingExpanded && "rotate-180"
                )}
              />
            </button>
            {thinkingExpanded ? (
              <div className="border-t border-[#BFDBFE] px-4 pb-4">
                <div className="mt-3 whitespace-pre-wrap text-sm leading-relaxed text-[#1E40AF]">
                  {message.thinking}
                </div>
              </div>
            ) : null}
          </div>
        ) : null}
        <div className="space-y-2">
          {isWaiting ? (
            <div className="ai-wait" aria-label="思考中">
              <span className="ai-wait-dots" aria-hidden="true">
                <span className="ai-wait-dot" />
                <span className="ai-wait-dot" />
                <span className="ai-wait-dot" />
              </span>
            </div>
          ) : null}
          {hasContent ? (
            reportMatch ? (
              <div className="space-y-3">
                {stripReportLink(displayContent) ? (
                  renderMarkdown(stripReportLink(displayContent))
                ) : null}
                <div className="rounded-2xl border border-[#DBEAFE] bg-gradient-to-r from-[#EFF6FF] to-white transition hover:border-[#93C5FD] hover:shadow-[0_12px_24px_rgba(37,99,235,0.08)]">
                  <Link
                    to={reportMatch[1]}
                    className="flex items-center justify-between gap-4 px-4 py-4"
                  >
                    <div className="flex items-center gap-3">
                      <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#2563EB] text-white">
                        <FileText className="h-5 w-5" />
                      </span>
                      <div>
                        <p className="text-sm font-semibold text-[#0F172A]">查看面试报告</p>
                        <p className="text-xs text-[#64748B]">进入结构化评估报告页，查看得分与推荐练习。</p>
                      </div>
                    </div>
                    <ArrowRight className="h-4 w-4 shrink-0 text-[#2563EB]" />
                  </Link>
                </div>
              </div>
            ) : (
              renderMarkdown(displayContent)
            )
          ) : null}
          {studyPayload ? <StudyCard payload={studyPayload} /> : null}
          {message.status === "error" ? (
            <p className="text-xs text-rose-500">生成已中断。</p>
          ) : null}
          {showFeedback ? (
            <FeedbackButtons
              messageId={message.id}
              feedback={message.feedback ?? null}
              content={message.content}
              alwaysVisible={Boolean(isLast)}
              showShareButton={Boolean(reportMatch)}
              onCopyContent={reportMatch ? handleCopyTranscript : undefined}
              onDownloadContent={reportMatch ? handleDownloadTranscript : undefined}
              onNativeShare={reportMatch ? handleShareTranscript : undefined}
            />
          ) : null}
        </div>
      </div>
    </div>
  );
});

function StudyCard({ payload }: { payload: StudyPayload }) {
  const practiceItems = payload.practiceQuestions ?? [];
  const relatedResources = payload.relatedResources ?? [];
  const nextActions = payload.nextActions ?? [];

  return (
    <div className="space-y-3 rounded-3xl border border-[#D6F5DF] bg-[#F6FCF7] p-4">
      <div className="flex flex-wrap items-center gap-2">
        <span className="rounded-full bg-[#DCFCE7] px-2.5 py-1 text-[11px] font-medium text-[#166534]">
          学练闭环
        </span>
        {payload.positionName ? (
          <span className="text-xs text-[#64748B]">{payload.positionName}</span>
        ) : null}
      </div>

      {practiceItems.length ? (
        <div>
          <p className="text-xs font-medium text-[#0F172A]">推荐练习</p>
          <div className="mt-2 space-y-2">
            {practiceItems.map((item, index) => (
              <div key={item.id || `${item.questionText}-${index}`} className="rounded-2xl bg-white px-4 py-3">
                <div className="flex flex-wrap items-center gap-2 text-[11px] text-[#64748B]">
                  {item.questionType ? <span>{item.questionType}</span> : null}
                  {typeof item.difficulty === "number" ? <span>难度 {item.difficulty}</span> : null}
                  {item.source ? <span>{item.source === "question_bank" ? "题库" : item.source}</span> : null}
                </div>
                {item.questionText ? (
                  <p className="mt-2 text-sm font-medium leading-6 text-[#0F172A]">{item.questionText}</p>
                ) : null}
                {item.focus ? (
                  <p className="mt-2 text-xs leading-5 text-[#475467]">练习重点：{item.focus}</p>
                ) : null}
                {item.suggestion ? (
                  <p className="mt-1 text-xs leading-5 text-[#475467]">建议：{item.suggestion}</p>
                ) : null}
              </div>
            ))}
          </div>
        </div>
      ) : null}

      {nextActions.length ? (
        <StudySection title="下一步" items={nextActions} />
      ) : null}

      {relatedResources.length ? (
        <div>
          <p className="text-xs font-medium text-[#0F172A]">知识资料</p>
          <div className="mt-2 space-y-2">
            {relatedResources.map((resource, index) => (
              <div key={resource.id || `${resource.title}-${index}`} className="rounded-2xl bg-white px-4 py-3">
                <p className="text-xs font-medium text-[#0F172A]">{resource.title || "知识库资料"}</p>
                {(resource.knowledgeBaseName || resource.matchedKeyword) ? (
                  <p className="mt-1 text-[11px] text-[#64748B]">
                    {resource.knowledgeBaseName || "知识库"}
                    {resource.matchedKeyword ? ` · 命中 ${resource.matchedKeyword}` : ""}
                  </p>
                ) : null}
                {resource.snippet ? (
                  <p className="mt-2 rounded-xl bg-[#F8FAFC] px-3 py-2 text-xs leading-5 text-[#334155]">
                    命中片段：{resource.snippet}
                  </p>
                ) : null}
                {resource.recommendationReason ? (
                  <p className="mt-2 text-xs leading-5 text-[#475467]">{resource.recommendationReason}</p>
                ) : null}
              </div>
            ))}
          </div>
        </div>
      ) : null}
    </div>
  );
}

function StudySection({ title, items }: { title: string; items: string[] }) {
  return (
    <div>
      <p className="text-xs font-medium text-[#0F172A]">{title}</p>
      <div className="mt-2 space-y-2">
        {items.map((item) => (
          <div key={`${title}-${item}`} className="rounded-2xl bg-white px-4 py-3 text-xs leading-5 text-[#334155]">
            {item}
          </div>
        ))}
      </div>
    </div>
  );
}
