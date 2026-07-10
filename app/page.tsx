import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import { getDashboardData } from "@/lib/supabase/data";

export default async function DashboardPage() {
  const data = await getDashboardData();
  const stats = [
    ["Total patients", data.counts.patients],
    ["Total branches", data.counts.branches],
    ["Total treatments", data.counts.treatments],
    ["CRM tasks", data.counts.crmTasks],
    ["Low stock alerts", data.counts.lowStockAlerts],
    ["Demo revenue", formatCurrency(data.demoRevenue)]
  ];

  return (
    <div className="space-y-6">
      <div><p className="text-sm font-medium text-muted-foreground">Dashboard</p><h1 className="text-3xl font-semibold">Clinic overview</h1></div>
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">{stats.map(([label, value]) => <Card key={label}><CardContent className="p-5"><div className="text-sm text-muted-foreground">{label}</div><div className="mt-2 text-3xl font-semibold">{value}</div></CardContent></Card>)}</section>
      <section className="grid gap-4 xl:grid-cols-2">
        <Card><CardHeader><CardTitle>Top opportunities</CardTitle></CardHeader><CardContent className="space-y-4">{data.topOpportunities.length ? data.topOpportunities.map((item) => <div key={item.id} className="rounded-md border border-border p-4"><div className="flex items-start justify-between gap-3"><div><div className="font-medium">{item.patientName}</div><div className="text-sm text-muted-foreground">{item.treatmentName} · score {item.score}</div></div><Badge tone={item.priority === "high" ? "danger" : "warn"}>{item.priority}</Badge></div><p className="mt-3 text-sm text-muted-foreground">{item.reason}</p></div>) : <p className="text-sm text-muted-foreground">No opportunities found.</p>}</CardContent></Card>
        <Card><CardHeader><CardTitle>Low stock alerts</CardTitle></CardHeader><CardContent className="space-y-3">{data.inventoryAlerts.length ? data.inventoryAlerts.map((item) => <div key={item.id} className="flex items-center justify-between gap-4 rounded-md border border-border p-3"><div><div className="font-medium">{item.productName}</div><div className="text-sm text-muted-foreground">{item.branchName} · lot {item.lotNumber}</div></div><Badge tone="warn">{item.quantityOnHand}/{item.minimumStockAlert}</Badge></div>) : <p className="text-sm text-muted-foreground">No low stock alerts.</p>}</CardContent></Card>
      </section>
    </div>
  );
}
