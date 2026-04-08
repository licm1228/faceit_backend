import { useState } from "react";
import { Search } from "lucide-react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from "@/components/ui/table";
import type { InterviewSession, SessionDetail } from "@/services/interviewService";
import { getInterviewSessionDetail, listInterviewSessionsByUser } from "@/services/interviewService";
import { getErrorMessage } from "@/utils/error";

export function InterviewSessionsPage() {
  const [userId, setUserId] = useState("");
  const [loading, setLoading] = useState(false);
  const [sessions, setSessions] = useState<InterviewSession[]>([]);
  const [detail, setDetail] = useState<SessionDetail | null>(null);

  const searchSessions = async () => {
    if (!userId.trim()) {
      toast.error("请输入用户ID");
      return;
    }
    setLoading(true);
    setDetail(null);
    try {
      const data = await listInterviewSessionsByUser(userId.trim());
      setSessions(data);
      if (data.length === 0) {
        toast.info("该用户暂无面试会话");
      }
    } catch (error) {
      toast.error(getErrorMessage(error, "查询会话失败"));
    } finally {
      setLoading(false);
    }
  };

  const loadDetail = async (sessionId: string) => {
    setLoading(true);
    try {
      const data = await getInterviewSessionDetail(sessionId);
      setDetail(data);
    } catch (error) {
      toast.error(getErrorMessage(error, "加载会话详情失败"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-page-header">
        <div>
          <h1 className="admin-page-title">面试会话查询</h1>
          <p className="admin-page-subtitle">按用户ID查询面试历史与答题详情</p>
        </div>
        <div className="admin-page-actions">
          <Input
            value={userId}
            onChange={(event) => setUserId(event.target.value)}
            placeholder="输入用户ID"
            className="w-[260px]"
          />
          <Button onClick={() => searchSessions().catch(() => null)}>
            <Search className="mr-2 h-4 w-4" />
            查询
          </Button>
        </div>
      </div>

      <Card>
        <CardContent className="pt-6">
          {loading ? (
            <div className="py-8 text-center text-muted-foreground">加载中...</div>
          ) : sessions.length === 0 ? (
            <div className="py-8 text-center text-muted-foreground">请输入用户ID后查询</div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>会话ID</TableHead>
                  <TableHead>状态</TableHead>
                  <TableHead>总分</TableHead>
                  <TableHead>创建时间</TableHead>
                  <TableHead className="w-[120px]">操作</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {sessions.map((item) => (
                  <TableRow key={item.id}>
                    <TableCell className="font-medium">{item.id}</TableCell>
                    <TableCell>{item.status || "-"}</TableCell>
                    <TableCell>{item.totalScore ?? "-"}</TableCell>
                    <TableCell>{item.createTime || "-"}</TableCell>
                    <TableCell>
                      <Button variant="outline" size="sm" onClick={() => loadDetail(item.id).catch(() => null)}>
                        详情
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {detail ? (
        <Card className="mt-4">
          <CardContent className="pt-6">
            <h2 className="text-base font-semibold text-slate-800">会话详情</h2>
            <p className="mt-2 text-sm text-slate-500">
              会话ID：{detail.session.id} · 状态：{detail.session.status} · 总分：
              {detail.session.totalScore ?? "-"}
            </p>
            <div className="mt-4 space-y-3">
              {detail.answers.map((answer, index) => (
                <div key={answer.id} className="rounded-lg border border-slate-200 bg-slate-50 p-3">
                  <p className="text-sm font-medium text-slate-800">第 {index + 1} 题（{answer.questionId}）</p>
                  <p className="mt-1 text-sm text-slate-600">回答：{answer.userAnswer}</p>
                  <p className="mt-1 text-sm text-slate-600">得分：{answer.score ?? "-"}</p>
                  <p className="mt-1 text-sm text-slate-600">反馈：{answer.feedback || "-"}</p>
                  <p className="mt-1 text-sm text-slate-600">建议：{answer.suggestions || "-"}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
}
