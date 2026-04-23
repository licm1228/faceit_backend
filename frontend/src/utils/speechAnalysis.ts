import type { SpeechAnalysis } from "@/services/interviewService";

const CLARITY_WPM_MIN = 120;
const CLARITY_WPM_MAX = 230;

function clamp(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, value));
}

function average(values: number[]) {
  if (values.length === 0) return 0;
  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

function round(value: number, digits = 2) {
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
}

function scoreByRange(value: number, idealMin: number, idealMax: number) {
  if (value >= idealMin && value <= idealMax) {
    return 90;
  }
  if (value <= 0) {
    return 0;
  }
  const distance = value < idealMin ? idealMin - value : value - idealMax;
  return clamp(Math.round(90 - distance * 0.8), 40, 90);
}

export function analyzeSpeechFromSamples(samples: Float32Array[], sampleRate: number, transcript: string): SpeechAnalysis | null {
  if (!samples.length || sampleRate <= 0) {
    return null;
  }

  const mergedLength = samples.reduce((sum, chunk) => sum + chunk.length, 0);
  if (mergedLength === 0) {
    return null;
  }

  const merged = new Float32Array(mergedLength);
  let offset = 0;
  for (const chunk of samples) {
    merged.set(chunk, offset);
    offset += chunk.length;
  }

  const absolute = Array.from(merged, (value) => Math.abs(value));
  const averageVolume = average(absolute);
  const peakVolume = absolute.reduce((max, value) => Math.max(max, value), 0);
  const durationSeconds = merged.length / sampleRate;
  const transcriptLength = transcript.replace(/\s+/g, "").length;
  const wordsPerMinute = durationSeconds > 0 ? (transcriptLength / durationSeconds) * 60 : 0;

  const silentThreshold = Math.max(averageVolume * 0.45, 0.012);
  const silentSamples = absolute.filter((value) => value < silentThreshold).length;
  const pauseRatio = merged.length > 0 ? silentSamples / merged.length : 0;

  const clarityScore = clamp(Math.round(
    scoreByRange(wordsPerMinute, CLARITY_WPM_MIN, CLARITY_WPM_MAX)
    - Math.max(0, (pauseRatio - 0.38) * 100)
  ), 35, 95);

  const confidenceScore = clamp(Math.round(
    50
    + Math.min(28, averageVolume * 140)
    + Math.min(12, peakVolume * 20)
    - Math.max(0, (pauseRatio - 0.35) * 60)
  ), 35, 95);

  const fluencyScore = clamp(Math.round(
    88
    - Math.max(0, Math.abs(wordsPerMinute - 180) * 0.45)
    - Math.max(0, (pauseRatio - 0.28) * 120)
  ), 30, 95);

  const expressionScore = clamp(Math.round(
    clarityScore * 0.4 + confidenceScore * 0.3 + fluencyScore * 0.3
  ), 0, 100);

  let summary = "表达节奏有待加强";
  if (expressionScore >= 85) {
    summary = "语速稳定，表达清晰，自信度较好";
  } else if (expressionScore >= 70) {
    summary = "表达整体清楚，节奏较稳，仍可优化停顿和重点强调";
  } else if (expressionScore >= 55) {
    summary = "能表达主要内容，但语速和停顿控制还有提升空间";
  }

  return {
    durationSeconds: round(durationSeconds, 1),
    wordsPerMinute: round(wordsPerMinute, 1),
    averageVolume: round(averageVolume, 3),
    peakVolume: round(peakVolume, 3),
    pauseRatio: round(pauseRatio, 2),
    clarityScore,
    confidenceScore,
    fluencyScore,
    expressionScore,
    summary
  };
}
