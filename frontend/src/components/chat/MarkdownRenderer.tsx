// @ts-nocheck
/* eslint-disable */

import * as React from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { ImageIcon } from "lucide-react";

import { cn } from "@/lib/utils";

const CodeBlock = React.lazy(() =>
  import("@/components/chat/CodeBlock").then((mod) => ({ default: mod.CodeBlock }))
);

interface MarkdownRendererProps {
  content: string;
}

export function MarkdownRenderer({ content }: MarkdownRendererProps) {
  return (
    <ReactMarkdown
      remarkPlugins={[remarkGfm]}
      components={{
        code({ inline, className, children, node, ...props }) {
          const match = /language-(\w+)/.exec(className || "");
          const language = match?.[1] || "text";
          const value = String(children).replace(/\n$/, "");

          // 判断是否为内联代码：inline 为 true 或者没有换行符
          if (inline || !value.includes('\n')) {
            return (
              <code
                className={cn(
                  "rounded px-1.5 py-0.5 text-[13px] font-mono bg-[#f6f8fa] text-[#24292f]",
                  "dark:bg-[#161b22] dark:text-[#c9d1d9]",
                  className
                )}
                {...props}
              >
                {children}
              </code>
            );
          }

          return (
            <React.Suspense
              fallback={
                <pre className="my-3 overflow-x-auto rounded-md border border-[#d0d7de] bg-[#f6f8fa] px-4 py-3 text-[13px] leading-6 text-[#24292f] dark:border-[#30363d] dark:bg-[#161b22] dark:text-[#c9d1d9]">
                  <code>{value}</code>
                </pre>
              }
            >
              <CodeBlock language={language} value={value} />
            </React.Suspense>
          );
        },
        img({ src, alt, ...props }) {
          const [hasError, setHasError] = React.useState(false);

          if (hasError) {
            return (
              <div className="my-3 flex items-center gap-2 text-sm text-[#999999]">
                <ImageIcon className="h-4 w-4" />
                <span>图片加载失败</span>
              </div>
            );
          }

          return (
            <img
              src={src}
              alt=""
              className="my-3 max-w-full rounded-lg"
              onError={() => setHasError(true)}
              loading="lazy"
              {...props}
            />
          );
        },
        a({ children, ...props }) {
          return (
            <a
              className="text-[#0969da] underline-offset-4 hover:underline dark:text-[#58a6ff]"
              target="_blank"
              rel="noreferrer"
              {...props}
            >
              {children}
            </a>
          );
        },
        table({ children, ...props }) {
          return (
            <div className="overflow-x-auto">
              <table className="w-full border-collapse border border-[#d0d7de] rounded-md dark:border-[#30363d]" {...props}>
                {children}
              </table>
            </div>
          );
        },
        thead({ children, ...props }) {
          return (
            <thead className="bg-[#f6f8fa] dark:bg-[#161b22]" {...props}>
              {children}
            </thead>
          );
        },
        th({ children, ...props }) {
          return (
            <th className="border-b border-[#d0d7de] border-r border-r-[#d0d7de] px-3 py-2 text-left text-sm font-semibold text-[#24292f] last:border-r-0 dark:border-[#30363d] dark:border-r-[#30363d] dark:text-[#c9d1d9]" {...props}>
              {children}
            </th>
          );
        },
        td({ children, ...props }) {
          return (
            <td className="border-b border-[#d0d7de] border-r border-r-[#d0d7de] px-3 py-2.5 text-sm text-[#24292f] last:border-r-0 dark:border-[#30363d] dark:border-r-[#30363d] dark:text-[#c9d1d9]" {...props}>
              {children}
            </td>
          );
        },
        blockquote({ children, ...props }) {
          return (
            <blockquote
              className="my-3 border-l-4 border-[#3B82F6] bg-[#F0F7FF] pl-3 pr-3 py-2 italic text-[#333333] dark:border-[#60A5FA] dark:bg-[#1A2332] dark:text-[#CCCCCC]"
              {...props}
            >
              {children}
            </blockquote>
          );
        },
        ul({ children, ...props }) {
          return (
            <ul className="my-2 ml-6 list-disc space-y-1" {...props}>
              {children}
            </ul>
          );
        },
        ol({ children, ...props }) {
          return (
            <ol className="my-2 ml-6 list-decimal space-y-1" {...props}>
              {children}
            </ol>
          );
        }
      }}
      className="prose prose-gray max-w-none dark:prose-invert prose-headings:font-semibold prose-headings:text-[#1A1A1A] dark:prose-headings:text-[#EEEEEE] prose-p:text-[#333333] dark:prose-p:text-[#CCCCCC] prose-p:leading-relaxed prose-li:text-[#333333] dark:prose-li:text-[#CCCCCC] prose-strong:text-[#1A1A1A] dark:prose-strong:text-[#EEEEEE]"
    >
      {content}
    </ReactMarkdown>
  );
}
