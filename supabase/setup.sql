-- Finarcast Supabase kurulumu (SQL Editor'da tek seferde calistirin)
-- Dashboard: https://supabase.com/dashboard -> SQL -> New query

-- 1) Tablolar
create table if not exists public.vaults (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null default '',
  currency text not null default 'AUTO',
  updated_at timestamptz not null default now()
);

create table if not exists public.recurring_templates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default '',
  is_income boolean not null default false,
  category_id text,
  icon_code text,
  amount double precision not null default 0,
  min_amount double precision,
  max_amount double precision,
  period_type int not null default 301,
  recurrence_day int,
  recurrence_date timestamptz,
  total_installments int,
  start_date timestamptz not null default now(),
  note text,
  currency text,
  is_paused boolean not null default false,
  is_archived boolean not null default false,
  is_notification_enabled boolean not null default false,
  has_notification boolean not null default false,
  notification_reminder_days int not null default 0,
  notification_hour int not null default 9,
  notification_minute int not null default 0,
  vault_id uuid references public.vaults(id) on delete set null,
  updated_at timestamptz not null default now()
);

create table if not exists public.transaction_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default '',
  is_income boolean not null default false,
  category_id text,
  icon_code text,
  amount double precision not null default 0,
  min_amount double precision,
  max_amount double precision,
  date timestamptz not null default now(),
  occurrence_date date not null,
  template_id uuid references public.recurring_templates(id) on delete set null,
  occurrence_key text not null,
  installment_number int,
  total_installments int,
  status int not null default 0,
  is_reviewed boolean not null default false,
  is_archived boolean not null default false,
  vault_id uuid references public.vaults(id) on delete set null,
  target_vault_id uuid references public.vaults(id) on delete set null,
  note text,
  currency text,
  updated_at timestamptz not null default now(),
  unique (user_id, occurrence_key)
);

create table if not exists public.app_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  language_code text not null default 'tr',
  theme_mode_index int not null default 0,
  data_retention_days int not null default 90,
  is_ai_notifications_enabled boolean not null default true,
  is_sync_enabled boolean not null default false,
  bg_color_style int not null default 2,
  accent_color_value bigint not null default 4278238420,
  currency_symbol text not null default '₺',
  permanent_deletion_days int not null default -1,
  updated_at timestamptz not null default now()
);

create table if not exists public.custom_categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  unique_id text not null unique,
  parent_id text not null,
  name text not null,
  icon_code int not null,
  updated_at timestamptz not null default now()
);


-- 2) RLS
alter table public.vaults enable row level security;
alter table public.recurring_templates enable row level security;
alter table public.transaction_records enable row level security;
alter table public.app_settings enable row level security;
alter table public.custom_categories enable row level security;

-- Vaults Policies
drop policy if exists "vaults_select_own" on public.vaults;
drop policy if exists "vaults_insert_own" on public.vaults;
drop policy if exists "vaults_update_own" on public.vaults;
drop policy if exists "vaults_delete_own" on public.vaults;
create policy "vaults_select_own" on public.vaults for select using (auth.uid() = user_id);
create policy "vaults_insert_own" on public.vaults for insert with check (auth.uid() = user_id);
create policy "vaults_update_own" on public.vaults for update using (auth.uid() = user_id);
create policy "vaults_delete_own" on public.vaults for delete using (auth.uid() = user_id);

-- Templates Policies
drop policy if exists "templates_select_own" on public.recurring_templates;
drop policy if exists "templates_insert_own" on public.recurring_templates;
drop policy if exists "templates_update_own" on public.recurring_templates;
drop policy if exists "templates_delete_own" on public.recurring_templates;
create policy "templates_select_own" on public.recurring_templates for select using (auth.uid() = user_id);
create policy "templates_insert_own" on public.recurring_templates for insert with check (auth.uid() = user_id);
create policy "templates_update_own" on public.recurring_templates for update using (auth.uid() = user_id);
create policy "templates_delete_own" on public.recurring_templates for delete using (auth.uid() = user_id);

-- Transaction Records Policies
drop policy if exists "tx_select_own" on public.transaction_records;
drop policy if exists "tx_insert_own" on public.transaction_records;
drop policy if exists "tx_update_own" on public.transaction_records;
drop policy if exists "tx_delete_own" on public.transaction_records;
create policy "tx_select_own" on public.transaction_records for select using (auth.uid() = user_id);
create policy "tx_insert_own" on public.transaction_records for insert with check (auth.uid() = user_id);
create policy "tx_update_own" on public.transaction_records for update using (auth.uid() = user_id);
create policy "tx_delete_own" on public.transaction_records for delete using (auth.uid() = user_id);

-- Settings Policies
drop policy if exists "settings_select_own" on public.app_settings;
drop policy if exists "settings_insert_own" on public.app_settings;
drop policy if exists "settings_update_own" on public.app_settings;
create policy "settings_select_own" on public.app_settings for select using (auth.uid() = user_id);
create policy "settings_insert_own" on public.app_settings for insert with check (auth.uid() = user_id);
create policy "settings_update_own" on public.app_settings for update using (auth.uid() = user_id);

-- Custom Categories Policies
drop policy if exists "custom_categories_select_own" on public.custom_categories;
drop policy if exists "custom_categories_insert_own" on public.custom_categories;
drop policy if exists "custom_categories_update_own" on public.custom_categories;
drop policy if exists "custom_categories_delete_own" on public.custom_categories;
create policy "custom_categories_select_own" on public.custom_categories for select using (auth.uid() = user_id);
create policy "custom_categories_insert_own" on public.custom_categories for insert with check (auth.uid() = user_id);
create policy "custom_categories_update_own" on public.custom_categories for update using (auth.uid() = user_id);
create policy "custom_categories_delete_own" on public.custom_categories for delete using (auth.uid() = user_id);

-- 3) Yetkilendirmeler (Grants)
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.vaults to anon, authenticated;
grant select, insert, update, delete on public.recurring_templates to anon, authenticated;
grant select, insert, update, delete on public.transaction_records to anon, authenticated;
grant select, insert, update, delete on public.app_settings to anon, authenticated;
grant select, insert, update, delete on public.custom_categories to anon, authenticated;
