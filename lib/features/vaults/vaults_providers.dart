import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/database/models/transaction_record.dart';
import '../../core/database/models/recurring_template.dart';
import '../../core/database/models/transaction_status.dart';
import '../../core/database/models/exchange_rate.dart';
import '../../core/database/models/custom_category.dart';
import '../../core/domain/recurrence_rule.dart';
import '../../core/domain/recurrence_engine.dart';
import '../../core/utils/category_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/services/balance_service.dart';

/// Tek bir işlem kaydı (UI Model)
class TransactionUI {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double amount;
  final double? minAmount;
  final double? maxAmount;
  final bool isIncome;
  final DateTime date;
  final int? dbId; // Isar DB ID (null = henüz kaydedilmemiş)
  final String? categoryId; // Multi-language desteği için benzersiz anahtar
  final String? iconCode;   // İkon referansı (ID veya özel kod)
  
  final int? vaultId;
  final int? targetVaultId;

  final String? note;
  final String? currency;
  final double? snapshotRate;

  final int status;
  final bool isReviewed;
  final int? templateId;
  final DateTime occurrenceDate;
  final int? installmentNumber;
  final int? totalInstallments;

  final bool isArchived;
  List<String> groupIds = []; // Çoklu kasa desteği (Kasa ID'leri, örn: "v_1")

  TransactionUI({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    this.minAmount,
    this.maxAmount,
    required this.isIncome,
    required this.date,
    this.dbId,
    this.categoryId,
    this.iconCode,
    this.vaultId,
    this.targetVaultId,
    this.note,
    this.currency,
    this.snapshotRate,
    required this.status,
    required this.isReviewed,
    this.templateId,
    required this.occurrenceDate,
    this.installmentNumber,
    this.totalInstallments,
    this.isArchived = false,
    List<String>? groupIds,
  }) : groupIds = groupIds ?? [];

  /// İşlemin etkin tutarını hesaplar.
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

  /// TransactionRecord'dan TransactionUI'a dönüştür
  factory TransactionUI.fromDB(TransactionRecord record, List<CustomCategory> customCategories) {
    return TransactionUI(
      id: 'db_${record.id}',
      name: record.title,
      icon: CategoryUtils.getCategoryIcon(
        categoryId: record.categoryId,
        customCategories: customCategories,
        iconCode: record.iconCode,
      ),
      color: CategoryUtils.getCategoryColor(
        categoryId: record.categoryId,
        customCategories: customCategories,
      ),
      amount: record.amount,
      minAmount: record.minAmount,
      maxAmount: record.maxAmount,
      isIncome: record.isIncome,
      date: record.date,
      dbId: record.id,
      categoryId: record.categoryId,
      iconCode: record.iconCode,
      vaultId: record.vaultId,
      targetVaultId: record.targetVaultId,
      note: record.note,
      currency: record.currency,
      snapshotRate: record.snapshotRate,
      status: record.status,
      isReviewed: record.isReviewed,
      templateId: record.templateId,
      occurrenceDate: record.occurrenceDate,
      installmentNumber: record.installmentNumber,
      totalInstallments: record.totalInstallments,
      isArchived: record.isArchived,
      groupIds: [
        if (record.vaultId != null) 'v_${record.vaultId}',
        if (record.targetVaultId != null) 'v_${record.targetVaultId}',
      ],
    );
  }
}

/// Tekrarlı İşlem Şablonu (UI Model)
class TemplateUI {
  final int id;
  final String title;
  final IconData icon;
  final Color color;
  final double amount;
  final double? minAmount;
  final double? maxAmount;
  final bool isIncome;
  final int periodType;
  final int? recurrenceDay;
  final DateTime? recurrenceDate;

  final int? totalInstallments;
  final DateTime startDate;
  final int? vaultId;
  final String? note;
  final String? currency;
  final bool isArchived;
  final bool isNotificationEnabled;
  final bool hasNotification;
  final int notificationReminderDays;
  final int notificationHour;
  final int notificationMinute;
  final String? categoryId;
  final String? iconCode;

  TemplateUI({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.amount,
    this.minAmount,
    this.maxAmount,
    required this.isIncome,
    required this.periodType,
    this.recurrenceDay,
    this.recurrenceDate,

    this.totalInstallments,
    required this.startDate,
    required this.vaultId,
    this.note,
    this.currency,
    required this.isArchived,
    required this.isNotificationEnabled,
    required this.hasNotification,
    required this.notificationReminderDays,
    required this.notificationHour,
    required this.notificationMinute,
    this.categoryId,
    this.iconCode,
  });

  factory TemplateUI.fromDB(RecurringTemplate t, List<CustomCategory> customCategories) {
    return TemplateUI(
      id: t.id,
      title: t.title,
      icon: CategoryUtils.getCategoryIcon(
        categoryId: t.categoryId,
        customCategories: customCategories,
        iconCode: t.iconCode,
      ),
      color: CategoryUtils.getCategoryColor(
        categoryId: t.categoryId,
        customCategories: customCategories,
      ),
      amount: t.amount,
      minAmount: t.minAmount,
      maxAmount: t.maxAmount,
      isIncome: t.isIncome,
      periodType: t.periodType,
      recurrenceDay: t.recurrenceDay,
      recurrenceDate: t.recurrenceDate,

      totalInstallments: t.totalInstallments,
      startDate: t.startDate,
      vaultId: t.vaultId,
      note: t.note,
      currency: t.currency,
      isArchived: t.isArchived,
      isNotificationEnabled: t.isNotificationEnabled,
      hasNotification: t.hasNotification,
      notificationReminderDays: t.notificationReminderDays,
      notificationHour: t.notificationHour,
      notificationMinute: t.notificationMinute,
      categoryId: t.categoryId,
      iconCode: t.iconCode,
    );
  }

  RecurrenceRule get recurrenceRule => RecurrenceRule(
        periodType: periodType,
        startDate: startDate,
        recurrenceDay: recurrenceDay,
        recurrenceDate: recurrenceDate,

        totalInstallments: totalInstallments,
      );

  double get effectiveAmount {
    if (amount == 0 && (minAmount != null || maxAmount != null)) {
      return ((minAmount ?? 0) + (maxAmount ?? 0)) /
          ((minAmount != null && maxAmount != null) ? 2 : 1);
    }
    return amount;
  }

  double _calculateMonthly(double baseAmount) {
    double monthly = 0;
    if (periodType == 250) {
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

  double get monthlyEquivalent => _calculateMonthly(effectiveAmount);
  double get minMonthlyEquivalent => _calculateMonthly(minAmount ?? amount);
  double get maxMonthlyEquivalent => _calculateMonthly(maxAmount ?? amount);

  double get getConvertedMinMonthlyEquivalent => _calculateMonthly(minAmount ?? amount); // Wait, no, we just convert them using CurrencyUtils.convert in the UI, or we can add helper convert methods. Let's look at the old code:
  // tx.maxMonthlyEquivalent > 0 ? CurrencyUtils.convert(tx.maxMonthlyEquivalent, tx.currency ?? '₺', currency, rates) : tx.getConvertedMonthlyEquivalent(currency, rates)
  // So they just read tx.maxMonthlyEquivalent, which we are adding here.

  double getConvertedAmount(String targetCurrency, List<ExchangeRate> rates) {
    return CurrencyUtils.convert(effectiveAmount, currency ?? '₺', targetCurrency, rates);
  }

  double getConvertedMonthlyEquivalent(String targetCurrency, List<ExchangeRate> rates) {
    return CurrencyUtils.convert(monthlyEquivalent, currency ?? '₺', targetCurrency, rates);
  }
}

/// Arayüz Görünüm Modu: Şablonlar (Planlar) veya Geçmiş (Gerçekleşen Kayıtlar)
enum VaultViewMode { templates, history }

final vaultViewModeProvider = StateProvider<VaultViewMode>((ref) => VaultViewMode.templates);

/// İşlem grubu (Kasa detaylarında göstermek için)
class TransactionGroup {
  final String id;
  String name;
  String currency;
  final List<String> transactionIds;

  TransactionGroup({
    required this.id,
    required this.name,
    this.currency = 'AUTO',
    List<String>? transactionIds,
  }) : transactionIds = transactionIds ?? [];
}

/// Filtreleme tipi
enum TransactionFilter { all, income, expense }

final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => TransactionFilter.all,
);

/// DB'den gelen işlemleri UI modeline çeviren provider
final vaultTransactionsProvider = Provider<List<TransactionUI>>((ref) {
  final dbRecords = ref.watch(allTransactionsProvider);
  final customCategories = ref.watch(customCategoriesProvider);
  final list = dbRecords.map((r) => TransactionUI.fromDB(r, customCategories)).toList();
  list.sort((a, b) {
    final dateCompare = b.date.compareTo(a.date);
    if (dateCompare != 0) {
      return dateCompare;
    }
    final aId = a.dbId ?? 0;
    final bId = b.dbId ?? 0;
    return bId.compareTo(aId);
  });
  return list;
});

/// DB'den gelen şablonları UI modeline çeviren provider
final vaultTemplatesProvider = Provider<List<TemplateUI>>((ref) {
  final dbTemplates = ref.watch(allTemplatesProvider);
  final customCategories = ref.watch(customCategoriesProvider);
  return dbTemplates.map((t) => TemplateUI.fromDB(t, customCategories)).toList();
});

/// Kasalar ve ilişkili işlemler grubu
final transactionGroupsProvider = Provider<List<TransactionGroup>>((ref) {
  final vaults = ref.watch(allVaultsProvider);
  final allTx = ref.watch(vaultTransactionsProvider);

  return vaults.map((v) {
    final relatedTxIds = allTx.where((t) => t.groupIds.contains('v_${v.id}')).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return TransactionGroup(
      id: 'v_${v.id}',
      name: v.name,
      currency: v.currency,
      transactionIds: relatedTxIds.map((t) => t.id).toList(),
    );
  }).toList();
});

class SelectedVaultNotifier extends StateNotifier<String?> {
  SelectedVaultNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('last_selected_vault_id');
      if (savedId != null) {
        state = savedId;
      }
    } catch (e) {
      debugPrint('❌ selectedVaultProvider yükleme hatası: $e');
    }
  }

  @override
  set state(String? value) {
    super.state = value;
    _save(value);
  }

  Future<void> _save(String? value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value == null) {
        await prefs.remove('last_selected_vault_id');
      } else {
        await prefs.setString('last_selected_vault_id', value);
      }
    } catch (e) {
      debugPrint('❌ selectedVaultProvider kaydetme hatası: $e');
    }
  }
}

/// Seçili kasa (null = Ana Kasa / Tümü)
final selectedVaultProvider = StateNotifierProvider<SelectedVaultNotifier, String?>((ref) {
  return SelectedVaultNotifier();
});

/// Seçili filtrelere göre şablonları listeler
final filteredVaultTemplatesProvider = Provider<List<TemplateUI>>((ref) {
  final allTemplates = ref.watch(vaultTemplatesProvider);
  final filter = ref.watch(transactionFilterProvider);
  final selectedVaultId = ref.watch(selectedVaultProvider);
  final groups = ref.watch(transactionGroupsProvider);
  final isIdValid = selectedVaultId == null || groups.any((g) => g.id == selectedVaultId);
  final effectiveVaultId = (isIdValid ? selectedVaultId : null) ?? (groups.isNotEmpty ? groups.first.id : null);

  // 1. Kasa Filtresi
  var filtered = effectiveVaultId == null
      ? allTemplates
      : allTemplates.where((t) {
          // Eğer şablonun kasa ID'si bir şekilde kaybolduysa (empty), onu tamamen gizlemek yerine
          // varsayılan olarak o anki kasada gösterelim veya id'yi düzeltelim.
          // Böylece "şablon kayboldu" anomalisi yaşanmaz.
          if (t.vaultId == null) {
            return true; // En azından listede görünsün, kullanıcı düzenleyebilsin.
          }
          final eId = int.tryParse(effectiveVaultId.replaceFirst('v_', ''));
          if (eId != null) {
            return t.vaultId == eId;
          }
          return false;
        }).toList();

  // 2. Gelir / Gider Filtresi
  filtered = filtered.where((t) {
    if (filter == TransactionFilter.income) return t.isIncome;
    if (filter == TransactionFilter.expense) return !t.isIncome;
    return true;
  }).toList();

  return filtered;
});

/// Seçili filtrelere göre işlemleri listeler (sadece bugün ve öncesi — geçmiş)
final filteredVaultTransactionsProvider = Provider<List<TransactionUI>>((ref) {
  final allTransactions = ref.watch(vaultTransactionsProvider).where((t) => !t.isArchived).toList();
  final filter = ref.watch(transactionFilterProvider);
  final selectedVaultId = ref.watch(selectedVaultProvider);
  final groups = ref.watch(transactionGroupsProvider);
  final isIdValid = selectedVaultId == null || groups.any((g) => g.id == selectedVaultId);
  final effectiveVaultId = (isIdValid ? selectedVaultId : null) ?? (groups.isNotEmpty ? groups.first.id : null);

  final today = DateTime.now();
  final todayNorm = DateTime(today.year, today.month, today.day);

  // 1. Kasa Filtresi
  var filtered = effectiveVaultId == null
      ? allTransactions
      : allTransactions.where((t) => t.groupIds.contains(effectiveVaultId)).toList();

  // 2. Sadece geçmiş + bugün
  filtered = filtered.where((t) {
    final d = DateTime(t.date.year, t.date.month, t.date.day);
    return !d.isAfter(todayNorm);
  }).toList();

  // 3. Tip Filtresi (Gelir/Gider)
  filtered = filtered.where((t) {
    if (filter == TransactionFilter.income) return t.isIncome;
    if (filter == TransactionFilter.expense) return !t.isIncome;
    return true;
  }).toList();

  return filtered;
});

/// Her gün grubu için kümülatif bakiye değerlerini önbellekleyen provider.
/// Bu sayede HistoryDayGroup build sırasında BalanceService çağrılmaz.
final dayBalanceCacheProvider = Provider<Map<DateTime, double>>((ref) {
  final selectedVaultId = ref.watch(selectedVaultProvider);
  final groups = ref.watch(transactionGroupsProvider);
  final isIdValid = selectedVaultId == null || groups.any((g) => g.id == selectedVaultId);
  final effectiveVaultId = (isIdValid ? selectedVaultId : null) ?? (groups.isNotEmpty ? groups.first.id : null);

  final allVaults = ref.watch(allVaultsProvider);
  final dbRecords = ref.watch(allTransactionsProvider);
  final settings = ref.watch(settingsProvider);
  final rates = ref.watch(exchangeRatesProvider).value ?? [];

  final filteredTransactions = ref.watch(filteredVaultTransactionsProvider);

  // Benzersiz tarihleri topla
  final Set<DateTime> uniqueDates = {};
  for (final tx in filteredTransactions) {
    uniqueDates.add(DateTime(tx.date.year, tx.date.month, tx.date.day));
  }

  final Map<DateTime, double> cache = {};

  if (effectiveVaultId == null) {
    // Genel bakiye modu
    for (final date in uniqueDates) {
      cache[date] = BalanceService.calculateNetBalance(
        vaults: allVaults,
        records: dbRecords,
        targetCurrency: settings.currencySymbol,
        rates: rates,
        untilDate: date,
      );
    }
  } else {
    // Kasa bazlı bakiye modu
    final vault = allVaults.where((v) => 'v_${v.id}' == effectiveVaultId).firstOrNull;
    if (vault != null) {
      final vaultCurrency = vault.currency;
      final targetCurrency = vaultCurrency == 'AUTO' ? settings.currencySymbol : vaultCurrency;
      for (final date in uniqueDates) {
        cache[date] = BalanceService.calculateVaultBalance(
          vault: vault,
          records: dbRecords,
          targetCurrency: targetCurrency,
          rates: rates,
          untilDate: date,
        );
      }
    }
  }

  return cache;
});

/// Günlük bakiye hesabında kullanılan para birimi
final dayBalanceCurrencyProvider = Provider<String>((ref) {
  final selectedVaultId = ref.watch(selectedVaultProvider);
  final groups = ref.watch(transactionGroupsProvider);
  final isIdValid = selectedVaultId == null || groups.any((g) => g.id == selectedVaultId);
  final effectiveVaultId = (isIdValid ? selectedVaultId : null) ?? (groups.isNotEmpty ? groups.first.id : null);
  final settings = ref.watch(settingsProvider);
  final allVaults = ref.watch(allVaultsProvider);

  if (effectiveVaultId == null) {
    return settings.currencySymbol;
  }
  final vault = allVaults.where((v) => 'v_${v.id}' == effectiveVaultId).firstOrNull;
  if (vault != null) {
    final vaultCurrency = vault.currency;
    return vaultCurrency == 'AUTO' ? settings.currencySymbol : vaultCurrency;
  }
  return settings.currencySymbol;
});

/// Gelecek tarihli tek seferlik işlemler — plan sekmesinde gösterilir
final futureOneTimeTransactionsProvider = Provider<List<TransactionUI>>((ref) {
  final allTransactions = ref.watch(vaultTransactionsProvider);
  final filter = ref.watch(transactionFilterProvider);
  final selectedVaultId = ref.watch(selectedVaultProvider);
  final groups = ref.watch(transactionGroupsProvider);
  final isIdValid = selectedVaultId == null || groups.any((g) => g.id == selectedVaultId);
  final effectiveVaultId = (isIdValid ? selectedVaultId : null) ?? (groups.isNotEmpty ? groups.first.id : null);

  final today = DateTime.now();
  final todayNorm = DateTime(today.year, today.month, today.day);

  // 1. Kasa Filtresi
  var filtered = effectiveVaultId == null
      ? allTransactions
      : allTransactions.where((t) => t.groupIds.contains(effectiveVaultId)).toList();

  // 2. Sadece gelecek tarihli + şablona bağlı olmayan (tek seferlik)
  filtered = filtered.where((t) {
    final d = DateTime(t.date.year, t.date.month, t.date.day);
    return d.isAfter(todayNorm) && t.templateId == null;
  }).toList();

  // 3. Tip Filtresi
  filtered = filtered.where((t) {
    if (filter == TransactionFilter.income) return t.isIncome;
    if (filter == TransactionFilter.expense) return !t.isIncome;
    return true;
  }).toList();

  // Tarihe göre sırala (yakın tarih önce)
  filtered.sort((a, b) => a.date.compareTo(b.date));

  return filtered;
});

/// Son kontrol edilen uygulama içi bildirimlerin zaman damgası
final lastCheckedNotificationsTimeProvider = StateNotifierProvider<LastCheckedNotificationsTimeNotifier, int>((ref) {
  return LastCheckedNotificationsTimeNotifier();
});

class LastCheckedNotificationsTimeNotifier extends StateNotifier<int> {
  LastCheckedNotificationsTimeNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('last_checked_notifications_time') ?? 0;
  }

  Future<void> updateToNow() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_checked_notifications_time', now);
    state = now;
  }
}

/// Şablon bildirim hatırlatma tarihini hesaplar
DateTime calculateTemplateReminderDateTime(TemplateUI tx) {
  DateTime targetDate = tx.startDate;
  targetDate = targetDate.subtract(Duration(days: tx.notificationReminderDays));
  return DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
    tx.notificationHour,
    tx.notificationMinute,
  );
}

/// Okunmamış bildirimlerin sayısı
final unseenNotificationsCountProvider = Provider<int>((ref) {
  final allTemplates = ref.watch(vaultTemplatesProvider);
  final lastChecked = ref.watch(lastCheckedNotificationsTimeProvider);
  final now = DateTime.now();

  int count = 0;
  for (final tx in allTemplates) {
    if (!tx.isNotificationEnabled) continue;
    final reminderTime = calculateTemplateReminderDateTime(tx);
    if (reminderTime.isBefore(now) && reminderTime.millisecondsSinceEpoch > lastChecked) {
      count++;
    }
  }
  return count;
});

class VaultCardData {
  final String? vaultId;
  final double income;
  final double expense;
  final double balance;
  final double? convertedBalance;
  final String currencySymbol;
  final String targetCurrency;
  final bool hasFlexibleTx;
  final double minNet;
  final double maxNet;

  VaultCardData({
    required this.vaultId,
    required this.income,
    required this.expense,
    required this.balance,
    this.convertedBalance,
    required this.currencySymbol,
    required this.targetCurrency,
    required this.hasFlexibleTx,
    required this.minNet,
    required this.maxNet,
  });
}

/// Her bir kasa için kart verilerini hesaplayan ve önbelleğe alan provider
final vaultCardDataProvider = Provider<Map<String?, VaultCardData>>((ref) {
  final globalCurrency = ref.watch(settingsProvider).currencySymbol;
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final allVaults = ref.watch(allVaultsProvider);
  
  final dbRecords = ref.watch(allTransactionsProvider);
  final allTransactions = ref.watch(vaultTransactionsProvider);
  final allTemplates = ref.watch(vaultTemplatesProvider);

  final Map<String?, VaultCardData> dataMap = {};

  // Deck items (tüm kasalar + gerekirse null yani genel bakiye için)
  final List<String?> ids = [null, ...allVaults.map((v) => 'v_${v.id}')];

  final now = DateTime.now();

  for (final vaultId in ids) {
    final vault = allVaults.where((v) => 'v_${v.id}' == vaultId).firstOrNull;
    final vaultCurrency = vault?.currency ?? 'AUTO';
    final targetCurrency = vaultCurrency == 'AUTO' ? globalCurrency : vaultCurrency;

    final txs = vaultId == null 
        ? allTransactions 
        : allTransactions.where((t) => t.groupIds.contains(vaultId)).toList();

    // 1. Aylık Akış (Gelir/Gider İstatistikleri)
    double income = 0;
    double expense = 0;

    // A. Tekrarlı şablonların bu aydaki katkısı (tahmini)
    final activeTemplates = vaultId == null
        ? allTemplates.where((t) => !t.isArchived)
        : allTemplates.where((t) => !t.isArchived && t.vaultId == int.parse(vaultId.replaceFirst('v_', '')));

    for (final t in activeTemplates) {
      final occurrences = RecurrenceEngine.occurrencesInMonth(t.recurrenceRule, now.year, now.month);
      if (occurrences > 0) {
        final amt = t.getConvertedAmount(targetCurrency, rates) * occurrences;
        if (t.isIncome) {
          income += amt;
        } else {
          expense += amt;
        }
      }
    }

    // B. Tek seferlik işlemlerin bu aydaki katkısı (somut ve atlanmamış olanlar)
    final activeTxs = txs.where((t) => t.templateId == null && t.status != TransactionStatus.skipped && !t.isArchived).toList();
    for (final t in activeTxs) {
      if (t.date.year == now.year && t.date.month == now.month) {
        final amt = t.getConvertedAmount(targetCurrency, rates);
        final isTransfer = t.targetVaultId != null;
        if (isTransfer) {
          if (vaultId != null) {
            final activeDbId = int.tryParse(vaultId.replaceFirst('v_', ''));
            if (t.targetVaultId == activeDbId) {
              income += amt;
            } else if (t.vaultId == activeDbId) {
              expense += amt;
            }
          }
          // Genel bakiyede transfer işlemleri gelir/gider akışına dahil edilmez
        } else {
          if (t.isIncome) {
            income += amt;
          } else {
            expense += amt;
          }
        }
      }
    }

    // 2. Toplam Bakiye (Geçmişten Bugüne Tüm Hareketler)
    final double balance;
    if (vaultId == null) {
      balance = BalanceService.calculateNetBalance(
        vaults: allVaults,
        records: dbRecords,
        targetCurrency: targetCurrency,
        rates: rates,
      );
    } else {
      balance = BalanceService.calculateVaultBalance(
        vault: vault!,
        records: dbRecords,
        targetCurrency: targetCurrency,
        rates: rates,
      );
    }

    // Döviz çevirisi
    final currencySymbol = vaultCurrency == 'AUTO' ? globalCurrency : vaultCurrency;

    double? convertedBalance;
    if (vaultCurrency != 'AUTO' && vaultCurrency != globalCurrency) {
      convertedBalance = CurrencyUtils.convert(balance, vaultCurrency, globalCurrency, rates);
    }

    // Esnek işlemler var mı? (Şablonlarda min/max var mı?)
    final hasFlexibleTx = activeTemplates.any((t) => t.minAmount != null || t.maxAmount != null) ||
                          activeTxs.any((t) => t.minAmount != null || t.maxAmount != null);

    // Worst / Best Case (Aylık Net Tahmin Aralığı)
    double minNet = 0;
    double maxNet = 0;

    if (hasFlexibleTx) {
      double minIncome = 0;
      double maxIncome = 0;
      double minExpense = 0;
      double maxExpense = 0;

      // Şablonlar üzerinden esnek aralıklar
      for (final t in activeTemplates) {
        final occurrences = RecurrenceEngine.occurrencesInMonth(t.recurrenceRule, now.year, now.month);
        if (occurrences > 0) {
          final minAmt = t.minAmount ?? t.amount;
          final maxAmt = t.maxAmount ?? t.amount;
          if (t.isIncome) {
            minIncome += CurrencyUtils.convert(minAmt * occurrences, t.currency ?? '₺', targetCurrency, rates);
            maxIncome += CurrencyUtils.convert(maxAmt * occurrences, t.currency ?? '₺', targetCurrency, rates);
          } else {
            minExpense += CurrencyUtils.convert(minAmt * occurrences, t.currency ?? '₺', targetCurrency, rates);
            maxExpense += CurrencyUtils.convert(maxAmt * occurrences, t.currency ?? '₺', targetCurrency, rates);
          }
        }
      }

      // Tek seferlik işlemler üzerinden esnek aralıklar
      for (final t in activeTxs) {
        if (t.date.year == now.year && t.date.month == now.month) {
          final minAmt = t.minAmount ?? t.amount;
          final maxAmt = t.maxAmount ?? t.amount;
          if (t.isIncome) {
            minIncome += CurrencyUtils.convert(minAmt, t.currency ?? '₺', targetCurrency, rates);
            maxIncome += CurrencyUtils.convert(maxAmt, t.currency ?? '₺', targetCurrency, rates);
          } else {
            minExpense += CurrencyUtils.convert(minAmt, t.currency ?? '₺', targetCurrency, rates);
            maxExpense += CurrencyUtils.convert(maxAmt, t.currency ?? '₺', targetCurrency, rates);
          }
        }
      }

      minNet = minIncome - maxExpense;
      maxNet = maxIncome - minExpense;
    }

    dataMap[vaultId] = VaultCardData(
      vaultId: vaultId,
      income: income,
      expense: expense,
      balance: balance,
      convertedBalance: convertedBalance,
      currencySymbol: currencySymbol,
      targetCurrency: targetCurrency,
      hasFlexibleTx: hasFlexibleTx,
      minNet: minNet,
      maxNet: maxNet,
    );
  }

  return dataMap;
});
