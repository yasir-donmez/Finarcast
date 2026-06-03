import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    // Webhook auth check (Optional but recommended: check Authorization header matching a secret in your RevenueCat webhook config)
    const authHeader = req.headers.get('Authorization')
    const webhookSecret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET')
    
    if (webhookSecret && authHeader !== `Bearer ${webhookSecret}`) {
      return new Response('Unauthorized', { status: 401 })
    }

    const payload = await req.json()
    console.log("RevenueCat Event:", payload.event.type, payload.event.app_user_id)

    const event = payload.event
    const userId = event.app_user_id
    const eventType = event.type // INITIAL_PURCHASE, RENEWAL, CANCELLATION, EXPIRATION, etc.

    if (!userId) {
      return new Response('No app_user_id provided', { status: 400 })
    }

    // Deno ortamında her zaman erişilebilir olan ANON_KEY'i kullanıyoruz.
    // Güvenlik duvarını (RLS) aşmak için RPC fonksiyonu kullanacağız.
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    // Check if it's a UUID (Supabase User ID)
    const uuidRegex = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
    if (!uuidRegex.test(userId)) {
      console.warn(`User ID ${userId} is not a valid UUID, skipping.`)
      return new Response('OK', { status: 200 })
    }

    let isPro = false
    let expiresAt = null

    // Determine status based on event type
    switch (eventType) {
      case 'INITIAL_PURCHASE':
      case 'RENEWAL':
      case 'UNCANCELLATION':
      case 'NON_RENEWING_PURCHASE':
        isPro = true
        expiresAt = event.expiration_at_ms ? new Date(event.expiration_at_ms).toISOString() : null
        break
      case 'CANCELLATION':
        // A cancellation means it won't renew, but it's still active until expiration.
        // Usually, we keep isPro = true if expiration_at_ms is in the future.
        if (event.expiration_at_ms && event.expiration_at_ms > Date.now()) {
          isPro = true
          expiresAt = new Date(event.expiration_at_ms).toISOString()
        } else {
          isPro = false
        }
        break
      case 'EXPIRATION':
      case 'BILLING_ISSUE':
      case 'REFUND':
        isPro = false
        break
      default:
        // Other events (TEST, SUBSCRIBER_ALIAS, etc.) we just return OK
        return new Response('OK', { status: 200 })
    }

    // Call the RPC function (which runs with SECURITY DEFINER privileges)
    const { error } = await supabaseClient.rpc('upsert_user_subscription', {
      p_user_id: userId,
      p_is_pro: isPro,
      p_expires_at: expiresAt
    })

    if (error) {
      console.error('Error updating subscription:', error)
      return new Response(JSON.stringify({ error: error.message }), { status: 500 })
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 })
  } catch (error) {
    console.error('Webhook error:', error)
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }
})
