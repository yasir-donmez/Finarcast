import 'package:isar/isar.dart';

part 'app_settings.g.dart';

/// Uygulama geneli ayarlar — Tek satırlık koleksiyon (id = 1 daima)
@collection
class AppSettings {
  Id id = 1; // Tek kayıt, her zaman id=1

  /// İşlemlerin kaç gün sonra otomatik olarak arşive kaldırılacağını belirler. -1 değeri otomatik arşivlemeyi devre dışı bırakır.
  int dataRetentionDays = 90;

  /// Taksiti bitmiş veya tek seferlik olan, süresi geçmiş işlemlerin veritabanından kalıcı olarak (fiziksel olarak) silineceği süreyi belirler (gün cinsinden). -1 değeri kalıcı silmeyi devre dışı bırakır.
  int permanentDeletionDays = -1;

  /// Tema Modu (0: Sistem Varsayılanı, 1: Aydınlık, 2: Karanlık)
  int themeModeIndex = 0;

  /// Arayüzün arka plan ve kart boyama stilini belirler (0: İkonları Boya, 1: Zemini Boya, 2: Sade/Minimalist).
  int bgColorStyle = 2;

  /// Ana Tema Rengi (Accent Color) — Örn: 0xFF00BCD4
  int accentColorValue = 0xFF00BCD4;

  /// Uygulama dili (varsayılan: tr)
  String languageCode = 'tr';

  /// Varsayılan para birimi simgesi (varsayılan: ₺)
  String currencySymbol = '₺';

  /// Uygulama genelinde yaklaşan işlem bildirimlerinin (hatırlatıcıların) aktif olup olmadığını belirleyen ana anahtardır.
  bool isNotificationsEnabled = true;

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
