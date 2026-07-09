# SQL Runbook

## Scope

This runbook explains the order to run the generated SQL files. Do not run these files until the owner approves execution.

Files:

1. `supabase/migrations/001_initial_schema.sql`
2. `supabase/seed/001_seed_demo_data.sql`

## Pre-run Checklist

Before running SQL:

1. Confirm this is a Supabase test project or disposable development database.
2. Confirm no production data exists in the target database.
3. Confirm the schema file has been reviewed after the latest changes.
4. Confirm seed data is safe to insert into the target environment.
5. Confirm Row Level Security is intentionally not enabled yet.
6. Confirm no external LINE, Facebook, Instagram, or TikTok integration will be connected during this run.

## Execution Order

Run in this exact order:

1. Run `supabase/migrations/001_initial_schema.sql`.
2. Confirm schema creation completed without errors.
3. Run `supabase/seed/001_seed_demo_data.sql`.
4. Confirm seed rows were inserted for one organization and four branches.

## Expected Schema Result

After the schema migration:

- UUID extension `pgcrypto` exists.
- All enum types exist before dependent tables use them.
- Tenant tables exist: `organizations`, `organization_settings`, `branches`.
- Patient, clinical, sales, inventory, CRM, opportunity, audit, and AI-ready tables exist.
- RLS is not enabled yet.

## Expected Seed Result

The seed creates one demo organization with these branches:

- Korat
- Khon Kaen
- Kaeng Khro
- Chum Phae

It also creates demo users, patients, communication channels, membership levels, treatments, repeat rules, package balance, inventory stock, one shipped stock transfer, CRM task, birthday campaign, opportunity rule, and doctor fee sample data.

## Post-run Smoke Checks

After running schema and seed, inspect these manually:

```sql
select count(*) from organizations;
select count(*) from branches;
select count(*) from patients;
select count(*) from patient_channels;
select count(*) from crm_tasks;
select count(*) from stock_transfers;
select count(*) from stock_movements;
select count(*) from patient_package_balances;
select count(*) from doctor_fee_entries;
```

Expected high-level result:

- `organizations`: at least 1
- `branches`: at least 4
- `patients`: at least 2
- `crm_tasks`: at least 1
- `stock_transfers`: at least 1
- `stock_movements`: at least 1 transfer_out movement

## Stock Transfer Policy

The approved operational policy is:

- `requested` / `approved`: no inventory movement yet
- `shipped`: create `transfer_out` from source branch
- `received`: create `transfer_in` to destination branch
- `cancelled` before shipped: no movement
- `cancelled` after shipped: handle with return movement or adjustment

The current schema supports this policy but does not automate stock quantity updates with triggers yet.

## Rollback Guidance

For a disposable test database, the safest rollback is to reset the database and rerun migrations.

Manual rollback SQL is not included because the schema has many foreign keys and should not be dropped casually.

## RLS Reminder

RLS is intentionally not enabled in Sprint 1. Future RLS should scope records by `organization_id` and then by branch access through `branch_users`.
