import { create } from "zustand";
import { feedback as feedbackStore } from "@/stores/useFeedbackStore";

import type {
  ChatMode,
  CompletionPayload,
  FeedbackValue,
  InterviewDraftConfig,
  InterviewRuntimeState,
  InterviewSessionState,
  Message,
  MessageDeltaPayload,
  Session
} from "@/types";
import {
  listMessages,
  listSessions,
  deleteSession as deleteSessionRequest,
  renameSession as renameSessionRequest
} from "@/services/sessionService";
import { stopTask, submitFeedback } from "@/services/chatService";
import {
  deleteInterviewChatSession,
  getInterviewChatSession,
  renameInterviewChatSession,
  resolveInterviewConfig,
  startInterviewChat
} from "@/services/interviewChatService";
import type { SpeechAnalysis } from "@/services/interviewService";
import { buildQuery } from "@/utils/helpers";
import { createStreamResponse } from "@/hooks/useStreamResponse";
import { storage } from "@/utils/storage";

interface ChatState {
  sessions: Session[];
  currentSessionId: string | null;
  currentSessionType: "chat" | "interview" | null;
  currentInterviewState: (InterviewSessionState & {
    reportAvailable?: boolean;
    runtime?: InterviewRuntimeState | null;
  }) | null;
  interviewDraftConfig: InterviewDraftConfig;
  messages: Message[];
  isLoading: boolean;
  sessionsLoaded: boolean;
  inputFocusKey: number;
  isStreaming: boolean;
  isCreatingNew: boolean;
  chatMode: ChatMode;
  deepThinkingEnabled: boolean;
  thinkingStartAt: number | null;
  streamTaskId: string | null;
  streamAbort: (() => void) | null;
  streamingMessageId: string | null;
  cancelRequested: boolean;
  fetchSessions: () => Promise<void>;
  createSession: () => Promise<string>;
  startInterviewSession: (config: InterviewDraftConfig, rawIntent?: string) => Promise<string>;
  deleteSession: (sessionId: string) => Promise<void>;
  renameSession: (sessionId: string, title: string) => Promise<void>;
  selectSession: (sessionId: string) => Promise<void>;
  updateSessionTitle: (sessionId: string, title: string) => void;
  setChatMode: (mode: ChatMode) => void;
  cycleChatMode: () => void;
  setDeepThinkingEnabled: (enabled: boolean) => void;
  setInterviewDraftConfig: (patch: Partial<InterviewDraftConfig>) => void;
  sendMessage: (content: string, speechAnalysis?: SpeechAnalysis | null) => Promise<void>;
  cancelGeneration: () => void;
  appendStreamContent: (delta: string) => void;
  appendThinkingContent: (delta: string) => void;
  submitFeedback: (messageId: string, feedback: FeedbackValue) => Promise<void>;
}

function mapVoteToFeedback(vote?: number | null): FeedbackValue {
  if (vote === 1) return "like";
  if (vote === -1) return "dislike";
  return null;
}

function upsertSession(sessions: Session[], next: Session) {
  const index = sessions.findIndex((session) => session.id === next.id);
  const updated = [...sessions];
  if (index >= 0) {
    updated[index] = { ...sessions[index], ...next };
  } else {
    updated.unshift(next);
  }
  return updated.sort((a, b) => {
    const timeA = a.lastTime ? new Date(a.lastTime).getTime() : 0;
    const timeB = b.lastTime ? new Date(b.lastTime).getTime() : 0;
    return timeB - timeA;
  });
}

function computeThinkingDuration(startAt?: number | null) {
  if (!startAt) return undefined;
  const seconds = Math.round((Date.now() - startAt) / 1000);
  return Math.max(1, seconds);
}

function mapConversationMessage(item: {
  id: number | string;
  role: string;
  content: string;
  createTime?: string;
  vote?: number | null;
}): Message {
  return {
    id: String(item.id),
    role: item.role === "assistant" ? "assistant" : "user",
    content: item.content,
    createdAt: item.createTime,
    feedback: mapVoteToFeedback(item.vote),
    status: "done"
  };
}

const DEFAULT_INTERVIEW_CONFIG: InterviewDraftConfig = {
  positionId: "",
  difficulty: 3,
  timeLimitMinutes: 20,
  questionLimit: 5
};

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || "").replace(/\/$/, "");
let fetchSessionsTask: Promise<void> | null = null;
let selectSessionTask: Promise<void> | null = null;
let selectingSessionId: string | null = null;
const CHAT_MODE_SEQUENCE: ChatMode[] = ["interview", "study", "free"];
const INTERVIEW_FEEDBACK_PLACEHOLDER = "我正在分析你的回答，稍等一下。";

export const useChatStore = create<ChatState>((set, get) => ({
  sessions: [],
  currentSessionId: null,
  currentSessionType: null,
  currentInterviewState: null,
  interviewDraftConfig: DEFAULT_INTERVIEW_CONFIG,
  messages: [],
  isLoading: false,
  sessionsLoaded: false,
  inputFocusKey: 0,
  isStreaming: false,
  isCreatingNew: false,
  chatMode: "interview",
  deepThinkingEnabled: false,
  thinkingStartAt: null,
  streamTaskId: null,
  streamAbort: null,
  streamingMessageId: null,
  cancelRequested: false,
  fetchSessions: async () => {
    if (fetchSessionsTask) {
      return fetchSessionsTask;
    }
    fetchSessionsTask = (async () => {
      set({ isLoading: true });
      try {
        const data = await listSessions();
        const fetchedSessions = data
          .map((item) => ({
            id: item.conversationId,
            title: item.title || "新对话",
            lastTime: item.lastTime,
            type: item.sessionType || "chat",
            status: item.interviewStatus,
            positionName: item.positionName
          }))
          .sort((a, b) => {
            const timeA = a.lastTime ? new Date(a.lastTime).getTime() : 0;
            const timeB = b.lastTime ? new Date(b.lastTime).getTime() : 0;
            return timeB - timeA;
          });
        set((state) => {
          const mergedSessions = fetchedSessions.reduce(
            (acc, session) => upsertSession(acc, session),
            state.sessions
          );
          return { sessions: mergedSessions };
        });
      } finally {
        set({ isLoading: false, sessionsLoaded: true });
        fetchSessionsTask = null;
      }
    })();
    return fetchSessionsTask;
  },
  createSession: async () => {
    const state = get();
    if (state.messages.length === 0 && !state.currentSessionId) {
      set({
        isCreatingNew: true,
        chatMode: "interview",
        isLoading: false,
        thinkingStartAt: null,
        deepThinkingEnabled: false,
        currentSessionType: null,
        currentInterviewState: null
      });
      return "";
    }
    if (state.isStreaming) {
      get().cancelGeneration();
    }
    set({
      currentSessionId: null,
      currentSessionType: null,
      currentInterviewState: null,
      messages: [],
      isStreaming: false,
      isLoading: false,
      isCreatingNew: true,
      chatMode: "interview",
      deepThinkingEnabled: false,
      thinkingStartAt: null,
      streamTaskId: null,
      streamAbort: null,
      streamingMessageId: null,
      cancelRequested: false
    });
    return "";
  },
  startInterviewSession: async (config, rawIntent) => {
    set({ isLoading: true, isCreatingNew: true });
    try {
      const response = await startInterviewChat({ ...config, rawIntent });
      const session: Session = {
        id: response.session.id,
        title: `面试 · ${response.session.positionName || "岗位"}`,
        lastTime: new Date().toISOString(),
        type: "interview",
        status: response.session.status,
        positionName: response.session.positionName
      };
      set((state) => ({
        currentSessionId: response.session.id,
        currentSessionType: "interview",
        currentInterviewState: {
          ...response.session,
          runtime: response.runtime,
          reportAvailable: response.reportAvailable
        },
        interviewDraftConfig: {
          positionId: response.session.positionId,
          difficulty: response.session.difficulty,
          timeLimitMinutes: response.session.timeLimitMinutes,
          questionLimit: response.session.questionLimit
        },
        messages: response.messages.map(mapConversationMessage),
        sessions: upsertSession(state.sessions, session),
        inputFocusKey: Date.now(),
        isCreatingNew: false
      }));
      return response.session.id;
    } catch (error) {
      feedbackStore.error((error as Error).message || "启动面试失败");
      throw error;
    } finally {
      set((state) => ({
        isLoading: false,
        isCreatingNew: state.currentSessionId ? state.isCreatingNew : false
      }));
    }
  },
  deleteSession: async (sessionId) => {
    const session = get().sessions.find((item) => item.id === sessionId);
    try {
      if (session?.type === "interview") {
        await deleteInterviewChatSession(sessionId);
      } else {
        await deleteSessionRequest(sessionId);
      }
      set((state) => ({
        sessions: state.sessions.filter((item) => item.id !== sessionId),
        messages: state.currentSessionId === sessionId ? [] : state.messages,
        currentSessionId: state.currentSessionId === sessionId ? null : state.currentSessionId,
        currentSessionType: state.currentSessionId === sessionId ? null : state.currentSessionType,
        currentInterviewState: state.currentSessionId === sessionId ? null : state.currentInterviewState
      }));
      feedbackStore.success("删除成功");
    } catch (error) {
      feedbackStore.error((error as Error).message || "删除会话失败");
    }
  },
  renameSession: async (sessionId, title) => {
    const nextTitle = title.trim();
    if (!nextTitle) return;
    const session = get().sessions.find((item) => item.id === sessionId);
    try {
      if (session?.type === "interview") {
        await renameInterviewChatSession(sessionId, nextTitle);
      } else {
        await renameSessionRequest(sessionId, nextTitle);
      }
      set((state) => ({
        sessions: state.sessions.map((item) =>
          item.id === sessionId ? { ...item, title: nextTitle } : item
        )
      }));
      feedbackStore.success("已重命名");
    } catch (error) {
      feedbackStore.error((error as Error).message || "重命名失败");
    }
  },
  selectSession: async (sessionId) => {
    if (!sessionId) return;
    const targetSession = get().sessions.find((item) => item.id === sessionId);
    if (get().currentSessionId === sessionId && get().messages.length > 0) return;
    if (selectingSessionId === sessionId && selectSessionTask) {
      return selectSessionTask;
    }
    if (get().isStreaming) {
      get().cancelGeneration();
    }
    set({
      isLoading: true,
      currentSessionId: sessionId,
      currentSessionType: targetSession?.type || "chat",
      currentInterviewState: null,
      isCreatingNew: false,
      thinkingStartAt: null
    });
    selectingSessionId = sessionId;
    selectSessionTask = (async () => {
      try {
        if (targetSession?.type === "interview") {
          const [data, interviewState] = await Promise.all([
            listMessages(sessionId),
            getInterviewChatSession(sessionId)
          ]);
          if (get().currentSessionId !== sessionId) {
            return;
          }
          set({
            messages: data.map(mapConversationMessage),
            currentSessionType: "interview",
            currentInterviewState: {
              ...interviewState.session,
              runtime: interviewState.runtime,
              reportAvailable: interviewState.reportAvailable
            }
          });
          return;
        }

        const data = await listMessages(sessionId);
        if (get().currentSessionId !== sessionId) {
          return;
        }
        set({
          messages: data.map(mapConversationMessage),
          currentSessionType: "chat",
          currentInterviewState: null
        });
      } catch (error) {
        feedbackStore.error((error as Error).message || "加载消息失败");
      } finally {
        if (selectingSessionId === sessionId) {
          selectingSessionId = null;
          selectSessionTask = null;
        }
        if (get().currentSessionId !== sessionId) {
          set({ isLoading: false });
          return;
        }
        set({
          isLoading: false,
          isStreaming: false,
          streamTaskId: null,
          streamAbort: null,
          streamingMessageId: null,
          cancelRequested: false
        });
      }
    })();
    return selectSessionTask;
  },
  updateSessionTitle: (sessionId, title) => {
    set((state) => ({
      sessions: state.sessions.map((session) =>
        session.id === sessionId ? { ...session, title } : session
      )
    }));
  },
  setChatMode: (mode) => {
    set({ chatMode: mode });
  },
  cycleChatMode: () => {
    set((state) => {
      const index = CHAT_MODE_SEQUENCE.indexOf(state.chatMode);
      const nextIndex = index >= 0 ? (index + 1) % CHAT_MODE_SEQUENCE.length : 0;
      return { chatMode: CHAT_MODE_SEQUENCE[nextIndex] };
    });
  },
  setDeepThinkingEnabled: (enabled) => {
    set({ deepThinkingEnabled: enabled });
  },
  setInterviewDraftConfig: (patch) => {
    set((state) => ({
      interviewDraftConfig: {
        ...state.interviewDraftConfig,
        ...patch
      }
    }));
  },
  sendMessage: async (content, speechAnalysis) => {
    const trimmed = content.trim();
    if (!trimmed) return;
    if (get().isStreaming) return;

    if (get().currentSessionType === "interview" && get().currentSessionId && get().currentInterviewState?.status !== "completed") {
      const sessionId = get().currentSessionId as string;
      const streamPrefix = `interview-assistant-${Date.now()}`;
      const optimisticUserMessage: Message = {
        id: `interview-user-${Date.now()}`,
        role: "user",
        content: trimmed,
        status: "done",
        createdAt: new Date().toISOString(),
        sessionType: "interview"
      };
      const optimisticAssistantId = `${streamPrefix}-1`;
      const optimisticAssistantMessage: Message = {
        id: optimisticAssistantId,
        role: "assistant",
        content: "",
        status: "streaming",
        createdAt: new Date().toISOString(),
        sessionType: "interview"
      };
      set((state) => ({
        isStreaming: true,
        streamingMessageId: optimisticAssistantId,
        streamTaskId: null,
        cancelRequested: false,
        inputFocusKey: Date.now(),
        messages: [...state.messages, optimisticUserMessage, optimisticAssistantMessage]
      }));
      const token = storage.getToken();
      const syncInterviewState = async () => {
        const [data, interviewState] = await Promise.all([
          listMessages(sessionId),
          getInterviewChatSession(sessionId)
        ]);
        set((state) => ({
          messages: data.map(mapConversationMessage),
          currentInterviewState: {
            ...interviewState.session,
            runtime: interviewState.runtime,
            reportAvailable: interviewState.reportAvailable
          },
          sessions: upsertSession(state.sessions, {
            id: interviewState.session.id,
            title:
              state.sessions.find((item) => item.id === interviewState.session.id)?.title ||
              `面试 · ${interviewState.session.positionName || "岗位"}`,
            lastTime: new Date().toISOString(),
            type: "interview",
            status: interviewState.session.status,
            positionName: interviewState.session.positionName
          }),
          inputFocusKey: Date.now()
        }));
      };

      const handlers = {
        onMessage: (payload: MessageDeltaPayload) => {
          if (!payload || typeof payload !== "object") return;
          if (payload.type === "phase") {
            const phase = payload.delta;
            if (phase === "feedback") {
              set((state) => ({
                messages: state.messages.map((message) =>
                  message.id === state.streamingMessageId && !message.content
                    ? {
                        ...message,
                        content: INTERVIEW_FEEDBACK_PLACEHOLDER
                      }
                    : message
                )
              }));
              return;
            }
            set((state) => {
              const currentStreamingId = state.streamingMessageId;
              const nextAssistantId = `${streamPrefix}-2`;
              const hasNextAssistant = state.messages.some((message) => message.id === nextAssistantId);
              return {
                messages: state.messages.map((message) =>
                  message.id === currentStreamingId && message.status === "streaming"
                    ? {
                        ...message,
                        status: "done"
                      }
                    : message
                ).concat(
                  hasNextAssistant
                    ? []
                    : [
                        {
                          id: nextAssistantId,
                          role: "assistant",
                          content: "",
                          status: "streaming",
                          createdAt: new Date().toISOString(),
                          sessionType: "interview"
                        } satisfies Message
                      ]
                ),
                streamingMessageId: nextAssistantId
              };
            });
            return;
          }
          if (payload.type !== "response") return;
          set((state) => ({
            messages: state.messages.map((message) => {
              if (message.id !== state.streamingMessageId) return message;
              if (message.status === "cancelled" || message.status === "error") return message;
              const shouldReplacePlaceholder = message.content === INTERVIEW_FEEDBACK_PLACEHOLDER;
              return {
                ...message,
                content: shouldReplacePlaceholder ? payload.delta : message.content + payload.delta
              };
            })
          }));
        },
        onFinish: () => {
          set((state) => ({
            messages: state.messages.map((message) =>
              message.id === state.streamingMessageId
                ? {
                    ...message,
                    status: "done"
                  }
                : message
            )
          }));
        },
        onDone: () => {
          set({
            isStreaming: false,
            streamAbort: null,
            streamTaskId: null,
            streamingMessageId: null,
            cancelRequested: false
          });
          void syncInterviewState().catch((error) => {
            feedbackStore.error((error as Error).message || "刷新面试状态失败");
          });
        },
        onError: (error: Error) => {
          set((state) => ({
            isStreaming: false,
            streamAbort: null,
            streamTaskId: null,
            streamingMessageId: null,
            cancelRequested: false,
            messages: state.messages.map((message) =>
              message.id === state.streamingMessageId
                ? {
                    ...message,
                    status: "error",
                    content: message.content || "生成失败，请重试。"
                  }
                : message
            )
          }));
          feedbackStore.error(error.message || "提交面试回答失败");
        }
      };

      const { start, cancel } = createStreamResponse(
        {
          url: `${API_BASE_URL}/interview/chat/sessions/${encodeURIComponent(sessionId)}/turn/stream`,
          method: "POST",
          body: JSON.stringify({
            content: trimmed,
            speechAnalysis: speechAnalysis ?? undefined
          }),
          headers: {
            "Content-Type": "application/json",
            ...(token ? { Authorization: token } : {})
          },
          retryCount: 0
        },
        handlers
      );

      set({ streamAbort: cancel });

      try {
        await start();
      } catch (error) {
        if ((error as Error).name === "AbortError") {
          return;
        }
        handlers.onError?.(error as Error);
      }
      return;
    }

    if (get().chatMode === "interview" && get().currentSessionType !== "interview") {
      try {
        const resolved = await resolveInterviewConfig(trimmed);
        if (resolved.matched && resolved.positionId) {
          await get().startInterviewSession(
            {
              positionId: resolved.positionId,
              difficulty: resolved.difficulty,
              timeLimitMinutes: resolved.timeLimitMinutes,
              questionLimit: resolved.questionLimit
            },
            trimmed
          );
          return;
        }
      } catch {
        // Fall back to the normal chat flow
      }
    }

    const deepThinkingEnabled = get().deepThinkingEnabled;
    const inputFocusKey = Date.now();

    const userMessage: Message = {
      id: `user-${Date.now()}`,
      role: "user",
      content: trimmed,
      status: "done",
      createdAt: new Date().toISOString()
    };
    const assistantId = `assistant-${Date.now()}`;
    const assistantMessage: Message = {
      id: assistantId,
      role: "assistant",
      content: "",
      thinking: deepThinkingEnabled ? "" : undefined,
      isDeepThinking: deepThinkingEnabled,
      isThinking: deepThinkingEnabled,
      status: "streaming",
      feedback: null,
      createdAt: new Date().toISOString()
    };

    set((state) => ({
      messages: [...state.messages, userMessage, assistantMessage],
      isStreaming: true,
      streamingMessageId: assistantId,
      thinkingStartAt: deepThinkingEnabled ? Date.now() : null,
      inputFocusKey,
      streamTaskId: null,
      cancelRequested: false
    }));

    const conversationId = get().currentSessionId;
    const query = buildQuery({
      question: trimmed,
      conversationId: conversationId || undefined,
      chatMode: get().chatMode,
      deepThinking: deepThinkingEnabled ? true : undefined
    });
    const url = `${API_BASE_URL}/rag/v3/chat${query}`;
    const token = storage.getToken();

    const handlers = {
      onMeta: (payload: { conversationId: string; taskId: string }) => {
        if (get().streamingMessageId !== assistantId) return;
        const nextId = payload.conversationId || get().currentSessionId;
        if (!nextId) return;
        const lastTime = new Date().toISOString();
        const existing = get().sessions.find((session) => session.id === nextId);
        set((state) => ({
          currentSessionId: nextId,
          currentSessionType: "chat",
          isCreatingNew: false,
          streamTaskId: payload.taskId,
          sessions: upsertSession(state.sessions, {
            id: nextId,
            title: existing?.title || "新对话",
            lastTime,
            type: "chat"
          })
        }));
        if (get().cancelRequested) {
          stopTask(payload.taskId).catch(() => null);
        }
      },
      onMessage: (payload: MessageDeltaPayload) => {
        if (!payload || typeof payload !== "object") return;
        if (payload.type !== "response") return;
        get().appendStreamContent(payload.delta);
      },
      onThinking: (payload: MessageDeltaPayload) => {
        if (!payload || typeof payload !== "object") return;
        if (payload.type !== "think") return;
        get().appendThinkingContent(payload.delta);
      },
      onReject: (payload: MessageDeltaPayload) => {
        if (!payload || typeof payload !== "object") return;
        get().appendStreamContent(payload.delta);
      },
      onFinish: (payload: CompletionPayload) => {
        if (get().streamingMessageId !== assistantId) return;
        if (!payload) return;
        if (payload.title && get().currentSessionId) {
          get().updateSessionTitle(get().currentSessionId as string, payload.title);
        }
        const currentId = get().currentSessionId;
        if (currentId) {
          const lastTime = new Date().toISOString();
          const existingTitle = get().sessions.find((session) => session.id === currentId)?.title || "新对话";
          const nextTitle = payload.title || existingTitle;
          set((state) => ({
            sessions: upsertSession(state.sessions, {
              id: currentId,
              title: nextTitle,
              lastTime,
              type: "chat"
            })
          }));
        }
        if (payload.messageId) {
          set((state) => ({
            messages: state.messages.map((message) =>
              message.id === state.streamingMessageId
                ? {
                    ...message,
                    id: String(payload.messageId),
                    status: "done",
                    isThinking: false,
                    thinkingDuration:
                      message.thinkingDuration ?? computeThinkingDuration(state.thinkingStartAt)
                  }
                : message
            )
          }));
        } else {
          set((state) => ({
            messages: state.messages.map((message) =>
              message.id === state.streamingMessageId
                ? {
                    ...message,
                    status: "done",
                    isThinking: false,
                    thinkingDuration:
                      message.thinkingDuration ?? computeThinkingDuration(state.thinkingStartAt)
                  }
                : message
            )
          }));
        }
      },
      onCancel: (payload: CompletionPayload) => {
        if (get().streamingMessageId !== assistantId) return;
        if (payload?.title && get().currentSessionId) {
          get().updateSessionTitle(get().currentSessionId as string, payload.title);
        }
        set((state) => ({
          messages: state.messages.map((message) => {
            if (message.id !== state.streamingMessageId) return message;
            const suffix = message.content.includes("（已停止生成）") ? "" : "\n\n（已停止生成）";
            const nextId = payload?.messageId ? String(payload.messageId) : message.id;
            return {
              ...message,
              id: nextId,
              content: message.content + suffix,
              status: "cancelled",
              isThinking: false,
              thinkingDuration:
                message.thinkingDuration ?? computeThinkingDuration(state.thinkingStartAt)
            };
          }),
          isStreaming: false,
          thinkingStartAt: null,
          streamTaskId: null,
          streamAbort: null,
          streamingMessageId: null,
          cancelRequested: false
        }));
      },
      onDone: () => {
        if (get().streamingMessageId !== assistantId) return;
        set({
          isStreaming: false,
          thinkingStartAt: null,
          streamTaskId: null,
          streamAbort: null,
          streamingMessageId: null,
          cancelRequested: false
        });
      },
      onTitle: (payload: { title: string }) => {
        if (get().streamingMessageId !== assistantId) return;
        if (payload?.title && get().currentSessionId) {
          get().updateSessionTitle(get().currentSessionId as string, payload.title);
        }
      },
      onError: (error: Error) => {
        if (get().streamingMessageId !== assistantId) return;
        set((state) => ({
          isStreaming: false,
          thinkingStartAt: null,
          streamTaskId: null,
          streamAbort: null,
          cancelRequested: false,
          messages: state.messages.map((message) =>
            message.id === state.streamingMessageId
              ? {
                  ...message,
                  status: "error",
                  isThinking: false,
                  thinkingDuration:
                    message.thinkingDuration ?? computeThinkingDuration(state.thinkingStartAt)
                }
              : message
          )
        }));
        feedbackStore.error(error.message || "生成失败");
      }
    };

    const { start, cancel } = createStreamResponse(
      {
        url,
        headers: token ? { Authorization: token } : undefined,
        retryCount: 1
      },
      handlers
    );

    set({ streamAbort: cancel });

    try {
      await start();
    } catch (error) {
      if ((error as Error).name === "AbortError") {
        return;
      }
      handlers.onError?.(error as Error);
    } finally {
      if (get().streamingMessageId === assistantId) {
        set({
          isStreaming: false,
          streamTaskId: null,
          streamAbort: null,
          streamingMessageId: null,
          cancelRequested: false
        });
      }
    }
  },
  cancelGeneration: () => {
    const { isStreaming, streamTaskId, streamAbort } = get();
    if (!isStreaming) return;
    set({ cancelRequested: true });
    if (streamTaskId) {
      stopTask(streamTaskId).catch(() => null);
      return;
    }
    streamAbort?.();
  },
  appendStreamContent: (delta) => {
    if (!delta) return;
    set((state) => {
      const shouldFinalizeThinking = state.thinkingStartAt != null;
      const duration = computeThinkingDuration(state.thinkingStartAt);
      return {
        thinkingStartAt: shouldFinalizeThinking ? null : state.thinkingStartAt,
        messages: state.messages.map((message) => {
          if (message.id !== state.streamingMessageId) return message;
          if (message.status === "cancelled" || message.status === "error") return message;
          return {
            ...message,
            content: message.content + delta,
            isThinking: shouldFinalizeThinking ? false : message.isThinking,
            thinkingDuration:
              shouldFinalizeThinking && !message.thinkingDuration ? duration : message.thinkingDuration
          };
        })
      };
    });
  },
  appendThinkingContent: (delta) => {
    if (!delta) return;
    set((state) => ({
      thinkingStartAt: state.thinkingStartAt ?? Date.now(),
      messages: state.messages.map((message) =>
        message.id === state.streamingMessageId &&
        message.status !== "cancelled" &&
        message.status !== "error"
          ? {
              ...message,
              thinking: `${message.thinking ?? ""}${delta}`,
              isThinking: true
            }
          : message
      )
    }));
  },
  submitFeedback: async (messageId, feedback) => {
    const vote = feedback === "like" ? 1 : feedback === "dislike" ? -1 : null;
    set((state) => ({
      messages: state.messages.map((message) =>
        message.id === messageId ? { ...message, feedback } : message
      )
    }));
    if (vote === null) {
      feedbackStore.success("取消成功");
      return;
    }
    try {
      await submitFeedback(messageId, vote);
      feedbackStore.success("感谢反馈");
    } catch (error) {
      feedbackStore.error((error as Error).message || "反馈失败");
    }
  }
}));
