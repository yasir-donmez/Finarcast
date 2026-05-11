import 'package:isar/isar.dart';

part 'financial_goal.g.dart';

/// Bir analiz oturumunu temsil eder.
/// Kullanıcı en fazla 3 analiz yapabilir; son 3'ü görüntülenir.
@collection
class FinancialGoal {
  Id id = Isar.autoIncrement;

  /// Hedef tutar (örn: 10000.0)
  double targetAmount = 0.0;

  /// Hedef para birimi simgesi (varsayılan: ₺)
  String currencySymbol = '₺';

  /// Hedef tarih (opsiyonel — girilmezse sistem alternatif tarihler önerir)
  DateTime? targetDate;

  /// Kapsam: null = tüm kasalar, değer varsa = o kasanın ID'si
  int? vaultId;

  /// Analiz oluşturulma tarihi
  DateTime createdAt = DateTime.now();

  /// O analiz anında üretilen AI Persona metni (~2-3 cümle)
  String? aiPersonaText;

  /// O analiz anında üretilen strateji özeti
  String? aiStrategyText;

  /// Kullanıcının bu analizde veto ettiği kategori adları
  List<String> rejectedCategories = [];

  /// Kullanıcının öneriyi onaylayıp onaylamadığı
  /// null = henüz geri bildirim verilmedi
  /// true = beğendi (persona kaydedildi)
  /// false = beğenmedi (persona kaydedilmedi, kategoriler veto listesine eklendi)
  bool? userApproved;

  /// Analizin tam detaylarını (skor, kesintiler vb.) saklayan JSON verisi
  String? analysisRawData;

  /// --- Senkronizasyon Alanları ---
  @Index()
  String? remoteId;

  @Index()
  DateTime updatedAt = DateTime.now();

  @Index()
  int syncStatus = 0;
}
