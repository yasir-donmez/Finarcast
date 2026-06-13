import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const apiKey = Deno.env.get('GEMINI_API_KEY')
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY is not configured in Supabase.')
    }

    // 1. Verify Authentication
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized: Missing Authorization header' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 401,
      })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized: Invalid token' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 401,
      })
    }

    // 2. Check Subscription and Rate Limits
    let isPro = false
    const { data: subData, error: subError } = await supabase
      .from('user_subscriptions')
      .select('is_pro')
      .eq('user_id', user.id)
      .maybeSingle()
      
    if (subError) {
      console.error('[Supabase Edge Function] Error fetching user subscription:', subError)
    }

    if (subData && subData.is_pro) {
      isPro = true
    }

    const dailyLimit = isPro ? 50 : 5
    console.log(`[Supabase Edge Function] User: ${user.id}, isPro: ${isPro}, dailyLimit: ${dailyLimit}`)

    // Check rate limit using anon role (RPC increments count safely due to SECURITY DEFINER)
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    const { data: rpcData, error: rpcError } = await supabaseClient.rpc('check_and_increment_ai_usage', {
      p_user_id: user.id,
      p_daily_limit: dailyLimit
    })

    if (rpcError) {
      console.error('RPC Error:', rpcError)
      throw new Error('Failed to verify usage quota: ' + rpcError.message)
    }

    if (!rpcData.allowed) {
      console.warn(`[Supabase Edge Function] Rate limit exceeded: User: ${user.id}, used: ${rpcData.used}, limit: ${rpcData.limit}, isPro: ${isPro}`)
      return new Response(JSON.stringify({ 
        error: 'Rate limit exceeded. Please wait or upgrade your plan.',
        isRateLimit: true,
        limit: rpcData.limit,
        used: rpcData.used,
        isPro: isPro
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 429,
      })
    }

    const payload = await req.json()
    const { text, image, mimeType, customCategories } = payload

    let prompt = ''
    let contents: any[] = []

    if (text) {
      prompt = buildTextPrompt(text, customCategories || [])
      contents = [{ parts: [{ text: prompt }] }]
    } else if (image && mimeType) {
      prompt = buildReceiptPrompt(customCategories || [])
      contents = [
        {
          parts: [
            { inlineData: { data: image, mimeType: mimeType } },
            { text: prompt }
          ]
        }
      ]
    } else {
      throw new Error('Invalid request payload. Provide either "text" or "image" and "mimeType".')
    }

    // Try fallback models (Gemini 2.5 Flash -> Gemini 2.0 Flash -> Lite models)
    const models = [
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-2.5-flash-lite',
      'gemini-2.0-flash-lite'
    ]
    
    let lastError = null
    let resultJson = null

    for (const model of models) {
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`
        
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents,
            generationConfig: {
              responseMimeType: 'application/json',
              temperature: 0.2
            }
          })
        })

        if (!response.ok) {
          const errText = await response.text()
          throw new Error(`HTTP ${response.status}: ${errText}`)
        }

        const resData = await response.json()
        const textResponse = resData.candidates?.[0]?.content?.parts?.[0]?.text
        if (!textResponse) {
          throw new Error('Empty response from model.')
        }

        const cleaned = textResponse.replace(/```json/g, '').replace(/```/g, '').trim()
        resultJson = JSON.parse(cleaned)
        break // Success! Exit loop
      } catch (err) {
        lastError = err
        console.warn(`[Supabase Edge Function] Failed with ${model}:`, err)
        // If rate limit / quota error, don't continue to other models
        if (err.message.includes('429') || err.message.toLowerCase().includes('quota')) {
          break
        }
      }
    }

    if (!resultJson) {
      throw lastError || new Error('All models failed to process.')
    }

    return new Response(JSON.stringify(resultJson), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})

function getParentCategoryName(id: string): string {
  switch (id) {
    case 'exp_rent': return 'Barınma';
    case 'exp_bill': return 'Faturalar';
    case 'exp_grocery': return 'Market';
    case 'exp_dining': return 'Yemek';
    case 'exp_trans': return 'Ulaşım';
    case 'exp_car': return 'Araç';
    case 'exp_cloth': return 'Giyim';
    case 'exp_beauty': return 'Kişisel Bakım';
    case 'exp_health': return 'Sağlık';
    case 'exp_sub': return 'Abonelikler';
    case 'exp_fun': return 'Eğlence';
    case 'exp_edu': return 'Eğitim';
    case 'exp_family': return 'Aile';
    case 'exp_shopping': return 'Alışveriş';
    case 'exp_travel': return 'Seyahat';
    case 'exp_debt': return 'Borç';
    case 'exp_tax': return 'Vergiler';
    case 'exp_other': return 'Diğer Giderler';
    case 'inc_salary': return 'Maaş';
    case 'inc_extra': return 'Ek Gelir';
    case 'inc_invest': return 'Yatırım Geliri';
    case 'inc_rent': return 'Kira Geliri';
    case 'inc_scholarship': return 'Burs';
    case 'inc_sale': return 'Satış';
    case 'inc_gift': return 'Hediye';
    case 'inc_other': return 'Diğer Gelirler';
    default: return 'Bilinmeyen';
  }
}

function buildTextPrompt(text: string, customCategories: any[]): string {
  const customBuffer: string[] = []
  if (customCategories && customCategories.length > 0) {
    customBuffer.push('\nKullanıcı Tanımlı Özel Alt Kategoriler:')
    for (const custom of customCategories) {
      const id = custom.id || ''
      const name = custom.name || ''
      const parentId = custom.parentId || ''
      const parentName = getParentCategoryName(parentId)
      customBuffer.push(`- ${id}: "${name}" (Ana Kategori: "${parentName}" - ${parentId})`)
    }
    customBuffer.push('ÖNEMLİ: Eğer harcama/gelir yukarıdaki özel alt kategorilerden biriyle eşleşiyorsa, categoryId olarak tam olarak o özel kategoriye ait ID değerini döndür.')
  }
  const customText = customBuffer.join('\n')

  return `
Sen bir kişisel finans yapay zekasısın. Sana gelen serbest metni analiz ederek bir harcama veya gelir işlemine dönüştür.
Bugün: ${new Date().toISOString().split('T')[0]}

Kurallar:
1. Başlık (title): İşlemin yapıldığı yerin/markanın adını yaz (örn: "Migros", "Starbucks", "Bim", "Shell"). Eğer marka/yer adı belirtilmemişse genel bir kategori/hizmet adı kullan (örn: "Borç Ödemesi", "Restoran", "Market", "Taksi", "Fatura", "Maaş"). Spesifik aldığın/yediğin ürünleri veya detayları (örn: "Tost", "Yoğurt", "Filtre Kahve") başlık alanına yazma; başlık genel kalsın.
2. Tutar (amount): Metindeki harcama veya gelir miktarını sayısal olarak çıkar. Metinde sayısal tutar olarak ne geçiyorsa tam olarak onu al (örneğin "500 gram altın" ifadesinde tutar 500.0'dir; "500 TL" ifadesinde 500.0'dir). Metinde sayısal bir tutar yoksa veya bir tutar aralığı belirtilmişse 0.0 değerini döndür (tarih/gün sayısını tutar olarak algılama!).
3. Esnek/Aralıklı Tutar (minAmount ve maxAmount): Eğer kullanıcı net tek bir tutar yerine bir tutar aralığı belirtirse (örn: "100 200 arası", "150-200 TL civarında", "100 ile 200 lira"), amount değerini 0.0 yap; bu aralığın alt limitini minAmount (örn: 100.0) ve üst limitini maxAmount (örn: 200.0) olarak döndür. Net bir aralık yoksa minAmount ve maxAmount alanlarını null yap.
4. Tarih (date): Bugünün tarihini baz alarak "dün", "yarın", "2 gün sonra", "pazartesi günü" gibi zaman belirteçlerini hesapla ve ISO formatında (YYYY-MM-DD) döndür. Örneğin "yarın" deniyorsa yarına ait tarihi ver. Belirtilmemişse bugünü yaz.
5. Not (note): Aldığın/yediğin ürünleri veya yaptığın spesifik harcama detaylarını bu alana yaz (örn: "Arkadaşa 500 gram altın borcu", "Tost yedik", "Yoğurt alındı"). Girdi metninde marka/yer adı dışında fazladan hiçbir detay yoksa not alanını boş veya null bırak.
6. İşlem Tipi (isIncome): Eğer metin bir gelir (maaş, burs, birinden alınan para, iade, satış kazancı vb.) belirtiyorsa true, gider belirtiyorsa false yap.
7. Para Birimi (currency): Metinde geçen para birimini ya da birim sembolünü çıkar. Desteklenen semboller şunlardır:
   - '₺' (Türk Lirası, TL, lira vb. için)
   - '\$' (Dolar, USD vb. için)
   - '€' (Euro, Avro vb. için)
   - '£' (Sterlin, GBP vb. için)
   - 'G' (Altın, gram altın, gr altın vb. için)
   - 'Ag' (Gümüş, gram gümüş, gr gümüş vb. için)
   Metinde bu birimlerden hangisi veya karşılığı geçiyorsa tam olarak o sembolü döndür; belirtilmemişse null veya '₺' döndür.
8. Hatırlatıcı Ayarları (Reminders):
   Metinde "hatırlat", "alarm kur", "bildirim gönder" vb. bir hatırlatıcı talebi olup olmadığını kontrol et.
   - isNotificationEnabled: Hatırlatıcı talebi varsa true, yoksa false döndür.
   - notificationReminderDays: Hatırlatmanın, işlem tarihinden kaç gün önce yapılacağını gösteren tamsayı. 
   - notificationHour: Hatırlatılacak saat (24 saatlik formatta tamsayı, 0-23 arası). Varsayılan olarak 9 döndür.
   - notificationMinute: Hatırlatacak dakika (0-59 arası tamsayı). Varsayılan olarak 0 döndür.
9. Kasa/Hesap Belirteci (vaultName): Kullanıcı belirli bir kasa/hesap belirtiyorsa (örn: "ortak kasa", "maaş hesabı", "ana kasa"), bu kasa veya kaynak kasa ismini metinden aynen çıkarıp döndür. Yoksa null döndür.
10. Hedef Kasa/Hesap Belirteci (targetVaultName): Eğer işlem bir kasa transferi (categoryId = "transfer") ise ve metinde hedef kasa/hesap belirtilmişse (örn: "Garanti'den Akbank'a transfer" ifadesinde Akbank hedef kasadır), hedef kasa ismini metinden aynen çıkarıp döndür. Transfer değilse veya hedef kasa belirtilmemişse null döndür.
11. Tekrarlama/Periyot (periodType): İşlem tekrarlı/periyodik ise şu formüle göre bir tamsayı döndür: 'birim * 100 + aralık'.
    - Birimler (unit): 1 = Gün, 2 = Hafta, 3 = Ay, 4 = Yıl.
    - Aralık (interval): Tekrarlama sıklığı (örn: her 1 birimde bir, her 2 birimde bir vb.).
    - Örnek kodlar: 
      * 0 = Tek Seferlik (tekrarsız harcama/gelir)
      * 101 = Günlük (her gün / 1 günde bir)
      * 102 = 2 günde bir, 103 = 3 günde bir, 104 = 4 günde bir
      * 201 = Haftalık (her hafta / 1 haftada bir)
      * 202 = 2 haftada bir, 203 = 3 haftada bir
      * 250 = Hafta içi her gün (Pazartesi-Cuma)
      * 251 = Hafta sonu her gün (Cumartesi-Pazar)
      * 301 = Aylık (her ay / 1 ayda bir)
      * 302 = 2 ayda bir, 303 = 3 ayda bir, 306 = 6 ayda bir
      * 401 = Yıllık (her yıl / 1 yılda bir)
      * 402 = 2 yılda bir
    Metne en uygun periyot kodunu yukarıdaki kurallara göre tam olarak sayısal olarak döndür. Periyodik olmayan normal harcamalar için mutlaka 0 döndür.
12. Tekrarlama Günü (recurrenceDay): Haftalık ise gün (1-7), aylık ise ayın günü (1-31).
13. Tekrarlama Süresi (recurrenceDuration): Toplam kaç kez tekrar edeceğini gösteren sayı.
14. Taksit Sayısı (remainingInstallments): Taksit sayısı.
15. Geleceğe Yönelik Tek Seferlik İşlemler Kısıtlaması: Gelecekte gerçekleşecek tek seferlik harcama/gelir planları doğrudan tek seferlik bir işlem olarak kaydedilemez (Geleceğe yönelik tek seferlik işlem veya geleceğe yönelik transfer yasaktır!). Bu nedenle, gelecekteki tek seferlik planlar için (örn: "Gelecek hafta 500 TL ödeyeceğim", "Yarın sabah 200 TL borç göndereceğim") periodType değerini 101 yapmalı ve tekrar/taksit sayısı olan remainingInstallments değerini tam olarak 1 döndürmelisin. Böylece bu işlem sistemde 1 kez tekrarlayacak bir plan/şablon olarak açılacaktır.
16. Transfer Kısıtlaması: Kasa transferi işlemleri (categoryId = "transfer") sadece tek seferlik geçmiş veya şimdiki zamanlı işlemler için geçerlidir. Transfer işlemleri için asla periyodik/tekrarlı bir plan oluşturulamaz (yani categoryId = "transfer" ise periodType kesinlikle 0 olmalı ve remainingInstallments kesinlikle null olmalıdır). Geleceğe yönelik bir transfer belirtildiyse bunu normal bir gider/borç veya transfer olarak değil, bugünün transfer işlemi olarak algıla.
17. Kategori Eşleştirme (categoryId): Aşağıdaki kategorilerden en uygun olanının "ID" değerini seç. En spesifik Alt Kategoriyi seçmeye çalış.

    **GİDERLER (isIncome = false):**
    - exp_rent (Barınma) -> Alt Kategoriler: exp_rent_home (Ev Kirası), exp_rent_office (Ofis Kirası), exp_rent_mortgage (Konut Kredisi), exp_rent_maintenance (Tadilat), exp_rent_storage (Depolama), exp_rent_insurance (Konut Sigortası), exp_rent_moving (Taşınma), exp_rent_dorm (Yurt), exp_rent_room (Oda Kirası)
    - exp_bill (Faturalar) -> Alt Kategoriler: exp_bill_electricity (Elektrik), exp_bill_water (Su), exp_bill_gas (Doğalgaz), exp_bill_internet (İnternet), exp_bill_phone (Telefon), exp_bill_dues (Aidat), exp_bill_tv (Televizyon)
    - exp_grocery (Market) -> Alt Kategoriler: exp_grocery_food (Gıda/Yiyecek), exp_grocery_cleaning (Temizlik), exp_grocery_drink (İçecek/Soda/Kola/Su), exp_grocery_pet (Evcil Hayvan), exp_grocery_hygiene (Kişisel Hijyen), exp_grocery_tobacco (Tütün), exp_grocery_alcohol (Alkol)
    - exp_dining (Yemek) -> Alt Kategoriler: exp_dining_restaurant (Restoran), exp_dining_cafe (Kafe/Kahve), exp_dining_fastfood (Hızlı Yemek/Döner/Burger), exp_dining_delivery (Eve Sipariş), exp_dining_canteen (Kantin)
    - exp_trans (Ulaşım) -> Alt Kategoriler: exp_trans_bus (Toplu Taşıma/Otobüs/Metro), exp_trans_taxi (Taksi), exp_trans_intercity (Şehirlerarası Ulaşım/Otobüs/Tren), exp_trans_scooter (Mikromobilite/Scooter/Martı)
    - exp_car (Araç) -> Alt Kategoriler: exp_car_fuel (Akaryakıt/Benzin/Dizel), exp_car_maintenance (Sanayi/Tamir/Bakım), exp_car_parking (Otopark/İSPARK), exp_car_wash (Oto Yıkama), exp_car_toll (Geçiş Ücreti/Köprü/HGS), exp_car_insurance (Kasko/Sigorta), exp_car_tax (MTV/Araç Vergisi), exp_car_rental (Araç Kiralama)
    - exp_cloth (Giyim) -> Alt Kategoriler: exp_cloth_daily (Günlük Giyim/Kıyafet), exp_cloth_shoes (Ayakkabı), exp_cloth_acc (Aksesuar/Çanta/Takı), exp_cloth_tailor (Terzi)
    - exp_beauty (Kişisel Bakım) -> Alt Kategoriler: exp_beauty_salon (Kuaför/Berber), exp_beauty_cosmetics (Kozmetik/Makyaj), exp_beauty_spa (Spa/Masaj), exp_beauty_esthetics (Estetik)
    - exp_health (Sağlık) -> Alt Kategoriler: exp_health_doctor (Muayene/Doktor Ücreti), exp_health_medicine (Eczane/İlaç), exp_health_dentist (Diş Hekimi/Tedavi), exp_health_surgery (Ameliyat/Hastane), exp_health_optics (Gözlük/Lens), exp_health_veterinary (Veteriner), exp_health_therapy (Psikolog/Terapi), exp_health_supplements (Gıda Takviyesi/Vitamin)
    - exp_sub (Abonelikler) -> Alt Kategoriler: exp_sub_stream (Netflix/Disney/Dizi-Film), exp_sub_music (Spotify/Youtube Premium), exp_sub_gym (Spor Salonu Üyeliği), exp_sub_software (iCloud/Google One/Yazılım), exp_sub_publishing (Dergi/Yayın/Medium)
    - exp_fun (Eğlence) -> Alt Kategoriler: exp_fun_cinema (Sinema), exp_fun_concert (Konser/Tiyatro), exp_fun_event (Etkinlik/Festival), exp_fun_game (Steam/Playstation/Oyun), exp_fun_hobby (Hobi Malzemeleri), exp_fun_gambling (Milli Piyango/Şans Oyunları)
    - exp_edu (Eğitim) -> Alt Kategoriler: exp_edu_school (Okul/Harç/Taksit), exp_edu_course (Kurs/Udemy/Eğitim), exp_edu_book (Kitap/Roman), exp_edu_stationery (Kırtasiye), exp_edu_exams (Sınav Ücretleri/ÖSYM/YDS)
    - exp_family (Aile) -> Alt Kategoriler: exp_family_baby (Bebek Bezi/Mama), exp_family_toy (Oyuncak), exp_family_allowance (Çocuğa Harçlık), exp_family_daycare (Kreş), exp_family_support (Aile Desteği), exp_family_care (Bakıcı), exp_family_alimony (Nafaka)
    - exp_shopping (Alışveriş) -> Alt Kategoriler: exp_shopping_tech (Telefon/Bilgisayar/Teknoloji), exp_shopping_furniture (Mobilya/Ev Eşyası), exp_shopping_decor (Ev Tekstili/Perde), exp_shopping_kitchen (Mutfak Gereçleri/Tabak), exp_shopping_gift (Hediye Alma), exp_shopping_general (Genel Alışveriş/Trendyol/Amazon), exp_shopping_sports (Spor Ekipmanı), exp_shopping_shipping (Kargo)
    - exp_travel (Seyahat) -> Alt Kategoriler: exp_travel_hotel (Otel/Konaklama/Airbnb), exp_travel_flight (Uçak/Otobüs/Gemi Bileti), exp_travel_tour (Turistik Gezi/Rehber), exp_travel_visa (Vize Ücretleri)
    - exp_debt (Borç) -> Alt Kategoriler: exp_debt_credit_card (Kredi Kartı Ödemesi), exp_debt_loan (Banka Kredisi/Taksit), exp_debt_personal (Arkadaşa/Birine Borç Ödeme), exp_debt_lending (Borç Verme)
    - exp_tax (Vergiler) -> Alt Kategoriler: exp_tax_income (Gelir Vergisi), exp_tax_fine (Trafik Cezası/Ceza), exp_tax_fee (Harç/Pasaport Harcı)
    - exp_invest (Yatırım) -> Alt Kategoriler: exp_invest_stocks (Hisse Senedi), exp_invest_gold (Altın), exp_invest_crypto (Kripto), exp_invest_pension (Bireysel Emeklilik)
    - exp_other (Diğer Giderler) -> Alt Kategoriler: exp_other_general (Genel/Sınıflandırılamayan), exp_other_donation (Bağış/LÖSEV), exp_other_tip (Bahşiş), exp_other_bank_fee (Banka Ücreti)

    **GELİRLER (isIncome = true):**
    - inc_salary (Maaş) -> Alt Kategoriler: inc_salary_main (Ana Maaş), inc_salary_bonus (Prim/Bonus), inc_salary_dividend (Temettü/Kâr Payı), inc_salary_pension (Emeklilik Maaşı), inc_salary_severance (Tazminat)
    - inc_extra (Ek Gelir) -> Alt Kategoriler: inc_extra_freelance (Freelance İşler), inc_extra_parttime (Yarı Zamanlı İş), inc_extra_commission (Satış Komisyonu), inc_extra_content (Youtube/Blog Geliri), inc_extra_affiliate (Satış Ortaklığı)
    - inc_invest (Yatırım Geliri) -> Alt Kategoriler: inc_invest_stock (Borsa/Hisse Geliri), inc_invest_crypto (Kripto Para Geliri), inc_invest_interest (Mevduat Faizi), inc_invest_gold (Altın), inc_invest_forex (Döviz Kârı), inc_invest_bond (Tahvil Geliri)
    - inc_rent (Kira Geliri) -> Alt Kategoriler: inc_rent_home (Ev Kira Geliri), inc_rent_office (Dükkan/Ofis Kira Geliri), inc_rent_car (Araç Kira Geliri), inc_rent_equipment (Ekipman Kira Geliri)
    - inc_scholarship (Burs) -> Alt Kategoriler: inc_scholarship_award (Öğrenim Bursu), inc_scholarship_loan (Kredi/KYK), inc_scholarship_gov (Devlet Yardımı), inc_scholarship_grant (Proje Desteği)
    - inc_sale (Satış) -> Alt Kategoriler: inc_sale_online (Online Satış Geliri), inc_sale_physical (İkinci Eşya Satış Geliri), inc_sale_vehicle (Araç Satış Geliri), inc_sale_property (Gayrimenkul/Ev Satış Geliri)
    - inc_gift (Hediye) -> Alt Kategoriler: inc_gift_general (Nakit Hediye/Bayram Harçlığı), inc_gift_award (Yarışma/Ödül Geliri), inc_gift_inheritance (Miras Geliri), inc_gift_alimony (Nafaka), inc_gift_allowance (Harçlık)
    - inc_other (Diğer Gelirler) -> Alt Kategoriler: inc_other_general (Genel/Diğer Gelir), inc_other_refund (İade Alınan Ücret), inc_other_lottery (Şans Oyunları İkramiyesi), inc_other_collection (Verilen Borcun Geri Alınması), inc_other_tax_refund (Vergi İadesi)

    **KASA TRANSFERLERİ (Kendi Hesapları Arasında Para Geçişi):**
    - transfer -> Kullanıcının kendi kasaları/hesapları arasındaki para çekme, hesaba para yatırma veya virman/transfer işlemleri için bu ID değerini kullan. isIncome değerini false yap.

${customText}

18. Sadece JSON formatında, kod blokları (markdown \`\`\`) olmadan şu şemaya göre yanıt dön:
{
  "title": "İşlem Başlığı",
  "amount": 150.0,
  "minAmount": null,
  "maxAmount": null,
  "categoryId": "kategori_id",
  "date": "YYYY-MM-DD",
  "isIncome": false,
  "note": "İşlem açıklaması",
  "currency": "₺",
  "isNotificationEnabled": false,
  "notificationReminderDays": 0,
  "notificationHour": 9,
  "notificationMinute": 0,
  "vaultName": null,
  "targetVaultName": null,
  "periodType": 0,
  "remainingInstallments": null,
  "recurrenceDay": null,
  "recurrenceDuration": null
}

Girdi Metni: "${text}"
  `
}

function buildReceiptPrompt(customCategories: any[]): string {
  const customBuffer: string[] = []
  if (customCategories && customCategories.length > 0) {
    customBuffer.push('\nKullanıcı Tanımlı Özel Alt Kategoriler:')
    for (const custom of customCategories) {
      const id = custom.id || ''
      const name = custom.name || ''
      const parentId = custom.parentId || ''
      const parentName = getParentCategoryName(parentId)
      customBuffer.push(`- ${id}: "${name}" (Ana Kategori: "${parentName}" - ${parentId})`)
    }
    customBuffer.push('ÖNEMLİ: Eğer fiş içeriği yukarıdaki özel alt kategorilerden biriyle eşleşiyorsa, categoryId olarak tam olarak o özel kategoriye ait ID değerini döndür.')
  }
  const customText = customBuffer.join('\n')

  return `
Sen bir fatura ve fiş analiz yapay zekasısın. Gönderilen fiş görselini inceleyerek harcama bilgilerini çıkar.

Kurallar:
1. Fişin kesildiği işletme adını (başlık), toplam tutarı (amount), fiş üzerindeki tarihi (date) ve kategoriyi belirle. Fişin kesildiği işletme adını (başlık) belirlerken resmi şirket unvanlarını (örn. 'TİC. A.Ş.', 'LTD. ŞTİ.', 'A.Ş.', 'A. S.', 'LTD. STI.') veya şube isimlerini temizle. Sadece bilinen marka/işletme adını sade ve kısa bir şekilde yaz (örn: 'ŞOK MARKETLER TİC. A.Ş.' veya 'ŞOK MARKET' yerine sadece 'Şok', 'MİGROS TİCARET A.Ş.' yerine sadece 'Migros', 'STARBUCKS KAHVE SANA' yerine sadece 'Starbucks').
2. Tarihi bulamazsan bugünün tarihini kullan. Tarih formatı YYYY-MM-DD olmalı.
3. Kategori olarak aşağıdaki ID'lerden en uygun olanını seç. Eğer fiş içeriği spesifik bir alt kategoriye tam uymuyorsa, doğrudan ana kategori ID'sini seç (örn: \`exp_grocery\`, \`exp_dining\` vb.):
   - exp_grocery (Market) -> Alt: exp_grocery_food, exp_grocery_cleaning, exp_grocery_drink, exp_grocery_pet, exp_grocery_hygiene, exp_grocery_tobacco, exp_grocery_alcohol
   - exp_dining (Yemek) -> Alt: exp_dining_restaurant, exp_dining_fastfood, exp_dining_cafe, exp_dining_delivery, exp_dining_canteen
   - exp_car (Araç) -> Alt: exp_car_fuel
   - exp_cloth (Giyim) -> Alt: exp_cloth_daily
   - exp_beauty (Kişisel Bakım) -> Alt: exp_beauty_salon, exp_beauty_cosmetics, exp_beauty_esthetics
   - exp_travel (Seyahat) -> Alt: exp_travel_flight, exp_travel_hotel
   - exp_shopping (Alışveriş) -> Alt: exp_shopping_tech, exp_shopping_furniture, exp_shopping_decor, exp_shopping_kitchen, exp_shopping_gift, exp_shopping_general, exp_shopping_sports, exp_shopping_shipping
   - exp_health (Sağlık) -> Alt: exp_health_doctor, exp_health_medicine, exp_health_dentist, exp_health_optics
   - exp_other (Diğer) -> Alt: exp_other_general, exp_other_bank_fee
   - transfer -> Kendi kasaların/hesapların arası para transferi (para çekme, para yatırma, virman).
${customText}
4. Fişteki ürünleri karmaşık kodlar, barkod sayıları, detaylı marka-model bilgileri gibi kirliliklerden arındırarak çok kısa, sade ve anlaşılır bir alışveriş özeti halinde, yan yana tek satırda aralarına virgül koyarak ve her ürünün başına madde işareti (•) ekleyerek (varsa adet, kg, litre, gram gibi miktar/nicelik bilgilerini de ekleyerek, örn. '• 2 adet Süt, • 1 kg Nohut, • 1.5 L Kola') "note" alanına yaz.
5. EĞER YÜKLENEN GÖRSEL GEÇERLİ BİR FİŞ VEYA FATURA DEĞİLSE ya da görselden hiçbir harcama/fiş bilgisi okunamıyorsa, "amount" değerini tam olarak -1.0 yap, "title" alanına "Okunamadı" yaz ve "note" alanına bunun nedenini detaylıca Türkçe olarak açıkla.
6. Sadece JSON formatında, kod blokları (markdown \`\`\`) olmadan şu şemaya göre yanıt dön:
{
  "title": "Mağaza/İşletme Adı",
  "amount": 789.50,
  "categoryId": "kategori_id",
  "date": "YYYY-MM-DD",
  "note": "Ürünlerin özeti"
}
  `
}
