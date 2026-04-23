import type { Position } from "@/services/interviewService";

export type JobPreset = {
  id: string;
  title: string;
  description: string;
  iconPath: string;
  preferredPositionNames: string[];
  positionKeywords: string[];
};

export type InterviewPresetState = {
  positionId?: string;
  preferredPositionNames?: string[];
  positionKeywords?: string[];
  difficulty?: number;
  timeLimitMinutes?: number;
  questionLimit?: number;
  autoStart?: boolean;
};

export const JOB_PRESETS: JobPreset[] = [
  {
    id: "web-frontend",
    title: "Web前端开发",
    description: "偏重 React、工程化、性能优化与浏览器基础",
    iconPath: "/icons/web-frontend.svg",
    preferredPositionNames: ["Web前端开发工程师"],
    positionKeywords: ["web前端", "前端", "react", "vue", "javascript", "typescript"]
  },
  {
    id: "java-backend",
    title: "Java后端开发",
    description: "覆盖 Java、Spring、数据库、并发与系统设计",
    iconPath: "/icons/java-backend.svg",
    preferredPositionNames: ["Java后端开发工程师"],
    positionKeywords: ["java后端", "java", "后端", "spring", "spring boot"]
  },
  {
    id: "python-algorithm",
    title: "Python算法开发",
    description: "聚焦 Python、数据结构、算法思维与编码实现",
    iconPath: "/icons/python-algorithm.svg",
    preferredPositionNames: ["Python算法开发工程师"],
    positionKeywords: ["python算法", "python", "算法", "机器学习", "数据结构", "算法复杂度"]
  }
];

function matchPositionKeywords(position: Position, keywords: string[]) {
  if (keywords.length === 0) {
    return false;
  }
  const searchText = [
    position.name,
    position.description,
    position.requiredSkills,
    position.interviewFocus
  ]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();

  return keywords.some((keyword) => searchText.includes(keyword));
}

function matchPositionByName(position: Position, preferredNames: string[]) {
  if (preferredNames.length === 0) {
    return false;
  }
  const positionName = (position.name || "").trim().toLowerCase();
  return preferredNames.some((name) => positionName === name.trim().toLowerCase());
}

export function resolveInterviewPresetPosition(
  positions: Position[],
  preset?: Pick<InterviewPresetState, "positionId" | "preferredPositionNames" | "positionKeywords"> | null
) {
  if (!preset || positions.length === 0) {
    return null;
  }

  const matchedPositionById = preset.positionId
    ? positions.find((position) => position.id === preset.positionId)
    : null;
  if (matchedPositionById) {
    return matchedPositionById;
  }

  const preferredNames = (preset.preferredPositionNames ?? []).map((name) => name.trim().toLowerCase());
  const matchedPositionByName = positions.find((position) => matchPositionByName(position, preferredNames));
  if (matchedPositionByName) {
    return matchedPositionByName;
  }

  const keywords = (preset.positionKeywords ?? []).map((keyword) => keyword.trim().toLowerCase());
  return positions.find((position) => matchPositionKeywords(position, keywords)) ?? null;
}
