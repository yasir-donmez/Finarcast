import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import '../database/models/transaction_record.dart';
import '../database/models/recurring_template.dart';
import '../database/models/transaction_status.dart';
import '../database/models/custom_category.dart';
import '../database/models/vault.dart';
import '../database/models/exchange_rate.dart';
import './settings_provider.dart';
import '../services/subscription_service.dart';
import '../services/balance_service.dart';

/// === ŞABLON PROVİDER'LARI ===

/// Tüm şablonları canlı dinleyen stream provider
final templatesStreamProvider = StreamProvider<List<RecurringTemplate>>((ref) {
  return DatabaseService.watchAllTemplates();
});

/// Tüm şablonların anlık listesi
final allTemplatesProvider = Provider<List<RecurringTemplate>>((ref) {
  return ref.watch(templatesStreamProvider).valueOrNull ?? [];
});

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

/// Gelir işlemleri (Atlanmamış olanlar)
final incomeTransactionsProvider = Provider<List<TransactionRecord>>((ref) {
  return ref.watch(allTransactionsProvider)
      .where((t) => t.isIncome && t.status != TransactionStatus.skipped)
      .toList();
});

/// Gider işlemleri (Atlanmamış olanlar)
final expenseTransactionsProvider = Provider<List<TransactionRecord>>((ref) {
  return ref.watch(allTransactionsProvider)
      .where((t) => !t.isIncome && t.status != TransactionStatus.skipped)
      .toList();
});

/// Toplam gelir (Sadece gerçekleşenler: tarihi bugün veya geçmiş olanlar ve atlanmamış olanlar)
final totalIncomeProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final targetCurrency = ref.watch(settingsProvider).currencySymbol;

  return ref
      .watch(allTransactionsProvider)
      .where((t) => t.isIncome && t.status != TransactionStatus.skipped && !t.occurrenceDate.isAfter(today))
      .fold<double>(0, (sum, t) => sum + t.getConvertedAmount(targetCurrency, rates));
});

/// Toplam gider (Sadece gerçekleşenler ve atlanmamış olanlar)
final totalExpenseProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final targetCurrency = ref.watch(settingsProvider).currencySymbol;

  return ref
      .watch(allTransactionsProvider)
      .where((t) => !t.isIncome && t.status != TransactionStatus.skipped && !t.occurrenceDate.isAfter(today))
      .fold<double>(0, (sum, t) => sum + t.getConvertedAmount(targetCurrency, rates));
});

/// Net bakiye (gelir - gider + kasaların ilk bakiyeleri)
final netBalanceProvider = Provider<double>((ref) {
  return BalanceService.calculateNetBalance(
    vaults: ref.watch(allVaultsProvider),
    records: ref.watch(allTransactionsProvider),
    targetCurrency: ref.watch(settingsProvider).currencySymbol,
    rates: ref.watch(exchangeRatesProvider).value ?? [],
  );
});

/// Net Min bakiye (Kötü senaryo - BalanceService delegasyonu)
final netMinBalanceProvider = Provider<double>((ref) {
  return BalanceService.calculateMinBalance(
    vaults: ref.watch(allVaultsProvider),
    records: ref.watch(allTransactionsProvider),
    targetCurrency: ref.watch(settingsProvider).currencySymbol,
    rates: ref.watch(exchangeRatesProvider).value ?? [],
  );
});

/// Net Max bakiye (İyi senaryo - BalanceService delegasyonu)
final netMaxBalanceProvider = Provider<double>((ref) {
  return BalanceService.calculateMaxBalance(
    vaults: ref.watch(allVaultsProvider),
    records: ref.watch(allTransactionsProvider),
    targetCurrency: ref.watch(settingsProvider).currencySymbol,
    rates: ref.watch(exchangeRatesProvider).value ?? [],
  );
});

/// === KASA PROVİDER'LARI ===

/// Kasaları canlı dinleyen stream provider
final vaultsStreamProvider = StreamProvider<List<Vault>>((ref) {
  return DatabaseService.watchAllVaults().map(
    (vaults) => vaults.toList()..sort((a, b) => a.id.compareTo(b.id)),
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
  final isPro = ref.watch(subscriptionServiceProvider).isPro;
  if (!isPro) return [];
  return ref.watch(customCategoriesStreamProvider).valueOrNull ?? [];
});
