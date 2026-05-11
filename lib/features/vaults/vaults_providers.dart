import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/db_providers.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/transaction_record.dart';
import '../../core/database/models/exchange_rate.dart';
import '../../core/utils/icon_utils.dart';
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
  }) : groupIds = groupIds ?? [];

  /// Belirli bir tutarın aylık karşılığını hesaplar.
  double _calculateMonthly(double baseAmount) {
    double monthly;
    switch (periodType) {
      case 1: // Haftalık
        monthly = baseAmount * 4.33;
      case 2: // Aylık
        monthly = baseAmount;
      case 3: // Yıllık
        monthly = baseAmount / 12;
      case 4: // 2 Haftada Bir
        monthly = baseAmount * 2.16;
      case 5: // 3 Haftada Bir
        monthly = baseAmount * 1.44;
      case 6: // 3 Ayda Bir
        monthly = baseAmount / 3;
      case 7: // 6 Ayda Bir
        monthly = baseAmount / 6;
      case 8: // Günlük
        monthly = baseAmount * 30;
      case 9: // 2 Günde Bir
        monthly = baseAmount * 15;
      case 10: // 3 Günde Bir
        monthly = baseAmount * 10;
      default: // Tek seferlik
        monthly = 0;
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

  /// TransactionRecord'dan TransactionUI'a dönüştür
  factory TransactionUI.fromDB(TransactionRecord record) {
    return TransactionUI(
      id: 'db_${record.id}',
      name: record.title,
      icon: IconUtils.getIcon(record.categoryId ?? record.iconCode ?? record.title),
      color: IconUtils.getColor(record.categoryId ?? record.iconCode ?? record.title),
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
  return dbRecords.map((r) => TransactionUI.fromDB(r)).toList();
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
