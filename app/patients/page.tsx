import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { getPatients } from "@/lib/supabase/data";

export default async function PatientsPage() {
  const patients = await getPatients();
  return <div className="space-y-6"><div><p className="text-sm font-medium text-muted-foreground">Patients</p><h1 className="text-3xl font-semibold">Patient list</h1></div><Card><CardHeader><CardTitle>{patients.length} patients</CardTitle></CardHeader><CardContent className="overflow-x-auto"><table className="w-full min-w-[720px] text-sm"><thead className="text-left text-muted-foreground"><tr><th className="py-2">Code</th><th>Name</th><th>Phone</th><th>Source</th><th>Status</th></tr></thead><tbody>{patients.map((patient) => <tr key={patient.id} className="border-t border-border"><td className="py-3">{patient.patient_code ?? "-"}</td><td className="font-medium">{patient.full_name}</td><td>{patient.phone ?? "-"}</td><td>{patient.source ?? "-"}</td><td><Badge>{patient.status}</Badge></td></tr>)}</tbody></table></CardContent></Card></div>;
}
