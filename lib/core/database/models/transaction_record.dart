import 'package:isar/isar.dart';
import '../../utils/currency_utils.dart';
import 'exchange_rate.dart';


part 'transaction_record.g.dart'; // Isar code generator tarafından üretilecek

@collection
class TransactionRecord {
  Id id = Isar.autoIncrement;

  /// İşlem Tipi: true -> Gelir, false -> Gider
  bool isIncome = false;

  String title = '';
  
  /// Kategori ID (Multi-language desteği için benzersiz anahtar)
  String? categoryId;

  /// Kategori İkon Kodu (Arayüzde Neumorphic kartta gösterilmek üzere)
  String? iconCode;

  /// İşlemin tutarı. Eğer bir aralık (Range) seçildiyse bu değer ortalama (Veya maks) alınabilir
  /// Şimdilik net bir değer olarak tutuyoruz
  double amount = 0.0;

  /// --- Esnek Bütçeleme (Min-Max Aralık) ---
  /// Kullanıcı esnek bütçe (Range) belirlediyse buraya yazılır
  double? minAmount;
  double? maxAmount;

  /// "Kırmızı Çizgi / Kilit Mekanizması" (Zorunlu Gider mi?)
  /// Eğer true ise algoritma (Yapay Zeka) tasarruf tavsiyesi verirken bu kaleme asla dokunmaz!
  bool isLocked = false;

  /// "Taksit/Süreli Borç Mekanizması"
  /// Eğer null değilse, bu giderin kalan ay sayısıdır. Her ay bu rakam düşer.
  int? remainingInstallments;

  /// Tekrarlama Periyodu (0: Tek Seferlik, 1: Haftalık, 2: Aylık, 3: Yıllık, 4: 2 Haftada Bir, 5: 3 Haftada Bir, 6: 3 Ayda Bir, 7: 6 Ayda Bir, 8: Günlük, 9: 2 Günde Bir, 10: 3 Günde Bir)
  int periodType = 0;

  /// Tekrarlama Detayları (Haftanın Hangi Günü, Ayın Hangi Günü vb.)
  int? recurrenceDay;
  DateTime? recurrenceDate;

  /// Kaç kez tekrar edeceği (0 = Sonsuz/Sürekli Tekrar Eder)
  int? recurrenceDuration;

  /// Kaydın oluştuğu veya gerçekleşeceği tarih
  DateTime date = DateTime.now();

  /// Hangi Kasalar (Vault) ile ilişkili? (Çoklu Kasa Desteği)
  /// İşlem tektir ancak birden fazla kasada listelenebilir.
  List<int> vaultIds = [];

  /// Ana sayfada gösterilsin mi?
  bool showOnDashboard = false;

  /// Dashboard'daki sıralama
  int dashboardOrder = 0;

  /// Dashboard'da bu işlemin dahil olduğu sayfanın yerleşim tipi (1, 2, 3, 4)
  int dashboardLayoutType = 4;

  /// Arşiv bayrağı: Süresi dolmuş periyodik işlemler silinmez, arşivlenir.
  /// true → aktif listede görünmez, analiz motoru geçmiş hesabında kullanır.
  bool isArchived = false;

  /// İşleme dair not veya açıklama
  String? note;

  /// İşlemin yapıldığı para birimi (USD, TRY vb.)
  String? currency;

  /// İşlemin yapıldığı konumun koordinatları
  double? latitude;
  double? longitude;
  
  // --- Bildirim Ayarları ---
  bool isNotificationEnabled = false;
  int notificationReminderDays = 0; // 0: Aynı gün, 1: Bir gün önce...
  int notificationHour = 9;
  int notificationMinute = 0;

  /// --- Senkronizasyon Alanları ---
  /// Sunucu anahtarı (UUID)
  @Index()
  String? remoteId;

  /// Son güncelleme tarihi (Eşitleme için)
  @Index()
  DateTime updatedAt = DateTime.now();

  /// Senkronizasyon Durumu (0: Senkronize, 1: Beklemede, 2: Silindi)
  @Index()
  int syncStatus = 0;

  /// İşlemin etkin tutarını hesaplar.
  /// Eğer amount 0 ise ve min/max varsa bunların ortalamasını döner.
  @ignore
  double get effectiveAmount {
    if (amount == 0 && (minAmount != null || maxAmount != null)) {
      return ((minAmount ?? 0) + (maxAmount ?? 0)) /
          ((minAmount != null && maxAmount != null) ? 2 : 1);
    }
    return amount;
  }

  /// İşlemin aylık karşılığını hesaplar.
  /// Dashboard ve Analiz motoru arasındaki tutarsızlığı önlemek için bu metod kullanılmalıdır.
  @ignore
  double get monthlyEquivalent {
    final baseAmount = effectiveAmount;
    double monthly;
    switch (periodType) {
      case 1: // Haftalık
        monthly = baseAmount * 4.33;
      case 2: // Aylık
        monthly = baseAmount;
      case 3: // Yıllık
        monthly = baseAmount / 12;
      case 4: // 2 Haftada Bir
        monthly = baseAmount * 2.16;
      case 5: // 3 Haftada Bir
        monthly = baseAmount * 1.44;
      case 6: // 3 Ayda Bir
        monthly = baseAmount / 3;
      case 7: // 6 Ayda Bir
        monthly = baseAmount / 6;
      case 8: // Günlük
        monthly = baseAmount * 30;
      case 9: // 2 Günde Bir
        monthly = baseAmount * 15;
      case 10: // 3 Günde Bir
        monthly = baseAmount * 10;
      default: // Tek seferlik
        monthly = 0;
    }
    // Kuruş karmaşasını önlemek için 2 haneye yuvarla
    return double.parse(monthly.toStringAsFixed(2));
  }

  /// Belirli bir hedef birime göre tutarı döndürür
  double getConvertedAmount(String targetCurrency, List<ExchangeRate> rates) {
    return CurrencyUtils.convert(effectiveAmount, currency ?? '₺', targetCurrency, rates);
  }

  /// Belirli bir hedef birime göre aylık karşılığı döndürür
  double getConvertedMonthlyEquivalent(String targetCurrency, List<ExchangeRate> rates) {
    return CurrencyUtils.convert(monthlyEquivalent, currency ?? '₺', targetCurrency, rates);
  }
}
