import { api } from "@/services/api";

export interface Position {
  id: string;
  name: string;
  description?: string;
  requiredSkills?: string;
  interviewFocus?: string;
}

export interface Question {
  id: string;
  positionId: string;
  questionType?: string;
  difficulty?: number;
  questionText: string;
  referenceAnswer?: string;
  keywords?: string[];
}

export interface InterviewSession {
  id: string;
  userId: string;
  positionId: string;
  status: string;
  totalScore?: number;
  evaluationReport?: string;
  currentQuestionCount?: number;
  timeLimit?: number;
  totalQuestions?: number;
  startTime?: string;
  endTime?: string;
  createTime?: string;
}

export interface AnswerEvaluation {
  score: number;
  technicalScore?: number;
  expressionScore?: number;
  logicScore?: number;
  knowledgeScore?: number;
  feedback: string;
  suggestions: string;
}

export interface SessionDetail {
  session: InterviewSession;
  answers: Array<{
    id: string;
    sessionId: string;
    questionId: string;
    questionText?: string;
    userAnswer: string;
    score?: number;
    technicalScore?: number;
    expressionScore?: number;
    logicScore?: number;
    knowledgeScore?: number;
    feedback?: string;
    suggestions?: string;
  }>;
}

export interface UserProfile {
  totalSessions: number;
  completedSessions: number;
  averageScore: number;
  lastScore?: number;
  averageDurationMinutes: number;
  performanceLevel?: string;
  recommendation?: string;
  weakTopics?: string[];
}

export interface GrowthCurvePoint {
  time: string;
  score: number;
  status?: string;
  durationMinutes?: number;
}

export interface Recommendation {
  summary: string;
  focusAreas: string[];
  nextStep: string;
  averageScore: number;
  completedSessions: number;
}

export async function listPositions(): Promise<Position[]> {
  return api.get<Position[], Position[]>("/position/list");
}

export async function createPosition(
  payload: Partial<Position>
): Promise<Position> {
  return api.post<Position, Position>("/position/create", payload);
}

export async function updatePosition(
  payload: Partial<Position> & { id: string }
): Promise<Position> {
  return api.put<Position, Position>("/position/update", payload);
}

export async function deletePosition(id: string): Promise<void> {
  return api.delete<void, void>(`/position/${id}`);
}

export async function listQuestions(): Promise<Question[]> {
  return api.get<Question[], Question[]>("/question/list");
}

export async function listQuestionsByPosition(
  positionId: string
): Promise<Question[]> {
  return api.get<Question[], Question[]>(`/question/by-position/${positionId}`);
}

export async function createQuestion(
  payload: Partial<Question>
): Promise<Question> {
  return api.post<Question, Question>("/question/create", payload);
}

export async function updateQuestion(
  payload: Partial<Question> & { id: string }
): Promise<Question> {
  return api.put<Question, Question>("/question/update", payload);
}

export async function deleteQuestion(id: string): Promise<void> {
  return api.delete<void, void>(`/question/${id}`);
}

export async function createInterviewSession(
  userId: string,
  positionId: string
): Promise<InterviewSession> {
  const query = new URLSearchParams({ userId, positionId });
  return api.post<InterviewSession, InterviewSession>(
    `/interview/create-session?${query.toString()}`
  );
}

export async function createInterviewSessionWithOptions(
  userId: string,
  positionId: string,
  options?: { timeLimit?: number; totalQuestions?: number }
): Promise<InterviewSession> {
  const query = new URLSearchParams({ userId, positionId });
  if (options?.timeLimit) {
    query.set("timeLimit", String(options.timeLimit));
  }
  if (options?.totalQuestions) {
    query.set("totalQuestions", String(options.totalQuestions));
  }
  return api.post<InterviewSession, InterviewSession>(
    `/interview/create-session-with-options?${query.toString()}`
  );
}

export async function startInterviewSession(
  sessionId: string
): Promise<InterviewSession> {
  const query = new URLSearchParams({ sessionId });
  return api.post<InterviewSession, InterviewSession>(
    `/interview/start-session?${query.toString()}`
  );
}

export async function getInterviewQuestion(
  sessionId: string,
  difficulty?: number
): Promise<Question> {
  const query = new URLSearchParams({ sessionId });
  if (typeof difficulty === "number") {
    query.set("difficulty", String(difficulty));
  }
  return api.get<Question, Question>(`/interview/get-question?${query.toString()}`);
}

export async function submitInterviewAnswer(
  sessionId: string,
  questionId: string,
  userAnswer: string
): Promise<AnswerEvaluation> {
  const query = new URLSearchParams({ sessionId, questionId });
  return api.post<AnswerEvaluation, AnswerEvaluation>(
    `/interview/submit-answer?${query.toString()}`,
    userAnswer,
    {
    headers: {
      "Content-Type": "text/plain;charset=UTF-8"
    }
    }
  );
}

export async function askFollowUpQuestion(
  sessionId: string,
  questionId: string,
  userAnswer: string
): Promise<Question> {
  const query = new URLSearchParams({ sessionId, questionId });
  return api.post<Question, Question>(
    `/interview/ask-follow-up?${query.toString()}`,
    userAnswer,
    {
    headers: {
      "Content-Type": "text/plain;charset=UTF-8"
    }
    }
  );
}

export async function completeInterviewSession(
  sessionId: string
): Promise<InterviewSession> {
  const query = new URLSearchParams({ sessionId });
  return api.post<InterviewSession, InterviewSession>(
    `/interview/complete-session?${query.toString()}`
  );
}

export async function listInterviewHistory(
  userId: string
): Promise<InterviewSession[]> {
  const query = new URLSearchParams({ userId });
  return api.get<InterviewSession[], InterviewSession[]>(
    `/interview/history?${query.toString()}`
  );
}

export async function getInterviewSessionDetail(
  sessionId: string
): Promise<SessionDetail> {
  const query = new URLSearchParams({ sessionId });
  return api.get<SessionDetail, SessionDetail>(
    `/interview/session-detail?${query.toString()}`
  );
}

export async function listInterviewSessionsByUser(
  userId: string
): Promise<InterviewSession[]> {
  const query = new URLSearchParams({ userId });
  return api.get<InterviewSession[], InterviewSession[]>(
    `/interview/history?${query.toString()}`
  );
}

export async function getUserProfile(): Promise<UserProfile> {
  return api.get<UserProfile, UserProfile>("/user/profile");
}

export async function getGrowthCurve(
  limit = 10
): Promise<GrowthCurvePoint[]> {
  return api.get<GrowthCurvePoint[], GrowthCurvePoint[]>("/user/growth-curve", {
    params: { limit }
  });
}

export async function getUserRecommendation(): Promise<Recommendation> {
  return api.get<Recommendation, Recommendation>("/user/recommendation");
}

function normalizeSpeechRecognitionText(payload: unknown) {
  if (typeof payload === "string") {
    return payload.trim();
  }
  if (!payload || typeof payload !== "object") {
    return "";
  }

  const candidate = payload as Record<string, unknown>;
  const nestedValue = candidate.data ?? candidate.text ?? candidate.result;
  if (typeof nestedValue === "string") {
    return nestedValue.trim();
  }

  return "";
}

export async function recognizeSpeechBase64(audioBase64: string, format = "pcm", sampleRate = 16000, language = "zh_cn") {
  const payload = new URLSearchParams({
    audio: audioBase64,
    format,
    sampleRate: String(sampleRate),
    language
  });
  const response = await api.post<unknown>("/speech/recognize/base64", payload, {
    headers: {
      "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
    }
  });
  return normalizeSpeechRecognitionText(response);
}
