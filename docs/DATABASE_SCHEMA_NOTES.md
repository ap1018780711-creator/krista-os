# Database Schema Notes

## Scope

Generated files are PostgreSQL / Supabase-compatible SQL files only. They are not executed and do not connect to Supabase.

Created files:

- `supabase/migrations/001_initial_schema.sql`
- `supabase/seed/001_seed_demo_data.sql`
- `docs/DATABASE_SCHEMA_NOTES.md`

## Multi-tenant Strategy

The schema is designed for SaaS and white-label use.

- `organizations` is the tenant table.
- `organization_settings` stores configurable app name, logo, theme colors, contact info, and future custom domain.
- Most business tables include `organization_id`.
- Branch-level operations include `branch_id` or source/destination branch fields.
- Unique constraints are scoped by organization where appropriate, for example `unique (organization_id, code)`.

## White-label Strategy

The repository can remain named `krista-os`, but business logic should not hardcode the product name.

Future frontend/app code should read:

- `organization_settings.app_name`
- `organization_settings.logo_url`
- `organization_settings.theme_primary_color`
- `organization_settings.theme_secondary_color`
- `organization_settings.custom_domain`

## Branches

Seed data creates one demo organization with four branches:

- Korat
- Khon Kaen
- Kaeng Khro
- Chum Phae

The schema supports unlimited branches per organization.

## Inventory And Stock Transfer

Inventory uses:

- `products`
- `product_lots`
- `inventory_stocks`
- `stock_transfers`
- `stock_transfer_items`
- `stock_movements`

Stock transfer statuses:

- requested
- approved
- shipped
- received
- cancelled

Transfer movement rules:

- Use `transfer_out` to reduce source branch stock.
- Use `transfer_in` to increase destination branch stock.
- Do not delete stock from one branch and manually add to another.
- Link transfer movement rows to `stock_transfer_id` and `stock_transfer_item_id` for traceability.

The migration does not include automatic stock quantity update triggers yet. That should be added after the operational policy is approved, because clinics may choose whether stock is reduced on approval, shipment, or receipt.

## Patient Channels And LINE Readiness

Patient communication channels are modeled in `patient_channels`.

Supported channel types include:

- LINE
- Facebook
- Instagram
- Phone
- Email
- TikTok Lead
- SMS

LINE-ready fields are included:

- `line_user_id`
- `line_display_name`
- `line_picture_url`
- `line_oa_id`
- `line_connected_at`

No LINE API connection is implemented.

## CRM Workflow

CRM automation uses:

- `crm_rule_templates`
- `crm_tasks`
- `crm_contact_attempts`
- `communication_logs`

A CRM task can reference:

- patient
- branch
- assigned staff
- related treatment
- related sale
- patient channel/contact method
- due date
- status
- priority
- outcome

This supports the flow: treatment completed -> CRM task generated -> staff contacts patient through LINE or another channel -> status/outcome updated.

## Package Balances And Partial Usage

Package balances use:

- `patient_package_balances`
- `package_balance_transactions`

Botox and Filler can support partial usage because treatments can be configured with:

- `balance_tracking_type = units` for Botox
- `balance_tracking_type = cc` for Filler
- `is_partial_usage_allowed = true`

Device treatments such as Ultraformer, Oligio, and Ulthera can still be tracked as package/treatment history, but are usually consumed per visit.

The balance table stores snapshots for performance, while the transaction table is the source of truth.

## Opportunity Engine

Opportunity Engine starts as rule-based scoring only.

Tables:

- `opportunity_rules`
- `patient_opportunities`
- `opportunity_score_factors`

No machine learning is implemented.

## Finance And Marketing

Finance support includes:

- `sales_orders`
- `sales_order_items`
- `payments`
- `sales_staff_credits`
- `expense_categories`
- `expenses`

Marketing support includes:

- `marketing_campaigns`
- `marketing_campaign_channels`
- birthday CRM tables
- patient channel opt-in and consent records

Commission calculation is not implemented. V1 tracks sales amount by staff through `sales_staff_credits`.

## Audit Logs

`audit_logs` is included for future traceability of sensitive operations.

Recommended audit targets:

- patient profile changes
- consent changes
- package balance changes
- stock transfers and stock movements
- CRM outcome changes
- payment and expense changes
- role/permission changes

## Future RLS Strategy

Row Level Security is intentionally not enabled yet.

When authentication and tenant session context are ready, enable RLS table-by-table with a strategy like:

1. Store the current organization context in a JWT claim, for example `organization_id`.
2. Store branch access in a claim or validate through `branch_users`.
3. For tenant tables, enforce `organization_id = auth.jwt()->>'organization_id'`.
4. For branch-operational tables, enforce both organization scope and branch access.
5. Keep platform-admin access separate from clinic-user access.
6. Add stricter policies for sensitive tables such as consents, audit logs, payments, expenses, and photos.
7. Use service-role access only for trusted backend jobs and automation.

RLS was not enabled in the migration to avoid locking development workflows before authentication design is finalized.

## Assumptions

- UUIDs use `gen_random_uuid()` from `pgcrypto`.
- All monetary values use `numeric(14,2)`.
- Quantity values use `numeric` to support units, cc, shots, sessions, and fractional usage.
- Organization-level data separation is mandatory for future SaaS usage.
- Branch-level restrictions will be enforced later through RLS and application policy.
- Stock quantity snapshots are stored in `inventory_stocks`, while `stock_movements` is the movement ledger.
- Patient channel records can contain external IDs but do not connect to external APIs yet.
- AI tables are generic future hooks, not active AI functionality.

## Doctor Fees

Pre-execution review added dedicated doctor fee tables:

- `doctor_fee_rules`
- `doctor_fee_entries`

Doctor fees are intentionally separate from:

- sales staff credits / commission tracking
- expenses
- payments

This keeps doctor payout review independent while still allowing links to doctor, treatment, treatment case, branch, and sale.
