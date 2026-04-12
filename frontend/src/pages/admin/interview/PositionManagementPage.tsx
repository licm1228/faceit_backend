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
import type { Position } from "@/services/interviewService";
import { createPosition, deletePosition, listPositions, updatePosition } from "@/services/interviewService";
import { getErrorMessage } from "@/utils/error";

const emptyForm = {
  name: "",
  description: "",
  requiredSkills: "",
  interviewFocus: ""
};

export function PositionManagementPage() {
  const [loading, setLoading] = useState(true);
  const [positions, setPositions] = useState<Position[]>([]);
  const [keyword, setKeyword] = useState("");
  const [searchKeyword, setSearchKeyword] = useState("");
  const [deleteTarget, setDeleteTarget] = useState<Position | null>(null);
  const [dialogState, setDialogState] = useState<{
    open: boolean;
    mode: "create" | "edit";
    item: Position | null;
  }>({ open: false, mode: "create", item: null });
  const [form, setForm] = useState(emptyForm);

  const loadPositions = async () => {
    try {
      setLoading(true);
      const data = await listPositions();
      setPositions(data);
    } catch (error) {
      toast.error(getErrorMessage(error, "加载岗位失败"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPositions().catch(() => null);
  }, []);

  useEffect(() => {
    if (!dialogState.open) {
      setForm(emptyForm);
      return;
    }
    if (dialogState.mode === "edit" && dialogState.item) {
      setForm({
        name: dialogState.item.name || "",
        description: dialogState.item.description || "",
        requiredSkills: dialogState.item.requiredSkills || "",
        interviewFocus: dialogState.item.interviewFocus || ""
      });
      return;
    }
    setForm(emptyForm);
  }, [dialogState]);

  const filtered = useMemo(() => {
    const value = keyword.trim().toLowerCase();
    if (!value) return positions;
    return positions.filter((item) =>
      `${item.name || ""} ${item.description || ""}`.toLowerCase().includes(value)
    );
  }, [keyword, positions]);

  const openCreate = () => setDialogState({ open: true, mode: "create", item: null });
  const openEdit = (item: Position) => setDialogState({ open: true, mode: "edit", item });

  const handleSubmit = async () => {
    if (!form.name.trim()) {
      toast.error("岗位名称不能为空");
      return;
    }
    const payload = {
      name: form.name.trim(),
      description: form.description.trim() || undefined,
      requiredSkills: form.requiredSkills.trim() || undefined,
      interviewFocus: form.interviewFocus.trim() || undefined
    };
    try {
      if (dialogState.mode === "create") {
        await createPosition(payload);
        toast.success("岗位创建成功");
      } else if (dialogState.item?.id) {
        await updatePosition({ id: dialogState.item.id, ...payload });
        toast.success("岗位更新成功");
      }
      setDialogState({ open: false, mode: "create", item: null });
      await loadPositions();
    } catch (error) {
      toast.error(getErrorMessage(error, "保存岗位失败"));
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget?.id) return;
    try {
      await deletePosition(deleteTarget.id);
      toast.success("岗位删除成功");
      setDeleteTarget(null);
      await loadPositions();
    } catch (error) {
      toast.error(getErrorMessage(error, "删除岗位失败"));
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-page-header">
        <div>
          <h1 className="admin-page-title">岗位管理</h1>
          <p className="admin-page-subtitle">维护面试岗位及其说明信息</p>
        </div>
        <div className="admin-page-actions">
          <Input
            value={searchKeyword}
            onChange={(event) => setSearchKeyword(event.target.value)}
            placeholder="搜索岗位名称/描述"
            className="w-[220px]"
          />
          <Button variant="outline" onClick={() => setKeyword(searchKeyword)}>
            搜索
          </Button>
          <Button variant="outline" onClick={() => loadPositions().catch(() => null)}>
            <RefreshCw className="mr-2 h-4 w-4" />
            刷新
          </Button>
          <Button className="admin-primary-gradient" onClick={openCreate}>
            <Plus className="mr-2 h-4 w-4" />
            新增岗位
          </Button>
        </div>
      </div>

      <Card>
        <CardContent className="pt-6">
          {loading ? (
            <div className="py-8 text-center text-muted-foreground">加载中...</div>
          ) : filtered.length === 0 ? (
            <div className="py-8 text-center text-muted-foreground">暂无岗位数据</div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[240px]">岗位名称</TableHead>
                  <TableHead>岗位描述</TableHead>
                  <TableHead className="w-[220px]">面试重点</TableHead>
                  <TableHead className="w-[170px] text-left">操作</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.map((item) => (
                  <TableRow key={item.id}>
                    <TableCell className="font-medium">{item.name}</TableCell>
                    <TableCell className="max-w-[420px] truncate" title={item.description || ""}>
                      {item.description || "-"}
                    </TableCell>
                    <TableCell className="max-w-[220px] truncate" title={item.interviewFocus || ""}>
                      {item.interviewFocus || "-"}
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
        <DialogContent className="sm:max-w-[560px]">
          <DialogHeader>
            <DialogTitle>{dialogState.mode === "create" ? "新增岗位" : "编辑岗位"}</DialogTitle>
            <DialogDescription>用于面试流程中的岗位选择</DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">岗位名称</label>
              <Input
                value={form.name}
                onChange={(event) => setForm((prev) => ({ ...prev, name: event.target.value }))}
                placeholder="例如：Java开发工程师"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">岗位描述</label>
              <Textarea
                value={form.description}
                onChange={(event) => setForm((prev) => ({ ...prev, description: event.target.value }))}
                rows={3}
                placeholder="岗位职责和要求"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">必备技能</label>
              <Input
                value={form.requiredSkills}
                onChange={(event) => setForm((prev) => ({ ...prev, requiredSkills: event.target.value }))}
                placeholder="例如：Java, Spring, MySQL"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">面试重点</label>
              <Input
                value={form.interviewFocus}
                onChange={(event) => setForm((prev) => ({ ...prev, interviewFocus: event.target.value }))}
                placeholder="例如：基础扎实、项目表达能力"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogState({ open: false, mode: "create", item: null })}>
              取消
            </Button>
            <Button onClick={() => handleSubmit().catch(() => null)}>保存</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <AlertDialog open={Boolean(deleteTarget)} onOpenChange={(open) => !open && setDeleteTarget(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>确认删除岗位</AlertDialogTitle>
            <AlertDialogDescription>
              [{deleteTarget?.name || "该岗位"}] 删除后将不再可选，是否继续？
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
