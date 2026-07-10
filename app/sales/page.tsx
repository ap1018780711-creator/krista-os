import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import { getSalesOrders } from "@/lib/supabase/data";

export default async function SalesPage() {
  const orders = await getSalesOrders();
  return <div className="space-y-6"><div><p className="text-sm font-medium text-muted-foreground">Sales</p><h1 className="text-3xl font-semibold">Sales orders</h1></div><Card><CardHeader><CardTitle>{orders.length} sales orders</CardTitle></CardHeader><CardContent className="overflow-x-auto"><table className="w-full min-w-[680px] text-sm"><thead className="text-left text-muted-foreground"><tr><th className="py-2">Order</th><th>Date</th><th>Status</th><th className="text-right">Total</th></tr></thead><tbody>{orders.map((order) => <tr key={order.id} className="border-t border-border"><td className="py-3 font-medium">{order.order_number}</td><td>{order.order_date}</td><td><Badge tone={order.status === "paid" ? "good" : "neutral"}>{order.status}</Badge></td><td className="text-right font-medium">{formatCurrency(order.total_amount)}</td></tr>)}</tbody></table></CardContent></Card></div>;
}
