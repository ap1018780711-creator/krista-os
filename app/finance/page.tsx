import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import { getFinanceSummary } from "@/lib/supabase/data";

export default async function FinancePage() {
  const summary = await getFinanceSummary();
  const cards = [["Paid revenue", formatCurrency(summary.paidRevenue)], ["Paid orders", summary.paidOrders], ["Draft doctor fees", formatCurrency(summary.draftDoctorFees)], ["Approved/paid expenses", formatCurrency(summary.approvedExpenses)]];
  return <div className="space-y-6"><div><p className="text-sm font-medium text-muted-foreground">Finance</p><h1 className="text-3xl font-semibold">Finance snapshot</h1></div><section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">{cards.map(([label, value]) => <Card key={label}><CardContent className="p-5"><div className="text-sm text-muted-foreground">{label}</div><div className="mt-2 text-2xl font-semibold">{value}</div></CardContent></Card>)}</section><Card><CardHeader><CardTitle>Scope</CardTitle></CardHeader><CardContent><p className="text-sm text-muted-foreground">This Sprint 2 view reads sales orders, doctor fee entries, and expenses from the current schema. No accounting workflow, auth, RLS, or schema change has been added.</p></CardContent></Card></div>;
}
