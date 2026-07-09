# Krista OS Final PRD

## Product Vision

The repository name is `krista-os`, but the product must be SaaS and white-label ready. The visible app name, logo, and theme must be configurable per clinic organization. Business logic must not hardcode "Krista OS" or any one clinic brand.

Version 1 focuses on clean operational structure, mock data, reusable UI, and future-ready domain models without connecting Supabase or creating a database yet.

## Multi-tenant SaaS Readiness

The system must support multiple clinic organizations in the future.

Requirements:

- One SaaS platform can host many clinic organizations.
- Each organization can have unlimited branches.
- Every organization-owned business record must support `organization_id`.
- Branch-level operational records must also support `branch_id`.
- Data must be separated by `organization_id` first and `branch_id` where relevant.
- Staff users may belong to one or more organizations and branches in the future.
- Reporting must be possible at organization level and branch level.

Current internal clinic organization has 4 initial branches:

- Korat
- Khon Kaen
- Kaeng Khro
- Chum Phae

These branches are seed/config data for the internal clinic only, not hardcoded platform assumptions.

## White-label Readiness

App branding must be configurable.

Organization settings should support:

- App name
- Legal clinic/company name
- Logo
- Theme color
- Secondary theme color
- Contact details
- Default language/timezone
- Future custom domain

Rules:

- Do not hardcode the product name in business logic.
- Use settings/config for display brand name and assets.
- Keep repository/package name separate from customer-facing app name.
- UI copy can use configured app name later.

## Patient Workflow

Primary patient journey:

Lead -> Booking -> Check-in -> Consultation -> Treatment Plan -> Payment -> Procedure -> Photo -> CRM -> Repeat Visit

Every future module should preserve this flow and allow handoff between clinical, sales, and CRM teams.

## Patient Communication Channels And LINE Readiness

Patient records must support multiple communication channels.

Supported channel types:

- LINE
- Facebook
- Instagram
- Phone
- Email
- TikTok Lead

Each patient channel should support:

- patient_id
- channel_type
- external_user_id
- display_name
- profile_url
- is_primary
- consent_to_contact
- marketing_opt_in
- last_contacted_at
- notes

LINE-specific future fields:

- line_user_id
- line_display_name
- line_picture_url
- line_oa_id
- line_connected_at

Do not implement the LINE API yet. The data model only needs to be ready for future LINE OA connection.

## Privacy And Consent

Patient data and marketing communication are sensitive.

The data model must support:

- Consent records
- Marketing opt-in tracking
- Communication history
- Audit logs
- Source and timestamp of consent
- Future revocation of consent

## Membership

Patients can register as clinic members.

Member levels:

- Standard
- Silver
- Gold
- Platinum

Member data should support:

- Total spending / LTV
- Points
- Member start date
- Member expiry date
- Member status on patient profile
- Future cashback
- Future discounts
- Future birthday benefits
- Future point redemption

## CRM Follow-up And LINE Workflow

CRM reminders/tasks should be generated from treatment history and repeat-cycle rules.

Example workflow:

Botox done -> follow-up due in 1, 2, 4 months -> CRM task created -> staff contacts patient via LINE -> status updated.

CRM task fields:

- patient_id
- branch_id
- assigned_staff_id
- related_treatment_id
- related_sale_id
- channel_type
- due_date
- status
- priority
- notes
- contacted_at
- outcome

CRM reminder status examples:

- pending
- contacted
- booked
- completed
- missed

Contact channel examples:

- LINE
- Phone
- Facebook
- Instagram
- Email
- SMS
- TikTok Lead

## Birthday CRM

The system should support birthday campaigns:

- Patients with birthday this month
- Patients with birthday next month
- Birthday benefit campaign creation
- Contacted / not contacted tracking
- Booked / not booked tracking
- Dashboard birthday CRM widget

## Treatment Repeat Cycle Rules

- Botox: repeat every 3-6 months
- Ultraformer: repeat every 6-12 months
- Oligio: repeat every 6-12 months
- Ulthera: repeat every 12-18 months
- Filler: repeat every 6-12 months
- Sculptra / collagen stimulator: repeat every 1-3 months

## Package And Balance Logic

Some packages are consumed in one visit, while injectable products may retain a balance.

Rules:

- Ultraformer 300 shots are usually consumed in one visit
- Oligio and Ulthera are usually consumed in one visit
- Botox can be partially used and remaining units stored for future use
- Filler can be partially used and remaining cc stored for future use
- System must support purchased quantity, used quantity, remaining quantity, and expiry

## Doctor Logic

- One treatment case has one doctor
- The same doctor handles consultation and procedure

## Sales Commission

- Sales commission is tier-based and may differ per person
- Version 1 only needs to track sales amount by each sale staff
- Commission calculation can be added later

## Inventory And Stock Movement

Inventory must support product records and stock movements.

Inventory item fields:

- Product name
- Category
- Brand
- Supplier
- Lot number
- Expiry date
- Unit cost
- Quantity
- Minimum stock alert
- Branch

Inventory movement types:

- stock_in
- stock_out
- adjustment
- expired
- damaged
- transfer_out
- transfer_in

## Stock Transfer Between Branches

Inventory must support transferring medicines/products between branches using proper transfer records and movement logs.

Do not simply delete stock from one branch and add to another.

Stock transfer workflow:

- requested
- approved
- shipped
- received
- cancelled

Each stock transfer must include:

- from_branch_id
- to_branch_id
- requested_by
- approved_by
- shipped_by
- received_by
- transfer_date
- received_date
- status
- notes

Each stock transfer item must include:

- product_id
- lot_number
- expiry_date
- quantity
- unit
- unit_cost

Transfer logic:

- `transfer_out` movement should reduce source branch stock when shipped or approved for shipping, depending on final operating policy.
- `transfer_in` movement should increase destination branch stock when received.
- Transfer records must connect the two movement logs for traceability.

## Opportunity Engine

Version 1 uses rule-based scoring, not machine learning.

Score inputs:

1. Repeat cycle due date
2. Treatment history
3. LTV
4. Visit frequency
5. Time since last visit
6. CRM response history
7. Cross-sell treatment relationship

Output fields:

- Recommended treatment
- Opportunity score 0-100
- Reason for recommendation
- Suggested CRM action
- Priority level: high, medium, low

Example rules:

- Botox done 4 months ago -> high Botox opportunity
- Filler done 10 months ago -> high Filler opportunity
- High LTV patient who did Filler but never did Oligio -> cross-sell Oligio
- Sculptra patient due in 1-3 months -> follow-up priority

## Dashboard Widgets

Dashboard should include:

- Revenue
- Cost
- Profit
- Treatment volume
- Top treatments
- Inventory alerts
- Doctor performance
- CRM due today
- CRM overdue
- Birthday patients this month
- Low stock alerts
- Membership summary
- Top member spending
- Opportunity Engine priorities

## Technical Scope For Current Skeleton

In scope now:

- PRD updates
- Domain model updates
- Multi-tenant and white-label readiness
- Mock-ready structure only

Out of scope until approval:

- Supabase connection
- Database schema SQL
- Authentication
- Real permissions enforcement
- External LINE API integration
- External service connections
- Machine learning
- Commission calculation
