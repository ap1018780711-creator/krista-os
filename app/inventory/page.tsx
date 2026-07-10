import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { getInventoryAlerts } from "@/lib/supabase/data";

export default async function InventoryPage() {
  const alerts = await getInventoryAlerts();
  return <div className="space-y-6"><div><p className="text-sm font-medium text-muted-foreground">Inventory</p><h1 className="text-3xl font-semibold">Stock alerts</h1></div><Card><CardHeader><CardTitle>{alerts.length} low stock alerts</CardTitle></CardHeader><CardContent className="space-y-3">{alerts.length ? alerts.map((item) => <div key={item.id} className="rounded-md border border-border p-4"><div className="flex items-center justify-between gap-3"><div><div className="font-medium">{item.productName}</div><div className="text-sm text-muted-foreground">{item.branchName} · lot {item.lotNumber}</div></div><Badge tone="warn">{item.quantityOnHand}/{item.minimumStockAlert}</Badge></div></div>) : <p className="text-sm text-muted-foreground">No products are below minimum stock.</p>}</CardContent></Card></div>;
}
