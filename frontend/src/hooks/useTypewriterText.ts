import * as React from "react";

interface UseTypewriterTextOptions {
  text?: string | null;
  enabled?: boolean;
  resetKey?: string | number;
  intervalMs?: number;
  onComplete?: () => void;
}

interface UseTypewriterTextResult {
  displayText: string;
  isAnimating: boolean;
  finishNow: () => void;
}

function getStepSize(length: number) {
  if (length <= 40) return 1;
  if (length <= 120) return 2;
  if (length <= 240) return 3;
  if (length <= 480) return 5;
  return 8;
}

export function useTypewriterText({
  text,
  enabled = true,
  resetKey,
  intervalMs = 24,
  onComplete
}: UseTypewriterTextOptions): UseTypewriterTextResult {
  const sourceText = text ?? "";
  const codePoints = React.useMemo(() => Array.from(sourceText), [sourceText]);
  const timerRef = React.useRef<number | null>(null);
  const indexRef = React.useRef(0);
  const onCompleteRef = React.useRef(onComplete);
  const [displayText, setDisplayText] = React.useState(() => (enabled ? "" : sourceText));
  const [isAnimating, setIsAnimating] = React.useState(false);

  onCompleteRef.current = onComplete;

  const clearTimer = React.useCallback(() => {
    if (timerRef.current !== null) {
      window.clearTimeout(timerRef.current);
      timerRef.current = null;
    }
  }, []);

  const finishNow = React.useCallback(() => {
    clearTimer();
    indexRef.current = codePoints.length;
    setDisplayText(sourceText);
    setIsAnimating(false);
  }, [clearTimer, codePoints.length, sourceText]);

  React.useEffect(() => {
    clearTimer();

    if (!enabled) {
      indexRef.current = codePoints.length;
      setDisplayText(sourceText);
      setIsAnimating(false);
      return;
    }

    if (codePoints.length === 0) {
      indexRef.current = 0;
      setDisplayText("");
      setIsAnimating(false);
      return;
    }

    indexRef.current = 0;
    setDisplayText("");
    setIsAnimating(true);

    const step = getStepSize(codePoints.length);

    const tick = () => {
      const nextIndex = Math.min(indexRef.current + step, codePoints.length);
      indexRef.current = nextIndex;
      setDisplayText(codePoints.slice(0, nextIndex).join(""));

      if (nextIndex >= codePoints.length) {
        timerRef.current = null;
        setIsAnimating(false);
        onCompleteRef.current?.();
        return;
      }

      timerRef.current = window.setTimeout(tick, intervalMs);
    };

    timerRef.current = window.setTimeout(tick, intervalMs);

    return clearTimer;
  }, [clearTimer, codePoints, enabled, intervalMs, resetKey, sourceText]);

  React.useEffect(() => clearTimer, [clearTimer]);

  return {
    displayText,
    isAnimating,
    finishNow
  };
}
