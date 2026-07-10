import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { getCrmTasks } from "@/lib/supabase/data";

export default async function CrmPage() {
  const tasks = await getCrmTasks();
  return <div className="space-y-6"><div><p className="text-sm font-medium text-muted-foreground">CRM</p><h1 className="text-3xl font-semibold">Follow-up tasks</h1></div><Card><CardHeader><CardTitle>{tasks.length} CRM tasks</CardTitle></CardHeader><CardContent className="space-y-3">{tasks.map((task) => <div key={task.id} className="rounded-md border border-border p-4"><div className="flex items-center justify-between gap-3"><div className="font-medium">{task.channel_type} follow-up</div><Badge tone={task.priority === "high" ? "danger" : "neutral"}>{task.priority}</Badge></div><div className="mt-2 text-sm text-muted-foreground">Due {task.due_date ?? "unscheduled"} · {task.status}</div><p className="mt-2 text-sm text-muted-foreground">{task.notes ?? "No notes"}</p></div>)}</CardContent></Card></div>;
}
