export type Role = "user" | "assistant";

export type FeedbackValue = "like" | "dislike" | null;

export type MessageStatus = "streaming" | "done" | "cancelled" | "error";

export interface User {
  userId: string;
  username?: string;
  role: string;
  token: string;
  avatar?: string;
}

export type CurrentUser = Omit<User, "token">;

export interface Session {
  id: string;
  title: string;
  lastTime?: string;
  type?: "chat" | "interview";
  status?: "pending" | "in_progress" | "completed";
  positionName?: string;
}

export interface Message {
  id: string;
  role: Role;
  content: string;
  thinking?: string;
  thinkingDuration?: number;
  isDeepThinking?: boolean;
  isThinking?: boolean;
  createdAt?: string;
  feedback?: FeedbackValue;
  status?: MessageStatus;
  sessionType?: "chat" | "interview";
}

export interface StreamMetaPayload {
  conversationId: string;
  taskId: string;
}

export interface MessageDeltaPayload {
  type: string;
  delta: string;
}

export interface CompletionPayload {
  messageId?: string | null;
  title?: string | null;
}

export interface InterviewPosition {
  id: string;
  name: string;
  description?: string;
}

export interface InterviewQuestion {
  id: string;
  positionId: string;
  questionType?: string;
  difficulty?: number;
  questionText: string;
  referenceAnswer?: string;
}

export interface InterviewDraftConfig {
  positionId: string;
  difficulty: number;
  timeLimitMinutes: number;
  questionLimit: number;
}

export interface InterviewRuntimeState extends InterviewDraftConfig {
  positionName?: string;
  currentQuestionId?: string;
  currentQuestionText?: string;
  questionIndex?: number;
  followUpCount?: number;
  askedQuestionIds?: string[];
}

export interface InterviewSessionState {
  id: string;
  status: "pending" | "in_progress" | "completed";
  positionId: string;
  positionName?: string;
  reportStatus?: "pending" | "ready";
  totalScore?: number;
  currentQuestionCount?: number;
  startTime?: string;
  endTime?: string;
  difficulty: number;
  timeLimitMinutes: number;
  questionLimit: number;
}

export interface InterviewReport {
  reportStatus?: "pending" | "ready";
  overallScore: number;
  positionName?: string;
  questionLimit?: number;
  timeLimitMinutes?: number;
  summary?: string;
  dimensionScores: {
    technicalCorrectness: number;
    knowledgeDepth: number;
    logicRigor: number;
    positionMatch: number;
  };
  highlights: string[];
  weaknesses: string[];
  improvementSuggestions: string[];
  recommendedPractices: Array<{
    id: string;
    questionText: string;
    difficulty?: number;
    questionType?: string;
  }>;
}
