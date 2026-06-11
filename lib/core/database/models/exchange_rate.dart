import 'package:isar_community/isar.dart';

part 'exchange_rate.g.dart';

@collection
class ExchangeRate {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String currencyCode; // USD, EUR, GOLD, GBP vb.

  late double rate; // Baz birime (Genelde TRY) göre oran

  late DateTime lastUpdated;

  DateTime? updatedAt;
  int? syncStatus; // 0: synced, 1: pending
}
