import * as React from "react";

import { cn } from "@/lib/utils";

interface FaceItMarkProps {
  className?: string;
  light?: boolean;
}

export function FaceItMark({ className, light = false }: FaceItMarkProps) {
  const primary = light ? "#FFFFFF" : "url(#fi-mark-gradient)";
  const accent = light ? "rgba(255,255,255,0.45)" : "#BFDBFE";

  return (
    <svg
      viewBox="0 0 64 64"
      aria-hidden="true"
      className={cn("shrink-0", className)}
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <linearGradient id="fi-mark-gradient" x1="14" y1="10" x2="50" y2="52" gradientUnits="userSpaceOnUse">
          <stop offset="0" stopColor="#60A5FA" />
          <stop offset="1" stopColor="#2563EB" />
        </linearGradient>
      </defs>
      <path d="M16 16h24v7H25v9h13v7H25v12h-9V16z" fill={primary} />
      <path d="M43 16h8v35h-8z" fill={primary} />
      <path d="M20 48c7-5.5 14-7 23.5-6.4" fill="none" stroke={accent} strokeWidth="3" strokeLinecap="round" />
    </svg>
  );
}
