import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { getBranches } from "@/lib/supabase/data";

export default async function BranchesPage() {
  const branches = await getBranches();
  return <div className="space-y-6"><div><p className="text-sm font-medium text-muted-foreground">Branches</p><h1 className="text-3xl font-semibold">Branch network</h1></div><Card><CardHeader><CardTitle>{branches.length} branches</CardTitle></CardHeader><CardContent className="grid gap-3 md:grid-cols-2">{branches.map((branch) => <div key={branch.id} className="rounded-md border border-border p-4"><div className="flex items-center justify-between"><div className="font-medium">{branch.name}</div><Badge tone={branch.is_active ? "good" : "neutral"}>{branch.is_active ? "active" : "inactive"}</Badge></div><div className="mt-2 text-sm text-muted-foreground">{branch.code}</div><div className="mt-1 text-sm text-muted-foreground">{branch.phone ?? "No phone"}</div></div>)}</CardContent></Card></div>;
}
