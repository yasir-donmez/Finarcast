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

  /// "Taksit/Süreli Borç Mekanizması"
  /// Eğer null değilse, bu giderin kalan ay sayısıdır. Her ay bu rakam düşer.
  int? remainingInstallments;

  /// Tekrarlama Periyodu: (Birim * 100) + Sıklık (Interval)
  /// Birim: 1->Gün, 2->Hafta, 3->Ay, 4->Yıl
  /// Özel: 250->Hafta İçi, 251->Hafta Sonu, 0->Tek Seferlik
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



  /// İşlemin arşivlenip arşivlenmediğini belirtir. Arşivlenen işlemler aktif listelerde ve hatırlatıcılarda gösterilmez ancak geçmiş raporlarında ve grafiklerde hesaplamaya katılır.
  bool isArchived = false;

  /// İşleme dair not veya açıklama
  String? note;

  /// İşlemin yapıldığı para birimi (USD, TRY vb.)
  String? currency;

  
  // --- Bildirim Ayarları ---
  bool isNotificationEnabled = false;
  bool hasNotification = false;
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
    double monthly = 0;
    
    if (periodType == 0) {
      monthly = 0;
    } else if (periodType == 250) {
      // Hafta İçi (Pzt-Cum) -> ortalama 21.67 gün
      monthly = baseAmount * 21.67;
    } else if (periodType == 251) {
      // Hafta Sonu (Cmt-Paz) -> ortalama 8.67 gün
      monthly = baseAmount * 8.67;
    } else {
      final unit = periodType ~/ 100;
      final interval = periodType % 100;
      if (interval > 0) {
        switch (unit) {
          case 1: // Gün
            monthly = baseAmount * (30 / interval);
            break;
          case 2: // Hafta
            monthly = baseAmount * (4.33 / interval);
            break;
          case 3: // Ay
            monthly = baseAmount / interval;
            break;
          case 4: // Yıl
            monthly = baseAmount / (12 * interval);
            break;
        }
      }
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
