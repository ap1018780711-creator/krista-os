-- Demo seed data for one organization with four branches.
-- Do not execute against production without review.

insert into organizations (id, slug, legal_name, status, default_timezone, default_locale)
values ('00000000-0000-0000-0000-000000000001', 'krista-internal', 'Krista Clinic Internal Demo', 'active', 'Asia/Bangkok', 'th-TH')
on conflict (slug) do nothing;

insert into organization_settings (id, organization_id, app_name, logo_url, theme_primary_color, theme_secondary_color, contact_phone, contact_email)
values ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Clinic OS Demo', null, '#202326', '#c7755f', '000-000-0000', 'demo@example.com')
on conflict (organization_id) do nothing;

insert into branches (id, organization_id, code, name)
values
('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'KORAT', 'Korat'),
('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'KHON-KAEN', 'Khon Kaen'),
('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'KAENG-KHRO', 'Kaeng Khro'),
('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'CHUM-PHAE', 'Chum Phae')
on conflict (organization_id, code) do nothing;

insert into users (id, full_name, email, phone, global_user_type)
values
('20000000-0000-0000-0000-000000000001', 'Demo Owner', 'owner@example.com', '0800000001', 'human'),
('20000000-0000-0000-0000-000000000002', 'Dr. Mira Chen', 'doctor@example.com', '0800000002', 'human'),
('20000000-0000-0000-0000-000000000003', 'Aom CRM', 'crm@example.com', '0800000003', 'human'),
('20000000-0000-0000-0000-000000000004', 'Mint Sales', 'sales@example.com', '0800000004', 'human')
on conflict (email) do nothing;

insert into organization_users (organization_id, user_id, organization_user_type)
values
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'owner'),
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'doctor'),
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'crm'),
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'staff')
on conflict (organization_id, user_id) do nothing;

insert into branch_users (organization_id, branch_id, user_id, is_primary)
values
('00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', true),
('00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', true),
('00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', true),
('00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000004', true)
on conflict (organization_id, branch_id, user_id) do nothing;

insert into membership_levels (id, organization_id, code, name, rank, min_ltv, points_multiplier)
values
('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'standard', 'Standard', 1, 0, 1),
('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'silver', 'Silver', 2, 50000, 1.1),
('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'gold', 'Gold', 3, 100000, 1.25),
('30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', 'platinum', 'Platinum', 4, 200000, 1.5)
on conflict (organization_id, code) do nothing;

insert into patients (id, organization_id, primary_branch_id, patient_code, full_name, phone, email, date_of_birth, source, status)
values
('40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'P-0001', 'Nicha S.', '0811111111', 'nicha@example.com', '1990-07-21', 'LINE', 'active'),
('40000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'P-0002', 'Pim A.', '0822222222', 'pim@example.com', '1988-08-04', 'Facebook', 'active')
on conflict (organization_id, patient_code) do nothing;

insert into patient_channels (id, organization_id, patient_id, channel_type, external_user_id, display_name, is_primary, consent_to_contact, marketing_opt_in, line_user_id, line_display_name, line_oa_id, line_connected_at)
values
('41000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'LINE', 'UdemoLineNicha', 'Nicha LINE', true, true, true, 'UdemoLineNicha', 'Nicha LINE', '@demo-oa', now()),
('41000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000002', 'Facebook', 'fb-pim-demo', 'Pim FB', true, true, false, null, null, null, null);

insert into patient_consents (organization_id, patient_id, channel_id, consent_type, status, source, granted_at, notes)
values
('00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '41000000-0000-0000-0000-000000000001', 'marketing', 'granted', 'LINE', now(), 'Demo marketing consent'),
('00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', null, 'privacy', 'granted', 'staff', now(), 'Demo privacy consent');

insert into patient_memberships (organization_id, patient_id, membership_level_id, total_spending_ltv, points_balance, start_date, expiry_date, status)
values
('00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000004', 248000, 12400, '2024-02-01', '2027-02-01', 'active'),
('00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000003', 142500, 7125, '2025-05-12', '2027-05-12', 'active');

insert into treatment_categories (id, organization_id, code, name)
values
('50000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'INJECTABLE', 'Injectable'),
('50000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'DEVICE', 'Device Treatment')
on conflict (organization_id, code) do nothing;

insert into treatments (id, organization_id, category_id, code, name, default_unit, balance_tracking_type, is_partial_usage_allowed)
values
('51000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 'BOTOX', 'Botox', 'unit', 'units', true),
('51000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 'FILLER', 'Filler', 'cc', 'cc', true),
('51000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000002', 'ULTRAFORMER', 'Ultraformer', 'shot', 'shots', false),
('51000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000002', 'OLIGIO', 'Oligio', 'session', 'sessions', false),
('51000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000002', 'ULTHERA', 'Ulthera', 'session', 'sessions', false),
('51000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 'SCULPTRA', 'Sculptra', 'vial', 'sessions', false)
on conflict (organization_id, code) do nothing;

insert into treatment_repeat_rules (organization_id, treatment_id, min_months, max_months, default_follow_up_days, notes)
values
('00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', 3, 6, 30, 'Botox repeat every 3-6 months'),
('00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000002', 6, 12, 14, 'Filler repeat every 6-12 months'),
('00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000003', 6, 12, 30, 'Ultraformer repeat every 6-12 months'),
('00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000004', 6, 12, 30, 'Oligio repeat every 6-12 months'),
('00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000005', 12, 18, 30, 'Ulthera repeat every 12-18 months'),
('00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000006', 1, 3, 30, 'Sculptra repeat every 1-3 months')
on conflict (organization_id, treatment_id) do nothing;

insert into treatment_cross_sell_rules (organization_id, source_treatment_id, recommended_treatment_id, weight, reason_template)
values
('00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000002', '51000000-0000-0000-0000-000000000004', 20, 'High LTV filler patient may be ready for Oligio cross-sell')
on conflict (organization_id, source_treatment_id, recommended_treatment_id) do nothing;

insert into sales_orders (id, organization_id, patient_id, branch_id, created_by_user_id, order_number, order_date, subtotal_amount, discount_amount, total_amount, status)
values
('60000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'SO-0001', current_date, 48000, 0, 48000, 'paid')
on conflict (organization_id, order_number) do nothing;

insert into sales_order_items (id, organization_id, sales_order_id, treatment_id, description, quantity, unit, unit_price, line_total, creates_package_balance, expiry_date)
values
('61000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', 'Botox 100 units', 100, 'unit', 480, 48000, true, (current_date + interval '12 months')::date);

insert into payments (organization_id, sales_order_id, received_by_user_id, method, amount, status)
values ('00000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'card', 48000, 'paid');

insert into sales_staff_credits (organization_id, sales_order_id, staff_user_id, credited_amount, notes)
values ('00000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 48000, 'V1 tracks sales amount only.');

insert into patient_package_balances (id, organization_id, patient_id, treatment_id, sales_order_item_id, original_quantity, used_quantity, remaining_quantity, unit, expiry_date, status)
values ('62000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', '61000000-0000-0000-0000-000000000001', 100, 64, 36, 'unit', (current_date + interval '12 months')::date, 'active');

insert into package_balance_transactions (organization_id, package_balance_id, type, quantity_delta, notes)
values
('00000000-0000-0000-0000-000000000001', '62000000-0000-0000-0000-000000000001', 'purchase', 100, 'Purchased Botox 100 units'),
('00000000-0000-0000-0000-000000000001', '62000000-0000-0000-0000-000000000001', 'usage', -64, 'Partial Botox usage; 36 units remain');

insert into suppliers (id, organization_id, name, contact_name)
values ('70000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Aesthetic Supply Co.', 'Demo Supplier')
on conflict (organization_id, name) do nothing;

insert into brands (id, organization_id, name)
values ('71000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Allergan')
on conflict (organization_id, name) do nothing;

insert into product_categories (id, organization_id, code, name)
values ('72000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'INJECTABLE', 'Injectable')
on conflict (organization_id, code) do nothing;

insert into products (id, organization_id, category_id, brand_id, supplier_id, sku, product_name, default_unit, unit_cost)
values ('73000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '72000000-0000-0000-0000-000000000001', '71000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001', 'BTX-100', 'Botox 100U', 'vial', 9200)
on conflict (organization_id, sku) do nothing;

insert into product_lots (id, organization_id, product_id, lot_number, expiry_date, unit_cost)
values ('74000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '73000000-0000-0000-0000-000000000001', 'BTX-0726-A', (current_date + interval '10 months')::date, 9200)
on conflict (organization_id, product_id, lot_number) do nothing;

insert into inventory_stocks (id, organization_id, product_lot_id, branch_id, quantity_on_hand, minimum_stock_alert)
values
('75000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '74000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 12, 8),
('75000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '74000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 4, 8)
on conflict (organization_id, product_lot_id, branch_id) do nothing;

insert into stock_transfers (id, organization_id, from_branch_id, to_branch_id, requested_by, approved_by, shipped_by, transfer_date, status, notes)
values ('76000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', current_date, 'shipped', 'Demo branch transfer');

insert into stock_transfer_items (id, organization_id, stock_transfer_id, product_id, lot_number, expiry_date, quantity, unit, unit_cost)
values ('77000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '76000000-0000-0000-0000-000000000001', '73000000-0000-0000-0000-000000000001', 'BTX-0726-A', (current_date + interval '10 months')::date, 2, 'vial', 9200);

insert into stock_movements (organization_id, inventory_stock_id, stock_transfer_id, stock_transfer_item_id, source_branch_id, destination_branch_id, actor_user_id, type, quantity_delta, notes)
values ('00000000-0000-0000-0000-000000000001', '75000000-0000-0000-0000-000000000001', '76000000-0000-0000-0000-000000000001', '77000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'transfer_out', -2, 'Demo transfer out from Korat');

insert into crm_rule_templates (id, organization_id, treatment_id, name, offset_days, trigger_event, default_channel_type)
values
('80000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', 'Botox follow-up 1 month', 30, 'procedure_completed', 'LINE'),
('80000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', 'Botox follow-up 2 months', 60, 'procedure_completed', 'LINE'),
('80000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', 'Botox follow-up 4 months', 120, 'procedure_completed', 'LINE');

insert into crm_tasks (id, organization_id, patient_id, branch_id, assigned_staff_id, related_treatment_id, related_sale_id, patient_channel_id, crm_rule_template_id, channel_type, due_date, status, priority, notes)
values ('81000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', '51000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '41000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000003', 'LINE', current_date, 'pending', 'high', 'Botox repeat opportunity via LINE');

insert into birthday_campaigns (id, organization_id, branch_id, campaign_month, name, benefit_description, status, created_by_user_id)
values ('82000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', null, date_trunc('month', current_date)::date, 'Birthday Benefit Demo', 'Birthday month benefit campaign', 'active', '20000000-0000-0000-0000-000000000001');

insert into birthday_campaign_patients (organization_id, birthday_campaign_id, patient_id, assigned_staff_id, birthday_date)
values ('00000000-0000-0000-0000-000000000001', '82000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', make_date(extract(year from current_date)::int, 7, 21));

insert into opportunity_rules (id, organization_id, code, name, recommended_treatment_id, rule_type, weight, priority_default, reason_template)
values
('90000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'BOTOX_REPEAT_DUE', 'Botox repeat cycle due', '51000000-0000-0000-0000-000000000001', 'repeat_cycle', 40, 'high', 'Botox done around 4 months ago'),
('90000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'FILLER_TO_OLIGIO', 'Cross-sell Oligio after Filler', '51000000-0000-0000-0000-000000000004', 'cross_sell', 25, 'medium', 'High LTV filler patient without Oligio history')
on conflict (organization_id, code) do nothing;

insert into patient_opportunities (id, organization_id, patient_id, recommended_treatment_id, opportunity_rule_id, crm_task_id, score, priority, reason, suggested_crm_action, status)
values ('91000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001', '81000000-0000-0000-0000-000000000001', 92, 'high', 'Botox was done around 4 months ago and patient has high LTV.', 'Send LINE follow-up and offer booking slots.', 'open');

insert into opportunity_score_factors (organization_id, patient_opportunity_id, factor_type, factor_value, score_contribution, explanation)
values
('00000000-0000-0000-0000-000000000001', '91000000-0000-0000-0000-000000000001', 'repeat_due', '4 months since Botox', 40, 'Within repeat cycle window'),
('00000000-0000-0000-0000-000000000001', '91000000-0000-0000-0000-000000000001', 'ltv', '248000', 25, 'High LTV patient');

insert into doctor_fee_rules (id, organization_id, treatment_id, doctor_user_id, calculation_type, fixed_amount, notes)
values ('a0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'fixed_amount', 12000, 'Demo Botox doctor fee rule');

insert into doctor_fee_entries (organization_id, branch_id, doctor_user_id, treatment_id, sales_order_id, doctor_fee_rule_id, fee_date, base_amount, fee_amount, status, notes)
values ('00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', '51000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', current_date, 48000, 12000, 'draft', 'Demo doctor fee entry separate from sales commission');

