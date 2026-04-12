import { api } from "@/services/api";
import type { InterviewDraftConfig, InterviewReport, InterviewRuntimeState, InterviewSessionState } from "@/types";

type InterviewChatMessage = {
  id: string | number;
  conversationId: string;
  role: string;
  content: string;
  vote?: number | null;
  createTime?: string;
};

type ResolveConfigResponse = {
  matched: boolean;
  positionId?: string | null;
  positionName?: string | null;
  difficulty: number;
  timeLimitMinutes: number;
  questionLimit: number;
};

type InterviewSessionResponse = {
  session: InterviewSessionState;
  messages: InterviewChatMessage[];
  runtime: InterviewRuntimeState;
  reportAvailable?: boolean;
  report?: InterviewReport;
};

export async function resolveInterviewConfig(content: string): Promise<ResolveConfigResponse> {
  return api.post<ResolveConfigResponse, ResolveConfigResponse>("/interview/chat/resolve-config", { content });
}

export async function startInterviewChat(
  payload: InterviewDraftConfig & { rawIntent?: string }
): Promise<InterviewSessionResponse> {
  return api.post<InterviewSessionResponse, InterviewSessionResponse>("/interview/chat/start", payload);
}

export async function sendInterviewChatTurn(
  sessionId: string,
  content: string
): Promise<InterviewSessionResponse> {
  return api.post<InterviewSessionResponse, InterviewSessionResponse>(
    `/interview/chat/sessions/${sessionId}/turn`,
    { content }
  );
}

export async function getInterviewChatSession(sessionId: string): Promise<{
  session: InterviewSessionState;
  runtime: InterviewRuntimeState;
  reportAvailable: boolean;
}> {
  return api.get(`/interview/chat/sessions/${sessionId}`);
}

export async function getInterviewChatReport(sessionId: string): Promise<InterviewReport> {
  return api.get<InterviewReport, InterviewReport>(`/interview/chat/sessions/${sessionId}/report`);
}

export async function renameInterviewChatSession(sessionId: string, title: string): Promise<void> {
  return api.put<void, void>(`/interview/chat/sessions/${sessionId}`, { title });
}

export async function deleteInterviewChatSession(sessionId: string): Promise<void> {
  return api.delete<void, void>(`/interview/chat/sessions/${sessionId}`);
}
