import { create } from "zustand";
import { toast } from "sonner";

import type { AnswerEvaluation, InterviewSession, Position, Question, SessionDetail } from "@/services/interviewService";
import {
  completeInterviewSession,
  createInterviewSession,
  getInterviewQuestion,
  getInterviewSessionDetail,
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
  sessionDetail: SessionDetail | null;
  difficulty: number;
  loading: boolean;
  submitting: boolean;
  fetchPositions: () => Promise<void>;
  createAndStartSession: (userId: string, positionId: string) => Promise<void>;
  fetchQuestion: () => Promise<void>;
  submitAnswer: (answer: string) => Promise<void>;
  completeSession: () => Promise<void>;
  fetchHistory: (userId: string) => Promise<void>;
  fetchSessionDetail: (sessionId: string) => Promise<void>;
  setDifficulty: (difficulty: number) => void;
  resetCurrentFlow: () => void;
}

export const useInterviewStore = create<InterviewState>((set, get) => ({
  positions: [],
  history: [],
  currentSession: null,
  currentQuestion: null,
  currentEvaluation: null,
  sessionDetail: null,
  difficulty: 3,
  loading: false,
  submitting: false,
  fetchPositions: async () => {
    set({ loading: true });
    try {
      const positions = await listPositions();
      set({ positions });
    } catch (error) {
      toast.error((error as Error).message || "加载岗位失败");
    } finally {
      set({ loading: false });
    }
  },
  createAndStartSession: async (userId, positionId) => {
    set({ loading: true, currentEvaluation: null, currentQuestion: null });
    try {
      const session = await createInterviewSession(userId, positionId);
      const started = await startInterviewSession(session.id);
      set({ currentSession: started });
      await get().fetchQuestion();
    } catch (error) {
      toast.error((error as Error).message || "创建面试会话失败");
    } finally {
      set({ loading: false });
    }
  },
  fetchQuestion: async () => {
    const { currentSession, difficulty } = get();
    if (!currentSession?.id) return;
    set({ loading: true, currentEvaluation: null });
    try {
      const question = await getInterviewQuestion(currentSession.id, difficulty);
      set({ currentQuestion: question });
    } catch (error) {
      toast.error((error as Error).message || "获取题目失败");
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
      toast.success("评估已生成");
    } catch (error) {
      toast.error((error as Error).message || "提交回答失败");
    } finally {
      set({ submitting: false });
    }
  },
  completeSession: async () => {
    const { currentSession } = get();
    if (!currentSession?.id) return;
    set({ loading: true });
    try {
      const completed = await completeInterviewSession(currentSession.id);
      set({ currentSession: completed });
      toast.success("面试已结束");
    } catch (error) {
      toast.error((error as Error).message || "结束面试失败");
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
      toast.error((error as Error).message || "加载面试历史失败");
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
      toast.error((error as Error).message || "加载会话详情失败");
    } finally {
      set({ loading: false });
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
      sessionDetail: null
    });
  }
}));
