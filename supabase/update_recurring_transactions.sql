-- Finarcast - Tekrarlı İşlemler Mimarisi Veritabanı Güncelleme Betiği
-- Supabase SQL Editor üzerinde çalıştırarak mevcut canlı veritabanını yeni mimariye taşıyabilirsiniz.

-- 1) recurring_templates tablosunu oluştur
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
  vault_ids uuid[],
  updated_at timestamptz not null default now()
);

-- 2) recurring_templates için RLS politikaları
alter table public.recurring_templates enable row level security;

drop policy if exists "templates_select_own" on public.recurring_templates;
drop policy if exists "templates_insert_own" on public.recurring_templates;
drop policy if exists "templates_update_own" on public.recurring_templates;
drop policy if exists "templates_delete_own" on public.recurring_templates;

create policy "templates_select_own" on public.recurring_templates for select using (auth.uid() = user_id);
create policy "templates_insert_own" on public.recurring_templates for insert with check (auth.uid() = user_id);
create policy "templates_update_own" on public.recurring_templates for update using (auth.uid() = user_id);
create policy "templates_delete_own" on public.recurring_templates for delete using (auth.uid() = user_id);

-- 3) transaction_records tablosunu yeni mimariye göre güncelle
alter table public.transaction_records 
  -- Eski sütunları kaldır
  drop column if exists period_type,
  drop column if exists remaining_installments,
  drop column if exists recurrence_day,
  drop column if exists recurrence_date,
  drop column if exists recurrence_duration,
  drop column if exists is_notification_enabled,
  drop column if exists has_notification,
  drop column if exists notification_reminder_days,
  drop column if exists notification_hour,
  drop column if exists notification_minute,
  
  -- Yeni sütunları ekle
  add column if not exists occurrence_date date,
  add column if not exists template_id uuid references public.recurring_templates(id) on delete set null,
  add column if not exists occurrence_key text,
  add column if not exists installment_number int,
  add column if not exists total_installments int,
  add column if not exists status int not null default 0,
  add column if not exists is_reviewed boolean not null default false,
  add column if not exists vault_ids uuid[];

-- 4) Eski işlemlerin occurrence_date ve occurrence_key değerlerini doldur (varsayılan)
update public.transaction_records
  set occurrence_date = coalesce(occurrence_date, date::date),
      occurrence_key = coalesce(occurrence_key, 'manual_' || id::text)
  where occurrence_date is null or occurrence_key is null;

-- 5) occurrence_date ve occurrence_key'i NOT NULL yap
alter table public.transaction_records
  alter column occurrence_date set not null,
  alter column occurrence_key set not null;

-- 6) Benzersiz anahtar kuralı ekle
alter table public.transaction_records
  drop constraint if exists transaction_records_user_id_occurrence_key_key,
  add constraint transaction_records_user_id_occurrence_key_key unique (user_id, occurrence_key);

-- 7) Yetkileri ata
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.recurring_templates to anon, authenticated;
grant select, insert, update, delete on public.transaction_records to anon, authenticated;
