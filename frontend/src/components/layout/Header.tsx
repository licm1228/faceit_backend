import * as React from "react";
import { Menu } from "lucide-react";
import { useLocation } from "react-router-dom";

import { UserMenu } from "@/components/layout/UserMenu";
import { Button } from "@/components/ui/button";
import { useChatStore } from "@/stores/chatStore";

interface HeaderProps {
  onToggleSidebar: () => void;
}

export function Header({ onToggleSidebar }: HeaderProps) {
  const location = useLocation();
  const { currentSessionId, sessions } = useChatStore();
  const currentSession = React.useMemo(
    () => sessions.find((session) => session.id === currentSessionId),
    [sessions, currentSessionId]
  );

  const pageTitle = React.useMemo(() => {
    if (location.pathname.startsWith("/interview-report")) {
      return "面试评估报告";
    }
    if (location.pathname.startsWith("/chat")) {
      return currentSession?.title || "聊天面试";
    }
    return currentSession?.title || "新对话";
  }, [currentSession?.title, location.pathname]);

  return (
    <header className="sticky top-0 z-20 bg-white">
      <div className="flex h-16 items-center justify-between px-6">
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="icon"
            onClick={onToggleSidebar}
            aria-label="切换侧边栏"
            className="text-gray-500 hover:bg-gray-100 lg:hidden"
          >
            <Menu className="h-5 w-5" />
          </Button>
          <p className="text-base font-medium text-gray-900">{pageTitle}</p>
        </div>
        <div className="flex items-center gap-2">
          <UserMenu
            align="end"
            side="bottom"
            sideOffset={10}
            className="flex items-center gap-2 rounded-xl border border-gray-200 bg-white px-2.5 py-1.5 text-left transition hover:bg-gray-50 data-[state=open]:bg-gray-50"
          />
        </div>
      </div>
    </header>
  );
}
