import 'package:isar_community/isar.dart';
import '../../domain/recurrence_rule.dart';
import '../../utils/currency_utils.dart';
import 'exchange_rate.dart';

part 'recurring_template.g.dart';

@collection
class RecurringTemplate {
  Id id = Isar.autoIncrement;

  // — Kimlik —
  String title = '';
  String? categoryId;
  String? iconCode;
  bool isIncome = false;

  // — Tutar —
  double amount = 0.0;
  double? minAmount;
  double? maxAmount;

  // — Periyot Kuralı —
  int periodType = 301;           // encoding: unit*100 + interval
  int? recurrenceDay;
  DateTime? recurrenceDate;
  int? totalInstallments;         // Taksit sayısı (null = sonsuz)
  DateTime startDate = DateTime.now();

  // — İlişkiler —
  @Index()
  int? vaultId;
  String? note;
  String? currency;

  // — Bildirim —
  bool isNotificationEnabled = false;
  bool hasNotificationConfigured = false;
  int notificationReminderDays = 0;
  int notificationHour = 9;
  int notificationMinute = 0;

  // — Durum —
  bool isPaused = false;
  bool isArchived = false;

  // — Senkronizasyon —
  @Index()
  String? remoteId;
  @Index()
  DateTime updatedAt = DateTime.now();
  @Index()
  int syncStatus = 0;

  // — Hesaplama (@ignore) —
  @ignore
  RecurrenceRule get recurrenceRule => RecurrenceRule(
        periodType: periodType,
        startDate: startDate,
        recurrenceDay: recurrenceDay,
        recurrenceDate: recurrenceDate,
        totalInstallments: totalInstallments,
      );

  @ignore
  double get effectiveAmount {
    if (amount == 0 && (minAmount != null || maxAmount != null)) {
      return ((minAmount ?? 0) + (maxAmount ?? 0)) /
          ((minAmount != null && maxAmount != null) ? 2 : 1);
    }
    return amount;
  }

  @ignore
  double get monthlyEquivalent {
    final baseAmount = effectiveAmount;
    double monthly = 0;
    
    if (periodType == 0) {
      monthly = 0;
    } else if (periodType == 250) {
      monthly = baseAmount * 21.67;
    } else if (periodType == 251) {
      monthly = baseAmount * 8.67;
    } else {
      final unit = periodType ~/ 100;
      final interval = periodType % 100;
      if (interval > 0) {
        switch (unit) {
          case 1:
            monthly = baseAmount * (30 / interval);
            break;
          case 2:
            monthly = baseAmount * (4.33 / interval);
            break;
          case 3:
            monthly = baseAmount / interval;
            break;
          case 4:
            monthly = baseAmount / (12 * interval);
            break;
        }
      }
    }
    return double.parse(monthly.toStringAsFixed(2));
  }

  double getConvertedMonthlyEquivalent(String targetCurrency, List<ExchangeRate> rates) {
    return CurrencyUtils.convert(monthlyEquivalent, currency ?? '₺', targetCurrency, rates);
  }
}
