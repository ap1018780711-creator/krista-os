import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { getOpportunities } from "@/lib/supabase/data";

export default async function OpportunitiesPage() {
  const opportunities = await getOpportunities();
  return <div className="space-y-6"><div><p className="text-sm font-medium text-muted-foreground">Opportunities</p><h1 className="text-3xl font-semibold">Opportunity engine</h1></div><Card><CardHeader><CardTitle>{opportunities.length} opportunities</CardTitle></CardHeader><CardContent className="space-y-3">{opportunities.map((item) => <div key={item.id} className="rounded-md border border-border p-4"><div className="flex items-start justify-between gap-3"><div><div className="font-medium">{item.patientName}</div><div className="text-sm text-muted-foreground">{item.treatmentName} · score {item.score}</div></div><Badge tone={item.priority === "high" ? "danger" : "warn"}>{item.priority}</Badge></div><p className="mt-3 text-sm text-muted-foreground">{item.reason}</p>{item.suggestedCrmAction ? <p className="mt-2 text-sm text-foreground">{item.suggestedCrmAction}</p> : null}</div>)}</CardContent></Card></div>;
}
