-- 1) Announcements Tablosunu Oluşturun
create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  content jsonb not null, -- Tüm dillerdeki çeviriler JSON formatında tutulur: {"tr": "...", "en": "...", "de": "..."}
  is_active boolean not null default true,
  is_premium_promotion boolean not null default false,
  created_at timestamptz not null default now()
);

-- 2) RLS (Satır Bazlı Güvenlik) Aktif Edin
alter table public.announcements enable row level security;

-- 3) Herkesin (Giriş Yapmış veya Yapmamış Tüm Kullanıcıların) Okuyabilmesi İçin RLS Politikası Tanımlayın
drop policy if exists "Allow public read access" on public.announcements;
create policy "Allow public read access" on public.announcements for select using (true);

-- 4) Yetkileri Verin
grant select on public.announcements to anon, authenticated;
