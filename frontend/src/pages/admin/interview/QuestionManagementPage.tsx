import { useEffect, useMemo, useState } from "react";
import { Pencil, Plus, RefreshCw, Trash2 } from "lucide-react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from "@/components/ui/table";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle
} from "@/components/ui/alert-dialog";
import type { Position, Question } from "@/services/interviewService";
import {
  createQuestion,
  deleteQuestion,
  listPositions,
  listQuestions,
  listQuestionsByPosition,
  updateQuestion
} from "@/services/interviewService";
import { getErrorMessage } from "@/utils/error";

type QuestionForm = {
  positionId: string;
  questionType: string;
  difficulty: string;
  questionText: string;
  referenceAnswer: string;
  keywords: string;
};

const emptyForm: QuestionForm = {
  positionId: "",
  questionType: "技术题",
  difficulty: "3",
  questionText: "",
  referenceAnswer: "",
  keywords: ""
};

const QUESTION_TYPES = ["技术题", "项目题", "行为题", "场景题", "算法题"];

export function QuestionManagementPage() {
  const [loading, setLoading] = useState(true);
  const [positions, setPositions] = useState<Position[]>([]);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [searchKeyword, setSearchKeyword] = useState("");
  const [keyword, setKeyword] = useState("");
  const [positionFilter, setPositionFilter] = useState("all");
  const [deleteTarget, setDeleteTarget] = useState<Question | null>(null);
  const [dialogState, setDialogState] = useState<{
    open: boolean;
    mode: "create" | "edit";
    item: Question | null;
  }>({ open: false, mode: "create", item: null });
  const [form, setForm] = useState<QuestionForm>(emptyForm);

  const loadPositions = async () => {
    const data = await listPositions();
    setPositions(data);
    if (data.length > 0 && !form.positionId) {
      setForm((prev) => ({ ...prev, positionId: data[0].id }));
    }
  };

  const loadQuestions = async (positionId: string) => {
    setLoading(true);
    try {
      const data = positionId === "all" ? await listQuestions() : await listQuestionsByPosition(positionId);
      setQuestions(data);
    } catch (error) {
      toast.error(getErrorMessage(error, "加载题目失败"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    Promise.all([loadPositions(), loadQuestions("all")]).catch((error) => {
      toast.error(getErrorMessage(error, "初始化题库页面失败"));
      setLoading(false);
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (dialogState.mode !== "edit" || !dialogState.item) {
      return;
    }
    setForm({
      positionId: dialogState.item.positionId || "",
      questionType: dialogState.item.questionType || "技术题",
      difficulty: String(dialogState.item.difficulty || 3),
      questionText: dialogState.item.questionText || "",
      referenceAnswer: dialogState.item.referenceAnswer || "",
      keywords: Array.isArray(dialogState.item.keywords) ? dialogState.item.keywords.join(", ") : ""
    });
  }, [dialogState]);

  const filtered = useMemo(() => {
    const value = keyword.trim().toLowerCase();
    if (!value) return questions;
    return questions.filter((item) =>
      `${item.questionText || ""} ${item.referenceAnswer || ""} ${item.questionType || ""}`
        .toLowerCase()
        .includes(value)
    );
  }, [keyword, questions]);

  const positionNameMap = useMemo(() => {
    const map = new Map<string, string>();
    positions.forEach((position) => map.set(position.id, position.name));
    return map;
  }, [positions]);

  const openCreate = () => {
    setDialogState({ open: true, mode: "create", item: null });
    setForm((prev) => ({
      ...emptyForm,
      positionId: prev.positionId || positions[0]?.id || ""
    }));
  };

  const openEdit = (item: Question) => {
    setDialogState({ open: true, mode: "edit", item });
  };

  const handleSave = async () => {
    if (!form.positionId) {
      toast.error("请选择岗位");
      return;
    }
    if (!form.questionText.trim()) {
      toast.error("题目内容不能为空");
      return;
    }
    const keywords = form.keywords
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean);
    const payload = {
      positionId: form.positionId,
      questionType: form.questionType,
      difficulty: Number(form.difficulty || 3),
      questionText: form.questionText.trim(),
      referenceAnswer: form.referenceAnswer.trim() || undefined,
      keywords: keywords.length > 0 ? keywords : undefined
    };
    try {
      if (dialogState.mode === "create") {
        await createQuestion(payload);
        toast.success("题目创建成功");
      } else if (dialogState.item?.id) {
        await updateQuestion({ id: dialogState.item.id, ...payload });
        toast.success("题目更新成功");
      }
      setDialogState({ open: false, mode: "create", item: null });
      await loadQuestions(positionFilter);
    } catch (error) {
      toast.error(getErrorMessage(error, "保存题目失败"));
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget?.id) return;
    try {
      await deleteQuestion(deleteTarget.id);
      toast.success("题目删除成功");
      setDeleteTarget(null);
      await loadQuestions(positionFilter);
    } catch (error) {
      toast.error(getErrorMessage(error, "删除题目失败"));
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-page-header">
        <div>
          <h1 className="admin-page-title">题库管理</h1>
          <p className="admin-page-subtitle">维护面试题目、难度与参考答案</p>
        </div>
        <div className="admin-page-actions">
          <Select
            value={positionFilter}
            onValueChange={(value) => {
              setPositionFilter(value);
              loadQuestions(value).catch(() => null);
            }}
          >
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="按岗位筛选" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">全部岗位</SelectItem>
              {positions.map((position) => (
                <SelectItem key={position.id} value={position.id}>
                  {position.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <Input
            value={searchKeyword}
            onChange={(event) => setSearchKeyword(event.target.value)}
            placeholder="搜索题目关键字"
            className="w-[220px]"
          />
          <Button variant="outline" onClick={() => setKeyword(searchKeyword)}>
            搜索
          </Button>
          <Button variant="outline" onClick={() => loadQuestions(positionFilter).catch(() => null)}>
            <RefreshCw className="mr-2 h-4 w-4" />
            刷新
          </Button>
          <Button className="admin-primary-gradient" onClick={openCreate}>
            <Plus className="mr-2 h-4 w-4" />
            新增题目
          </Button>
        </div>
      </div>

      <Card>
        <CardContent className="pt-6">
          {loading ? (
            <div className="py-8 text-center text-muted-foreground">加载中...</div>
          ) : filtered.length === 0 ? (
            <div className="py-8 text-center text-muted-foreground">暂无题目数据</div>
          ) : (
            <Table className="min-w-[940px]">
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[170px]">岗位</TableHead>
                  <TableHead className="w-[92px]">类型</TableHead>
                  <TableHead className="w-[74px]">难度</TableHead>
                  <TableHead>题目内容</TableHead>
                  <TableHead className="w-[170px] text-left">操作</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map((item) => (
                  <TableRow key={item.id}>
                    <TableCell>{positionNameMap.get(item.positionId) || item.positionId}</TableCell>
                    <TableCell>{item.questionType || "-"}</TableCell>
                    <TableCell>{item.difficulty ?? "-"}</TableCell>
                    <TableCell className="max-w-[560px] truncate" title={item.questionText}>
                      {item.questionText}
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button variant="outline" size="sm" onClick={() => openEdit(item)}>
                          <Pencil className="mr-0.5 h-4 w-4" />
                          编辑
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          className="text-destructive hover:text-destructive"
                          onClick={() => setDeleteTarget(item)}
                        >
                          <Trash2 className="mr-0.5 h-4 w-4" />
                          删除
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      <Dialog
        open={dialogState.open}
        onOpenChange={(open) => setDialogState((prev) => ({ ...prev, open, item: open ? prev.item : null }))}
      >
        <DialogContent className="sm:max-w-[720px]">
          <DialogHeader>
            <DialogTitle>{dialogState.mode === "create" ? "新增题目" : "编辑题目"}</DialogTitle>
            <DialogDescription>面试题库会被面试流程和随机选题接口使用</DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 md:grid-cols-3">
            <div className="space-y-2">
              <label className="text-sm font-medium">岗位</label>
              <Select value={form.positionId} onValueChange={(value) => setForm((prev) => ({ ...prev, positionId: value }))}>
                <SelectTrigger>
                  <SelectValue placeholder="选择岗位" />
                </SelectTrigger>
                <SelectContent>
                  {positions.map((position) => (
                    <SelectItem key={position.id} value={position.id}>
                      {position.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">类型</label>
              <Select value={form.questionType} onValueChange={(value) => setForm((prev) => ({ ...prev, questionType: value }))}>
                <SelectTrigger>
                  <SelectValue placeholder="选择类型" />
                </SelectTrigger>
                <SelectContent>
                  {QUESTION_TYPES.map((type) => (
                    <SelectItem key={type} value={type}>
                      {type}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">难度</label>
              <Select value={form.difficulty} onValueChange={(value) => setForm((prev) => ({ ...prev, difficulty: value }))}>
                <SelectTrigger>
                  <SelectValue placeholder="选择难度" />
                </SelectTrigger>
                <SelectContent>
                  {[1, 2, 3, 4, 5].map((level) => (
                    <SelectItem key={level} value={String(level)}>
                      {level}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">题目内容</label>
            <Textarea
              value={form.questionText}
              onChange={(event) => setForm((prev) => ({ ...prev, questionText: event.target.value }))}
              rows={4}
              placeholder="请输入题目"
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">参考答案</label>
            <Textarea
              value={form.referenceAnswer}
              onChange={(event) => setForm((prev) => ({ ...prev, referenceAnswer: event.target.value }))}
              rows={5}
              placeholder="请输入参考答案（可选）"
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium">关键词</label>
            <Input
              value={form.keywords}
              onChange={(event) => setForm((prev) => ({ ...prev, keywords: event.target.value }))}
              placeholder="多个关键词用英文逗号分隔"
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogState({ open: false, mode: "create", item: null })}>
              取消
            </Button>
            <Button onClick={() => handleSave().catch(() => null)}>保存</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <AlertDialog open={Boolean(deleteTarget)} onOpenChange={(open) => !open && setDeleteTarget(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>确认删除题目</AlertDialogTitle>
            <AlertDialogDescription>
              删除后该题目将不再出现在随机选题中，是否继续？
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>取消</AlertDialogCancel>
            <AlertDialogAction onClick={() => handleDelete().catch(() => null)}>删除</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
