import * as React from "react";
import { Lock, Menu, MessageSquare, Plus } from "lucide-react";
import { Link, useNavigate, useParams } from "react-router-dom";

import { FaceItMark } from "@/components/common/FaceItMark";
import { GuestPrompt } from "@/components/chat/GuestPrompt";
import { ChatInput } from "@/components/chat/ChatInput";
import { MessageList } from "@/components/chat/MessageList";
import { WelcomeScreen } from "@/components/chat/WelcomeScreen";
import { MainLayout } from "@/components/layout/MainLayout";
import { useAuthStore } from "@/stores/authStore";
import { useChatStore } from "@/stores/chatStore";

function GuestChatShell() {
  const [sidebarOpen, setSidebarOpen] = React.useState(false);

  return (
    <div className="flex min-h-screen bg-[#FAFAFA]">
      <div
        className={`fixed inset-0 z-30 bg-slate-900/30 backdrop-blur-sm transition-opacity lg:hidden ${sidebarOpen ? "opacity-100" : "pointer-events-none opacity-0"}`}
        onClick={() => setSidebarOpen(false)}
      />
      <aside
        className={`fixed left-0 top-0 z-40 flex h-screen w-[280px] flex-shrink-0 flex-col bg-[#FAFAFA] p-3 transition-transform lg:static lg:h-screen lg:translate-x-0 ${sidebarOpen ? "translate-x-0" : "-translate-x-full"}`}
      >
        <div className="border-b border-[#F0F0F0] pb-3">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg border border-[#BFDBFE] bg-white shadow-[0_6px_16px_rgba(37,99,235,0.08)]">
              <FaceItMark className="h-5 w-5" />
            </div>
            <div className="font-poppins">
              <p className="text-base font-semibold text-[#1A1A1A]">Face It 面试官</p>
              <p className="text-xs text-[#999999]">Guest Preview</p>
            </div>
          </div>
        </div>
        <div className="py-3 space-y-4">
          <div className="relative overflow-hidden rounded-2xl border border-[#E6EEF6] bg-gradient-to-br from-[#EFF6FF] via-white to-[#DBEAFE] p-4 shadow-[0_14px_30px_rgba(15,23,42,0.08)]">
            <span
              aria-hidden="true"
              className="absolute -right-10 -top-10 h-24 w-24 rounded-full bg-[#BAE6FD]/70 blur-2xl"
            />
            <span
              aria-hidden="true"
              className="absolute -left-12 -bottom-10 h-28 w-28 rounded-full bg-[#DBEAFE]/75 blur-2xl"
            />
            <div className="relative">
              <div className="flex items-center gap-2 text-[#2563EB]">
                <span className="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#2563EB] text-white shadow-[0_6px_14px_rgba(37,99,235,0.3)]">
                  <Lock className="h-4 w-4" />
                </span>
                <div>
                  <p className="text-sm font-semibold text-[#1F2937]">面试练习，从这里开始</p>
                  <p className="text-xs text-[#64748B]">登录后即可保存进度，获得更完整的对话与练习体验。</p>
                </div>
              </div>
              <div className="mt-4 space-y-2">
                <Link
                  to="/login"
                  className="flex w-full items-center gap-3 rounded-2xl bg-white/90 px-4 py-3 text-left shadow-[0_10px_20px_rgba(15,23,42,0.08)]"
                >
                  <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-gradient-to-br from-[#60A5FA] to-[#2563EB] text-white shadow-[0_6px_14px_rgba(37,99,235,0.3)]">
                    <Plus className="h-4 w-4" />
                  </span>
                  <span className="font-poppins flex-1">
                    <span className="block text-sm font-semibold text-[#1F2937]">登录后开始体验</span>
                    <span className="block text-xs text-[#94A3B8]">解锁发送消息、历史会话与完整能力</span>
                  </span>
                </Link>
                <Link
                  to="/login?mode=register"
                  className="flex w-full items-center gap-3 rounded-2xl border border-[#DBEAFE] bg-[#EFF6FF] px-4 py-3 text-left transition-colors hover:bg-[#DBEAFE]"
                >
                  <span className="flex h-11 w-11 items-center justify-center rounded-2xl bg-[#2563EB] text-white shadow-[0_6px_14px_rgba(37,99,235,0.3)]">
                    <MessageSquare className="h-4 w-4" />
                  </span>
                  <span className="font-poppins flex-1">
                    <span className="block text-sm font-semibold text-[#1F2937]">注册账号</span>
                    <span className="block text-xs text-[#64748B]">创建账号后继续使用 Face It</span>
                  </span>
                </Link>
              </div>
            </div>
          </div>
          <div className="flex flex-1 items-center justify-center rounded-3xl border border-dashed border-[#DBEAFE] bg-white/70 px-6 py-10 text-center text-[#6B7280]">
            用更轻松的方式开始模拟面试、整理回答思路，并获得更清晰的反馈，助力你拿下大厂 Offer。
          </div>
        </div>
      </aside>
      <div className="flex min-h-screen flex-1 flex-col bg-white">
        <header className="sticky top-0 z-20 bg-white">
          <div className="flex h-16 items-center justify-between px-6">
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setSidebarOpen((prev) => !prev)}
                aria-label="切换侧边栏"
                className="inline-flex h-10 w-10 items-center justify-center rounded-lg text-gray-500 transition hover:bg-gray-100 lg:hidden"
              >
                <Menu className="h-5 w-5" />
              </button>
              <p className="text-base font-medium text-gray-900">Face It Chat</p>
            </div>
            <div className="flex items-center gap-2">
              <Link
                to="/login"
                className="rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm font-medium text-gray-700 transition hover:bg-gray-50"
              >
                登录
              </Link>
              <Link
                to="/login?mode=register"
                className="rounded-xl bg-gray-900 px-3 py-2 text-sm font-medium text-white transition hover:bg-black"
              >
                注册
              </Link>
            </div>
          </div>
        </header>
        <main className="flex-1 min-h-0 overflow-y-auto bg-white">
          <MessageList messages={[]} isLoading={false} isStreaming={false} sessionKey="guest" welcomeDisabled />
          <div className="px-6 pb-8">
            <GuestPrompt />
          </div>
        </main>
      </div>
    </div>
  );
}

export function ChatPage() {
  const navigate = useNavigate();
  const { sessionId } = useParams<{ sessionId: string }>();
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  const {
    messages,
    isLoading,
    isStreaming,
    currentSessionId,
    currentSessionType,
    currentInterviewState,
    sessions,
    isCreatingNew,
    fetchSessions,
    selectSession
  } = useChatStore();
  const [sessionsReady, setSessionsReady] = React.useState(false);
  const sessionExists = React.useMemo(() => {
    if (!sessionId) return false;
    return sessions.some((session) => session.id === sessionId);
  }, [sessionId, sessions]);
  const hasMessages = messages.length > 0;
  const isSelectingSession = Boolean(currentSessionId) && isLoading && !hasMessages;
  const showWelcome = !sessionId && !currentSessionId && !hasMessages;
  const showInput = !isSelectingSession && !(currentSessionType === "interview" && currentInterviewState?.status === "completed");

  React.useEffect(() => {
    if (!isAuthenticated) {
      setSessionsReady(true);
      return;
    }
    let active = true;
    fetchSessions()
      .catch(() => null)
      .finally(() => {
        if (active) {
          setSessionsReady(true);
        }
      });
    return () => {
      active = false;
    };
  }, [fetchSessions, isAuthenticated]);

  React.useEffect(() => {
    if (!isAuthenticated) {
      return;
    }
    if (sessionId) {
      if (sessionsReady && !sessionExists) {
        navigate("/chat", { replace: true });
        return;
      }
      selectSession(sessionId).catch(() => null);
      return;
    }
    if (!sessionsReady || isCreatingNew || currentSessionId) {
      return;
    }
    if (sessions.length > 0) {
      const latestSession = sessions[0];
      selectSession(latestSession.id).catch(() => null);
      return;
    }
  }, [
    currentSessionId,
    isAuthenticated,
    isCreatingNew,
    navigate,
    selectSession,
    sessionExists,
    sessionId,
    sessions,
    sessionsReady
  ]);

  React.useEffect(() => {
    if (!isAuthenticated) {
      return;
    }
    if (currentSessionId && currentSessionId !== sessionId) {
      navigate(`/chat/${currentSessionId}`, { replace: true });
    }
  }, [currentSessionId, isAuthenticated, navigate, sessionId]);

  if (!isAuthenticated) {
    return <GuestChatShell />;
  }

  return (
    <MainLayout>
      <div className="flex h-full flex-col bg-white">
        <div className="flex-1 min-h-0">
          {showWelcome ? (
            <div className="h-full overflow-y-auto">
              <WelcomeScreen />
            </div>
          ) : (
            <MessageList
              messages={messages}
              isLoading={isSelectingSession}
              isStreaming={isStreaming}
              sessionKey={currentSessionId}
            />
          )}
        </div>
        {showInput ? (
          <div className="relative z-20 bg-white">
            <div className="mx-auto max-w-[800px] px-6 pt-1 pb-4">
              <ChatInput />
            </div>
          </div>
        ) : null}
      </div>
    </MainLayout>
  );
}
