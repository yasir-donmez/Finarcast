import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';
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

  /// İşlemin tutarı.
  double amount = 0.0;

  /// --- Esnek Bütçeleme (Min-Max Aralık) ---
  double? minAmount;
  double? maxAmount;

  /// Kaydın oluştuğu veya gerçekleşeceği tarih
  DateTime date = DateTime.now();

  /// Normalize gerçekleşme tarihi (saat/dakika/saniye sıfırlanmış: yyyy-MM-dd)
  @Index()
  DateTime occurrenceDate = DateTime.now();

  /// Hangi Kasa (Vault) ile ilişkili? (Tekli Kasa Desteği)
  @Index()
  int? vaultId;

  /// Transfer işlemlerinde hedef kasa ID'si (null = normal işlem)
  @Index()
  int? targetVaultId;

  /// İlişkili Şablon ID (null = tek seferlik/manuel)
  @Index()
  int? templateId;

  /// Idempotency / Duplicate Önleme Anahtarı
  @Index(unique: true, replace: true)
  String occurrenceKey = '';

  /// Taksit Bilgileri
  int? installmentNumber;
  int? totalInstallments;

  /// İşlem Durumu (0 = confirmed, 2 = skipped)
  @Index()
  int status = 0;

  /// Kullanıcı kaydı inceledi mi?
  @Index()
  bool isReviewed = false;

  /// İşlemin arşivlenip arşivlenmediğini belirtir.
  bool isArchived = false;

  /// İşleme dair not veya açıklama
  String? note;

  /// İşlemin yapıldığı para birimi (USD, TRY vb.)
  String? currency;

  /// İşlem oluşturulduğu andaki döviz kuru (1 birim kaynak para birimi = X TRY).
  /// Null ise güncel kur kullanılır (geriye dönük uyumluluk).
  double? snapshotRate;

  /// --- Senkronizasyon Alanları ---
  @Index()
  String? remoteId;

  @Index()
  DateTime updatedAt = DateTime.now();

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

  /// Belirli bir hedef birime göre tutarı döndürür
  double getConvertedAmount(String targetCurrency, List<ExchangeRate> rates) {
    return CurrencyUtils.convertWithSnapshot(
      effectiveAmount,
      currency ?? '₺',
      targetCurrency,
      rates,
      snapshotRate: snapshotRate,
    );
  }

  /// Tek seferlik kayıt için occurrenceKey üretir
  static String generateManualKey() => 'manual_${const Uuid().v4()}';
}
