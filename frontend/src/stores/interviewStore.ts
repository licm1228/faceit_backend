import { create } from "zustand";
import { feedback } from "@/stores/useFeedbackStore";

import type {
  AnswerEvaluation,
  GrowthCurvePoint,
  InterviewSession,
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
    set({ loading: true, currentEvaluation: null, currentQuestion: null, followUpQuestion: null });
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
    set({ loading: true, currentEvaluation: null, followUpQuestion: null });
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
    set({ submitting: true });
    try {
      const evaluation = await submitInterviewAnswer(currentSession.id, currentQuestion.id, answer);
      set({ currentEvaluation: evaluation });
      feedback.success("评估已生成");
    } catch (error) {
      feedback.error((error as Error).message || "提交回答失败");
    } finally {
      set({ submitting: false });
    }
  },
  generateFollowUp: async (answer) => {
    const { currentSession, currentQuestion } = get();
    if (!currentSession?.id || !currentQuestion?.id) return;
    try {
      const followUp = await askFollowUpQuestion(currentSession.id, currentQuestion.id, answer);
      set({ followUpQuestion: followUp });
      feedback.success("已生成追问");
    } catch {
      set({ followUpQuestion: null });
      feedback.info("当前后端分支暂不支持追问接口");
    }
  },
  completeSession: async () => {
    const { currentSession, history, sessionDetail } = get();
    if (!currentSession?.id) return;
    set({ loading: true });
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
        history: history.map((item) => (item.id === completedSession.id ? { ...item, ...completedSession } : item)),
        sessionDetail: sessionDetail?.session?.id === completedSession.id
          ? { ...sessionDetail, session: { ...sessionDetail.session, ...completedSession } }
          : sessionDetail
      });
      if (currentSession.userId) {
        await Promise.allSettled([
          get().fetchHistory(currentSession.userId),
          get().fetchProfileData()
        ]);
      }
      feedback.success("面试已结束");
    } catch (error) {
      feedback.error((error as Error).message || "结束面试失败");
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
  resetCurrentFlow: () => {
    set({
      currentSession: null,
      currentQuestion: null,
      currentEvaluation: null,
      followUpQuestion: null,
      sessionDetail: null
    });
  }
}));
