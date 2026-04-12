import { api } from "@/services/api";

export interface ConversationVO {
  conversationId: string;
  title: string;
  lastTime?: string;
  sessionType?: "chat" | "interview";
  interviewStatus?: "pending" | "in_progress" | "completed";
  positionName?: string;
}

export interface ConversationMessageVO {
  id: number | string;
  conversationId: string;
  role: string;
  content: string;
  vote: number | null;
  createTime?: string;
}

export async function listSessions(): Promise<ConversationVO[]> {
  return api.get<ConversationVO[], ConversationVO[]>("/conversations");
}

export async function deleteSession(conversationId: string): Promise<void> {
  return api.delete<void, void>(`/conversations/${conversationId}`);
}

export async function renameSession(conversationId: string, title: string): Promise<void> {
  return api.put<void, void>(`/conversations/${conversationId}`, { title });
}

export async function listMessages(
  conversationId: string
): Promise<ConversationMessageVO[]> {
  return api.get<ConversationMessageVO[], ConversationMessageVO[]>(
    `/conversations/${conversationId}/messages`
  );
}
