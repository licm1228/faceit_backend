import type { Message } from "@/types";

const STUDY_PAYLOAD_START = "<!--FACEIT_STUDY_PAYLOAD_BEGIN";
const STUDY_PAYLOAD_PATTERN =
  /<!--FACEIT_STUDY_PAYLOAD_BEGIN\s*([\s\S]*?)\s*FACEIT_STUDY_PAYLOAD_END-->/;

export interface StudyPracticeItem {
  id?: string;
  questionText?: string;
  difficulty?: number;
  questionType?: string;
  focus?: string;
  referenceAnswerPreview?: string;
  suggestion?: string;
  source?: string;
}

export interface StudyResourceItem {
  id?: string;
  title?: string;
  knowledgeBaseName?: string;
  matchedKeyword?: string;
  resourceType?: string;
  recommendationReason?: string;
  snippet?: string;
  score?: number;
}

export interface StudyPayload {
  kind?: string;
  positionName?: string;
  learningSummary?: string;
  conceptExplanation?: string;
  keyPoints?: string[];
  commonMistakes?: string[];
  practiceQuestions?: StudyPracticeItem[];
  answerFramework?: string[];
  nextActions?: string[];
  relatedResources?: StudyResourceItem[];
}

export function parseStudyMessage(content: string): {
  displayContent: string;
  studyPayload?: StudyPayload;
} {
  if (!content) {
    return { displayContent: "" };
  }

  const match = content.match(STUDY_PAYLOAD_PATTERN);
  const markerIndex = content.indexOf(STUDY_PAYLOAD_START);
  const displayContent = markerIndex >= 0 ? content.slice(0, markerIndex).trim() : content.trim();

  if (!match?.[1]) {
    return { displayContent };
  }

  try {
    return {
      displayContent,
      studyPayload: JSON.parse(match[1]) as StudyPayload
    };
  } catch {
    return { displayContent };
  }
}

export function isStudyMessage(message: Message): boolean {
  return Boolean(parseStudyMessage(message.content).studyPayload);
}
