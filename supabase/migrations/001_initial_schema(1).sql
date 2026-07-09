
-- Krista OS initial schema
-- Supabase-compatible PostgreSQL migration.
-- Approved for file generation only. Do not execute until explicitly approved.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create type tenant_status as enum ('trial', 'active', 'suspended', 'cancelled');
create type global_user_type as enum ('human', 'system', 'platform_admin');
create type organization_user_type as enum ('owner', 'doctor', 'manager', 'staff', 'accountant', 'crm', 'system');
create type patient_status as enum ('lead', 'active', 'inactive', 'archived');
create type channel_type as enum ('LINE', 'Facebook', 'Instagram', 'Phone', 'Email', 'TikTok Lead', 'SMS');
create type consent_type as enum ('treatment', 'privacy', 'marketing', 'photo', 'communication');
create type consent_status as enum ('granted', 'revoked', 'expired');
create type workflow_stage as enum ('lead', 'booking', 'check_in', 'consultation', 'treatment_plan', 'payment', 'procedure', 'photo', 'crm', 'repeat_visit');
create type lead_status as enum ('new', 'contacted', 'booked', 'lost', 'converted');
create type appointment_status as enum ('booked', 'confirmed', 'checked_in', 'completed', 'cancelled', 'no_show');
create type appointment_type as enum ('consultation', 'procedure', 'follow_up', 'review');
create type plan_status as enum ('draft', 'proposed', 'accepted', 'declined', 'expired');
create type plan_item_status as enum ('proposed', 'accepted', 'declined');
create type treatment_case_status as enum ('planned', 'paid', 'in_progress', 'completed', 'cancelled');
create type treatment_unit as enum ('session', 'unit', 'cc', 'shot', 'vial');
create type balance_tracking_type as enum ('none', 'units', 'cc', 'shots', 'sessions');
create type photo_type as enum ('before', 'after', 'progress', 'consent');
create type sales_order_status as enum ('draft', 'confirmed', 'paid', 'refunded', 'cancelled');
create type payment_method as enum ('cash', 'card', 'transfer', 'financing', 'other');
create type payment_status as enum ('pending', 'paid', 'voided', 'refunded');
create type package_balance_status as enum ('active', 'exhausted', 'expired', 'cancelled');
create type package_transaction_type as enum ('purchase', 'usage', 'adjustment', 'expiry', 'refund');
create type stock_transfer_status as enum ('requested', 'approved', 'shipped', 'received', 'cancelled');
create type stock_movement_type as enum ('stock_in', 'stock_out', 'adjustment', 'expired', 'damaged', 'transfer_out', 'transfer_in');
create type crm_trigger_event as enum ('procedure_completed', 'package_expiring', 'birthday', 'opportunity_generated', 'manual');
create type crm_task_status as enum ('pending', 'contacted', 'booked', 'completed', 'missed');
create type priority_level as enum ('high', 'medium', 'low');
create type crm_outcome as enum ('no_answer', 'contacted', 'booked', 'declined', 'completed', 'missed', 'other');
create type birthday_campaign_status as enum ('draft', 'active', 'completed', 'cancelled');
create type contacted_status as enum ('not_contacted', 'contacted');
create type booked_status as enum ('not_booked', 'booked');
create type opportunity_rule_type as enum ('repeat_cycle', 'cross_sell', 'ltv', 'visit_frequency', 'crm_response', 'last_visit_gap');
create type opportunity_status as enum ('open', 'assigned', 'contacted', 'booked', 'dismissed', 'completed');
create type opportunity_factor_type as enum ('repeat_due', 'treatment_history', 'ltv', 'visit_frequency', 'last_visit_gap', 'crm_response', 'cross_sell');
create type ai_job_status as enum ('queued', 'running', 'succeeded', 'failed', 'cancelled');
create type expense_status as enum ('draft', 'approved', 'paid', 'voided');
create type communication_direction as enum ('inbound', 'outbound');

create table organizations (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  legal_name text not null,
  status tenant_status not null default 'trial',
  default_timezone text not null default 'Asia/Bangkok',
  default_locale text not null default 'th-TH',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table organizations is 'Clinic organization tenant. All customer-owned data is scoped by organization_id.';

create table organization_settings (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null unique references organizations(id) on delete cascade,
  app_name text not null,
  logo_url text,
  theme_primary_color text not null default '#202326',
  theme_secondary_color text not null default '#c7755f',
  contact_phone text,
  contact_email text,
  custom_domain text,
  settings_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table organization_settings is 'White-label app name, logo, theme, and future tenant configuration.';

create table branches (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  code text not null,
  name text not null,
  address text,
  phone text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code)
);
comment on table branches is 'Clinic branches under one organization. Supports unlimited branches per tenant.';

create table users (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  email text unique,
  phone text,
  global_user_type global_user_type not null default 'human',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table organization_users (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  organization_user_type organization_user_type not null default 'staff',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, user_id)
);

create table branch_users (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  branch_id uuid not null references branches(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  unique (organization_id, branch_id, user_id)
);

create table roles (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code)
);

create table permissions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  description text,
  created_at timestamptz not null default now()
);

create table user_roles (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  user_id uuid not null references users(id) on delete cascade,
  role_id uuid not null references roles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (organization_id, user_id, role_id)
);

create table role_permissions (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references roles(id) on delete cascade,
  permission_id uuid not null references permissions(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (role_id, permission_id)
);

create table patients (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  primary_branch_id uuid references branches(id) on delete set null,
  patient_code text,
  full_name text not null,
  phone text,
  email text,
  date_of_birth date,
  gender text,
  source text,
  status patient_status not null default 'lead',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, patient_code)
);
comment on table patients is 'Patients are tenant-scoped and may be connected to multiple communication channels.';

create table patient_channels (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  channel_type channel_type not null,
  external_user_id text,
  display_name text,
  profile_url text,
  is_primary boolean not null default false,
  consent_to_contact boolean not null default false,
  marketing_opt_in boolean not null default false,
  last_contacted_at timestamptz,
  notes text,
  line_user_id text,
  line_display_name text,
  line_picture_url text,
  line_oa_id text,
  line_connected_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table patient_channels is 'Future-ready communication channel records, including LINE OA fields. No external API is connected by this migration.';

create table patient_consents (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  channel_id uuid references patient_channels(id) on delete set null,
  consent_type consent_type not null,
  status consent_status not null default 'granted',
  source text,
  granted_at timestamptz,
  revoked_at timestamptz,
  evidence_url text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((status <> 'granted') or (granted_at is not null))
);
comment on table patient_consents is 'Consent history for privacy, marketing, communication, treatment, and photo usage.';

create table communication_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  channel_id uuid references patient_channels(id) on delete set null,
  staff_user_id uuid references users(id) on delete set null,
  channel_type channel_type not null,
  direction communication_direction not null default 'outbound',
  message_summary text,
  outcome crm_outcome,
  communicated_at timestamptz not null default now(),
  related_entity_table text,
  related_entity_id uuid,
  created_at timestamptz not null default now()
);
comment on table communication_logs is 'Communication history without requiring full sensitive message storage.';

create table membership_levels (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  code text not null,
  name text not null,
  rank integer not null,
  min_ltv numeric(14,2) not null default 0,
  points_multiplier numeric(8,2) not null default 1,
  benefits_json jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code),
  unique (organization_id, rank)
);

create table patient_memberships (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  membership_level_id uuid not null references membership_levels(id),
  total_spending_ltv numeric(14,2) not null default 0,
  points_balance numeric(14,2) not null default 0,
  start_date date not null,
  expiry_date date,
  status text not null default 'active' check (status in ('active', 'expired', 'suspended', 'cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table patient_workflow_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  branch_id uuid references branches(id) on delete set null,
  stage workflow_stage not null,
  source_table text,
  source_id uuid,
  actor_user_id uuid references users(id) on delete set null,
  occurred_at timestamptz not null default now(),
  notes text,
  created_at timestamptz not null default now()
);

create table leads (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  branch_id uuid references branches(id) on delete set null,
  assigned_staff_id uuid references users(id) on delete set null,
  source text,
  status lead_status not null default 'new',
  converted_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table appointments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  branch_id uuid not null references branches(id),
  doctor_user_id uuid references users(id) on delete set null,
  assigned_staff_id uuid references users(id) on delete set null,
  scheduled_at timestamptz not null,
  status appointment_status not null default 'booked',
  appointment_type appointment_type not null default 'consultation',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table consultations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  appointment_id uuid references appointments(id) on delete set null,
  patient_id uuid not null references patients(id) on delete cascade,
  doctor_user_id uuid not null references users(id),
  consultation_at timestamptz not null default now(),
  concern_notes text,
  diagnosis_notes text,
  recommended_plan_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table treatment_categories (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  parent_category_id uuid references treatment_categories(id) on delete set null,
  code text not null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code)
);

create table treatments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  category_id uuid references treatment_categories(id) on delete set null,
  code text not null,
  name text not null,
  default_unit treatment_unit not null default 'session',
  balance_tracking_type balance_tracking_type not null default 'none',
  is_partial_usage_allowed boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code)
);
comment on table treatments is 'Treatment catalog. Botox/Filler can allow partial balance usage; devices are usually consumed per visit.';

create table treatment_repeat_rules (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  treatment_id uuid not null references treatments(id) on delete cascade,
  min_months integer not null check (min_months >= 0),
  max_months integer not null check (max_months >= min_months),
  default_follow_up_days integer,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, treatment_id)
);

create table treatment_cross_sell_rules (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  source_treatment_id uuid not null references treatments(id) on delete cascade,
  recommended_treatment_id uuid not null references treatments(id) on delete cascade,
  weight integer not null default 10,
  reason_template text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, source_treatment_id, recommended_treatment_id),
  check (source_treatment_id <> recommended_treatment_id)
);

create table treatment_plans (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  consultation_id uuid references consultations(id) on delete set null,
  patient_id uuid not null references patients(id) on delete cascade,
  doctor_user_id uuid not null references users(id),
  status plan_status not null default 'draft',
  plan_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table treatment_plan_items (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  treatment_plan_id uuid not null references treatment_plans(id) on delete cascade,
  treatment_id uuid not null references treatments(id),
  recommended_quantity numeric(12,2) not null default 1 check (recommended_quantity > 0),
  unit treatment_unit not null default 'session',
  quoted_price numeric(14,2) not null default 0,
  status plan_item_status not null default 'proposed',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table treatment_cases (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  branch_id uuid not null references branches(id),
  treatment_id uuid not null references treatments(id),
  doctor_user_id uuid not null references users(id),
  treatment_plan_item_id uuid references treatment_plan_items(id) on delete set null,
  treatment_date date not null,
  status treatment_case_status not null default 'planned',
  clinical_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table treatment_cases is 'One treatment case has one doctor. Consultation and procedure should remain with the same doctor at application policy level.';

create table procedures (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  treatment_case_id uuid not null references treatment_cases(id) on delete cascade,
  doctor_user_id uuid not null references users(id),
  procedure_at timestamptz not null default now(),
  used_quantity numeric(12,2) not null default 1 check (used_quantity >= 0),
  unit treatment_unit not null default 'session',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table procedure_photos (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  procedure_id uuid not null references procedures(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  photo_type photo_type not null,
  storage_path text not null,
  uploaded_by_user_id uuid references users(id) on delete set null,
  captured_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table sales_orders (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  branch_id uuid not null references branches(id),
  created_by_user_id uuid references users(id) on delete set null,
  order_number text not null,
  order_date date not null default current_date,
  subtotal_amount numeric(14,2) not null default 0,
  discount_amount numeric(14,2) not null default 0,
  total_amount numeric(14,2) not null default 0,
  status sales_order_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, order_number),
  check (subtotal_amount >= 0 and discount_amount >= 0 and total_amount >= 0)
);

create table sales_order_items (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  sales_order_id uuid not null references sales_orders(id) on delete cascade,
  treatment_id uuid references treatments(id) on delete set null,
  description text not null,
  quantity numeric(12,2) not null default 1 check (quantity > 0),
  unit treatment_unit not null default 'session',
  unit_price numeric(14,2) not null default 0 check (unit_price >= 0),
  line_total numeric(14,2) not null default 0 check (line_total >= 0),
  creates_package_balance boolean not null default false,
  expiry_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table payments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  sales_order_id uuid not null references sales_orders(id) on delete cascade,
  received_by_user_id uuid references users(id) on delete set null,
  payment_date timestamptz not null default now(),
  method payment_method not null,
  amount numeric(14,2) not null check (amount >= 0),
  reference_number text,
  status payment_status not null default 'paid',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table sales_staff_credits (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  sales_order_id uuid not null references sales_orders(id) on delete cascade,
  staff_user_id uuid not null references users(id),
  credited_amount numeric(14,2) not null check (credited_amount >= 0),
  credited_at timestamptz not null default now(),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table sales_staff_credits is 'V1 tracks sales amount by staff. Tier commission calculation is deferred.';

create table patient_package_balances (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  treatment_id uuid not null references treatments(id),
  sales_order_item_id uuid references sales_order_items(id) on delete set null,
  original_quantity numeric(12,2) not null check (original_quantity >= 0),
  used_quantity numeric(12,2) not null default 0 check (used_quantity >= 0),
  remaining_quantity numeric(12,2) not null default 0 check (remaining_quantity >= 0),
  unit treatment_unit not null,
  expiry_date date,
  status package_balance_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (used_quantity + remaining_quantity <= original_quantity + 0.01)
);
comment on table patient_package_balances is 'Package/balance snapshot for Botox units, Filler cc, device shots, or sessions. Ledger transactions are source of truth.';

create table package_balance_transactions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  package_balance_id uuid not null references patient_package_balances(id) on delete cascade,
  treatment_case_id uuid references treatment_cases(id) on delete set null,
  actor_user_id uuid references users(id) on delete set null,
  type package_transaction_type not null,
  quantity_delta numeric(12,2) not null,
  transaction_at timestamptz not null default now(),
  notes text,
  created_at timestamptz not null default now()
);
comment on table package_balance_transactions is 'Ledger for purchases, partial usage, adjustments, expiry, and refunds.';

create table expense_categories (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  code text not null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code)
);

create table expenses (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  branch_id uuid references branches(id) on delete set null,
  category_id uuid references expense_categories(id) on delete set null,
  vendor_name text,
  expense_date date not null default current_date,
  amount numeric(14,2) not null check (amount >= 0),
  status expense_status not null default 'draft',
  notes text,
  created_by_user_id uuid references users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table suppliers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  contact_name text,
  phone text,
  email text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, name)
);

create table brands (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, name)
);

create table product_categories (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  code text not null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code)
);

create table products (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  category_id uuid references product_categories(id) on delete set null,
  brand_id uuid references brands(id) on delete set null,
  supplier_id uuid references suppliers(id) on delete set null,
  sku text not null,
  product_name text not null,
  default_unit text not null default 'piece',
  unit_cost numeric(14,2) not null default 0 check (unit_cost >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, sku)
);

create table product_lots (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  lot_number text not null,
  expiry_date date,
  unit_cost numeric(14,2) not null default 0 check (unit_cost >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, product_id, lot_number)
);

create table inventory_stocks (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  product_lot_id uuid not null references product_lots(id) on delete cascade,
  branch_id uuid not null references branches(id) on delete cascade,
  quantity_on_hand numeric(14,2) not null default 0,
  minimum_stock_alert numeric(14,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, product_lot_id, branch_id),
  check (quantity_on_hand >= 0),
  check (minimum_stock_alert >= 0)
);

create table stock_transfers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  from_branch_id uuid not null references branches(id),
  to_branch_id uuid not null references branches(id),
  requested_by uuid not null references users(id),
  approved_by uuid references users(id),
  shipped_by uuid references users(id),
  received_by uuid references users(id),
  transfer_date date not null default current_date,
  received_date date,
  status stock_transfer_status not null default 'requested',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (from_branch_id <> to_branch_id)
);
comment on table stock_transfers is 'Branch-to-branch inventory transfer workflow: requested, approved, shipped, received, cancelled.';

create table stock_transfer_items (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  stock_transfer_id uuid not null references stock_transfers(id) on delete cascade,
  product_id uuid not null references products(id),
  lot_number text not null,
  expiry_date date,
  quantity numeric(14,2) not null check (quantity > 0),
  unit text not null,
  unit_cost numeric(14,2) not null default 0 check (unit_cost >= 0),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table stock_movements (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  inventory_stock_id uuid references inventory_stocks(id) on delete set null,
  stock_transfer_id uuid references stock_transfers(id) on delete set null,
  stock_transfer_item_id uuid references stock_transfer_items(id) on delete set null,
  source_branch_id uuid references branches(id) on delete set null,
  destination_branch_id uuid references branches(id) on delete set null,
  actor_user_id uuid references users(id) on delete set null,
  type stock_movement_type not null,
  quantity_delta numeric(14,2) not null,
  movement_at timestamptz not null default now(),
  reference_type text,
  reference_id uuid,
  notes text,
  created_at timestamptz not null default now(),
  check (
    (type in ('stock_in', 'transfer_in') and quantity_delta > 0)
    or (type in ('stock_out', 'expired', 'damaged', 'transfer_out') and quantity_delta < 0)
    or (type = 'adjustment')
  )
);
comment on table stock_movements is 'Inventory ledger. Transfers create paired transfer_out and transfer_in movements linked to stock transfer records.';

create table crm_rule_templates (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  treatment_id uuid references treatments(id) on delete cascade,
  name text not null,
  offset_days integer not null default 0,
  trigger_event crm_trigger_event not null,
  default_channel_type channel_type not null default 'LINE',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table crm_tasks (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  branch_id uuid not null references branches(id),
  assigned_staff_id uuid references users(id) on delete set null,
  related_treatment_id uuid references treatments(id) on delete set null,
  related_sale_id uuid references sales_orders(id) on delete set null,
  patient_channel_id uuid references patient_channels(id) on delete set null,
  crm_rule_template_id uuid references crm_rule_templates(id) on delete set null,
  channel_type channel_type not null default 'LINE',
  due_date date not null,
  status crm_task_status not null default 'pending',
  priority priority_level not null default 'medium',
  notes text,
  contacted_at timestamptz,
  outcome crm_outcome,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table crm_tasks is 'CRM automation tasks can reference a patient contact channel for LINE/Facebook/Phone/etc. workflows.';

create table crm_contact_attempts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  crm_task_id uuid references crm_tasks(id) on delete cascade,
  patient_channel_id uuid references patient_channels(id) on delete set null,
  birthday_campaign_patient_id uuid,
  contacted_by_user_id uuid references users(id) on delete set null,
  channel_type channel_type not null,
  outcome crm_outcome not null,
  contacted_at timestamptz not null default now(),
  notes text,
  created_at timestamptz not null default now()
);

create table birthday_campaigns (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  branch_id uuid references branches(id) on delete set null,
  campaign_month date not null,
  name text not null,
  benefit_description text,
  status birthday_campaign_status not null default 'draft',
  created_by_user_id uuid references users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table birthday_campaign_patients (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  birthday_campaign_id uuid not null references birthday_campaigns(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  assigned_staff_id uuid references users(id) on delete set null,
  contacted_status contacted_status not null default 'not_contacted',
  booked_status booked_status not null default 'not_booked',
  birthday_date date not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, birthday_campaign_id, patient_id)
);

alter table crm_contact_attempts
  add constraint crm_contact_attempts_birthday_fk
  foreign key (birthday_campaign_patient_id)
  references birthday_campaign_patients(id)
  on delete set null;

create table marketing_campaigns (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  branch_id uuid references branches(id) on delete set null,
  name text not null,
  campaign_type text not null,
  start_date date,
  end_date date,
  budget_amount numeric(14,2) not null default 0 check (budget_amount >= 0),
  status text not null default 'draft' check (status in ('draft', 'active', 'completed', 'cancelled')),
  created_by_user_id uuid references users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table marketing_campaign_channels (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  marketing_campaign_id uuid not null references marketing_campaigns(id) on delete cascade,
  channel_type channel_type not null,
  external_campaign_id text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table opportunity_rules (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  code text not null,
  name text not null,
  recommended_treatment_id uuid references treatments(id) on delete set null,
  rule_type opportunity_rule_type not null,
  weight integer not null default 10,
  priority_default priority_level not null default 'medium',
  reason_template text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code),
  check (weight >= 0)
);
comment on table opportunity_rules is 'Rule-based Opportunity Engine configuration. No machine learning is implemented.';

create table patient_opportunities (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_id uuid not null references patients(id) on delete cascade,
  recommended_treatment_id uuid references treatments(id) on delete set null,
  opportunity_rule_id uuid references opportunity_rules(id) on delete set null,
  crm_task_id uuid references crm_tasks(id) on delete set null,
  score integer not null check (score between 0 and 100),
  priority priority_level not null default 'medium',
  reason text not null,
  suggested_crm_action text,
  status opportunity_status not null default 'open',
  generated_at timestamptz not null default now(),
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table opportunity_score_factors (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  patient_opportunity_id uuid not null references patient_opportunities(id) on delete cascade,
  factor_type opportunity_factor_type not null,
  factor_value text,
  score_contribution integer not null default 0,
  explanation text,
  created_at timestamptz not null default now()
);

create table audit_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references organizations(id) on delete set null,
  actor_user_id uuid references users(id) on delete set null,
  action text not null,
  entity_table text not null,
  entity_id uuid,
  before_json jsonb,
  after_json jsonb,
  ip_address text,
  user_agent text,
  occurred_at timestamptz not null default now()
);
comment on table audit_logs is 'Operational audit trail for sensitive patient, consent, stock, CRM, and finance changes.';

create table ai_modules (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references organizations(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, code)
);

create table ai_jobs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  ai_module_id uuid not null references ai_modules(id) on delete cascade,
  requested_by_user_id uuid references users(id) on delete set null,
  entity_table text,
  entity_id uuid,
  input_json jsonb not null default '{}'::jsonb,
  status ai_job_status not null default 'queued',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz
);

create table ai_outputs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  ai_job_id uuid not null references ai_jobs(id) on delete cascade,
  output_type text not null,
  output_json jsonb not null default '{}'::jsonb,
  confidence_score numeric(5,4) check (confidence_score is null or (confidence_score >= 0 and confidence_score <= 1)),
  created_at timestamptz not null default now()
);

-- Indexes
create index idx_branches_org on branches (organization_id, is_active);
create index idx_org_users_org_user on organization_users (organization_id, user_id);
create index idx_branch_users_org_branch on branch_users (organization_id, branch_id);
create index idx_patients_org_branch on patients (organization_id, primary_branch_id);
create index idx_patients_org_phone on patients (organization_id, phone);
create index idx_patients_org_birthdate on patients (organization_id, date_of_birth);
create index idx_patient_channels_patient on patient_channels (organization_id, patient_id);
create index idx_patient_channels_external on patient_channels (organization_id, channel_type, external_user_id);
create index idx_patient_consents_patient on patient_consents (organization_id, patient_id, consent_type, status);
create index idx_communication_logs_patient on communication_logs (organization_id, patient_id, communicated_at desc);
create index idx_memberships_patient on patient_memberships (organization_id, patient_id, status);
create index idx_workflow_patient on patient_workflow_events (organization_id, patient_id, occurred_at desc);
create index idx_leads_queue on leads (organization_id, branch_id, status, created_at desc);
create index idx_appointments_schedule on appointments (organization_id, branch_id, scheduled_at);
create index idx_appointments_doctor on appointments (organization_id, doctor_user_id, scheduled_at);
create index idx_consultations_patient on consultations (organization_id, patient_id, consultation_at desc);
create index idx_treatments_active on treatments (organization_id, is_active, balance_tracking_type);
create index idx_treatment_cases_patient on treatment_cases (organization_id, patient_id, treatment_date desc);
create index idx_treatment_cases_doctor on treatment_cases (organization_id, doctor_user_id, treatment_date desc);
create index idx_procedures_case on procedures (organization_id, treatment_case_id, procedure_at desc);
create index idx_sales_orders_branch_date on sales_orders (organization_id, branch_id, order_date desc);
create index idx_sales_orders_patient on sales_orders (organization_id, patient_id, order_date desc);
create index idx_sales_staff_credits_staff on sales_staff_credits (organization_id, staff_user_id, credited_at desc);
create index idx_package_balances_patient on patient_package_balances (organization_id, patient_id, status);
create index idx_package_balances_expiry on patient_package_balances (organization_id, expiry_date, status);
create index idx_package_tx_balance on package_balance_transactions (organization_id, package_balance_id, transaction_at desc);
create index idx_expenses_branch_date on expenses (organization_id, branch_id, expense_date desc);
create index idx_products_active on products (organization_id, is_active);
create index idx_product_lots_expiry on product_lots (organization_id, expiry_date);
create index idx_inventory_stocks_branch on inventory_stocks (organization_id, branch_id, quantity_on_hand);
create index idx_stock_transfers_status on stock_transfers (organization_id, status, transfer_date desc);
create index idx_stock_transfers_from on stock_transfers (organization_id, from_branch_id, status);
create index idx_stock_transfers_to on stock_transfers (organization_id, to_branch_id, status);
create index idx_stock_movements_stock on stock_movements (organization_id, inventory_stock_id, movement_at desc);
create index idx_stock_movements_type on stock_movements (organization_id, type, movement_at desc);
create index idx_crm_tasks_due on crm_tasks (organization_id, branch_id, due_date, status);
create index idx_crm_tasks_staff on crm_tasks (organization_id, assigned_staff_id, due_date);
create index idx_crm_tasks_priority on crm_tasks (organization_id, status, priority, due_date);
create index idx_crm_contact_attempts_task on crm_contact_attempts (organization_id, crm_task_id, contacted_at desc);
create index idx_birthday_campaigns_month on birthday_campaigns (organization_id, branch_id, campaign_month);
create index idx_birthday_campaign_patients_status on birthday_campaign_patients (organization_id, contacted_status, booked_status);
create index idx_marketing_campaigns_status on marketing_campaigns (organization_id, status, start_date);
create index idx_opportunities_priority on patient_opportunities (organization_id, priority, score desc);
create index idx_opportunities_patient on patient_opportunities (organization_id, patient_id, generated_at desc);
create index idx_audit_logs_entity on audit_logs (organization_id, entity_table, entity_id);
create index idx_audit_logs_actor on audit_logs (organization_id, actor_user_id, occurred_at desc);
create index idx_ai_jobs_status on ai_jobs (organization_id, ai_module_id, status, created_at desc);
create index idx_ai_jobs_entity on ai_jobs (organization_id, entity_table, entity_id);

-- updated_at triggers
create trigger trg_organizations_updated_at before update on organizations for each row execute function public.set_updated_at();
create trigger trg_organization_settings_updated_at before update on organization_settings for each row execute function public.set_updated_at();
create trigger trg_branches_updated_at before update on branches for each row execute function public.set_updated_at();
create trigger trg_users_updated_at before update on users for each row execute function public.set_updated_at();
create trigger trg_organization_users_updated_at before update on organization_users for each row execute function public.set_updated_at();
create trigger trg_roles_updated_at before update on roles for each row execute function public.set_updated_at();
create trigger trg_patients_updated_at before update on patients for each row execute function public.set_updated_at();
create trigger trg_patient_channels_updated_at before update on patient_channels for each row execute function public.set_updated_at();
create trigger trg_patient_consents_updated_at before update on patient_consents for each row execute function public.set_updated_at();
create trigger trg_membership_levels_updated_at before update on membership_levels for each row execute function public.set_updated_at();
create trigger trg_patient_memberships_updated_at before update on patient_memberships for each row execute function public.set_updated_at();
create trigger trg_leads_updated_at before update on leads for each row execute function public.set_updated_at();
create trigger trg_appointments_updated_at before update on appointments for each row execute function public.set_updated_at();
create trigger trg_consultations_updated_at before update on consultations for each row execute function public.set_updated_at();
create trigger trg_treatment_categories_updated_at before update on treatment_categories for each row execute function public.set_updated_at();
create trigger trg_treatments_updated_at before update on treatments for each row execute function public.set_updated_at();
create trigger trg_treatment_repeat_rules_updated_at before update on treatment_repeat_rules for each row execute function public.set_updated_at();
create trigger trg_treatment_cross_sell_rules_updated_at before update on treatment_cross_sell_rules for each row execute function public.set_updated_at();
create trigger trg_treatment_plans_updated_at before update on treatment_plans for each row execute function public.set_updated_at();
create trigger trg_treatment_plan_items_updated_at before update on treatment_plan_items for each row execute function public.set_updated_at();
create trigger trg_treatment_cases_updated_at before update on treatment_cases for each row execute function public.set_updated_at();
create trigger trg_procedures_updated_at before update on procedures for each row execute function public.set_updated_at();
create trigger trg_procedure_photos_updated_at before update on procedure_photos for each row execute function public.set_updated_at();
create trigger trg_sales_orders_updated_at before update on sales_orders for each row execute function public.set_updated_at();
create trigger trg_sales_order_items_updated_at before update on sales_order_items for each row execute function public.set_updated_at();
create trigger trg_payments_updated_at before update on payments for each row execute function public.set_updated_at();
create trigger trg_sales_staff_credits_updated_at before update on sales_staff_credits for each row execute function public.set_updated_at();
create trigger trg_patient_package_balances_updated_at before update on patient_package_balances for each row execute function public.set_updated_at();
create trigger trg_expense_categories_updated_at before update on expense_categories for each row execute function public.set_updated_at();
create trigger trg_expenses_updated_at before update on expenses for each row execute function public.set_updated_at();
create trigger trg_suppliers_updated_at before update on suppliers for each row execute function public.set_updated_at();
create trigger trg_brands_updated_at before update on brands for each row execute function public.set_updated_at();
create trigger trg_product_categories_updated_at before update on product_categories for each row execute function public.set_updated_at();
create trigger trg_products_updated_at before update on products for each row execute function public.set_updated_at();
create trigger trg_product_lots_updated_at before update on product_lots for each row execute function public.set_updated_at();
create trigger trg_inventory_stocks_updated_at before update on inventory_stocks for each row execute function public.set_updated_at();
create trigger trg_stock_transfers_updated_at before update on stock_transfers for each row execute function public.set_updated_at();
create trigger trg_stock_transfer_items_updated_at before update on stock_transfer_items for each row execute function public.set_updated_at();
create trigger trg_crm_rule_templates_updated_at before update on crm_rule_templates for each row execute function public.set_updated_at();
create trigger trg_crm_tasks_updated_at before update on crm_tasks for each row execute function public.set_updated_at();
create trigger trg_birthday_campaigns_updated_at before update on birthday_campaigns for each row execute function public.set_updated_at();
create trigger trg_birthday_campaign_patients_updated_at before update on birthday_campaign_patients for each row execute function public.set_updated_at();
create trigger trg_marketing_campaigns_updated_at before update on marketing_campaigns for each row execute function public.set_updated_at();
create trigger trg_marketing_campaign_channels_updated_at before update on marketing_campaign_channels for each row execute function public.set_updated_at();
create trigger trg_opportunity_rules_updated_at before update on opportunity_rules for each row execute function public.set_updated_at();
create trigger trg_patient_opportunities_updated_at before update on patient_opportunities for each row execute function public.set_updated_at();
create trigger trg_ai_modules_updated_at before update on ai_modules for each row execute function public.set_updated_at();
create trigger trg_ai_jobs_updated_at before update on ai_jobs for each row execute function public.set_updated_at();

-- Doctor fee finance tables added during pre-execution review.
create type doctor_fee_status as enum ('draft', 'approved', 'paid', 'voided');
create type doctor_fee_calculation_type as enum ('fixed_amount', 'percentage', 'manual');

create table doctor_fee_rules (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  treatment_id uuid references treatments(id) on delete cascade,
  doctor_user_id uuid references users(id) on delete cascade,
  calculation_type doctor_fee_calculation_type not null default 'manual',
  fixed_amount numeric(14,2) check (fixed_amount is null or fixed_amount >= 0),
  percentage_rate numeric(7,4) check (percentage_rate is null or (percentage_rate >= 0 and percentage_rate <= 1)),
  is_active boolean not null default true,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table doctor_fee_rules is 'Optional future doctor fee rule configuration, separate from sales commission.';

create table doctor_fee_entries (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id) on delete cascade,
  branch_id uuid references branches(id) on delete set null,
  doctor_user_id uuid not null references users(id),
  treatment_id uuid references treatments(id) on delete set null,
  treatment_case_id uuid references treatment_cases(id) on delete set null,
  sales_order_id uuid references sales_orders(id) on delete set null,
  doctor_fee_rule_id uuid references doctor_fee_rules(id) on delete set null,
  fee_date date not null default current_date,
  base_amount numeric(14,2) not null default 0 check (base_amount >= 0),
  fee_amount numeric(14,2) not null default 0 check (fee_amount >= 0),
  status doctor_fee_status not null default 'draft',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table doctor_fee_entries is 'Doctor fee ledger entries, separate from sales staff credits and expenses.';

create index idx_doctor_fee_rules_org_treatment on doctor_fee_rules (organization_id, treatment_id, is_active);
create index idx_doctor_fee_rules_org_doctor on doctor_fee_rules (organization_id, doctor_user_id, is_active);
create index idx_doctor_fee_entries_doctor on doctor_fee_entries (organization_id, doctor_user_id, fee_date desc);
create index idx_doctor_fee_entries_branch on doctor_fee_entries (organization_id, branch_id, fee_date desc);
create index idx_doctor_fee_entries_status on doctor_fee_entries (organization_id, status, fee_date desc);

create trigger trg_doctor_fee_rules_updated_at before update on doctor_fee_rules for each row execute function public.set_updated_at();
create trigger trg_doctor_fee_entries_updated_at before update on doctor_fee_entries for each row execute function public.set_updated_at();
