-- Finarcast veritabanından silinen/gereksiz kolonları temizleme betiği
-- Supabase Dashboard -> SQL Editor üzerinde çalıştırarak canlı veritabanını güncelleyebilirsiniz.

-- 1) vaults tablosundaki gereksiz sütunları sil
alter table public.vaults 
  drop column if exists is_included_in_total,
  drop column if exists min_limit,
  drop column if exists max_limit,
  drop column if exists dashboard_layout_type,
  drop column if exists show_on_dashboard,
  drop column if exists dashboard_order;

-- 2) transaction_records tablosundaki gereksiz sütunları sil
alter table public.transaction_records 
  drop column if exists dashboard_order,
  drop column if exists show_on_dashboard;

-- 3) app_settings tablosundaki gereksiz sütunları sil
alter table public.app_settings 
  drop column if exists country_name;

-- 4) Yetkilendirmeler (Grants)
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.vaults to anon, authenticated;
grant select, insert, update, delete on public.transaction_records to anon, authenticated;
grant select, insert, update, delete on public.app_settings to anon, authenticated;
grant select, insert, update, delete on public.custom_categories to anon, authenticated;

