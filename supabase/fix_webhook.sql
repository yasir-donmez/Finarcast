-- Bu fonksiyon RevenueCat webhook'unun RLS (Güvenlik) engeline takılmadan abonelikleri güncelleyebilmesini sağlar.
-- SECURITY DEFINER yetkisi sayesinde admin yetkileriyle çalışır.

CREATE OR REPLACE FUNCTION public.upsert_user_subscription(
  p_user_id UUID,
  p_is_pro BOOLEAN,
  p_expires_at TIMESTAMPTZ
)
RETURNS void AS $$
BEGIN
  INSERT INTO public.user_subscriptions (user_id, is_pro, expires_at, updated_at)
  VALUES (p_user_id, p_is_pro, p_expires_at, NOW())
  ON CONFLICT (user_id) DO UPDATE 
  SET 
    is_pro = EXCLUDED.is_pro,
    expires_at = EXCLUDED.expires_at,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
