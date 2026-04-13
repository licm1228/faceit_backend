import { Link } from "react-router-dom";

export function GuestPrompt() {
  return (
    <div className="mx-auto mt-6 max-w-[860px] rounded-2xl border border-[#DBEAFE] bg-white/90 p-4 text-center shadow-sm">
      <p className="text-sm text-[#4B5563]">
        You are in guest mode. 可以浏览聊天界面，但发送消息、会话记录和具体功能需要先登录。
      </p>
      <div className="mt-3 flex flex-wrap items-center justify-center gap-3">
        <Link
          to="/login"
          className="rounded-full bg-[#2563EB] px-4 py-2 text-sm font-medium text-white transition hover:bg-[#1D4ED8]"
        >
          Login
        </Link>
        <Link
          to="/login?mode=register"
          className="rounded-full border border-[#BFDBFE] bg-[#EFF6FF] px-4 py-2 text-sm font-medium text-[#2563EB] transition hover:bg-[#DBEAFE]"
        >
          Register
        </Link>
      </div>
    </div>
  );
}
