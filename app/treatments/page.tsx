import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { getTreatments } from "@/lib/supabase/data";

export default async function TreatmentsPage() {
  const treatments = await getTreatments();
  return <div className="space-y-6"><div><p className="text-sm font-medium text-muted-foreground">Treatments</p><h1 className="text-3xl font-semibold">Treatment catalog</h1></div><Card><CardHeader><CardTitle>{treatments.length} treatments</CardTitle></CardHeader><CardContent className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">{treatments.map((treatment) => <div key={treatment.id} className="rounded-md border border-border p-4"><div className="flex items-center justify-between gap-3"><div className="font-medium">{treatment.name}</div><Badge tone={treatment.is_active ? "good" : "neutral"}>{treatment.is_active ? "active" : "inactive"}</Badge></div><div className="mt-2 text-sm text-muted-foreground">{treatment.code} · {treatment.default_unit}</div><div className="mt-1 text-sm text-muted-foreground">Balance: {treatment.balance_tracking_type}</div></div>)}</CardContent></Card></div>;
}
