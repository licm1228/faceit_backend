import { create } from "zustand";
import { feedback } from "@/stores/useFeedbackStore";

import type {
  AnswerEvaluation,
  GrowthCurvePoint,
  InterviewSession,
  InterviewStreamMessagePayload,
  Position,
  Question,
  Recommendation,
  SessionDetail,
  UserProfile
} from "@/services/interviewService";
import {
  askFollowUpQuestion,
  completeInterviewSession,
  createInterviewSession,
  createInterviewSessionWithOptions,
  getGrowthCurve,
  getInterviewQuestion,
  getInterviewSessionDetail,
  getUserProfile,
  getUserRecommendation,
  listInterviewHistory,
  listPositions,
  startInterviewSession,
  streamCompleteInterviewSession,
  streamFollowUpQuestion,
  streamInterviewAnswer,
  submitInterviewAnswer
} from "@/services/interviewService";

interface InterviewState {
  positions: Position[];
  history: InterviewSession[];
  currentSession: InterviewSession | null;
  currentQuestion: Question | null;
  currentEvaluation: AnswerEvaluation | null;
  followUpQuestion: Question | null;
  sessionDetail: SessionDetail | null;
  profile: UserProfile | null;
  growthCurve: GrowthCurvePoint[];
  recommendation: Recommendation | null;
  difficulty: number;
  loading: boolean;
  submitting: boolean;
  isStreamingEvaluation: boolean;
  isStreamingFollowUp: boolean;
  isStreamingReport: boolean;
  streamingFeedback: string;
  streamingSuggestions: string;
  streamingFollowUpText: string;
  streamingReport: string;
  streamAbort: (() => void) | null;
  fetchPositions: () => Promise<void>;
  createAndStartSession: (
    userId: string,
    positionId: string,
    options?: { timeLimit?: number; totalQuestions?: number }
  ) => Promise<void>;
  fetchQuestion: () => Promise<void>;
  submitAnswer: (answer: string) => Promise<void>;
  generateFollowUp: (answer: string) => Promise<void>;
  completeSession: () => Promise<void>;
  fetchHistory: (userId: string) => Promise<void>;
  fetchSessionDetail: (sessionId: string) => Promise<void>;
  fetchProfileData: () => Promise<void>;
  setDifficulty: (difficulty: number) => void;
  cancelStreaming: () => void;
  resetCurrentFlow: () => void;
}

export const useInterviewStore = create<InterviewState>((set, get) => ({
  positions: [],
  history: [],
  currentSession: null,
  currentQuestion: null,
  currentEvaluation: null,
  followUpQuestion: null,
  sessionDetail: null,
  profile: null,
  growthCurve: [],
  recommendation: null,
  difficulty: 3,
  loading: false,
  submitting: false,
  isStreamingEvaluation: false,
  isStreamingFollowUp: false,
  isStreamingReport: false,
  streamingFeedback: "",
  streamingSuggestions: "",
  streamingFollowUpText: "",
  streamingReport: "",
  streamAbort: null,
  fetchPositions: async () => {
    set({ loading: true });
    try {
      const positions = await listPositions();
      set({ positions });
    } catch (error) {
      feedback.error((error as Error).message || "加载岗位失败");
    } finally {
      set({ loading: false });
    }
  },
  createAndStartSession: async (userId, positionId, options) => {
    get().cancelStreaming();
    set({
      loading: true,
      currentEvaluation: null,
      currentQuestion: null,
      followUpQuestion: null,
      streamingFeedback: "",
      streamingSuggestions: "",
      streamingFollowUpText: "",
      streamingReport: ""
    });
    try {
      let session: InterviewSession;
      try {
        session = await createInterviewSessionWithOptions(userId, positionId, options);
      } catch {
        session = await createInterviewSession(userId, positionId);
      }
      const started = await startInterviewSession(session.id);
      set({ currentSession: started });
      await get().fetchQuestion();
    } catch (error) {
      feedback.error((error as Error).message || "创建面试会话失败");
    } finally {
      set({ loading: false });
    }
  },
  fetchQuestion: async () => {
    const { currentSession, difficulty } = get();
    if (!currentSession?.id) return;
    get().cancelStreaming();
    set({
      loading: true,
      currentEvaluation: null,
      followUpQuestion: null,
      streamingFeedback: "",
      streamingSuggestions: "",
      streamingFollowUpText: ""
    });
    try {
      const question = await getInterviewQuestion(currentSession.id, difficulty);
      set((state) => ({
        currentQuestion: question,
        currentSession: state.currentSession
          ? {
            ...state.currentSession,
            currentQuestionCount: (state.currentSession.currentQuestionCount ?? 0) + 1
          }
          : state.currentSession
      }));
    } catch (error) {
      feedback.error((error as Error).message || "获取题目失败");
      set({ currentQuestion: null });
    } finally {
      set({ loading: false });
    }
  },
  submitAnswer: async (answer) => {
    const { currentSession, currentQuestion } = get();
    if (!currentSession?.id || !currentQuestion?.id) return;
    get().cancelStreaming();
    set({
      submitting: true,
      currentEvaluation: null,
      streamingFeedback: "",
      streamingSuggestions: "",
      isStreamingEvaluation: true
    });
    let finished = false;
    try {
      const handlers = {
        onMessage: (payload: InterviewStreamMessagePayload) => {
          if (payload?.type === "feedback") {
            set((state) => ({ streamingFeedback: `${state.streamingFeedback}${payload.delta}` }));
          } else if (payload?.type === "suggestions") {
            set((state) => ({ streamingSuggestions: `${state.streamingSuggestions}${payload.delta}` }));
          }
        },
        onFinish: (payload: unknown) => {
          const evaluation = payload as AnswerEvaluation;
          finished = true;
          set({
            currentEvaluation: evaluation,
            streamingFeedback: evaluation?.feedback || "",
            streamingSuggestions: evaluation?.suggestions || "",
            isStreamingEvaluation: false,
            streamAbort: null
          });
        }
      };
      const { start, cancel } = streamInterviewAnswer(currentSession.id, currentQuestion.id, answer, handlers);
      set({ streamAbort: cancel });
      await start();
      if (!finished) {
        throw new Error("流式评估未返回结果");
      }
      feedback.success("评估已生成");
    } catch (error) {
      if ((error as Error).name === "AbortError") {
        set({
          isStreamingEvaluation: false,
          streamAbort: null
        });
        return;
      }
      try {
        const evaluation = await submitInterviewAnswer(currentSession.id, currentQuestion.id, answer);
        set({
          currentEvaluation: evaluation,
          streamingFeedback: "",
          streamingSuggestions: "",
          isStreamingEvaluation: false,
          streamAbort: null
        });
        feedback.success("评估已生成");
      } catch (fallbackError) {
        feedback.error((fallbackError as Error).message || (error as Error).message || "提交回答失败");
        set({
          currentEvaluation: null,
          streamingFeedback: "",
          streamingSuggestions: "",
          isStreamingEvaluation: false,
          streamAbort: null
        });
      }
    } finally {
      set({ submitting: false });
    }
  },
  generateFollowUp: async (answer) => {
    const { currentSession, currentQuestion } = get();
    if (!currentSession?.id || !currentQuestion?.id) return;
    get().cancelStreaming();
    set({
      loading: true,
      followUpQuestion: null,
      streamingFollowUpText: "",
      isStreamingFollowUp: true
    });
    let finished = false;
    try {
      const handlers = {
        onMessage: (payload: InterviewStreamMessagePayload) => {
          if (payload?.type === "follow_up") {
            set((state) => ({ streamingFollowUpText: `${state.streamingFollowUpText}${payload.delta}` }));
          }
        },
        onFinish: (payload: unknown) => {
          const followUp = payload as Question | null;
          finished = true;
          set({
            followUpQuestion: followUp,
            streamingFollowUpText: followUp?.questionText || "",
            isStreamingFollowUp: false,
            streamAbort: null
          });
        }
      };
      const { start, cancel } = streamFollowUpQuestion(currentSession.id, currentQuestion.id, answer, handlers);
      set({ streamAbort: cancel });
      await start();
      if (!finished) {
        throw new Error("流式追问未返回结果");
      }
      feedback.success("已生成追问");
    } catch (error) {
      if ((error as Error).name === "AbortError") {
        set({
          isStreamingFollowUp: false,
          streamAbort: null
        });
        return;
      }
      try {
        const followUp = await askFollowUpQuestion(currentSession.id, currentQuestion.id, answer);
        set({
          followUpQuestion: followUp,
          streamingFollowUpText: "",
          isStreamingFollowUp: false,
          streamAbort: null
        });
        feedback.success("已生成追问");
      } catch {
        set({
          followUpQuestion: null,
          streamingFollowUpText: "",
          isStreamingFollowUp: false,
          streamAbort: null
        });
        feedback.info((error as Error).message || "当前后端分支暂不支持追问接口");
      }
    } finally {
      set({ loading: false });
    }
  },
  completeSession: async () => {
    const { currentSession, history, sessionDetail } = get();
    if (!currentSession?.id) return;
    get().cancelStreaming();
    set({
      loading: true,
      isStreamingReport: true,
      streamingReport: ""
    });
    let finished = false;
    try {
      const handlers = {
        onMessage: (payload: InterviewStreamMessagePayload) => {
          if (payload?.type === "report") {
            set((state) => ({ streamingReport: `${state.streamingReport}${payload.delta}` }));
          }
        },
        onFinish: (payload: unknown) => {
          const completed = payload as InterviewSession;
          const completedSession: InterviewSession = {
            ...currentSession,
            ...completed,
            status: "completed",
            endTime: completed.endTime ?? new Date().toISOString()
          };
          finished = true;
          set({
            currentSession: completedSession,
            currentQuestion: null,
            currentEvaluation: null,
            followUpQuestion: null,
            streamingFeedback: "",
            streamingSuggestions: "",
            streamingFollowUpText: "",
            streamingReport: completedSession.evaluationReport || "",
            isStreamingReport: false,
            streamAbort: null,
            history: history.map((item) => (item.id === completedSession.id ? { ...item, ...completedSession } : item)),
            sessionDetail: sessionDetail?.session?.id === completedSession.id
              ? { ...sessionDetail, session: { ...sessionDetail.session, ...completedSession } }
              : sessionDetail
          });
        }
      };
      const { start, cancel } = streamCompleteInterviewSession(currentSession.id, handlers);
      set({ streamAbort: cancel });
      await start();
      if (!finished) {
        throw new Error("流式报告未返回结果");
      }
      if (currentSession.userId) {
        await Promise.allSettled([
          get().fetchHistory(currentSession.userId),
          get().fetchProfileData()
        ]);
      }
      feedback.success("面试已结束");
    } catch (error) {
      if ((error as Error).name === "AbortError") {
        set({
          isStreamingReport: false,
          streamAbort: null
        });
        return;
      }
      const latestState = get();
      try {
        const completed = await completeInterviewSession(currentSession.id);
        const completedSession: InterviewSession = {
          ...currentSession,
          ...completed,
          status: "completed",
          endTime: completed.endTime ?? new Date().toISOString()
        };
        set({
          currentSession: completedSession,
          currentQuestion: null,
          currentEvaluation: null,
          followUpQuestion: null,
          streamingFeedback: "",
          streamingSuggestions: "",
          streamingFollowUpText: "",
          streamingReport: "",
          isStreamingReport: false,
          streamAbort: null,
          history: latestState.history.map((item) => (item.id === completedSession.id ? { ...item, ...completedSession } : item)),
          sessionDetail: latestState.sessionDetail?.session?.id === completedSession.id
            ? { ...latestState.sessionDetail, session: { ...latestState.sessionDetail.session, ...completedSession } }
            : latestState.sessionDetail
        });
        if (currentSession.userId) {
          await Promise.allSettled([
            get().fetchHistory(currentSession.userId),
            get().fetchProfileData()
          ]);
        }
        feedback.success("面试已结束");
      } catch (fallbackError) {
        feedback.error((fallbackError as Error).message || (error as Error).message || "结束面试失败");
        set({
          isStreamingReport: false,
          streamingReport: "",
          streamAbort: null
        });
      }
    } finally {
      set({ loading: false });
    }
  },
  fetchHistory: async (userId) => {
    set({ loading: true });
    try {
      const history = await listInterviewHistory(userId);
      set({ history });
    } catch (error) {
      feedback.error((error as Error).message || "加载面试历史失败");
    } finally {
      set({ loading: false });
    }
  },
  fetchSessionDetail: async (sessionId) => {
    set({ loading: true, sessionDetail: null });
    try {
      const detail = await getInterviewSessionDetail(sessionId);
      set({ sessionDetail: detail });
    } catch (error) {
      feedback.error((error as Error).message || "加载会话详情失败");
    } finally {
      set({ loading: false });
    }
  },
  fetchProfileData: async () => {
    try {
      const [profile, curve, recommendation] = await Promise.all([
        getUserProfile(),
        getGrowthCurve(10),
        getUserRecommendation()
      ]);
      set({
        profile,
        growthCurve: curve,
        recommendation
      });
    } catch {
      set({
        profile: null,
        growthCurve: [],
        recommendation: null
      });
    }
  },
  setDifficulty: (difficulty) => {
    set({ difficulty });
  },
  cancelStreaming: () => {
    const abort = get().streamAbort;
    abort?.();
    set({
      isStreamingEvaluation: false,
      isStreamingFollowUp: false,
      isStreamingReport: false,
      streamAbort: null
    });
  },
  resetCurrentFlow: () => {
    get().cancelStreaming();
    set({
      currentSession: null,
      currentQuestion: null,
      currentEvaluation: null,
      followUpQuestion: null,
      sessionDetail: null,
      streamingFeedback: "",
      streamingSuggestions: "",
      streamingFollowUpText: "",
      streamingReport: ""
    });
  }
}));
