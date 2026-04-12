import * as React from "react";
import { BookOpen, LogOut, PlayCircle, Settings } from "lucide-react";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger
} from "@/components/ui/dropdown-menu";
import { useAuthStore } from "@/stores/authStore";

interface UserMenuProps {
  align?: "start" | "center" | "end";
  side?: "top" | "right" | "bottom" | "left";
  sideOffset?: number;
  className?: string;
}

export function UserMenu({ align = "end", side = "bottom", sideOffset = 8, className }: UserMenuProps) {
  const { user, logout } = useAuthStore();
  const [avatarFailed, setAvatarFailed] = React.useState(false);

  React.useEffect(() => {
    setAvatarFailed(false);
  }, [user?.avatar, user?.userId]);

  const avatarUrl = user?.avatar?.trim();
  const showAvatar = Boolean(avatarUrl) && !avatarFailed;
  const avatarFallback = (user?.username || user?.userId || "用户").slice(0, 1).toUpperCase();
  const displayName = (() => {
    const fallback = user?.username || user?.userId || "用户";
    return /^\d+$/.test(fallback) ? "用户" : fallback;
  })();

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          type="button"
          className={
            className ??
            "flex items-center gap-2 rounded-lg p-2 text-left transition-colors hover:bg-[#F5F5F5] data-[state=open]:bg-[#EEEEEE]"
          }
          aria-label="用户菜单"
        >
          <div className="flex h-8 w-8 items-center justify-center overflow-hidden rounded-full bg-[#3B82F6] text-white">
            {showAvatar ? (
              <img
                src={avatarUrl}
                alt={displayName}
                className="h-full w-full object-cover"
                onError={() => setAvatarFailed(true)}
              />
            ) : (
              <span className="text-sm font-medium">{avatarFallback}</span>
            )}
          </div>
          <span className="flex-1 truncate text-sm font-medium text-[#1A1A1A]">{displayName}</span>
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align={align} side={side} sideOffset={sideOffset} className="w-48">
        {user?.role === "admin" ? (
          <DropdownMenuItem asChild>
            <a href="/admin" target="_blank" rel="noreferrer" className="flex items-center">
              <Settings className="mr-2 h-4 w-4" />
              管理后台
            </a>
          </DropdownMenuItem>
        ) : null}
        <DropdownMenuItem asChild>
          <a
            href="https://nageoffer.com/ragent"
            target="_blank"
            rel="noreferrer"
            className="flex items-center"
          >
            <BookOpen className="mr-2 h-4 w-4" />
            使用文档
          </a>
        </DropdownMenuItem>
        <DropdownMenuItem asChild>
          <a
            href="https://space.bilibili.com/352177376"
            target="_blank"
            rel="noreferrer"
            className="flex items-center"
          >
            <PlayCircle className="mr-2 h-4 w-4" />
            视频教程
          </a>
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => logout()} className="text-rose-600 focus:text-rose-600">
          <LogOut className="mr-2 h-4 w-4" />
          退出登录
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
