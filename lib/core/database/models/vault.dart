import 'package:isar_community/isar.dart';

part 'vault.g.dart'; // Isar code generator tarafından üretilecek

@collection
class Vault {
  Id id = Isar.autoIncrement;

  /// Kasanın Adı (Örn: "Maaş Hesabı", "Yastık Altı Altın", "Dolar Zulası")
  String name = '';

  /// Kasanın Ana Birimi (Örn: "TRY", "USD", "GRAM", "AUTO")
  String currency = 'AUTO';







  /// --- Senkronizasyon Alanları ---
  @Index()
  String? remoteId;

  @Index()
  DateTime updatedAt = DateTime.now();

  @Index()
  int syncStatus = 0;
}
