import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/db_providers.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/transaction_record.dart';
import '../../core/database/models/exchange_rate.dart';
import '../../core/database/models/custom_category.dart';
import '../../core/utils/category_utils.dart';
import '../../core/utils/currency_utils.dart';

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
  final int periodType; // 0: Tek Seferlik, 1: Haftalık, 2: Aylık, 3: Yıllık
  final DateTime date;
  final int? remainingInstallments; // Taksit sayısı (varsa)
  final int? dbId; // Isar DB ID (null = henüz kaydedilmemiş)
  final String? categoryId; // Multi-language desteği için benzersiz anahtar
  final String? iconCode;   // İkon referansı (ID veya özel kod)
  
  // --- Eksik Kalan Detaylar ---
  final String? note;
  final String? currency;
  final int? recurrenceDay;
  final DateTime? recurrenceDate;
  final int? recurrenceDuration;

  final bool showOnDashboard;
  final int dashboardLayoutType;
  final bool isArchived;
  List<String> groupIds = []; // Çoklu kasa desteği
  
  // --- Bildirim Ayarları ---
  final bool isNotificationEnabled;
  final bool hasNotification;
  final int notificationReminderDays;
  final int notificationHour;
  final int notificationMinute;

  TransactionUI({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    this.minAmount,
    this.maxAmount,
    required this.isIncome,
    required this.periodType,
    required this.date,
    this.remainingInstallments,
    this.dbId,
    this.categoryId,
    this.iconCode,
    this.note,
    this.currency,
    this.recurrenceDay,
    this.recurrenceDate,
    this.recurrenceDuration,
    required this.showOnDashboard,
    this.dashboardLayoutType = 4,
    this.isArchived = false,
    List<String>? groupIds,
    this.isNotificationEnabled = false,
    this.hasNotification = false,
    this.notificationReminderDays = 0,
    this.notificationHour = 9,
    this.notificationMinute = 0,
  }) : groupIds = groupIds ?? [];

  /// Belirli bir tutarın aylık karşılığını hesaplar.
  double _calculateMonthly(double baseAmount) {
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
    return double.parse(monthly.toStringAsFixed(2));
  }

  /// İşlemin etkin tutarını hesaplar.
  double get effectiveAmount {
    if (amount == 0 && (minAmount != null || maxAmount != null)) {
      return ((minAmount ?? 0) + (maxAmount ?? 0)) /
          ((minAmount != null && maxAmount != null) ? 2 : 1);
    }
    return amount;
  }

  /// İşlemin aylık karşılığını hesaplar.
  double get monthlyEquivalent => _calculateMonthly(effectiveAmount);

  /// Minimum aylık karşılık (esnek işlemler için)
  double get minMonthlyEquivalent => _calculateMonthly(minAmount ?? amount);

  /// Maksimum aylık karşılık (esnek işlemler için)
  double get maxMonthlyEquivalent => _calculateMonthly(maxAmount ?? amount);

  /// Ortalama aylık karşılık (esnek işlemler için)
  double get avgMonthlyEquivalent => monthlyEquivalent;

  /// Belirli bir hedef birime göre tutarı döndürür
  double getConvertedAmount(String targetCurrency, List<ExchangeRate> rates) {
    return CurrencyUtils.convert(effectiveAmount, currency ?? '₺', targetCurrency, rates);
  }

  /// Belirli bir hedef birime göre aylık karşılığı döndürür
  double getConvertedMonthlyEquivalent(String targetCurrency, List<ExchangeRate> rates) {
    return CurrencyUtils.convert(monthlyEquivalent, currency ?? '₺', targetCurrency, rates);
  }

  /// Bugüne kadar gerçekleşmiş tekrar sayısını hesaplar.
  int _countWeekdays(DateTime start, DateTime end) {
    int count = 0;
    DateTime cur = start;
    while (!cur.isAfter(end)) {
      if (cur.weekday >= 1 && cur.weekday <= 5) {
        count++;
      }
      cur = cur.add(const Duration(days: 1));
    }
    return count;
  }

  int _countWeekends(DateTime start, DateTime end) {
    int count = 0;
    DateTime cur = start;
    while (!cur.isAfter(end)) {
      if (cur.weekday == 6 || cur.weekday == 7) {
        count++;
      }
      cur = cur.add(const Duration(days: 1));
    }
    return count;
  }

  int get passedOccurrences {
    if (periodType == 0) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDate = DateTime(date.year, date.month, date.day);
      return today.isBefore(startDate) ? 0 : 1;
    }

    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final start = DateTime(date.year, date.month, date.day);
    
    if (now.isBefore(start)) return 0;

    final diffDays = now.difference(start).inDays;
    int intervals = 0;
    
    if (periodType == 250) {
      intervals = _countWeekdays(start, now) - 1;
    } else if (periodType == 251) {
      intervals = _countWeekends(start, now) - 1;
    } else {
      final unit = periodType ~/ 100;
      final interval = periodType % 100;
      if (interval > 0) {
        switch (unit) {
          case 1: // Gün
            intervals = diffDays ~/ interval;
            break;
          case 2: // Hafta
            intervals = diffDays ~/ (interval * 7);
            break;
          case 3: // Ay
            int months = (now.year - start.year) * 12 + now.month - start.month;
            if (now.day < start.day) months--;
            intervals = months ~/ interval;
            break;
          case 4: // Yıl
            int years = now.year - start.year;
            if (now.month < start.month || (now.month == start.month && now.day < start.day)) years--;
            intervals = years ~/ interval;
            break;
        }
      }
    }
    
    int passed = (intervals < 0 ? 0 : intervals) + 1;
    
    if (recurrenceDuration != null && recurrenceDuration! > 0) {
      if (passed > recurrenceDuration!) passed = recurrenceDuration!;
    }
    
    return passed;
  }

  /// Belirtilen yıl ve ay içinde bu işlemin tam olarak kaç kez gerçekleşeceğini (veya gerçekleştiğini) hesaplar.
  int getOccurrencesInMonth(int targetYear, int targetMonth) {
    if (periodType == 0) {
      return (date.year == targetYear && date.month == targetMonth) ? 1 : 0;
    }

    // Basit bir simülasyon: Ayın başından sonuna kadar tüm günleri gez ve tetiklenip tetiklenmediğine bak
    final monthStart = DateTime(targetYear, targetMonth, 1);
    final monthEnd = DateTime(targetYear, targetMonth + 1, 0); // Son gün
    
    final start = DateTime(date.year, date.month, date.day);
    
    // İşlem bu aydan sonra başlıyorsa 0
    if (start.isAfter(monthEnd)) return 0;

    // Eğer bitiş tarihi varsa, onu hesapla
    DateTime? endDate;
    if (recurrenceDuration != null && recurrenceDuration! > 0) {
      final duration = recurrenceDuration! - 1;
      if (duration <= 0) {
        endDate = start;
      }
      else {
        if (periodType == 250) {
          DateTime temp = start;
          for (int i = 0; i < duration; i++) {
            int addDays = 1;
            if (temp.weekday == DateTime.friday) {
              addDays = 3;
            } else if (temp.weekday == DateTime.saturday) {
              addDays = 2;
            }
            temp = temp.add(Duration(days: addDays));
          }
          endDate = temp;
        } else if (periodType == 251) {
          DateTime temp = start;
          for (int i = 0; i < duration; i++) {
            int addDays = 1;
            if (temp.weekday == DateTime.sunday) {
              addDays = 6;
            } else if (temp.weekday >= DateTime.monday && temp.weekday <= DateTime.friday) {
              addDays = DateTime.saturday - temp.weekday;
            }
            temp = temp.add(Duration(days: addDays));
          }
          endDate = temp;
        } else {
          final unit = periodType ~/ 100;
          final interval = periodType % 100;
          if (interval > 0) {
            switch (unit) {
              case 1: endDate = start.add(Duration(days: duration * interval)); break;
              case 2: endDate = start.add(Duration(days: duration * interval * 7)); break;
              case 3: endDate = DateTime(start.year, start.month + (duration * interval), start.day); break;
              case 4: endDate = DateTime(start.year + (duration * interval), start.month, start.day); break;
            }
          }
        }
      }
    }

    // İşlem tamamen bu aydan önce bittiyse 0
    if (endDate != null && endDate.isBefore(monthStart)) return 0;

    int occurrences = 0;
    
    // Günlük/Haftalık gibi gün bazlı periyotlar için: 
    // Ayın ilk gününden son gününe iterasyon
    DateTime current = monthStart.isBefore(start) ? start : monthStart;
    final endIteration = endDate != null && endDate.isBefore(monthEnd) ? endDate : monthEnd;

    final unit = periodType ~/ 100;
    final interval = periodType % 100;

    if (periodType == 250 || periodType == 251 || unit == 1 || unit == 2) {
      while (current.isBefore(endIteration) || current.isAtSameMomentAs(endIteration)) {
        final diffDays = current.difference(start).inDays;
        bool isHit = false;
        if (periodType == 250) {
          isHit = current.weekday >= 1 && current.weekday <= 5;
        } else if (periodType == 251) {
          isHit = current.weekday == 6 || current.weekday == 7;
        } else if (interval > 0) {
          if (unit == 1) {
            isHit = diffDays % interval == 0;
          } else if (unit == 2) {
            isHit = diffDays % (interval * 7) == 0;
          }
        }
        if (isHit) occurrences++;
        current = current.add(const Duration(days: 1));
      }
    } 
    // Aylık/Yıllık bazlı periyotlar için:
    else if (unit == 3 || unit == 4) {
      // Bu periyotlarda ayın o günü tetiklenir (veya o aya ait son gün)
      int targetDay = recurrenceDate?.day ?? start.day;
      
      // Şubatta 30'u arıyorsak 28/29'a düşür
      final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;
      if (targetDay > lastDayOfMonth) targetDay = lastDayOfMonth;
      
      final candidateDate = DateTime(targetYear, targetMonth, targetDay);
      
      if (!candidateDate.isBefore(start) && (endDate == null || !candidateDate.isAfter(endDate))) {
        // Ayların farkını bul
        int monthsDiff = (candidateDate.year - start.year) * 12 + (candidateDate.month - start.month);
        bool isHit = false;
        if (interval > 0) {
          if (unit == 3) {
            isHit = monthsDiff % interval == 0;
          } else if (unit == 4) {
            isHit = monthsDiff % (interval * 12) == 0;
          }
        }
        if (isHit) occurrences = 1;
      }
    }
    return occurrences;
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
      periodType: record.periodType,
      date: record.date,
      remainingInstallments: record.remainingInstallments,
      dbId: record.id,
      categoryId: record.categoryId,
      iconCode: record.iconCode,
      note: record.note,
      currency: record.currency,
      recurrenceDay: record.recurrenceDay,
      recurrenceDate: record.recurrenceDate,
      recurrenceDuration: record.recurrenceDuration,
      showOnDashboard: record.showOnDashboard,
      dashboardLayoutType: record.dashboardLayoutType,
      isArchived: record.isArchived,
      groupIds: record.vaultIds.map((vId) => 'v_$vId').toList(),
      isNotificationEnabled: record.isNotificationEnabled,
      hasNotification: record.hasNotification,
      notificationReminderDays: record.notificationReminderDays,
      notificationHour: record.notificationHour,
      notificationMinute: record.notificationMinute,
    );
  }
}

/// İşlem grubu (Klasör mantığı)
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

/// Aktif filtre
final transactionFilterProvider = StateProvider<TransactionFilter>(
  (ref) => TransactionFilter.all,
);

/// DB'den gelen işlemleri UI modeline çeviren provider
final vaultTransactionsProvider = Provider<List<TransactionUI>>((ref) {
  final dbRecords = ref.watch(allTransactionsProvider);
  final customCategories = ref.watch(customCategoriesProvider);
  return dbRecords.map((r) => TransactionUI.fromDB(r, customCategories)).toList();
});

/// Gruplama işlemi için yardımcı notifier
final transactionGroupingProvider = Provider(
  (ref) => TransactionGroupingHelper(),
);

class TransactionGroupingHelper {
  /// Bir işleme kasa ekler veya çıkarır (Toggle)
  Future<void> toggleVault(String transactionId, String vaultId) async {
    if (!transactionId.startsWith('db_')) return;
    final txId = int.tryParse(transactionId.replaceFirst('db_', ''));
    if (txId == null) return;

    if (!vaultId.startsWith('v_')) return;
    final vId = int.tryParse(vaultId.replaceFirst('v_', ''));
    if (vId == null) return;

    final record = await DatabaseService.getTransaction(txId);
    if (record == null) return;

    final currentVaults = List<int>.from(record.vaultIds);
    if (currentVaults.contains(vId)) {
      currentVaults.remove(vId);
    } else {
      currentVaults.add(vId);
    }
    
    record.vaultIds = currentVaults;
    await DatabaseService.updateTransaction(record);
  }

  /// Bir işlemden kasayı tamamen çıkarır
  Future<void> removeFromVault(String transactionId, String vaultId) async {
     if (!transactionId.startsWith('db_')) return;
    final txId = int.tryParse(transactionId.replaceFirst('db_', ''));
    if (txId == null) return;

    if (!vaultId.startsWith('v_')) return;
    final vId = int.tryParse(vaultId.replaceFirst('v_', ''));
    if (vId == null) return;

    final record = await DatabaseService.getTransaction(txId);
    if (record == null) return;

    final currentVaults = List<int>.from(record.vaultIds);
    currentVaults.remove(vId);
    
    record.vaultIds = currentVaults;
    await DatabaseService.updateTransaction(record);
  }

  /// Tek seferde kasanın tüm içeriğini set eder (Picker için)
  Future<void> setVaultTransactions(String vaultId, List<String> transactionIds) async {
    if (!vaultId.startsWith('v_')) return;
    final vId = int.tryParse(vaultId.replaceFirst('v_', ''));
    if (vId == null) return;

    final allTx = await DatabaseService.getAllTransactions();
    
    // İşlem listesindeki her işlem için bu kasayı ekle/çıkar
    for (final record in allTx) {
      final txUiId = 'db_${record.id}';
      final currentVaults = List<int>.from(record.vaultIds);
      bool changed = false;

      if (transactionIds.contains(txUiId)) {
        if (!currentVaults.contains(vId)) {
          currentVaults.add(vId);
          changed = true;
        }
      } else {
        if (currentVaults.contains(vId)) {
          currentVaults.remove(vId);
          changed = true;
        }
      }

      if (changed) {
        record.vaultIds = currentVaults;
        await DatabaseService.updateTransaction(record);
      }
    }
  }
}

/// Gruplar — Database tabanlı provider
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

/// Grup işlemleri için yardımcı notifier
final transactionGroupsNotifierProvider = Provider(
  (ref) => TransactionGroupsHelper(),
);

class TransactionGroupsHelper {
  /// Grubun adını değiştir
  Future<void> renameGroup(String groupId, String newName) async {
    if (!groupId.startsWith('v_')) return;
    final id = int.tryParse(groupId.replaceFirst('v_', ''));
    if (id == null) return;

    final vaults = await DatabaseService.getAllVaults();
    final vault = vaults.where((v) => v.id == id).firstOrNull;
    if (vault != null) {
      vault.name = newName;
      await DatabaseService.updateVault(vault);
    }
  }

  /// Grubu tamamen sil
  Future<void> deleteGroup(String groupId) async {
    if (!groupId.startsWith('v_')) return;
    final id = int.tryParse(groupId.replaceFirst('v_', ''));
    if (id == null) return;

    // Önce bu gruptaki tüm işlemleri çıkar
    final allTx = await DatabaseService.getAllTransactions();
    for (final tx in allTx) {
      if (tx.vaultIds.contains(id)) {
        final updatedVaults = List<int>.from(tx.vaultIds)..remove(id);
        tx.vaultIds = updatedVaults;
        await DatabaseService.updateTransaction(tx);
      }
    }

    // Kasayı (Grubu) sil
    await DatabaseService.deleteVault(id);
  }
}

/// Seçili kasa (null = Ana Kasa / Tümü)
final selectedVaultProvider = StateProvider<String?>((ref) => null);

/// Seçili periyot (null = Tümü, 0: Tek Seferlik, 1: Haftalık, 2: Aylık, 3: Yıllık)
final selectedPeriodProvider = StateProvider<int?>((ref) => null);

/// Seçili filtrelemelere göre işlemleri getiren provider
final filteredVaultTransactionsProvider = Provider<List<TransactionUI>>((ref) {
  final allTransactions = ref.watch(vaultTransactionsProvider);
  final filter = ref.watch(transactionFilterProvider);
  final selectedVaultId = ref.watch(selectedVaultProvider);
  final selectedPeriod = ref.watch(selectedPeriodProvider);

  // 1. Kasa Filtresi
  var filtered = selectedVaultId == null
      ? allTransactions
      : allTransactions.where((t) => t.groupIds.contains(selectedVaultId)).toList();

  // 2. Tip Filtresi (Gelir/Gider)
  filtered = filtered.where((t) {
    if (filter == TransactionFilter.income) return t.isIncome;
    if (filter == TransactionFilter.expense) return !t.isIncome;
    return true;
  }).toList();

  // 3. Periyot Filtresi
  if (selectedPeriod != null) {
    filtered = filtered.where((t) => t.periodType == selectedPeriod).toList();
  }

  return filtered;
});

/// Son kontrol edilen uygulama içi bildirimlerin zaman damgası (SharedPreferences'ta saklanır)
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

/// Bildirim zamanı gelmiş (tetiklenmiş) tüm işlemleri getiren helper
DateTime calculateTransactionReminderDateTime(TransactionUI tx) {
  DateTime targetDate = tx.date;
  targetDate = targetDate.subtract(Duration(days: tx.notificationReminderDays));
  return DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
    tx.notificationHour,
    tx.notificationMinute,
  );
}

/// Okunmamış (tetiklenmiş ama son kontrolden sonra) bildirimlerin sayısı
final unseenNotificationsCountProvider = Provider<int>((ref) {
  final allTransactions = ref.watch(vaultTransactionsProvider);
  final lastChecked = ref.watch(lastCheckedNotificationsTimeProvider);
  final now = DateTime.now();

  int count = 0;
  for (final tx in allTransactions) {
    if (!tx.isNotificationEnabled) continue;
    final reminderTime = calculateTransactionReminderDateTime(tx);
    // Bildirim zamanı geçmiş ve kullanıcının son kontrol ettiği zamandan sonra ise
    if (reminderTime.isBefore(now) && reminderTime.millisecondsSinceEpoch > lastChecked) {
      count++;
    }
  }
  return count;
});
