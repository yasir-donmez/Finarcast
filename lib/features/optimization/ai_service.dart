import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/database/models/transaction_record.dart';
import '../../core/database/models/vault.dart';
import '../../core/database/models/financial_goal.dart';

/// Gemini AI entegrasyonu — Persona üretimi + Tasarruf stratejisi
class AiService {
  // API Key'i buraya güvenli şekilde alıyoruz.
  // Gerçek projede --dart-define veya .env dosyasından alınmalı.
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
  );


  static GenerativeModel _getModel() {
    final key = _apiKey.isNotEmpty ? _apiKey : dotenv.get('GEMINI_API_KEY', fallback: '');
    
    debugPrint('🔑 [AiService] API Key Control: ${key.isNotEmpty ? "MEVCUT (Sonda: ${key.substring(key.length - 4)})" : "EKSIK"}');

    if (key.isEmpty) {
      throw Exception(
        'Gemini API Key bulunamadı. '
        '.env dosyasına GEMINI_API_KEY ekleyin veya '
        'flutter run --dart-define=GEMINI_API_KEY=your_key_here ile başlatın.',
      );
    }
    
    // Model adını 2026 güncel GA sürümü olan gemini-2.5-flash yapıyoruz.
    return GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.7,
      ),
    );
  }

  /// API anahtarı var mı ve internet bağlantısı kurulabilir mi kontrol et
  static bool get isAvailable => 
      _apiKey.isNotEmpty || dotenv.get('GEMINI_API_KEY', fallback: '').isNotEmpty;

  // =====================
  // PERSONA ÜRETME
  // =====================

  /// Kullanıcının verilerinden finansal persona metni üretir.
  /// Analiz başında çağrılır, daha sonra onay alınırsa kaydedilir.
  static Future<String> generatePersona({
    required List<TransactionRecord> allTransactions,
    required List<Vault> vaults,
    String? countryName,
    String? languageCode,
    List<FinancialGoal> previousGoals = const [],
  }) async {
    final model = _getModel();

    // Anonim özet hazırla
    final totalBalance = vaults.fold(0.0, (sum, v) => sum + v.balance);
    final incomes = allTransactions.where((t) => t.isIncome && !t.isArchived);
    final expenses = allTransactions.where((t) => !t.isIncome && !t.isArchived);

    final totalMonthlyIncome = incomes
        .fold(0.0, (sum, t) => sum + t.monthlyEquivalent);
    final totalMonthlyExpense = expenses
        .fold(0.0, (sum, t) => sum + t.monthlyEquivalent);

    final lockedCount = expenses.where((t) => t.isLocked).length;
    final flexibleCount = expenses.where((t) => !t.isLocked).length;

    // Kategori özetleri (anonim - sadece başlık ve tutar)
    final categoryMap = <String, double>{};
    for (final tx in expenses.where((t) => !t.isLocked)) {
      categoryMap[tx.title] = (categoryMap[tx.title] ?? 0) + tx.monthlyEquivalent;
    }
    final topCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topStr = topCategories
        .take(5)
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(0)} TL')
        .join(', ');

    final prevApprovals = previousGoals.where((g) => g.userApproved == true).length;
    final prevRejections = previousGoals.where((g) => g.userApproved == false).length;

    final prompt = '''
Sen bir finansal koçsun. Kullanıcının son harcama verilerine bakarak ona tek bir "Finansal Karakter/Persona" ata.
Bu karakter hem akılda kalıcı, hem biraz eğlenceli hem de paylaşılabilir olmalı (Spotify Wrapped tarzında).

Veriler:
- Toplam bakiye: ${totalBalance.toStringAsFixed(0)} TL
- Aylık gelir: ${totalMonthlyIncome.toStringAsFixed(0)} TL
- Aylık gider (esnek): ${totalMonthlyExpense.toStringAsFixed(0)} TL
- Kilitli gider sayısı: $lockedCount, Esnek gider sayısı: $flexibleCount
- En öne çıkan gider kategorileri: $topStr
- Konum/Ülke: ${countryName ?? "Otomatik (Dil: $languageCode)"}
- Geçmiş onaylanan analiz sayısı: $prevApprovals
- Geçmiş reddedilen analiz sayısı: $prevRejections

KURALLAR:
1. YEREL VE KÜLTÜREL UYUM: Kullanıcının bulunduğu ülkeye (${countryName ?? languageCode ?? "Genel"}) ve kültürüne uygun, o coğrafyada karşılığı olan anlamlı ve ilgi çekici bir "finansal lakap" (persona) bul. 
2. KISA VE ÖZ: Sadece TEK BİR CÜMLE yaz.
3. FORMAT: [Kültürel Karakter Adı]: [Tek cümlelik, etkileyici ve durumu özetleyen açıklama].
4. Sadece metni döndür.
5. Sadece JSON formatında döndür: {"persona": "metin buraya"}

Örnek (Türkiye için):
Tututumlu Sultan: Kaynaklarını bereketli kullanıyor, birikimlerini akıllıca yönetiyorsun.
''';

    debugPrint('🤖 [AiService] Persona üretiliyor...');
    try {
      final response = await model.generateContent([Content.text(prompt)]).timeout(
        const Duration(seconds: 30),
      );
      final text = response.text ?? '{}';
      debugPrint('✅ [AiService] Persona yanıtı alındı.');
      final data = jsonDecode(text.replaceAll('```json', '').replaceAll('```', '').trim());
      return data['persona'] ?? 'Finansal yolculuğun başlıyor.';
    } catch (e) {
      debugPrint('❌ [AiService] Persona Hatası: $e');
      return 'Finansal yolculuğun başlıyor. Hedeflerine adım adım yaklaşıyorsun.';
    }
  }

  // =====================
  // STRATEJİ ÜRETME
  // =====================

  /// Matematiksel bağlam paketini alıp AI stratejisi üretir.
  /// Sadece tasarruf açığı varsa ve internet mevcutsa çağrılır.
  static Future<OptimizationResult> generateStrategy({
    required double requiredMonthlySaving,
    required List<CategoryContext> flexibleCategories,
    required List<String> rejectedCategories,
    required double targetAmount,
    required int monthsToGoal,
    String? countryName,
    String? languageCode,
    String? baseCurrency,
  }) async {
    final model = _getModel();

    final categoriesStr = flexibleCategories.map((c) {
      final minStr = c.minAmount != null ? ', min: ${c.minAmount!.toStringAsFixed(0)}' : '';
      final maxStr = c.maxAmount != null ? ', max: ${c.maxAmount!.toStringAsFixed(0)}' : '';
      final varStr = c.coefficientOfVariation != null
          ? ', değişkenlik: %${(c.coefficientOfVariation! * 100).toStringAsFixed(0)}'
          : '';
      final installmentStr = c.remainingInstallments != null
          ? ', kalan taksit: ${c.remainingInstallments} ay'
          : '';
      String periodStr = '';
      if (c.periodType == 1) periodStr = ' (Haftalık)';
      if (c.periodType == 4) periodStr = ' (2 Haftada Bir)';
      if (c.periodType == 5) periodStr = ' (3 Haftada Bir)';
      if (c.periodType == 2) periodStr = ' (Aylık)';
      if (c.periodType == 6) periodStr = ' (3 Ayda Bir)';
      if (c.periodType == 7) periodStr = ' (6 Ayda Bir)';
      if (c.periodType == 3) periodStr = ' (Yıllık)';
      return '- ${c.name}$periodStr: tutar ${c.currentAmount.toStringAsFixed(0)} $baseCurrency$minStr$maxStr$varStr$installmentStr (KategID: ${c.name})';
    }).join('\n');

    final rejectedStr = rejectedCategories.isEmpty
        ? 'Yok'
        : rejectedCategories.join(', ');

    final prompt = '''
Sen bir finansal optimizasyon yapay zekasısın. Kullanıcıya aylık tasarruf planı üret.

Veriler:
- Gereken aylık tasarruf: ${requiredMonthlySaving.toStringAsFixed(0)} $baseCurrency
- Hedefe kalan ay: $monthsToGoal ay
- Kullanıcının dili/konumu: ${countryName ?? "Otomatik (Dil: $languageCode)"}
- Kullanıcının daha önce reddettiği kategoriler: $rejectedStr

Kısılabilir harcama kategorileri:
$categoriesStr

KURALLAR:
1. Temel İhtiyaç Önceliği: Kira, Fatura, Market, Temizlik, Sağlık, Ulaşım gibi yaşamsal ve temel ihtiyaç kategorilerini en son kes. DİKKAT: Bu kalemleri asla tamamen sıfırlama veya gerçek dışı tutarlara düşürme. Kullanıcının bulunduğu bölgenin (${countryName ?? languageCode ?? "Genel"}) yaşam maliyetlerini ve asgari yaşam standartlarını göz önünde bulundur. Eğer bu kategoriler için "min" değeri verilmişse bu değer KESİN bir alt sınırdır (hard limit), altına kesinlikle inemezsin. Eğer "min" verilmemişse, verilen para birimi ve tutarlardaki genel yaşam standartlarına göre mantıklı ve gerçekçi bir alt sınır belirle ve o sınırda dur.
2. Lüks ve İsteklerin Kesilmesi: Fast Food, Oyun, Eğlence, Yemek, Abonelikler gibi isteğe bağlı harcamaları ilk önce kes. Hedefe ulaşmak için gerekiyorsa bunları çekinmeden 0'a indirebilirsin.
3. Gerçekçilik ve Yapıcılık: Gerekçe (reason) alanını doldururken aşırı spesifik veya yargılayıcı olma. Daha profesyonel, yapıcı ve stratejik ifadeler kullan. ("İsteğe bağlı bir harcama kalemi olduğu için öncelikli olarak kısıldı" vb.)
4. Değişkenlik Faktörü: Kişiye özgü düşün; değişken harcamalar (yüksek değişkenlik yüzdesi) daha kolay kesilebilir, tutarlı/sabit tutarlara ise son çare olarak dokun.
5. Periyot / Sıklık Değişimi Önerileri (ÖNEMLİ!): Eğer bir harcamanın periyodu düzenliyse, bunu sadece tutarı düşürerek değil, daha seyrek periyotlara taşıyarak da kısıtlama tavsiyesi verebilirsin. Yeni periyot sistemi: Haftada Bir(1), 2 Haftada Bir(4), 3 Haftada Bir(5), Ayda Bir(2), 3 Ayda Bir(6), 6 Ayda Bir(7), Yılda Bir(3), Günlük(8), 2 Günde Bir(9), 3 Günde Bir(10). Örneğin Haftalık 800 TL olan bir harcamayı "2 Haftada Bir 800 TL"ye veya "Aylık 1500 TL"ye uyarlayıp gerekçesine "Periyodu haftalıktan 2 haftada bire/aylığa çekerek tasarruf sağlandı" yazabilirsin. Değerleri hesaplarken yıllık tutarlar üzerinden matematiksel işlem yap.
6. Hata Yanıtı: Eğer kategoriler hiç kısılamayacak durumdaysa JSON formatında boş "cuts" döndür ve "coachMessage" kısmında açıklama yap.
7. Taksitli İşlemler: Eğer bir işlemin "kalan taksit" süresi varsa, bunu keserken taksit bitiminden sonraki tasarrufu da hesaba katabilirsin. Taksitli borçları keserken daha temkinli ol (banka borcu vs olabilir).
8. Reddettiği kategoriler (kullanıcının kısmak istemediği) son çare olarak değerlendirilmelidir.
9. Toplamda gereken tasarrufu tam olarak karşıla; eksik veya fazla kesinti yapma.

JSON formatında döndür:
{
  "cuts": [
    {
      "category": "Kategori Adı", 
      "currentAmount": 0, 
      "suggestedAmount": 0, 
      "suggestedMin": 0,
      "suggestedMax": 0,
      "newPeriod": 2,
      "saving": 0, 
      "reason": "Kısa ve yapıcı gerekçe (örn: Haftalık gider, aylık periyoda çekilerek azaltıldı)"
    }
  ],
  "coachMessage": "2-3 cümle motive edici koç mesajı",
  "isFeasible": true
}
Not: Eğer periyot değişimi önermiyorsan "newPeriod" alanını işlemin mevcut periyoduyla aynı bırak. "suggestedMin" ve "suggestedMax" alanlarını, önerdiğin yeni tutar etrafında mantıklı bir esneklik payı (range) olarak belirle. Eğer işlem sabitse ikisini de "suggestedAmount" ile aynı yapabilirsin.
''';

    debugPrint('🤖 [AiService] Strateji üretiliyor...');
    try {
      final response = await model.generateContent([Content.text(prompt)]).timeout(
        const Duration(seconds: 45),
      );
      
      final text = response.text ?? '{}';
      debugPrint('✅ [AiService] Strateji yanıtı alındı: $text');
      final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
      return OptimizationResult.fromJson(cleaned);
    } catch (e) {
      debugPrint('❌ [AiService] Strateji Hatası: $e');
      rethrow;
    }
  }
}

/// Bir kategori hakkında AI'ya gönderilecek bağlam bilgisi
class CategoryContext {
  final String name;
  final double currentAmount;
  final double? minAmount;
  final double? maxAmount;
  /// Varyasyon katsayısı: standart sapma / ortalama (0-1 arası; yüksek = değişken)
  final double? coefficientOfVariation;
  /// Periyot Tipi (0: Tek Seferlik, 1: Haftalık, 2: Aylık, 3: Yıllık)
  final int periodType;
  /// Kalan taksit sayısı
  final int? remainingInstallments;

  const CategoryContext({
    required this.name,
    required this.currentAmount,
    this.minAmount,
    this.maxAmount,
    this.coefficientOfVariation,
    this.periodType = 0,
    this.remainingInstallments,
  });
}

/// AI'dan gelen optimizasyon sonucu
class OptimizationResult {
  final List<CutSuggestion> cuts;
  final String coachMessage;
  final bool isFeasible;

  const OptimizationResult({
    required this.cuts,
    required this.coachMessage,
    required this.isFeasible,
  });

  factory OptimizationResult.fromJson(String jsonStr) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      
      final List<dynamic> cutsData = data['cuts'] ?? [];
      final cuts = cutsData.map((c) => CutSuggestion(
        category: c['category'] ?? '',
        currentAmount: (c['currentAmount'] ?? 0).toDouble(),
        suggestedAmount: (c['suggestedAmount'] ?? 0).toDouble(),
        suggestedMin: (c['suggestedMin'] ?? 0).toDouble(),
        suggestedMax: (c['suggestedMax'] ?? 0).toDouble(),
        newPeriod: c['newPeriod'] as int?,
        saving: (c['saving'] ?? 0).toDouble(),
        reason: c['reason'] ?? '',
      )).toList();

      return OptimizationResult(
        cuts: cuts,
        coachMessage: data['coachMessage'] ?? 'Hedefe adım adım yaklaşıyorsun!',
        isFeasible: data['isFeasible'] ?? true,
      );
    } catch (e) {
      debugPrint('❌ [OptimizationResult] JSON Parse Hatası: $e');
      return const OptimizationResult(
        cuts: [],
        coachMessage: 'Analiz tamamlandı. Veriler işlenirken bir sorun oluştu.',
        isFeasible: true,
      );
    }
  }
}

/// Bir kategoride yapılacak kesinti önerisi
class CutSuggestion {
  final String category;
  final double currentAmount;
  final double suggestedAmount;
  final double? suggestedMin;
  final double? suggestedMax;
  final int? newPeriod;
  final double saving;
  final String reason;

  const CutSuggestion({
    required this.category,
    required this.currentAmount,
    required this.suggestedAmount,
    this.suggestedMin,
    this.suggestedMax,
    this.newPeriod,
    required this.saving,
    required this.reason,
  });
}
