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
}

export interface InterviewSession {
  id: string;
  userId: string;
  positionId: string;
  status: string;
  totalScore?: number;
  evaluationReport?: string;
  startTime?: string;
  endTime?: string;
  createTime?: string;
}

export interface AnswerEvaluation {
  score: number;
  feedback: string;
  suggestions: string;
}

export interface SessionDetail {
  session: InterviewSession;
  answers: Array<{
    id: string;
    sessionId: string;
    questionId: string;
    userAnswer: string;
    score?: number;
    feedback?: string;
    suggestions?: string;
  }>;
}

export async function listPositions() {
  return api.get<Position[]>("/position/list");
}

export async function createPosition(payload: Partial<Position>) {
  return api.post<Position>("/position/create", payload);
}

export async function updatePosition(payload: Partial<Position> & { id: string }) {
  return api.put<Position>("/position/update", payload);
}

export async function deletePosition(id: string) {
  return api.delete<void>(`/position/${id}`);
}

export async function listQuestions() {
  return api.get<Question[]>("/question/list");
}

export async function listQuestionsByPosition(positionId: string) {
  return api.get<Question[]>(`/question/by-position/${positionId}`);
}

export async function createQuestion(payload: Partial<Question>) {
  return api.post<Question>("/question/create", payload);
}

export async function updateQuestion(payload: Partial<Question> & { id: string }) {
  return api.put<Question>("/question/update", payload);
}

export async function deleteQuestion(id: string) {
  return api.delete<void>(`/question/${id}`);
}

export async function createInterviewSession(userId: string, positionId: string) {
  const query = new URLSearchParams({ userId, positionId });
  return api.post<InterviewSession>(`/interview/create-session?${query.toString()}`);
}

export async function startInterviewSession(sessionId: string) {
  const query = new URLSearchParams({ sessionId });
  return api.post<InterviewSession>(`/interview/start-session?${query.toString()}`);
}

export async function getInterviewQuestion(sessionId: string, difficulty?: number) {
  const query = new URLSearchParams({ sessionId });
  if (typeof difficulty === "number") {
    query.set("difficulty", String(difficulty));
  }
  return api.get<Question>(`/interview/get-question?${query.toString()}`);
}

export async function submitInterviewAnswer(sessionId: string, questionId: string, userAnswer: string) {
  const query = new URLSearchParams({ sessionId, questionId });
  return api.post<AnswerEvaluation>(`/interview/submit-answer?${query.toString()}`, userAnswer, {
    headers: {
      "Content-Type": "text/plain;charset=UTF-8"
    }
  });
}

export async function completeInterviewSession(sessionId: string) {
  const query = new URLSearchParams({ sessionId });
  return api.post<InterviewSession>(`/interview/complete-session?${query.toString()}`);
}

export async function listInterviewHistory(userId: string) {
  const query = new URLSearchParams({ userId });
  return api.get<InterviewSession[]>(`/interview/history?${query.toString()}`);
}

export async function getInterviewSessionDetail(sessionId: string) {
  const query = new URLSearchParams({ sessionId });
  return api.get<SessionDetail>(`/interview/session-detail?${query.toString()}`);
}
