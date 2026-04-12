// @ts-nocheck
/* eslint-disable */

import * as React from "react";
import { Check, Copy } from "lucide-react";
import { Prism as SyntaxHighlighter } from "react-syntax-highlighter";
import { oneDark, oneLight } from "react-syntax-highlighter/dist/esm/styles/prism";

import { Button } from "@/components/ui/button";
import { useThemeStore } from "@/stores/themeStore";

interface CodeBlockProps {
  language: string;
  value: string;
}

export function CodeBlock({ language, value }: CodeBlockProps) {
  const theme = useThemeStore((state) => state.theme);

  return (
    <div className="my-3 overflow-hidden rounded-md border border-[#d0d7de] bg-[#f6f8fa] dark:border-[#30363d] dark:bg-[#161b22]">
      <div className="flex items-center justify-between border-b border-[#d0d7de] bg-[#f6f8fa] px-3 py-1.5 dark:border-[#30363d] dark:bg-[#161b22]">
        <span className="font-mono text-[11px] font-semibold uppercase tracking-wider text-[#57606a] dark:text-[#8b949e]">
          {language}
        </span>
        <CopyButton value={value} />
      </div>
      <div className="overflow-x-auto">
        <SyntaxHighlighter
          language={language}
          style={theme === "dark" ? oneDark : oneLight}
          PreTag="div"
          customStyle={{
            margin: 0,
            padding: "0.75rem 1rem",
            background: "transparent",
            fontSize: "13px",
            lineHeight: "1.5"
          }}
          showLineNumbers={false}
          wrapLines={true}
        >
          {value}
        </SyntaxHighlighter>
      </div>
    </div>
  );
}

function CopyButton({ value }: { value: string }) {
  const [copied, setCopied] = React.useState(false);

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(value);
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    } catch {
      setCopied(false);
    }
  };

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={handleCopy}
      aria-label="复制代码"
      className="h-7 w-7 hover:bg-[#eaeef2] dark:hover:bg-[#30363d] transition-colors"
    >
      {copied ? (
        <Check className="h-3.5 w-3.5 text-green-600 dark:text-green-400" />
      ) : (
        <Copy className="h-3.5 w-3.5 text-[#57606a] dark:text-[#8b949e]" />
      )}
    </Button>
  );
}
