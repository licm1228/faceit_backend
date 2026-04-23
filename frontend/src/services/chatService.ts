import { api } from "@/services/api";

export async function stopTask(taskId: string): Promise<void> {
  return api.post<void, void>(`/rag/v3/stop?taskId=${encodeURIComponent(taskId)}`);
}

export async function submitFeedback(
  messageId: string,
  vote: number
): Promise<void> {
  return api.post<void, void>(`/conversations/messages/${messageId}/feedback`, {
    vote
  });
}
