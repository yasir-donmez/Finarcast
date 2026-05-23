import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import '../database/models/transaction_record.dart';
import '../database/models/custom_category.dart';
import '../utils/currency_utils.dart';

import '../database/models/vault.dart';
import '../database/models/exchange_rate.dart';
import './settings_provider.dart';

/// === İŞLEM PROVİDER'LARI ===

/// Tüm işlemleri canlı dinleyen stream provider
final transactionsStreamProvider = StreamProvider<List<TransactionRecord>>((
  ref,
) {
  return DatabaseService.watchAllTransactions();
});

/// Tüm işlemlerin anlık listesi (kolayca erişim için)
final allTransactionsProvider = Provider<List<TransactionRecord>>((ref) {
  return ref.watch(transactionsStreamProvider).valueOrNull ?? [];
});

/// Gelir işlemleri
final incomeTransactionsProvider = Provider<List<TransactionRecord>>((ref) {
  return ref.watch(allTransactionsProvider).where((t) => t.isIncome).toList();
});

/// Gider işlemleri
final expenseTransactionsProvider = Provider<List<TransactionRecord>>((ref) {
  return ref.watch(allTransactionsProvider).where((t) => !t.isIncome).toList();
});

/// Toplam gelir (Sadece gerçekleşenler: tarihi bugün veya geçmiş olanlar)
final totalIncomeProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final targetCurrency = ref.watch(settingsProvider).currencySymbol;

  return ref
      .watch(allTransactionsProvider)
      .where((t) => t.isIncome && (t.date.isBefore(now) || t.date.isAtSameMomentAs(now)))
      .fold<double>(0, (sum, t) => sum + t.getConvertedAmount(targetCurrency, rates));
});

/// Toplam gider (Sadece gerçekleşenler)
final totalExpenseProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final targetCurrency = ref.watch(settingsProvider).currencySymbol;

  return ref
      .watch(allTransactionsProvider)
      .where((t) => !t.isIncome && (t.date.isBefore(now) || t.date.isAtSameMomentAs(now)))
      .fold<double>(0, (sum, t) => sum + t.getConvertedAmount(targetCurrency, rates));
});

/// Net bakiye (gelir - gider)
final netBalanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

/// Net Min bakiye (Kötü senaryo - Sadece gerçekleşenler üzerinden)
final netMinBalanceProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final targetCurrency = ref.watch(settingsProvider).currencySymbol;
  
  return ref.watch(allTransactionsProvider)
      .where((t) => t.date.isBefore(now) || t.date.isAtSameMomentAs(now))
      .fold<double>(0, (sum, t) {
    if (t.isIncome) {
      final val = t.minAmount ?? t.amount;
      return sum + CurrencyUtils.convert(val, t.currency ?? '₺', targetCurrency, rates);
    } else {
      final val = t.maxAmount ?? t.amount;
      return sum - CurrencyUtils.convert(val, t.currency ?? '₺', targetCurrency, rates);
    }
  });
});

/// Net Max bakiye (İyi senaryo - Sadece gerçekleşenler üzerinden)
final netMaxBalanceProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final targetCurrency = ref.watch(settingsProvider).currencySymbol;

  return ref.watch(allTransactionsProvider)
      .where((t) => t.date.isBefore(now) || t.date.isAtSameMomentAs(now))
      .fold<double>(0, (sum, t) {
    if (t.isIncome) {
      final val = t.maxAmount ?? t.amount;
      return sum + CurrencyUtils.convert(val, t.currency ?? '₺', targetCurrency, rates);
    } else {
      final val = t.minAmount ?? t.amount;
      return sum - CurrencyUtils.convert(val, t.currency ?? '₺', targetCurrency, rates);
    }
  });
});

/// === KASA PROVİDER'LARI ===

/// Kasaları canlı dinleyen stream provider
final vaultsStreamProvider = StreamProvider<List<Vault>>((ref) {
  return DatabaseService.watchAllVaults().map(
    (vaults) => vaults.toList()
      ..sort((a, b) {
        final cmp = a.dashboardOrder.compareTo(b.dashboardOrder);
        if (cmp != 0) return cmp;
        return a.id.compareTo(b.id);
      }),
  );
});

/// Kasaların anlık listesi
final allVaultsProvider = Provider<List<Vault>>((ref) {
  return ref.watch(vaultsStreamProvider).valueOrNull ?? [];
});

/// Döviz kurlarını canlı dinle
final exchangeRatesProvider = StreamProvider<List<ExchangeRate>>((ref) {
  return DatabaseService.watchAllExchangeRates();
});

/// Özel alt kategorileri canlı dinleyen stream provider
final customCategoriesStreamProvider = StreamProvider<List<CustomCategory>>((ref) {
  return DatabaseService.watchAllCustomCategories();
});

/// Özel alt kategorilerin anlık listesi
final customCategoriesProvider = Provider<List<CustomCategory>>((ref) {
  return ref.watch(customCategoriesStreamProvider).valueOrNull ?? [];
});
