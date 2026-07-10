import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function SettingsPage() {
  return <div className="space-y-6"><div><p className="text-sm font-medium text-muted-foreground">Settings</p><h1 className="text-3xl font-semibold">Workspace settings</h1></div><Card><CardHeader><CardTitle>Environment</CardTitle></CardHeader><CardContent className="space-y-3 text-sm text-muted-foreground"><p>Supabase reads use only NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY.</p><p>Authentication, RLS policies, service-role access, SQL execution, and schema changes are intentionally not included in this sprint.</p></CardContent></Card></div>;
}
