import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'draft_service.dart';
import '../../../core/services/custom_category_service.dart';

class SmartParserService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static GenerativeModel _getModel() {
    final key = _apiKey.isNotEmpty ? _apiKey : dotenv.get('GEMINI_API_KEY', fallback: '');

    if (key.isEmpty) {
      throw Exception('Gemini API Key bulunamadı.');
    }

    return GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.2, // Doğruluk için düşük sıcaklık
      ),
    );
  }

  static bool get isAvailable =>
      _apiKey.isNotEmpty || dotenv.get('GEMINI_API_KEY', fallback: '').isNotEmpty;

  /// Serbest metni veya ses transkripsiyonunu analiz eder
  static Future<DraftTransaction> parseText(String text) async {
    final id = const Uuid().v4();
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return DraftTransaction(
        id: id,
        title: 'Boş Taslak',
        amount: 0.0,
        date: DateTime.now(),
      );
    }

    if (!isAvailable) {
      throw Exception('Yapay Zeka analizi için internet bağlantısı ve API anahtarı gereklidir.');
    }

    try {
      final model = _getModel();
      final customCategories = await CustomCategoryService.getAllCustomSubcategories();
      final prompt = _buildTextPrompt(cleanText, customCategories);

      final response = await model.generateContent([Content.text(prompt)]).timeout(
        const Duration(seconds: 15),
      );

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Boş yanıt alındı');
      }

      final cleaned = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleaned);

      return DraftTransaction(
        id: id,
        title: data['title'] ?? _capitalize(cleanText),
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        minAmount: data['minAmount'] != null ? (data['minAmount'] as num).toDouble() : null,
        maxAmount: data['maxAmount'] != null ? (data['maxAmount'] as num).toDouble() : null,
        categoryId: data['categoryId'] ?? 'exp_other_general',
        date: data['date'] != null ? DateTime.tryParse(data['date']) ?? DateTime.now() : DateTime.now(),
        isIncome: data['isIncome'] ?? false,
        note: data['note'],
        reason: 'Hızlı Metin Girişi',
        currency: data['currency'],
        isNotificationEnabled: data['isNotificationEnabled'] ?? false,
        notificationReminderDays: data['notificationReminderDays'] ?? 0,
        notificationHour: data['notificationHour'] ?? 9,
        notificationMinute: data['notificationMinute'] ?? 0,
        vaultName: data['vaultName'],
        periodType: data['periodType'] ?? 0,
        remainingInstallments: data['remainingInstallments'],
        recurrenceDay: data['recurrenceDay'],
        recurrenceDuration: data['recurrenceDuration'],
      );
    } catch (e) {
      debugPrint('❌ [SmartParserService] AI Parse hatası: $e');
      throw Exception('Yapay Zeka analizi başarısız oldu. Lütfen internet bağlantınızı kontrol edin.');
    }
  }

  /// Fiş görselini analiz edip harcama bilgisi çıkarır (Gemini Vision)
  static Future<DraftTransaction?> parseReceiptImage(Uint8List imageBytes, String mimeType) async {
    if (!isAvailable) {
      throw Exception('Fiş okuma için internet bağlantısı ve API anahtarı gereklidir.');
    }

    try {
      final model = _getModel();
      final customCategories = await CustomCategoryService.getAllCustomSubcategories();
      final prompt = _buildReceiptPrompt(customCategories);
      final content = [
        Content.multi([
          DataPart(mimeType, imageBytes),
          TextPart(prompt),
        ])
      ];

      final response = await model.generateContent(content).timeout(
        const Duration(seconds: 25),
      );

      final responseText = response.text;
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Görselden veri okunamadı.');
      }

      final cleaned = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleaned);

      final id = const Uuid().v4();
      return DraftTransaction(
        id: id,
        title: data['title'] ?? 'Fiş Harcaması',
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        categoryId: data['categoryId'] ?? 'exp_grocery_food',
        date: data['date'] != null ? DateTime.tryParse(data['date']) ?? DateTime.now() : DateTime.now(),
        isIncome: false,
        note: data['note'],
        reason: 'Fiş Fotoğrafı',
        currency: data['currency'],
      );
    } catch (e) {
      debugPrint('❌ [SmartParserService] Fiş görseli analiz hatası: $e');
      throw Exception('Fiş okunamadı. Lütfen internet bağlantınızı kontrol edin.');
    }
  }

  /// Panodaki (Clipboard) metni analiz edip banka SMS'i veya harcama bildirimi olup olmadığını kontrol eder
  static Future<DraftTransaction?> checkAndParseClipboard(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || cleanText.length < 15) return null;

    // Basit bir ön kontrol: İçinde "harcama", "ödeme", "tutar", "TL", "lira", "nolu kart", "hesabınızdan" vb. geçiyor mu?
    final trText = cleanText.toLowerCase();
    final isFinancial = trText.contains('tl') ||
        trText.contains('lira') ||
        trText.contains('harcama') ||
        trText.contains('ödeme') ||
        trText.contains('kart') ||
        trText.contains('hesabından') ||
        trText.contains('para transferi');

    if (!isFinancial) return null;

    try {
      // AI yardımıyla bu SMS'i çözümleriz
      final parsed = await parseText(cleanText);
      if (parsed.amount > 0 || parsed.minAmount != null) {
        return DraftTransaction(
          id: parsed.id,
          title: parsed.title,
          amount: parsed.amount,
          minAmount: parsed.minAmount,
          maxAmount: parsed.maxAmount,
          categoryId: parsed.categoryId,
          date: parsed.date,
          isIncome: parsed.isIncome,
          note: parsed.note ?? 'Kopyalanan Metinden Yakalandı',
          reason: 'Pano Bildirimi',
          currency: parsed.currency,
          isNotificationEnabled: parsed.isNotificationEnabled,
          notificationReminderDays: parsed.notificationReminderDays,
          notificationHour: parsed.notificationHour,
          notificationMinute: parsed.notificationMinute,
          vaultName: parsed.vaultName,
          periodType: parsed.periodType,
          remainingInstallments: parsed.remainingInstallments,
          recurrenceDay: parsed.recurrenceDay,
          recurrenceDuration: parsed.recurrenceDuration,
        );
      }
    } catch (_) {}
    return null;
  }

  static String _getParentCategoryName(String id) {
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

  static String _buildTextPrompt(String text, List<Map<String, String>> customCategories) {
    final customBuffer = StringBuffer();
    if (customCategories.isNotEmpty) {
      customBuffer.writeln('\nKullanıcı Tanımlı Özel Alt Kategoriler:');
      for (final custom in customCategories) {
        final id = custom['id'] ?? '';
        final name = custom['name'] ?? '';
        final parentId = custom['parentId'] ?? '';
        final parentName = _getParentCategoryName(parentId);
        customBuffer.writeln('- $id: "$name" (Ana Kategori: "$parentName" - $parentId)');
      }
      customBuffer.writeln('ÖNEMLİ: Eğer harcama/gelir yukarıdaki özel alt kategorilerden biriyle eşleşiyorsa, categoryId olarak tam olarak o özel kategoriye ait ID değerini döndür.');
    }

    return '''
Sen bir kişisel finans yapay zekasısın. Sana gelen serbest metni analiz ederek bir harcama veya gelir işlemine dönüştür.
Bugün: ${DateTime.now().toIso8601String().split('T')[0]} (Gün: ${_getTurkishDayName(DateTime.now().weekday)})

Kurallar:
1. Başlık (title): İşlemin yapıldığı yerin/markanın adını yaz (örn: "Migros", "Starbucks", "Bim", "Shell"). Eğer marka/yer adı belirtilmemişse genel bir kategori/hizmet adı kullan (örn: "Borç Ödemesi", "Restoran", "Market", "Taksi", "Fatura", "Maaş"). Spesifik aldığın/yediğin ürünleri veya detayları (örn: "Tost", "Yoğurt", "Filtre Kahve") başlık alanına yazma; başlık genel kalsın.
2. Tutar (amount): Metindeki harcama veya gelir miktarını sayısal olarak çıkar. Metinde sayısal tutar olarak ne geçiyorsa tam olarak onu al (örneğin "500 gram altın" ifadesinde tutar 500.0'dir; "500 TL" ifadesinde 500.0'dir). Metinde sayısal bir tutar yoksa veya bir tutar aralığı belirtilmişse 0.0 değerini döndür (tarih/gün sayısını tutar olarak algılama!).
3. Esnek/Aralıklı Tutar (minAmount ve maxAmount): Eğer kullanıcı net tek bir tutar yerine bir tutar aralığı belirtirse (örn: "100 200 arası", "150-200 TL civarında", "100 ile 200 lira"), amount değerini 0.0 yap; bu aralığın alt limitini minAmount (örn: 100.0) ve üst limitini maxAmount (örn: 200.0) olarak döndür. Net bir aralık yoksa minAmount ve maxAmount alanlarını null yap.
4. Tarih (date): Bugünün tarihini (${DateTime.now().toIso8601String().split('T')[0]}) baz alarak "dün", "yarın", "2 gün sonra", "pazartesi günü" gibi zaman belirteçlerini hesapla ve ISO formatında (YYYY-MM-DD) döndür. Örneğin "yarın" deniyorsa yarına ait tarihi ver. Belirtilmemişse bugünü yaz.
5. Not (note): Aldığın/yediğin ürünleri veya yaptığın spesifik harcama detaylarını bu alana yaz (örn: "Arkadaşa 500 gram altın borcu", "Tost yedik", "Yoğurt alındı"). Böylece harcama detayları not alanında saklanır. Eğer girdi metninde marka/yer adı dışında fazladan hiçbir detay yoksa not alanını boş ("") veya null bırak.
6. İşlem Tipi (isIncome): Eğer metin bir gelir (maaş, burs, birinden alınan para, iade, satış kazancı vb.) belirtiyorsa true, gider belirtiyorsa false yap.
7. Para Birimi (currency): Metinde geçen para birimini ya da birim sembolünü çıkar. Desteklenen semboller şunlardır:
   - '₺' (Türk Lirası, TL, lira vb. için)
   - '\$' (Dolar, USD vb. için)
   - '€' (Euro, Avro vb. için)
   - '£' (Sterlin, GBP vb. için)
   - 'G' (Altın, gram altın, gr altın vb. için)
   - 'Ag' (Gümüş, gram gümüş, gr gümüş vb. için)
   - Diğerleri: '¥' (Yen), '₩' (Won), '元' (Yuan), 'R\$' (Real), 'Fr' (Frank), 'SR' (Riyal), 'KD' (Dinar).
   Metinde bu birimlerden hangisi veya hangisinin karşılığı geçiyorsa tam olarak o sembolü döndür (örn: metinde 'gram altın' veya 'altın' geçiyorsa 'G' döndür; 'dolar' veya '\$' geçiyorsa '\$' döndür; belirtilmemişse null veya '₺' döndür).
8. Hatırlatıcı Ayarları (Reminders):
   Metinde "hatırlat", "alarm kur", "bildirim gönder" vb. bir hatırlatıcı/uyarı talebi olup olmadığını kontrol et.
   - isNotificationEnabled: Hatırlatıcı talebi varsa true, yoksa false döndür.
   - notificationReminderDays: Hatırlatmanın, işlem tarihinden (date) kaç gün önce yapılacağını gösteren tamsayı. Örneğin: İşlem tarihi yarın ise ve "bugün hatırlat" denmişse, aradaki fark 1 gündür, yani 1 döndür. İşlem günü hatırlatılacaksa 0 döndür.
   - notificationHour: Hatırlatılacak saat (24 saatlik formatta tamsayı, 0-23 arası). Örneğin: "akşam 8" -> 20, "sabah 9" -> 9. Saat belirtilmemiş ama hatırlatıcı istenmişse varsayılan olarak 9 döndür.
   - notificationMinute: Hatırlatacak dakika (0-59 arası tamsayı). Belirtilmemişse varsayılan olarak 0 döndür.
9. Kasa/Hesap Belirteci (vaultName): Kullanıcı işlemin belirli bir kasa veya hesap üzerinden yapılacağını belirtiyorsa (örn: "ortak kasa", "maaş hesabı", "dolar kasası", "ana kasa"), bu kasa ismini metinden aynen çıkarıp döndür. Herhangi bir kasa adı geçmiyorsa null döndür.
10. Tekrarlama/Periyot (periodType): Eğer işlem periyodik veya tekrarlayan bir işlem ise (örn: "her ay", "haftalık", "yıllık", "günlük"), periyot tipini şu tamsayı kodlarından birine göre döndür:
    - 0: Tek Seferlik (Herhangi bir tekrarlama belirtilmemişse varsayılan)
    - 1: Haftalık ("her hafta", "haftalık" vb.)
    - 2: Aylık ("her ay", "aylık", "ayda bir" vb.)
    - 3: Yıllık ("her yıl", "yıllık" vb.)
    - 4: İki Haftada Bir ("15 günde bir", "2 haftada bir")
    - 5: Üç Haftada Bir
    - 6: Üç Ayda Bir
    - 7: Altı Ayda Bir
    - 8: Günlük ("her gün", "günlük")
    - 9: İki Günde Bir
    - 10: Üç Günde Bir
11. Tekrarlama Günü (recurrenceDay): Eğer işlem periyodik ise (periodType > 0) tekrarlama gününü hesapla:
    - Eğer haftalık (periodType = 1) veya 2 haftalık (4), 3 haftalık (5) ise, haftanın gününü tamsayı olarak döndür (1: Pazartesi, 2: Salı, 3: Çarşamba, 4: Perşembe, 5: Cuma, 6: Cumartesi, 7: Pazar). Örn: 'her Salı' -> 2.
    - Eğer aylık (periodType = 2) veya 3 aylık (6), 6 aylık (7) ise, ayın gününü tamsayı (1-31 arası) döndür. Örn: 'her ayın 15'i' -> 15.
    - Belirtilmemişse null döndür.
12. Tekrarlama Süresi (recurrenceDuration): Periyodik işlemin toplam kaç kez tekrar edeceğini (kaç periyot süreceğini) belirtiyorsa tamsayı olarak döndür (örn: '3 ay boyunca her ay' -> 3, '5 hafta boyunca her hafta' -> 5). Belirtilmemiş veya süresiz/sonsuz ise null döndür.
13. Taksit Sayısı (remainingInstallments): Kullanıcı işlemin taksitli olduğunu belirtiyorsa (örn: "6 taksitli", "12 ay taksitle"), taksit sayısını tamsayı olarak döndür. Taksit belirtilmemişse null döndür.
14. Kategori Eşleştirme (categoryId): Aşağıdaki kategorilerden en uygun olanının "ID" değerini seç.
    Kural: Harcama/gelir detayına göre en spesifik **Alt Kategoriyi** seç. Eğer harcama/gelir detayından spesifik bir alt kategori netleştirilemiyorsa, doğrudan genel **Ana Kategori** ID'sini (örn: `exp_grocery`, `exp_dining`, `inc_salary` vb.) seç.

    **GİDERLER (isIncome = false ise):**
    - exp_grocery (Market Ana Kategorisi - alt kategorilere uymayan genel market harcamaları için)
      Alt Kategoriler: exp_grocery_food (Gıda/yiyecek/içecek), exp_grocery_cleaning (Temizlik malzemesi/deterjan), exp_grocery_personal (Kişisel bakım/şampuan/diş macunu vb.), exp_grocery_pet (Evcil hayvan/mama/kum)
    
    - exp_dining (Dışarıda Yemek Ana Kategorisi - genel restoran/yemek harcamaları)
      Alt Kategoriler: exp_dining_restaurant (Restoran/yemek), exp_dining_fastfood (Burger/pizza/fastfood/döner vb.), exp_dining_cafe (Kahve/çay/kafe/pastane), exp_dining_delivery (Eve sipariş/paket servis)
    
    - exp_rent (Kira Ana Kategorisi - genel kira giderleri)
      Alt Kategoriler: exp_rent_home (Ev kirası), exp_rent_office (Ofis kirası), exp_rent_storage (Depo kirası)
    
    - exp_bill (Fatura Ana Kategorisi - genel faturalar)
      Alt Kategoriler: exp_bill_electricity (Elektrik faturası), exp_bill_water (Su faturası), exp_bill_gas (Doğalgaz faturası), exp_bill_internet (İnternet faturası), exp_bill_phone (Telefon faturası), exp_bill_dues (Site/apartman aidatı)
    
    - exp_home (Ev Ana Kategorisi - genel ev giderleri)
      Alt Kategoriler: exp_home_furniture (Mobilya/dekorasyon), exp_home_maintenance (Ev tadilatı/tesisat), exp_home_supplies (Ev alışverişi/mutfak gereçleri), exp_home_garden (Bahçe/bitki/toprak)
    
    - exp_fun (Eğlence Ana Kategorisi - genel eğlence masrafları)
      Alt Kategoriler: exp_fun_cinema (Sinema), exp_fun_concert (Konser/festival), exp_fun_event (Etkinlik, tiyatro, müze, lunapark vb.), exp_fun_hobby (Hobi malzemeleri)
    
    - exp_sub (Abonelik Ana Kategorisi - genel abonelikler)
      Alt Kategoriler: exp_sub_stream (Dizi/film - Netflix/Exxen vb.), exp_sub_music (Müzik - Spotify vb.), exp_sub_software (Yazılım/lisans/iCloud vb.), exp_sub_gym (Spor salonu/fitness)
    
    - exp_health (Sağlık Ana Kategorisi - genel sağlık harcamaları)
      Alt Kategoriler: exp_health_doctor (Muayene/hastane), exp_health_medicine (İlaç/eczane), exp_health_surgery (Ameliyat/operasyon), exp_health_dentist (Diş hekimi)
    
    - exp_trans (Ulaşım/Seyahat Ana Kategorisi - genel ulaşım/seyahat harcamaları)
      Alt Kategoriler: exp_trans_taxi (Taksi/Uber), exp_trans_bus (Metro/akbil/toplu taşıma), exp_trans_train (Tren/YHT), exp_trans_flight (Uçak bileti), exp_trans_travel (Seyahat/konaklama/otel/tatil)
    
    - exp_car (Araç Ana Kategorisi - genel araç masrafları)
      Alt Kategoriler: exp_car_fuel (Akaryakıt/benzin/yakıt), exp_car_maintenance (Araç bakımı/tamir/lastik), exp_car_insurance (Kasko/sigorta), exp_car_parking (Otopark/HGS/köprü geçişi)
    
    - exp_cloth (Giyim Ana Kategorisi - genel giyim harcamaları)
      Alt Kategoriler: exp_cloth_daily (Günlük giyim/kıyafet), exp_cloth_shoes (Ayakkabı/bot), exp_cloth_acc (Aksesuar, çanta, cüzdan, saat vb.)
    
    - exp_beauty (Güzellik Ana Kategorisi - genel güzellik masrafları)
      Alt Kategoriler: exp_beauty_salon (Kuaför/berber/güzellik salonu), exp_beauty_cosmetics (Makyaj/kozmetik/parfüm), exp_beauty_spa (Spa/masaj)
    
    - exp_edu (Eğitim Ana Kategorisi - genel eğitim)
      Alt Kategoriler: exp_edu_course (Kurs/online eğitim), exp_edu_book (Kitap/kırtasiye), exp_edu_school (Okul taksitleri/harç)
    
    - exp_family (Aile Ana Kategorisi - genel aile masrafları)
      Alt Kategoriler: exp_family_baby (Bebek bezi/maması/giyim vb.), exp_family_toy (Çocuk oyuncağı), exp_family_allowance (Verilen harçlık)
    
    - exp_debt (Borç Ana Kategorisi - genel borç giderleri)
      Alt Kategoriler: exp_debt_credit_card (Kredi kartı ödemesi), exp_debt_loan (Kredi taksiti), exp_debt_personal (Şahsi borç ödeme/borç verme)
    
    - exp_tax (Vergi Ana Kategorisi - genel vergiler)
      Alt Kategoriler: exp_tax_income (Gelir/kurumlar vergisi), exp_tax_fine (Trafik/vergi cezası), exp_tax_fee (Pasaport/ehliyet harcı)
    
    - exp_invest (Yatırım Ana Kategorisi - genel yatırımlar)
      Alt Kategoriler: exp_invest_gold (Altın/döviz/gümüş alımı), exp_invest_stock (Borsa/hisse/fon), exp_invest_crypto (Kripto para/Bitcoin), exp_invest_savings (Birikim/mevduat)
    
    - exp_other (Diğer Ana Kategorisi - diğer giderler)
      Alt Kategoriler: exp_other_general (Diğer genel giderler), exp_other_donation (Bağış/yardım), exp_other_insurance (DASK/konut/sağlık sigortası)

    **GELİRLER (isIncome = true ise):**
    - inc_salary (Maaş Ana Kategorisi - genel maaş geliri)
      Alt Kategoriler: inc_salary_main (Ana iş maaşı), inc_salary_bonus (Prim/ikramiye/mesai), inc_salary_dividend (Hisse temettü geliri), inc_salary_pension (Emeklilik maaşı)
    
    - inc_extra (Ek Gelir Ana Kategorisi - genel ek gelir)
      Alt Kategoriler: inc_extra_freelance (Freelance/proje geliri), inc_extra_parttime (Yarı zamanlı/part-time), inc_extra_commission (Komisyon/aracılık geliri)
    
    - inc_invest (Yatırım Ana Kategorisi - genel yatırım gelirleri)
      Alt Kategoriler: inc_invest_stock (Hisse/fon satış kârı), inc_invest_crypto (Kripto satış kârı), inc_invest_interest (Vadeli faiz geliri), inc_invest_gold (Döviz/altın kâr satışı), inc_invest_property (Ev/arsa satış geliri)
    
    - inc_scholarship (Burs Ana Kategorisi - genel burslar)
      Alt Kategoriler: inc_scholarship_award (Öğrenci bursu), inc_scholarship_loan (Öğrenim kredisi), inc_scholarship_gov (Sosyal/aile yardımı)
    
    - inc_sale (Satış Ana Kategorisi - genel satış gelirleri)
      Alt Kategoriler: inc_sale_online (E-ticaret geliri), inc_sale_physical (İkinci el Letgo/Dolap satışı)
    
    - inc_rent (Kira Ana Kategorisi - genel kira gelirleri)
      Alt Kategoriler: inc_rent_home (Ev kira geliri), inc_rent_office (İş yeri/ofis kira geliri), inc_rent_car (Araç kira geliri)
    
    - inc_gift (Hediye Ana Kategorisi - genel hediyeler)
      Alt Kategoriler: inc_gift_general (Hediye para/harçlık), inc_gift_award (Yarışma/ödül kazancı)
    
    - inc_other (Diğer Gelir Ana Kategorisi - diğer gelirler)
      Alt Kategoriler: inc_other_general (Diğer genel gelirler), inc_other_refund (Alışveriş iadesi), inc_other_lottery (Şans oyunları/bahis)
$customBuffer

15. Sadece JSON formatında, kod blokları (markdown ```) olmadan şu şemaya göre yanıt dön:
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

Girdi Metni: "$text"
''';
  }

  static String _buildReceiptPrompt(List<Map<String, String>> customCategories) {
    final customBuffer = StringBuffer();
    if (customCategories.isNotEmpty) {
      customBuffer.writeln('\nKullanıcı Tanımlı Özel Alt Kategoriler:');
      for (final custom in customCategories) {
        final id = custom['id'] ?? '';
        final name = custom['name'] ?? '';
        final parentId = custom['parentId'] ?? '';
        final parentName = _getParentCategoryName(parentId);
        customBuffer.writeln('- $id: "$name" (Ana Kategori: "$parentName" - $parentId)');
      }
      customBuffer.writeln('ÖNEMLİ: Eğer fiş içeriği yukarıdaki özel alt kategorilerden biriyle eşleşiyorsa, categoryId olarak tam olarak o özel kategoriye ait ID değerini döndür.');
    }

    return '''
Sen bir fatura ve fiş analiz yapay zekasısın. Gönderilen fiş görselini inceleyerek harcama bilgilerini çıkar.

Kurallar:
1. Fişin kesildiği işletme adını (başlık), toplam tutarı (amount), fiş üzerindeki tarihi (date) ve kategoriyi belirle.
2. Tarihi bulamazsan bugünün tarihini kullan. Tarih formatı YYYY-MM-DD olmalı.
3. Kategori olarak aşağıdaki ID'lerden en uygun olanını seç. Eğer fiş içeriği spesifik bir alt kategoriye tam uymuyorsa, doğrudan ana kategori ID'sini seç (örn: `exp_grocery`, `exp_dining` vb.):
   - exp_grocery (Market Ana Kategorisi)
     Alt Kategoriler: exp_grocery_food (Gıda/yiyecek/içecek), exp_grocery_cleaning (Temizlik malzemesi vb.), exp_grocery_personal (Kişisel bakım), exp_grocery_pet (Evcil hayvan)
   - exp_dining (Dışarıda Yemek Ana Kategorisi)
     Alt Kategoriler: exp_dining_restaurant (Restoran/yemek), exp_dining_fastfood (Burger/pizza/fastfood vb.), exp_dining_cafe (Starbucks/Kafe), exp_dining_delivery (Eve sipariş)
   - exp_car (Araç Ana Kategorisi)
     Alt Kategoriler: exp_car_fuel (Akaryakıt/benzin)
   - exp_cloth (Giyim Ana Kategorisi)
     Alt Kategoriler: exp_cloth_daily (Giyim mağazaları vb.)
   - exp_beauty (Güzellik Ana Kategorisi)
     Alt Kategoriler: exp_beauty_salon (Kuaför/berber), exp_beauty_cosmetics (Kozmetik vb.)
   - exp_trans (Ulaşım/Seyahat Ana Kategorisi)
     Alt Kategoriler: exp_trans_travel (Seyahat, otobüs/uçak bileti)
   - exp_other (Diğer Ana Kategorisi)
     Alt Kategoriler: exp_other_general (Diğer her şey)
$customBuffer
4. Fişteki ürünleri karmaşık kodlar, barkod sayıları, detaylı marka-model bilgileri gibi kirliliklerden arındırarak çok kısa, sade ve anlaşılır bir alışveriş özeti halinde "note" alanına yaz. Benzer veya aynı türdeki ürünleri nitelik ve nicelik olarak sadeleştirip gruplayarak yazabilirsin (örn: "Süt x2, Yoğurt, Ekmek" veya "Kahve, Kek"). Gereksiz uzunluktaki ve kafa karıştırıcı fiş yazılarını temizle.
5. Sadece JSON formatında, kod blokları (markdown ```) olmadan şu şemaya göre yanıt dön:
{
  "title": "Mağaza/İşletme Adı",
  "amount": 789.50,
  "categoryId": "kategori_id",
  "date": "YYYY-MM-DD",
  "note": "Ürünlerin özeti"
}
''';
  }

  static String _getTurkishDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Pazartesi';
      case 2: return 'Salı';
      case 3: return 'Çarşamba';
      case 4: return 'Perşembe';
      case 5: return 'Cuma';
      case 6: return 'Cumartesi';
      case 7: return 'Pazar';
      default: return '';
    }
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
