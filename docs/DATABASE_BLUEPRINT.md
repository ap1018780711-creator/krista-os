# Domain Model And Database Blueprint

Sprint 1 scope: domain model and database blueprint only. SQL generation requires explicit approval.

The repository name is `krista-os`, but the customer-facing product name must be configurable. Business logic should use organization settings for app name, logo, and theme.

## Design Principles

- Multi-tenant first: organization-owned records include `organization_id`.
- Branch-aware operations: branch-level records include `branch_id` where operationally relevant.
- Normalize operational data and avoid duplicated business facts.
- Keep clinic, sales, inventory, CRM, and analytics data connected through stable IDs.
- Store package balances as ledger-style transactions.
- Support partial Botox unit usage and partial Filler cc usage.
- Use transfer records plus movement logs for branch stock transfers.
- Keep Opportunity Engine rule-based for V1 while preserving score explanations.
- Capture consent, communication history, and audit logs.
- Leave generic hooks for future AI modules.

## Tenant And Brand Boundary

- `organizations` represents a clinic company/customer tenant.
- `organization_settings` stores white-label brand settings.
- `branches` belong to organizations.
- Current internal organization starts with Korat, Khon Kaen, Kaeng Khro, and Chum Phae branches.
- Future organizations can have their own branches, brand settings, users, patients, inventory, CRM, and reports.

## ER Diagram Text Format

```text
organizations 1--1 organization_settings
organizations 1--* branches
organizations 1--* organization_users *--1 users
organizations 1--* roles
roles *--* permissions through role_permissions
users *--* roles through user_roles
branches 1--* branch_users *--1 users

organizations 1--* patients
branches 1--* patients as primary_branch
patients 1--* patient_channels
patients 1--* patient_consents
patients 1--* patient_memberships *--1 membership_levels
patients 1--* patient_workflow_events
patients 1--* communication_logs

patients 1--* leads
patients 1--* appointments
branches 1--* appointments
users 1--* appointments as doctor_or_staff
appointments 0..1--1 consultations
consultations 1--* treatment_plans

treatment_plans 1--* treatment_plan_items *--1 treatments
treatments *--1 treatment_categories
treatments 1--0..1 treatment_repeat_rules
treatments *--* treatments through treatment_cross_sell_rules
treatment_plan_items 0..1--1 treatment_cases
treatment_cases *--1 patients
treatment_cases *--1 users as doctor
treatment_cases *--1 treatments
treatment_cases 1--* procedures
procedures 1--* procedure_photos

patients 1--* sales_orders
branches 1--* sales_orders
sales_orders 1--* sales_order_items
sales_orders 1--* payments
sales_orders 1--* sales_staff_credits *--1 users
sales_order_items 0..1--1 patient_package_balances
patient_package_balances 1--* package_balance_transactions

organizations 1--* suppliers
organizations 1--* brands
organizations 1--* product_categories
organizations 1--* products
products 1--* product_lots
product_lots 1--* inventory_stocks *--1 branches
inventory_stocks 1--* stock_movements
stock_transfers 1--* stock_transfer_items
stock_transfers 1--* stock_movements as transfer_out_and_transfer_in

crm_rule_templates 1--* crm_tasks
patients 1--* crm_tasks
patient_channels 1--* crm_tasks as preferred_channel
crm_tasks 1--* crm_contact_attempts
crm_contact_attempts *--1 patient_channels
birthday_campaigns 1--* birthday_campaign_patients *--1 patients
birthday_campaign_patients 1--* crm_contact_attempts

opportunity_rules 1--* patient_opportunities
patients 1--* patient_opportunities
patient_opportunities *--1 treatments as recommended_treatment
patient_opportunities 1--* opportunity_score_factors
patient_opportunities 0..1--1 crm_tasks

audit_logs *--1 users
ai_modules 1--* ai_jobs 1--* ai_outputs
```

## Table List

### Tenant, Branding, And Access
1. organizations
2. organization_settings
3. branches
4. users
5. organization_users
6. branch_users
7. roles
8. permissions
9. user_roles
10. role_permissions

### Patient, Channels, Consent, And Membership
11. patients
12. patient_channels
13. patient_consents
14. communication_logs
15. membership_levels
16. patient_memberships
17. patient_workflow_events

### Appointment And Clinical Workflow
18. leads
19. appointments
20. consultations
21. treatment_categories
22. treatments
23. treatment_repeat_rules
24. treatment_cross_sell_rules
25. treatment_plans
26. treatment_plan_items
27. treatment_cases
28. procedures
29. procedure_photos

### Sales And Package Balances
30. sales_orders
31. sales_order_items
32. payments
33. sales_staff_credits
34. patient_package_balances
35. package_balance_transactions

### Inventory And Stock Transfer
36. suppliers
37. brands
38. product_categories
39. products
40. product_lots
41. inventory_stocks
42. stock_transfers
43. stock_transfer_items
44. stock_movements

### CRM And Birthday CRM
45. crm_rule_templates
46. crm_tasks
47. crm_contact_attempts
48. birthday_campaigns
49. birthday_campaign_patients

### Opportunity Engine
50. opportunity_rules
51. patient_opportunities
52. opportunity_score_factors

### Audit And Future AI
53. audit_logs
54. ai_modules
55. ai_jobs
56. ai_outputs

## Primary Keys

All tables use `id uuid` as the primary key unless explicitly revised during SQL design.

## Tenant Key Rules

- Every tenant-owned table includes `organization_id`.
- Every branch-operational table includes `branch_id` or source/destination branch references.
- Join tables that assign users to organizations or branches include both sides as foreign keys.
- Cross-tenant joins are never allowed in application logic.
- Recommended row-level security later should scope by `organization_id`, then branch access.

## Core Relationships

- One organization has one organization_settings record and many branches.
- One organization has many users through organization_users.
- Users can be assigned to many branches through branch_users.
- Organization-level roles can be assigned to users through user_roles.
- A patient belongs to one organization and has a primary branch.
- A patient can have many communication channels and consent records.
- CRM tasks can reference the intended patient channel.
- A stock transfer moves inventory from one branch to another through stock_transfer and stock_transfer_items records.
- Stock transfer does not delete stock directly; it creates movement logs: transfer_out and transfer_in.
- Opportunity records can generate CRM tasks but remain explainable through score factors.

## Foreign Keys Summary

| Table | Foreign Keys |
| --- | --- |
| organization_settings | organization_id -> organizations.id |
| branches | organization_id -> organizations.id |
| organization_users | organization_id -> organizations.id; user_id -> users.id |
| branch_users | organization_id -> organizations.id; branch_id -> branches.id; user_id -> users.id |
| roles | organization_id -> organizations.id |
| user_roles | organization_id -> organizations.id; user_id -> users.id; role_id -> roles.id |
| role_permissions | role_id -> roles.id; permission_id -> permissions.id |
| patients | organization_id -> organizations.id; primary_branch_id -> branches.id |
| patient_channels | organization_id -> organizations.id; patient_id -> patients.id |
| patient_consents | organization_id -> organizations.id; patient_id -> patients.id; channel_id -> patient_channels.id |
| communication_logs | organization_id -> organizations.id; patient_id -> patients.id; channel_id -> patient_channels.id; staff_user_id -> users.id |
| membership_levels | organization_id -> organizations.id |
| patient_memberships | organization_id -> organizations.id; patient_id -> patients.id; membership_level_id -> membership_levels.id |
| patient_workflow_events | organization_id -> organizations.id; patient_id -> patients.id; branch_id -> branches.id; actor_user_id -> users.id |
| leads | organization_id -> organizations.id; patient_id -> patients.id; branch_id -> branches.id; assigned_staff_id -> users.id |
| appointments | organization_id -> organizations.id; patient_id -> patients.id; branch_id -> branches.id; doctor_user_id -> users.id; assigned_staff_id -> users.id |
| consultations | organization_id -> organizations.id; appointment_id -> appointments.id; patient_id -> patients.id; doctor_user_id -> users.id |
| treatment_categories | organization_id -> organizations.id; parent_category_id -> treatment_categories.id |
| treatments | organization_id -> organizations.id; category_id -> treatment_categories.id |
| treatment_repeat_rules | organization_id -> organizations.id; treatment_id -> treatments.id |
| treatment_cross_sell_rules | organization_id -> organizations.id; source_treatment_id -> treatments.id; recommended_treatment_id -> treatments.id |
| treatment_plans | organization_id -> organizations.id; consultation_id -> consultations.id; patient_id -> patients.id; doctor_user_id -> users.id |
| treatment_plan_items | organization_id -> organizations.id; treatment_plan_id -> treatment_plans.id; treatment_id -> treatments.id |
| treatment_cases | organization_id -> organizations.id; patient_id -> patients.id; branch_id -> branches.id; treatment_id -> treatments.id; doctor_user_id -> users.id; treatment_plan_item_id -> treatment_plan_items.id |
| procedures | organization_id -> organizations.id; treatment_case_id -> treatment_cases.id; doctor_user_id -> users.id |
| procedure_photos | organization_id -> organizations.id; procedure_id -> procedures.id; patient_id -> patients.id; uploaded_by_user_id -> users.id |
| sales_orders | organization_id -> organizations.id; patient_id -> patients.id; branch_id -> branches.id; created_by_user_id -> users.id |
| sales_order_items | organization_id -> organizations.id; sales_order_id -> sales_orders.id; treatment_id -> treatments.id |
| payments | organization_id -> organizations.id; sales_order_id -> sales_orders.id; received_by_user_id -> users.id |
| sales_staff_credits | organization_id -> organizations.id; sales_order_id -> sales_orders.id; staff_user_id -> users.id |
| patient_package_balances | organization_id -> organizations.id; patient_id -> patients.id; treatment_id -> treatments.id; sales_order_item_id -> sales_order_items.id |
| package_balance_transactions | organization_id -> organizations.id; package_balance_id -> patient_package_balances.id; treatment_case_id -> treatment_cases.id; actor_user_id -> users.id |
| suppliers | organization_id -> organizations.id |
| brands | organization_id -> organizations.id |
| product_categories | organization_id -> organizations.id |
| products | organization_id -> organizations.id; category_id -> product_categories.id; brand_id -> brands.id; supplier_id -> suppliers.id |
| product_lots | organization_id -> organizations.id; product_id -> products.id |
| inventory_stocks | organization_id -> organizations.id; product_lot_id -> product_lots.id; branch_id -> branches.id |
| stock_transfers | organization_id -> organizations.id; from_branch_id -> branches.id; to_branch_id -> branches.id; requested_by -> users.id; approved_by -> users.id; shipped_by -> users.id; received_by -> users.id |
| stock_transfer_items | organization_id -> organizations.id; stock_transfer_id -> stock_transfers.id; product_id -> products.id |
| stock_movements | organization_id -> organizations.id; inventory_stock_id -> inventory_stocks.id; stock_transfer_id -> stock_transfers.id; stock_transfer_item_id -> stock_transfer_items.id; source_branch_id -> branches.id; destination_branch_id -> branches.id; actor_user_id -> users.id |
| crm_rule_templates | organization_id -> organizations.id; treatment_id -> treatments.id |
| crm_tasks | organization_id -> organizations.id; patient_id -> patients.id; branch_id -> branches.id; assigned_staff_id -> users.id; related_treatment_id -> treatments.id; related_sale_id -> sales_orders.id; patient_channel_id -> patient_channels.id; crm_rule_template_id -> crm_rule_templates.id |
| crm_contact_attempts | organization_id -> organizations.id; crm_task_id -> crm_tasks.id; patient_channel_id -> patient_channels.id; contacted_by_user_id -> users.id; birthday_campaign_patient_id -> birthday_campaign_patients.id |
| birthday_campaigns | organization_id -> organizations.id; branch_id -> branches.id; created_by_user_id -> users.id |
| birthday_campaign_patients | organization_id -> organizations.id; birthday_campaign_id -> birthday_campaigns.id; patient_id -> patients.id; assigned_staff_id -> users.id |
| opportunity_rules | organization_id -> organizations.id; recommended_treatment_id -> treatments.id |
| patient_opportunities | organization_id -> organizations.id; patient_id -> patients.id; recommended_treatment_id -> treatments.id; opportunity_rule_id -> opportunity_rules.id; crm_task_id -> crm_tasks.id |
| opportunity_score_factors | organization_id -> organizations.id; patient_opportunity_id -> patient_opportunities.id |
| audit_logs | organization_id -> organizations.id; actor_user_id -> users.id |
| ai_modules | organization_id -> organizations.id |
| ai_jobs | organization_id -> organizations.id; ai_module_id -> ai_modules.id; requested_by_user_id -> users.id |
| ai_outputs | organization_id -> organizations.id; ai_job_id -> ai_jobs.id |

## Index Recommendations

### Global

- Index every foreign key.
- Add composite indexes beginning with `organization_id` on tenant-owned tables.
- Add `organization_id, branch_id, date` indexes for operational reporting.
- Use unique indexes scoped by organization, e.g. unique(organization_id, code).
- Use partial indexes for active/open records where supported.
- Use status/date indexes for queues: CRM tasks, transfers, appointments, opportunities.

| Area | Recommended Indexes |
| --- | --- |
| Tenant | organizations unique(slug), organization_settings unique(organization_id), branches unique(organization_id, code) |
| Access | organization_users unique(organization_id, user_id), branch_users unique(organization_id, branch_id, user_id), roles unique(organization_id, code) |
| Patients | patients index(organization_id, primary_branch_id), index(organization_id, phone), index(organization_id, date_of_birth), index(organization_id, status) |
| Channels | patient_channels index(organization_id, patient_id), unique(organization_id, channel_type, external_user_id), index(organization_id, channel_type, marketing_opt_in) |
| Consent | patient_consents index(organization_id, patient_id, consent_type), index(organization_id, status, granted_at) |
| Communication | communication_logs index(organization_id, patient_id, communicated_at), index(organization_id, channel_type, communicated_at) |
| Membership | membership_levels unique(organization_id, code), patient_memberships index(organization_id, patient_id, status), index(organization_id, expiry_date) |
| Workflow | patient_workflow_events index(organization_id, patient_id, occurred_at), index(organization_id, branch_id, stage, occurred_at) |
| Clinical | appointments index(organization_id, branch_id, scheduled_at), treatment_cases index(organization_id, patient_id, treatment_date), index(organization_id, doctor_user_id, treatment_date) |
| Sales | sales_orders index(organization_id, branch_id, order_date), unique(organization_id, order_number), sales_staff_credits index(organization_id, staff_user_id, credited_at) |
| Package Balance | patient_package_balances index(organization_id, patient_id, status), index(organization_id, expiry_date), package_balance_transactions index(organization_id, package_balance_id, transaction_at) |
| Inventory | products unique(organization_id, sku), product_lots unique(organization_id, product_id, lot_number), inventory_stocks unique(organization_id, product_lot_id, branch_id) |
| Transfers | stock_transfers index(organization_id, status, transfer_date), index(organization_id, from_branch_id, status), index(organization_id, to_branch_id, status) |
| Stock Movements | stock_movements index(organization_id, inventory_stock_id, movement_at), index(organization_id, source_branch_id, movement_at), index(organization_id, destination_branch_id, movement_at), index(organization_id, type) |
| CRM | crm_tasks index(organization_id, branch_id, due_date), index(organization_id, assigned_staff_id, due_date), index(organization_id, status, priority, due_date), index(organization_id, patient_channel_id) |
| Birthday CRM | birthday_campaigns index(organization_id, branch_id, campaign_month), birthday_campaign_patients unique(organization_id, birthday_campaign_id, patient_id) |
| Opportunities | patient_opportunities index(organization_id, patient_id, generated_at), index(organization_id, priority, score), index(organization_id, status) |
| Audit | audit_logs index(organization_id, actor_user_id, occurred_at), index(organization_id, entity_table, entity_id) |
| AI | ai_jobs index(organization_id, ai_module_id, status, created_at), index(organization_id, entity_table, entity_id) |

## Data Dictionary

Format: `column:type - notes`. All tables include `id:uuid PK`. Most tenant-owned tables include `organization_id:uuid FK`.

### organizations
- id:uuid - tenant primary key
- slug:text - unique tenant slug
- legal_name:text - legal clinic/company name
- status:enum - active, suspended, cancelled, trial
- default_timezone:text - tenant default timezone
- default_locale:text - tenant default language/locale
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### organization_settings
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- app_name:text - configurable app/brand name
- logo_url:text - configurable logo asset
- theme_primary_color:text - primary brand color
- theme_secondary_color:text - secondary brand color
- contact_phone:text - public contact phone
- contact_email:text - public contact email
- custom_domain:text - future white-label domain
- settings_json:jsonb - future configurable settings
- updated_at:timestamptz - last update timestamp

### branches
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- code:text - branch code unique within organization
- name:text - branch name, e.g. Korat
- address:text - optional full address
- phone:text - branch phone
- is_active:boolean - active/closed branch flag
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### users
- id:uuid - primary key
- full_name:text - person name
- email:text - unique login/contact email when present
- phone:text - phone when present
- global_user_type:enum - human, system, platform_admin
- is_active:boolean - account status
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### organization_users
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- user_id:uuid - FK to users
- organization_user_type:enum - owner, doctor, manager, staff, accountant, crm, system
- is_active:boolean - tenant membership status
- created_at:timestamptz - assignment timestamp

### branch_users
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- branch_id:uuid - FK to branches
- user_id:uuid - FK to users
- is_primary:boolean - user's main branch for organization
- created_at:timestamptz - assignment timestamp

### roles
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- code:text - role code unique within organization
- name:text - display name
- description:text - role purpose
- created_at:timestamptz - creation timestamp

### permissions
- id:uuid - primary key
- code:text - platform-level permission code
- description:text - permission purpose
- created_at:timestamptz - creation timestamp

### user_roles
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- user_id:uuid - FK to users
- role_id:uuid - FK to roles
- created_at:timestamptz - assignment timestamp

### role_permissions
- id:uuid - primary key
- role_id:uuid - FK to roles
- permission_id:uuid - FK to permissions
- created_at:timestamptz - assignment timestamp

### patients
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- primary_branch_id:uuid - FK to branches
- patient_code:text - human-friendly code scoped to organization
- full_name:text - patient name
- phone:text - main phone snapshot
- email:text - main email snapshot
- date_of_birth:date - birthday CRM input
- gender:text - optional profile field
- source:text - lead/customer source
- status:enum - lead, active, inactive, archived
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### patient_channels
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- channel_type:enum - LINE, Facebook, Instagram, Phone, Email, TikTok Lead
- external_user_id:text - external platform user ID
- display_name:text - platform display name
- profile_url:text - external profile URL
- is_primary:boolean - preferred channel flag
- consent_to_contact:boolean - contact consent summary
- marketing_opt_in:boolean - marketing permission summary
- last_contacted_at:timestamptz - last communication timestamp
- notes:text - channel notes
- line_user_id:text - future LINE user ID
- line_display_name:text - future LINE display name
- line_picture_url:text - future LINE profile image
- line_oa_id:text - future LINE OA identifier
- line_connected_at:timestamptz - future LINE connection timestamp
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### patient_consents
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- channel_id:uuid - FK to patient_channels, nullable for general consent
- consent_type:enum - treatment, privacy, marketing, photo, communication
- status:enum - granted, revoked, expired
- source:text - form, staff, LINE, website, import
- granted_at:timestamptz - consent granted timestamp
- revoked_at:timestamptz - consent revoked timestamp
- evidence_url:text - optional consent proof storage path
- notes:text - consent notes

### communication_logs
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- channel_id:uuid - FK to patient_channels
- staff_user_id:uuid - FK to users
- channel_type:enum - LINE, Facebook, Instagram, Phone, Email, TikTok Lead, SMS
- direction:enum - inbound, outbound
- message_summary:text - summary, not full sensitive content by default
- outcome:enum - contacted, no_answer, booked, declined, completed, other
- communicated_at:timestamptz - communication timestamp
- related_entity_table:text - optional source table
- related_entity_id:uuid - optional source record ID

### membership_levels
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- code:text - standard, silver, gold, platinum
- name:text - display name
- rank:integer - upgrade order
- min_ltv:numeric - optional qualification threshold
- points_multiplier:numeric - future points logic
- benefits_json:jsonb - future cashback, discounts, birthday benefits, redemption config
- is_active:boolean - level availability

### patient_memberships
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- membership_level_id:uuid - FK to membership_levels
- total_spending_ltv:numeric - LTV snapshot
- points_balance:numeric - current points balance
- start_date:date - membership start
- expiry_date:date - membership expiry
- status:enum - active, expired, suspended, cancelled
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### patient_workflow_events
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- branch_id:uuid - FK to branches
- stage:enum - lead, booking, check_in, consultation, treatment_plan, payment, procedure, photo, crm, repeat_visit
- source_table:text - optional source entity table
- source_id:uuid - optional source entity ID
- actor_user_id:uuid - FK to users
- occurred_at:timestamptz - stage timestamp
- notes:text - workflow notes

### leads
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- branch_id:uuid - FK to branches
- assigned_staff_id:uuid - FK to users
- source:text - ads, referral, walk-in, TikTok Lead, etc.
- status:enum - new, contacted, booked, lost, converted
- created_at:timestamptz - lead timestamp
- converted_at:timestamptz - conversion timestamp
- notes:text - lead notes

### appointments
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- branch_id:uuid - FK to branches
- doctor_user_id:uuid - FK to users, optional until assigned
- assigned_staff_id:uuid - FK to users
- scheduled_at:timestamptz - appointment time
- status:enum - booked, confirmed, checked_in, completed, cancelled, no_show
- appointment_type:enum - consultation, procedure, follow_up, review
- notes:text - booking notes
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### consultations
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- appointment_id:uuid - FK to appointments
- patient_id:uuid - FK to patients
- doctor_user_id:uuid - FK to users
- consultation_at:timestamptz - consultation timestamp
- concern_notes:text - patient concerns
- diagnosis_notes:text - doctor notes
- recommended_plan_notes:text - recommendation summary
- created_at:timestamptz - creation timestamp

### treatment_categories
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- parent_category_id:uuid - self FK for hierarchy
- code:text - category code unique within organization
- name:text - category name
- created_at:timestamptz - creation timestamp

### treatments
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- category_id:uuid - FK to treatment_categories
- code:text - treatment code unique within organization
- name:text - treatment name
- default_unit:enum - session, unit, cc, shot, vial
- balance_tracking_type:enum - none, units, cc, shots, sessions
- is_partial_usage_allowed:boolean - true for Botox/Filler style balances
- is_active:boolean - treatment availability
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### treatment_repeat_rules
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- treatment_id:uuid - FK to treatments
- min_months:integer - earliest repeat timing
- max_months:integer - latest repeat timing
- default_follow_up_days:integer - default CRM reminder offset
- notes:text - rule notes
- is_active:boolean - rule availability

### treatment_cross_sell_rules
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- source_treatment_id:uuid - FK to treatments
- recommended_treatment_id:uuid - FK to treatments
- weight:integer - scoring weight
- reason_template:text - opportunity explanation template
- is_active:boolean - rule availability

### treatment_plans
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- consultation_id:uuid - FK to consultations
- patient_id:uuid - FK to patients
- doctor_user_id:uuid - FK to users
- status:enum - draft, proposed, accepted, declined, expired
- plan_notes:text - plan summary
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### treatment_plan_items
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- treatment_plan_id:uuid - FK to treatment_plans
- treatment_id:uuid - FK to treatments
- recommended_quantity:numeric - suggested quantity
- unit:text - unit, cc, shots, session
- quoted_price:numeric - proposed price
- status:enum - proposed, accepted, declined
- notes:text - item notes

### treatment_cases
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- branch_id:uuid - FK to branches
- treatment_id:uuid - FK to treatments
- doctor_user_id:uuid - FK to users; same doctor handles consultation and procedure
- treatment_plan_item_id:uuid - FK to treatment_plan_items
- treatment_date:date - case date
- status:enum - planned, paid, in_progress, completed, cancelled
- clinical_notes:text - treatment notes
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### procedures
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- treatment_case_id:uuid - FK to treatment_cases
- doctor_user_id:uuid - FK to users
- procedure_at:timestamptz - procedure timestamp
- used_quantity:numeric - quantity consumed in this procedure
- unit:text - unit, cc, shots, session
- notes:text - procedure notes
- created_at:timestamptz - creation timestamp

### procedure_photos
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- procedure_id:uuid - FK to procedures
- patient_id:uuid - FK to patients
- photo_type:enum - before, after, progress, consent
- storage_path:text - future file storage path
- uploaded_by_user_id:uuid - FK to users
- captured_at:timestamptz - photo capture time
- created_at:timestamptz - creation timestamp

### sales_orders
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- branch_id:uuid - FK to branches
- created_by_user_id:uuid - FK to users
- order_number:text - human-friendly order number scoped to organization
- order_date:date - sale date
- subtotal_amount:numeric - before discount/tax
- discount_amount:numeric - discount amount
- total_amount:numeric - final amount
- status:enum - draft, confirmed, paid, refunded, cancelled
- created_at:timestamptz - creation timestamp

### sales_order_items
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- sales_order_id:uuid - FK to sales_orders
- treatment_id:uuid - FK to treatments
- description:text - line item label
- quantity:numeric - purchased quantity
- unit:text - unit, cc, shots, session
- unit_price:numeric - unit price
- line_total:numeric - line total
- creates_package_balance:boolean - true when balance should be tracked
- expiry_date:date - package expiry when applicable

### payments
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- sales_order_id:uuid - FK to sales_orders
- received_by_user_id:uuid - FK to users
- payment_date:timestamptz - payment timestamp
- method:enum - cash, card, transfer, financing, other
- amount:numeric - payment amount
- reference_number:text - optional external reference
- status:enum - pending, paid, voided, refunded

### sales_staff_credits
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- sales_order_id:uuid - FK to sales_orders
- staff_user_id:uuid - FK to users
- credited_amount:numeric - sales amount credited to staff
- credited_at:timestamptz - credit timestamp
- notes:text - commission calculation deferred

### patient_package_balances
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- treatment_id:uuid - FK to treatments
- sales_order_item_id:uuid - FK to sales_order_items
- original_quantity:numeric - purchased quantity
- used_quantity:numeric - cached used quantity from ledger
- remaining_quantity:numeric - cached remaining quantity from ledger
- unit:text - unit, cc, shots, session
- expiry_date:date - package/balance expiry
- status:enum - active, exhausted, expired, cancelled
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### package_balance_transactions
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- package_balance_id:uuid - FK to patient_package_balances
- treatment_case_id:uuid - FK to treatment_cases, nullable for purchase/adjustment
- actor_user_id:uuid - FK to users
- type:enum - purchase, usage, adjustment, expiry, refund
- quantity_delta:numeric - positive for purchase/add, negative for usage/reduction
- transaction_at:timestamptz - transaction timestamp
- notes:text - reason or clinical reference

### suppliers
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- name:text - supplier name
- contact_name:text - optional contact person
- phone:text - supplier phone
- email:text - supplier email
- is_active:boolean - supplier availability

### brands
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- name:text - brand name unique within organization
- created_at:timestamptz - creation timestamp

### product_categories
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- code:text - unique product category code within organization
- name:text - category name
- created_at:timestamptz - creation timestamp

### products
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- category_id:uuid - FK to product_categories
- brand_id:uuid - FK to brands
- supplier_id:uuid - FK to suppliers
- sku:text - unique product SKU within organization
- product_name:text - product name
- default_unit:text - vial, box, tube, piece, etc.
- unit_cost:numeric - default cost before lot overrides
- is_active:boolean - product availability
- created_at:timestamptz - creation timestamp

### product_lots
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- product_id:uuid - FK to products
- lot_number:text - supplier/manufacturer lot
- expiry_date:date - lot expiry
- unit_cost:numeric - lot-specific cost
- created_at:timestamptz - creation timestamp

### inventory_stocks
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- product_lot_id:uuid - FK to product_lots
- branch_id:uuid - FK to branches
- quantity_on_hand:numeric - current stock snapshot
- minimum_stock_alert:numeric - branch-level alert threshold
- updated_at:timestamptz - last stock update timestamp

### stock_transfers
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- from_branch_id:uuid - FK to branches
- to_branch_id:uuid - FK to branches
- requested_by:uuid - FK to users
- approved_by:uuid - FK to users, nullable until approved
- shipped_by:uuid - FK to users, nullable until shipped
- received_by:uuid - FK to users, nullable until received
- transfer_date:date - requested/shipped transfer date based on policy
- received_date:date - received date
- status:enum - requested, approved, shipped, received, cancelled
- notes:text - transfer notes
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### stock_transfer_items
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- stock_transfer_id:uuid - FK to stock_transfers
- product_id:uuid - FK to products
- lot_number:text - transferred lot number snapshot
- expiry_date:date - transferred lot expiry snapshot
- quantity:numeric - transferred quantity
- unit:text - transfer unit
- unit_cost:numeric - unit cost snapshot
- notes:text - item notes

### stock_movements
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- inventory_stock_id:uuid - FK to inventory_stocks
- stock_transfer_id:uuid - FK to stock_transfers, nullable
- stock_transfer_item_id:uuid - FK to stock_transfer_items, nullable
- source_branch_id:uuid - FK to branches
- destination_branch_id:uuid - FK to branches, used for transfers
- actor_user_id:uuid - FK to users
- type:enum - stock_in, stock_out, adjustment, expired, damaged, transfer_out, transfer_in
- quantity_delta:numeric - positive or negative stock movement
- movement_at:timestamptz - movement timestamp
- reference_type:text - optional source document type
- reference_id:uuid - optional source document ID
- notes:text - movement reason

### crm_rule_templates
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- treatment_id:uuid - FK to treatments, nullable for general rules
- name:text - rule name
- offset_days:integer - days after trigger event
- trigger_event:enum - procedure_completed, package_expiring, birthday, opportunity_generated, manual
- default_channel_type:enum - LINE, Facebook, Instagram, Phone, Email, TikTok Lead, SMS
- is_active:boolean - rule availability
- created_at:timestamptz - creation timestamp

### crm_tasks
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- branch_id:uuid - FK to branches
- assigned_staff_id:uuid - FK to users
- related_treatment_id:uuid - FK to treatments
- related_sale_id:uuid - FK to sales_orders
- patient_channel_id:uuid - FK to patient_channels
- crm_rule_template_id:uuid - FK to crm_rule_templates
- channel_type:enum - LINE, Facebook, Instagram, Phone, Email, TikTok Lead, SMS
- due_date:date - CRM due date
- status:enum - pending, contacted, booked, completed, missed
- priority:enum - high, medium, low
- notes:text - task notes
- contacted_at:timestamptz - last contacted timestamp
- outcome:enum - no_answer, contacted, booked, declined, completed, missed
- created_at:timestamptz - creation timestamp
- updated_at:timestamptz - last update timestamp

### crm_contact_attempts
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- crm_task_id:uuid - FK to crm_tasks
- patient_channel_id:uuid - FK to patient_channels
- birthday_campaign_patient_id:uuid - FK to birthday_campaign_patients, nullable
- contacted_by_user_id:uuid - FK to users
- channel_type:enum - LINE, Facebook, Instagram, Phone, Email, TikTok Lead, SMS
- outcome:enum - no_answer, contacted, booked, declined, completed
- contacted_at:timestamptz - contact timestamp
- notes:text - contact notes

### birthday_campaigns
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- branch_id:uuid - FK to branches, nullable for all-branch campaigns
- campaign_month:date - first day of campaign month
- name:text - campaign name
- benefit_description:text - birthday benefit details
- status:enum - draft, active, completed, cancelled
- created_by_user_id:uuid - FK to users
- created_at:timestamptz - creation timestamp

### birthday_campaign_patients
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- birthday_campaign_id:uuid - FK to birthday_campaigns
- patient_id:uuid - FK to patients
- assigned_staff_id:uuid - FK to users
- contacted_status:enum - not_contacted, contacted
- booked_status:enum - not_booked, booked
- birthday_date:date - patient birthday occurrence for campaign year
- notes:text - campaign notes
- updated_at:timestamptz - last update timestamp

### opportunity_rules
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- code:text - unique rule code within organization
- name:text - rule name
- recommended_treatment_id:uuid - FK to treatments
- rule_type:enum - repeat_cycle, cross_sell, ltv, visit_frequency, crm_response, last_visit_gap
- weight:integer - contribution to 0-100 score
- priority_default:enum - high, medium, low
- reason_template:text - explanation template
- is_active:boolean - rule availability
- created_at:timestamptz - creation timestamp

### patient_opportunities
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_id:uuid - FK to patients
- recommended_treatment_id:uuid - FK to treatments
- opportunity_rule_id:uuid - FK to opportunity_rules
- crm_task_id:uuid - FK to crm_tasks, nullable until CRM created
- score:integer - 0-100 opportunity score
- priority:enum - high, medium, low
- reason:text - recommendation reason
- suggested_crm_action:text - next best CRM action
- status:enum - open, assigned, contacted, booked, dismissed, completed
- generated_at:timestamptz - score generation timestamp
- expires_at:timestamptz - optional opportunity expiry

### opportunity_score_factors
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- patient_opportunity_id:uuid - FK to patient_opportunities
- factor_type:enum - repeat_due, treatment_history, ltv, visit_frequency, last_visit_gap, crm_response, cross_sell
- factor_value:text - stored input summary
- score_contribution:integer - points added or subtracted
- explanation:text - why factor affected score

### audit_logs
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- actor_user_id:uuid - FK to users, nullable for system jobs
- action:text - created, updated, deleted, status_changed, consent_changed, transfer_status_changed, etc.
- entity_table:text - target table name
- entity_id:uuid - target record ID
- before_json:jsonb - optional before snapshot
- after_json:jsonb - optional after snapshot
- ip_address:text - optional request IP
- user_agent:text - optional client info
- occurred_at:timestamptz - audit timestamp

### ai_modules
- id:uuid - primary key
- organization_id:uuid - FK to organizations, nullable if platform-level module
- code:text - unique AI module code
- name:text - module display name
- description:text - module purpose
- is_active:boolean - availability
- created_at:timestamptz - creation timestamp

### ai_jobs
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- ai_module_id:uuid - FK to ai_modules
- requested_by_user_id:uuid - FK to users
- entity_table:text - optional target/source table
- entity_id:uuid - optional target/source record ID
- input_json:jsonb - input payload snapshot
- status:enum - queued, running, succeeded, failed, cancelled
- created_at:timestamptz - job creation timestamp
- completed_at:timestamptz - job completion timestamp

### ai_outputs
- id:uuid - primary key
- organization_id:uuid - FK to organizations
- ai_job_id:uuid - FK to ai_jobs
- output_type:text - summary, recommendation, classification, draft_message, etc.
- output_json:jsonb - structured AI output
- confidence_score:numeric - optional confidence
- created_at:timestamptz - output creation timestamp

## SQL Generation Status

SQL has not been generated. Generate SQL only after explicit approval.
