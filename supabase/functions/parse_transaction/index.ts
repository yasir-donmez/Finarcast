import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

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
    case 'exp_grocery': return 'Market';
    case 'exp_dining': return 'Dışarıda Yemek';
    case 'exp_rent': return 'Kira';
    case 'exp_bill': return 'Fatura';
    case 'exp_home': return 'Ev';
    case 'exp_fun': return 'Eğlence';
    case 'exp_sub': return 'Abonelik';
    case 'exp_health': return 'Sağlık';
    case 'exp_trans': return 'Ulaşım';
    case 'exp_car': return 'Araç';
    case 'exp_cloth': return 'Giyim';
    case 'exp_beauty': return 'Güzellik';
    case 'exp_edu': return 'Eğitim';
    case 'exp_family': return 'Aile';
    case 'exp_debt': return 'Borç';
    case 'exp_tax': return 'Vergi';
    case 'exp_invest': return 'Yatırım';
    case 'exp_other': return 'Diğer';
    case 'inc_salary': return 'Maaş';
    case 'inc_extra': return 'Ek Gelir';
    case 'inc_invest': return 'Yatırım';
    case 'inc_scholarship': return 'Burs';
    case 'inc_sale': return 'Satış';
    case 'inc_rent': return 'Kira';
    case 'inc_gift': return 'Hediye';
    case 'inc_other': return 'Diğer';
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
9. Kasa/Hesap Belirteci (vaultName): Kullanıcı belirli bir kasa/hesap belirtiyorsa (örn: "ortak kasa", "maaş hesabı", "ana kasa"), bu kasa ismini metinden aynen çıkarıp döndür. Yoksa null döndür.
10. Tekrarlama/Periyot (periodType): Eğer işlem periyodik ise şu kodlardan birini döndür:
    - 0: Tek Seferlik, 1: Haftalık, 2: Aylık, 3: Yıllık, 4: İki Haftada Bir, 8: Günlük.
11. Tekrarlama Günü (recurrenceDay): Haftalık ise gün (1-7), aylık ise ayın günü (1-31).
12. Tekrarlama Süresi (recurrenceDuration): Toplam kaç kez tekrar edeceğini gösteren sayı.
13. Taksit Sayısı (remainingInstallments): Taksit sayısı.
14. Kategori Eşleştirme (categoryId): Aşağıdaki kategorilerden en uygun olanının "ID" değerini seç. En spesifik Alt Kategoriyi seçmeye çalış.

    **GİDERLER (isIncome = false):**
    - exp_grocery (Market) -> Alt Kategoriler: exp_grocery_food (Gıda/yiyecek/içecek), exp_grocery_cleaning (Temizlik), exp_grocery_personal (Kişisel bakım), exp_grocery_pet (Evcil hayvan)
    - exp_dining (Dışarıda Yemek) -> Alt Kategoriler: exp_dining_restaurant (Restoran), exp_dining_fastfood (Fastfood), exp_dining_cafe (Kahve/kafe), exp_dining_delivery (Eve sipariş)
    - exp_rent (Kira) -> Alt Kategoriler: exp_rent_home (Ev), exp_rent_office (Ofis)
    - exp_bill (Fatura) -> Alt Kategoriler: exp_bill_electricity (Elektrik), exp_bill_water (Su), exp_bill_gas (Doğalgaz), exp_bill_internet (İnternet), exp_bill_phone (Telefon), exp_bill_dues (Aidat)
    - exp_home (Ev) -> Alt Kategoriler: exp_home_furniture (Mobilya), exp_home_maintenance (Tadilat), exp_home_supplies (Gereçler), exp_home_garden (Bahçe)
    - exp_fun (Eğlence) -> Alt Kategoriler: exp_fun_cinema, exp_fun_concert, exp_fun_event, exp_fun_hobby
    - exp_sub (Abonelik) -> Alt Kategoriler: exp_sub_stream, exp_sub_music, exp_sub_software, exp_sub_gym
    - exp_health (Sağlık) -> Alt Kategoriler: exp_health_doctor, exp_health_medicine, exp_health_surgery, exp_health_dentist
    - exp_trans (Ulaşım) -> Alt Kategoriler: exp_trans_taxi, exp_trans_bus, exp_trans_train, exp_trans_flight, exp_trans_travel (Seyahat/Otel)
    - exp_car (Araç) -> Alt Kategoriler: exp_car_fuel (Akaryakıt), exp_car_maintenance (Tamir), exp_car_insurance (Kasko), exp_car_parking (Otopark/HGS)
    - exp_cloth (Giyim) -> Alt Kategoriler: exp_cloth_daily, exp_cloth_shoes, exp_cloth_acc (Aksesuar)
    - exp_beauty (Güzellik) -> Alt Kategoriler: exp_beauty_salon (Kuaför), exp_beauty_cosmetics (Kozmetik)
    - exp_edu (Eğitim) -> Alt Kategoriler: exp_edu_course, exp_edu_book, exp_edu_school
    - exp_family (Aile) -> Alt Kategoriler: exp_family_baby, exp_family_toy, exp_family_allowance (Harçlık)
    - exp_debt (Borç) -> Alt Kategoriler: exp_debt_credit_card, exp_debt_loan, exp_debt_personal (Borç Ödeme/Verme)
    - exp_tax (Vergi) -> Alt Kategoriler: exp_tax_income, exp_tax_fine (Ceza), exp_tax_fee (Harc)
    - exp_invest (Yatırım) -> Alt Kategoriler: exp_invest_gold (Altın/Döviz), exp_invest_stock (Hisse/Fon), exp_invest_crypto, exp_invest_savings
    - exp_other (Diğer) -> Alt Kategoriler: exp_other_general, exp_other_donation, exp_other_insurance

    **GELİRLER (isIncome = true):**
    - inc_salary (Maaş) -> Alt Kategoriler: inc_salary_main, inc_salary_bonus, inc_salary_dividend (Temettü), inc_salary_pension
    - inc_extra (Ek Gelir) -> Alt Kategoriler: inc_extra_freelance, inc_extra_parttime, inc_extra_commission
    - inc_invest (Yatırım) -> Alt Kategoriler: inc_invest_stock, inc_invest_crypto, inc_invest_interest, inc_invest_gold, inc_invest_property
    - inc_scholarship (Burs) -> Alt Kategoriler: inc_scholarship_award, inc_scholarship_loan, inc_scholarship_gov
    - inc_sale (Satış) -> Alt Kategoriler: inc_sale_online, inc_sale_physical
    - inc_rent (Kira) -> Alt Kategoriler: inc_rent_home, inc_rent_office, inc_rent_car
    - inc_gift (Hediye) -> Alt Kategoriler: inc_gift_general, inc_gift_award
    - inc_other (Diğer) -> Alt Kategoriler: inc_other_general, inc_other_refund, inc_other_lottery

${customText}

15. Sadece JSON formatında, kod blokları (markdown \`\`\`) olmadan şu şemaya göre yanıt dön:
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
1. Fişin kesildiği işletme adını (başlık), toplam tutarı (amount), fiş üzerindeki tarihi (date) ve kategoriyi belirle.
2. Tarihi bulamazsan bugünün tarihini kullan. Tarih formatı YYYY-MM-DD olmalı.
3. Kategori olarak aşağıdaki ID'lerden en uygun olanını seç. Eğer fiş içeriği spesifik bir alt kategoriye tam uymuyorsa, doğrudan ana kategori ID'sini seç (örn: \`exp_grocery\`, \`exp_dining\` vb.):
   - exp_grocery (Market) -> Alt: exp_grocery_food, exp_grocery_cleaning, exp_grocery_personal, exp_grocery_pet
   - exp_dining (Dışarıda Yemek) -> Alt: exp_dining_restaurant, exp_dining_fastfood, exp_dining_cafe, exp_dining_delivery
   - exp_car (Araç) -> Alt: exp_car_fuel
   - exp_cloth (Giyim) -> Alt: exp_cloth_daily
   - exp_beauty (Güzellik) -> Alt: exp_beauty_salon, exp_beauty_cosmetics
   - exp_trans (Ulaşım) -> Alt: exp_trans_travel
   - exp_other (Diğer) -> Alt: exp_other_general
${customText}
4. Fişteki ürünleri karmaşık kodlar, barkod sayıları, detaylı marka-model bilgileri gibi kirliliklerden arındırarak çok kısa, sade ve anlaşılır bir alışveriş özeti halinde "note" alanına yaz.
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
