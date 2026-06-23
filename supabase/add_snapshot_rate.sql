-- Finarcast - Döviz Kuru Sabitleme (Snapshot Rate) Desteği
-- Supabase SQL Editor üzerinde (https://supabase.com/dashboard -> SQL Editor) çalıştırarak mevcut canlı veritabanınızı güncelleyebilirsiniz.

-- 1) transaction_records tablosuna snapshot_rate sütununu ekle
alter table public.transaction_records 
  add column if not exists snapshot_rate double precision;
