-- 1. user_subscriptions Tablosu
-- Kullanıcının güncel abonelik durumunu tutar
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  is_pro BOOLEAN NOT NULL DEFAULT false,
  expires_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS for user_subscriptions
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "subscriptions_select_own" ON public.user_subscriptions;
CREATE POLICY "subscriptions_select_own" ON public.user_subscriptions 
FOR SELECT USING (auth.uid() = user_id);

-- Yalnızca service_role (Admin) insert/update yapabilir, kullanıcı yapamaz.
DROP POLICY IF EXISTS "subscriptions_insert_admin" ON public.user_subscriptions;
CREATE POLICY "subscriptions_insert_admin" ON public.user_subscriptions 
FOR INSERT WITH CHECK (false); -- Kullanıcı ekleyemez (Edge Function service role kullanacak)

DROP POLICY IF EXISTS "subscriptions_update_admin" ON public.user_subscriptions;
CREATE POLICY "subscriptions_update_admin" ON public.user_subscriptions 
FOR UPDATE USING (false);

-- 2. ai_usage_logs Tablosu
-- Günlük limit kontrolü için her bir AI isteğini kaydeder
CREATE TABLE IF NOT EXISTS public.ai_usage_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  request_type TEXT NOT NULL DEFAULT 'parse_transaction'
);

-- Hızlı sorgulama için Index
CREATE INDEX IF NOT EXISTS idx_ai_usage_user_date ON public.ai_usage_logs(user_id, created_at);

ALTER TABLE public.ai_usage_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "ai_logs_select_own" ON public.ai_usage_logs;
CREATE POLICY "ai_logs_select_own" ON public.ai_usage_logs 
FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "ai_logs_insert_admin" ON public.ai_usage_logs;
CREATE POLICY "ai_logs_insert_admin" ON public.ai_usage_logs 
FOR INSERT WITH CHECK (false); -- Sadece Edge Function yazacak

-- 3. Kota Kontrol ve Artırma Fonksiyonu
-- Edge function içinden RPC (Remote Procedure Call) ile çağrılacak.
-- Aynı anda hem kontrol edip hem de limit aşılmadıysa kaydı atar (Race condition önlemi).
CREATE OR REPLACE FUNCTION public.check_and_increment_ai_usage(
  p_user_id UUID, 
  p_daily_limit INT
)
RETURNS JSONB AS $$
DECLARE
  today_count INT;
BEGIN
  -- Bugüne ait kullanımı say (UTC'ye göre veya server time'a göre)
  SELECT COUNT(*) INTO today_count
  FROM public.ai_usage_logs
  WHERE user_id = p_user_id
    AND created_at >= CURRENT_DATE;
  
  -- Limit aşıldıysa false dön
  IF today_count >= p_daily_limit THEN
    RETURN jsonb_build_object(
      'allowed', false, 
      'used', today_count, 
      'limit', p_daily_limit
    );
  END IF;
  
  -- Limit aşılmadıysa kullanımı kaydet
  INSERT INTO public.ai_usage_logs (user_id) VALUES (p_user_id);
  
  -- İzin verildi ve güncel sayıyı dön
  RETURN jsonb_build_object(
    'allowed', true, 
    'used', today_count + 1, 
    'limit', p_daily_limit
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
