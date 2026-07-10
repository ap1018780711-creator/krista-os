import { unstable_noStore as noStore } from "next/cache";
import { getSupabaseClient } from "@/lib/supabase/client";

export type Branch = { id: string; code: string; name: string; phone: string | null; address: string | null; is_active: boolean };
export type Patient = { id: string; patient_code: string | null; full_name: string; phone: string | null; email: string | null; status: string; source: string | null; primary_branch_id: string | null; created_at: string };
export type Treatment = { id: string; code: string; name: string; default_unit: string; balance_tracking_type: string; is_active: boolean };
export type CrmTask = { id: string; patient_id: string; branch_id: string | null; due_date: string | null; status: string; priority: string; channel_type: string; notes: string | null };
export type InventoryAlert = { id: string; productName: string; branchName: string; lotNumber: string; quantityOnHand: number; minimumStockAlert: number };
export type Opportunity = { id: string; patientName: string; treatmentName: string; score: number; priority: string; reason: string; status: string; suggestedCrmAction: string | null; generatedAt: string };
export type SalesOrder = { id: string; order_number: string; order_date: string; total_amount: number; status: string; patient_id: string | null; branch_id: string | null };
export type FinanceSummary = { paidRevenue: number; paidOrders: number; draftDoctorFees: number; approvedExpenses: number };

const DEMO_ORG_ID = "00000000-0000-0000-0000-000000000001";

function client() {
  noStore();
  return getSupabaseClient();
}

async function countRows(table: string) {
  const supabase = client();
  if (!supabase) return 0;
  const { count } = await supabase.from(table).select("id", { count: "exact", head: true }).eq("organization_id", DEMO_ORG_ID);
  return count ?? 0;
}

export async function getBranches(): Promise<Branch[]> {
  const supabase = client();
  if (!supabase) return [];
  const { data } = await supabase.from("branches").select("id, code, name, phone, address, is_active").eq("organization_id", DEMO_ORG_ID).order("name");
  return data ?? [];
}

export async function getPatients(): Promise<Patient[]> {
  const supabase = client();
  if (!supabase) return [];
  const { data } = await supabase.from("patients").select("id, patient_code, full_name, phone, email, status, source, primary_branch_id, created_at").eq("organization_id", DEMO_ORG_ID).order("created_at", { ascending: false });
  return data ?? [];
}

export async function getTreatments(): Promise<Treatment[]> {
  const supabase = client();
  if (!supabase) return [];
  const { data } = await supabase.from("treatments").select("id, code, name, default_unit, balance_tracking_type, is_active").eq("organization_id", DEMO_ORG_ID).order("name");
  return data ?? [];
}

export async function getCrmTasks(): Promise<CrmTask[]> {
  const supabase = client();
  if (!supabase) return [];
  const { data } = await supabase.from("crm_tasks").select("id, patient_id, branch_id, due_date, status, priority, channel_type, notes").eq("organization_id", DEMO_ORG_ID).order("due_date", { ascending: true });
  return data ?? [];
}

export async function getInventoryAlerts(): Promise<InventoryAlert[]> {
  const supabase = client();
  if (!supabase) return [];

  const { data: stocks } = await supabase.from("inventory_stocks").select("id, product_lot_id, branch_id, quantity_on_hand, minimum_stock_alert").eq("organization_id", DEMO_ORG_ID).order("quantity_on_hand", { ascending: true });
  const lowStocks = (stocks ?? []).filter((stock) => Number(stock.quantity_on_hand) <= Number(stock.minimum_stock_alert));
  if (lowStocks.length === 0) return [];

  const lotIds = [...new Set(lowStocks.map((stock) => stock.product_lot_id).filter(Boolean))];
  const branchIds = [...new Set(lowStocks.map((stock) => stock.branch_id).filter(Boolean))];
  const { data: lots } = await supabase.from("product_lots").select("id, product_id, lot_number").in("id", lotIds);
  const productIds = [...new Set((lots ?? []).map((lot) => lot.product_id).filter(Boolean))];
  const { data: products } = await supabase.from("products").select("id, product_name").in("id", productIds);
  const { data: branches } = await supabase.from("branches").select("id, name").in("id", branchIds);

  const lotMap = new Map((lots ?? []).map((lot) => [lot.id, lot]));
  const productMap = new Map((products ?? []).map((product) => [product.id, product.product_name]));
  const branchMap = new Map((branches ?? []).map((branch) => [branch.id, branch.name]));

  return lowStocks.map((stock) => {
    const lot = lotMap.get(stock.product_lot_id);
    return {
      id: stock.id,
      productName: productMap.get(lot?.product_id ?? "") ?? "Unknown product",
      branchName: branchMap.get(stock.branch_id) ?? "Unknown branch",
      lotNumber: lot?.lot_number ?? "-",
      quantityOnHand: Number(stock.quantity_on_hand),
      minimumStockAlert: Number(stock.minimum_stock_alert)
    };
  });
}

export async function getOpportunities(): Promise<Opportunity[]> {
  const supabase = client();
  if (!supabase) return [];
  const { data: rows } = await supabase.from("patient_opportunities").select("id, patient_id, recommended_treatment_id, score, priority, reason, suggested_crm_action, status, generated_at").eq("organization_id", DEMO_ORG_ID).order("score", { ascending: false });
  const opportunities = rows ?? [];
  if (opportunities.length === 0) return [];

  const patientIds = [...new Set(opportunities.map((item) => item.patient_id).filter(Boolean))];
  const treatmentIds = [...new Set(opportunities.map((item) => item.recommended_treatment_id).filter(Boolean))];
  const { data: patients } = await supabase.from("patients").select("id, full_name").in("id", patientIds);
  const { data: treatments } = await supabase.from("treatments").select("id, name").in("id", treatmentIds);
  const patientMap = new Map((patients ?? []).map((patient) => [patient.id, patient.full_name]));
  const treatmentMap = new Map((treatments ?? []).map((treatment) => [treatment.id, treatment.name]));

  return opportunities.map((item) => ({
    id: item.id,
    patientName: patientMap.get(item.patient_id) ?? "Unknown patient",
    treatmentName: treatmentMap.get(item.recommended_treatment_id ?? "") ?? "No treatment",
    score: item.score,
    priority: item.priority,
    reason: item.reason,
    status: item.status,
    suggestedCrmAction: item.suggested_crm_action,
    generatedAt: item.generated_at
  }));
}

export async function getSalesOrders(): Promise<SalesOrder[]> {
  const supabase = client();
  if (!supabase) return [];
  const { data } = await supabase.from("sales_orders").select("id, order_number, order_date, total_amount, status, patient_id, branch_id").eq("organization_id", DEMO_ORG_ID).order("order_date", { ascending: false });
  return (data ?? []).map((order) => ({ ...order, total_amount: Number(order.total_amount) }));
}

export async function getFinanceSummary(): Promise<FinanceSummary> {
  const supabase = client();
  if (!supabase) return { paidRevenue: 0, paidOrders: 0, draftDoctorFees: 0, approvedExpenses: 0 };
  const [sales, doctorFees, expenses] = await Promise.all([
    supabase.from("sales_orders").select("total_amount, status").eq("organization_id", DEMO_ORG_ID),
    supabase.from("doctor_fee_entries").select("fee_amount, status").eq("organization_id", DEMO_ORG_ID),
    supabase.from("expenses").select("amount, status").eq("organization_id", DEMO_ORG_ID)
  ]);
  const paidSales = (sales.data ?? []).filter((row) => row.status === "paid");
  return {
    paidRevenue: paidSales.reduce((sum, row) => sum + Number(row.total_amount), 0),
    paidOrders: paidSales.length,
    draftDoctorFees: (doctorFees.data ?? []).filter((row) => row.status === "draft").reduce((sum, row) => sum + Number(row.fee_amount), 0),
    approvedExpenses: (expenses.data ?? []).filter((row) => row.status === "approved" || row.status === "paid").reduce((sum, row) => sum + Number(row.amount), 0)
  };
}

export async function getDashboardData() {
  const [branches, patients, treatments, crmTasks, inventoryAlerts, opportunities, salesOrders] = await Promise.all([
    getBranches(), getPatients(), getTreatments(), getCrmTasks(), getInventoryAlerts(), getOpportunities(), getSalesOrders()
  ]);
  const paidOrders = salesOrders.filter((order) => order.status === "paid");
  return {
    counts: {
      patients: await countRows("patients") || patients.length,
      branches: await countRows("branches") || branches.length,
      treatments: await countRows("treatments") || treatments.length,
      crmTasks: await countRows("crm_tasks") || crmTasks.length,
      lowStockAlerts: inventoryAlerts.length
    },
    topOpportunities: opportunities.slice(0, 5),
    demoRevenue: paidOrders.reduce((sum, order) => sum + order.total_amount, 0),
    recentCrmTasks: crmTasks.slice(0, 5),
    inventoryAlerts
  };
}
