import * as React from "react";
import { Brain, ChevronDown, FileText, ArrowRight } from "lucide-react";
import { Link } from "react-router-dom";

import { FeedbackButtons } from "@/components/chat/FeedbackButtons";
import { ThinkingIndicator } from "@/components/chat/ThinkingIndicator";
import { cn } from "@/lib/utils";
import type { Message } from "@/types";

const MarkdownRenderer = React.lazy(() =>
  import("@/components/chat/MarkdownRenderer").then((mod) => ({ default: mod.MarkdownRenderer }))
);

interface MessageItemProps {
  message: Message;
  isLast?: boolean;
}

export const MessageItem = React.memo(function MessageItem({ message, isLast }: MessageItemProps) {
  const isUser = message.role === "user";
  const showFeedback =
    message.role === "assistant" &&
    message.status !== "streaming" &&
    message.id &&
    !message.id.startsWith("assistant-");
  const isThinking = Boolean(message.isThinking);
  const [thinkingExpanded, setThinkingExpanded] = React.useState(false);
  const hasThinking = Boolean(message.thinking && message.thinking.trim().length > 0);
  const hasContent = message.content.trim().length > 0;
  const isWaiting = message.status === "streaming" && !isThinking && !hasContent;
  const reportMatch = message.content.match(/\[查看面试报告\]\((\/interview-report\/[^)]+)\)/);

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
                {message.content.replace(reportMatch[0], "").trim() ? (
                  renderMarkdown(message.content.replace(reportMatch[0], "").trim())
                ) : null}
                <Link
                  to={reportMatch[1]}
                  className="flex items-center justify-between rounded-2xl border border-[#DBEAFE] bg-gradient-to-r from-[#EFF6FF] to-white px-4 py-4 transition hover:border-[#93C5FD] hover:shadow-[0_12px_24px_rgba(37,99,235,0.08)]"
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
                  <ArrowRight className="h-4 w-4 text-[#2563EB]" />
                </Link>
              </div>
            ) : (
              renderMarkdown(message.content)
            )
          ) : null}
          {message.status === "error" ? (
            <p className="text-xs text-rose-500">生成已中断。</p>
          ) : null}
          {showFeedback ? (
            <FeedbackButtons
              messageId={message.id}
              feedback={message.feedback ?? null}
              content={message.content}
              alwaysVisible={Boolean(isLast)}
            />
          ) : null}
        </div>
      </div>
    </div>
  );
});
