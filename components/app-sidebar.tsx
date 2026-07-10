"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BarChart3, Boxes, Building2, CircleDollarSign, ClipboardList, LayoutDashboard, LineChart, Settings, Sparkles, Stethoscope, UsersRound } from "lucide-react";
import { cn } from "@/lib/utils";

const navItems = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/branches", label: "Branches", icon: Building2 },
  { href: "/patients", label: "Patients", icon: UsersRound },
  { href: "/treatments", label: "Treatments", icon: Stethoscope },
  { href: "/crm", label: "CRM", icon: ClipboardList },
  { href: "/inventory", label: "Inventory", icon: Boxes },
  { href: "/sales", label: "Sales", icon: BarChart3 },
  { href: "/finance", label: "Finance", icon: CircleDollarSign },
  { href: "/opportunities", label: "Opportunities", icon: Sparkles },
  { href: "/settings", label: "Settings", icon: Settings }
];

export function AppSidebar() {
  const pathname = usePathname();
  const itemClass = (href: string) => {
    const active = href === "/" ? pathname === "/" : pathname.startsWith(href);
    return cn("flex h-11 shrink-0 items-center gap-3 rounded-md px-3 text-sm font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground", active && "bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground");
  };

  return (
    <>
      <div className="sticky top-0 z-30 border-b border-border bg-white lg:hidden">
        <div className="px-4 py-3"><div className="text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground">Krista OS</div><div className="text-lg font-semibold">Clinic Console</div></div>
        <nav className="flex gap-2 overflow-x-auto px-3 pb-3">
          {navItems.map((item) => {
            const Icon = item.icon;
            return <Link key={item.href} href={item.href} className={itemClass(item.href)}><Icon className="h-4 w-4" aria-hidden="true" />{item.label}</Link>;
          })}
        </nav>
      </div>
      <aside className="fixed inset-y-0 left-0 z-20 hidden w-64 border-r border-border bg-white lg:block">
        <div className="flex h-16 items-center border-b border-border px-5"><div><div className="text-sm font-semibold uppercase tracking-[0.16em] text-muted-foreground">Krista OS</div><div className="text-lg font-semibold">Clinic Console</div></div></div>
        <nav className="space-y-1 px-3 py-4">
          {navItems.map((item) => {
            const Icon = item.icon;
            return <Link key={item.href} href={item.href} className={itemClass(item.href)}><Icon className="h-4 w-4" aria-hidden="true" />{item.label}</Link>;
          })}
        </nav>
        <div className="absolute bottom-0 left-0 right-0 border-t border-border p-4"><div className="flex items-center gap-2 rounded-md bg-muted px-3 py-2 text-xs text-muted-foreground"><LineChart className="h-4 w-4 text-accent" aria-hidden="true" />Dev database, read-only frontend</div></div>
      </aside>
    </>
  );
}
