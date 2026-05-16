import 'package:isar/isar.dart';

part 'app_settings.g.dart';

/// Uygulama geneli ayarlar — Tek satırlık koleksiyon (id = 1 daima)
@collection
class AppSettings {
  Id id = 1; // Tek kayıt, her zaman id=1

  /// Veri saklama süresi (Görünürlük & AI Analizi için - gün cinsinden)
  /// -1 = Hiçbir zaman arşivleme (sonsuz)
  int dataRetentionDays = 90;

  /// Veritabanından kalıcı silme süresi (gün cinsinden)
  /// -1 = Hiçbir zaman kalıcı silme
  int permanentDeletionDays = -1;

  /// Tema Modu
  /// 0 = Sistem Varsayılanı
  /// 1 = Aydınlık (Light)
  /// 2 = Karanlık (Dark)
  int themeModeIndex = 0;

  /// Arka Plan Deseni Yoğunluğu
  /// 0 = Kapalı, 1 = Hafif, 2 = Orta, 3 = Yoğun
  int bgPatternDensity = 1;

  /// Arka Plan Renklendirme Stili
  /// 0 = İkonları Boya, 1 = Zemini Boya, 2 = Sade
  int bgColorStyle = 1;

  /// Ana Tema Rengi (Accent Color) — Örn: 0xFF00E5FF
  int accentColorValue = 0xFF00E5FF;

  /// Uygulama dili (varsayılan: tr)
  String languageCode = 'tr';

  /// Varsayılan para birimi simgesi (varsayılan: ₺)
  String currencySymbol = '₺';

  /// Kullanıcının bulunduğu ülke (AI analizi için - Örn: "Türkiye")
  String? countryName;

  /// Tüm uygulama bildirimleri açık mı? (Master Switch)
  bool isNotificationsEnabled = true;

  /// Konum servisleri açık mı?
  bool isLocationEnabled = false;

  /// Bulut senkronizasyonu aktif mi?
  bool isSyncEnabled = false;

  /// --- Senkronizasyon Alanları ---
  @Index()
  String? remoteId;

  @Index()
  DateTime updatedAt = DateTime.now();

  @Index()
  int syncStatus = 0;
}
