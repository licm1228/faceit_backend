import { cn } from "@/lib/utils";

interface FaceItMarkProps {
  className?: string;
  light?: boolean;
}

export function FaceItMark({ className, light = false }: FaceItMarkProps) {
  return (
    <img
      src="/FASTGPT.svg"
      alt=""
      aria-hidden="true"
      className={cn("shrink-0 object-contain", light && "brightness-0 invert", className)}
    />
  );
}
