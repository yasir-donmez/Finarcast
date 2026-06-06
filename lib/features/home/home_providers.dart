import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/utils/currency_utils.dart';
import '../vaults/vaults_providers.dart';

/// Zaman makinesi tekerleği çevrildiğinde eklenen sanal (gelecek) bakiye bonusu
final simulationBonusProvider = StateProvider<double>((ref) => 0.0);

/// Seçili kasa filtresi (Ana ekran genel bakiye alanı için)
final homeMainBalanceVaultIdProvider = StateProvider<String?>((ref) => null);

/// Seçili kasa filtresine göre gerçek bakiyeyi hesaplar (Ana ekran için)
final homeRealBalanceProvider = Provider<double>((ref) {
  final vaultId = ref.watch(homeMainBalanceVaultIdProvider);
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final targetCurrency = ref.watch(settingsProvider).currencySymbol;
  final now = DateTime.now();

  if (vaultId == null) {
    return ref.watch(netBalanceProvider);
  }

  final rawVaultId = int.tryParse(vaultId.replaceFirst('v_', ''));
  if (rawVaultId == null) {
    return ref.watch(netBalanceProvider);
  }

  final allVaults = ref.watch(allVaultsProvider);
  final vault = allVaults.where((v) => v.id == rawVaultId).firstOrNull;
  final vaultCurrency = vault?.currency ?? 'AUTO';
  final vaultInitialBalance = vault != null
      ? CurrencyUtils.convert(vault.balance, vaultCurrency == 'AUTO' ? targetCurrency : vaultCurrency, targetCurrency, rates)
      : 0.0;

  final allTx = ref.watch(allTransactionsProvider);
  final filteredTx = allTx.where((t) => t.vaultIds.contains(rawVaultId) && (t.date.isBefore(now) || t.date.isAtSameMomentAs(now)));

  double balance = vaultInitialBalance;
  for (final t in filteredTx) {
    final amt = t.getConvertedAmount(targetCurrency, rates);
    if (t.isIncome) {
      balance += amt;
    } else {
      balance -= amt;
    }
  }
  return balance;
});

/// Seçili kasa filtresine göre esnek bütçe alt limitini hesaplar
final homeMinBalanceProvider = Provider<double>((ref) {
  final vaultId = ref.watch(homeMainBalanceVaultIdProvider);
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final targetCurrency = ref.watch(settingsProvider).currencySymbol;
  final now = DateTime.now();

  if (vaultId == null) {
    return ref.watch(netMinBalanceProvider);
  }

  final rawVaultId = int.tryParse(vaultId.replaceFirst('v_', ''));
  if (rawVaultId == null) {
    return ref.watch(netMinBalanceProvider);
  }

  final allVaults = ref.watch(allVaultsProvider);
  final vault = allVaults.where((v) => v.id == rawVaultId).firstOrNull;
  final vaultCurrency = vault?.currency ?? 'AUTO';
  final vaultInitialBalance = vault != null
      ? CurrencyUtils.convert(vault.balance, vaultCurrency == 'AUTO' ? targetCurrency : vaultCurrency, targetCurrency, rates)
      : 0.0;

  final allTx = ref.watch(allTransactionsProvider);
  final filteredTx = allTx.where((t) => t.vaultIds.contains(rawVaultId) && (t.date.isBefore(now) || t.date.isAtSameMomentAs(now)));

  double balance = vaultInitialBalance;
  for (final t in filteredTx) {
    if (t.isIncome) {
      final val = t.minAmount ?? t.amount;
      balance += CurrencyUtils.convert(val, t.currency ?? '₺', targetCurrency, rates);
    } else {
      final val = t.maxAmount ?? t.amount;
      balance -= CurrencyUtils.convert(val, t.currency ?? '₺', targetCurrency, rates);
    }
  }
  return balance;
});

/// Seçili kasa filtresine göre esnek bütçe üst limitini hesaplar
final homeMaxBalanceProvider = Provider<double>((ref) {
  final vaultId = ref.watch(homeMainBalanceVaultIdProvider);
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final targetCurrency = ref.watch(settingsProvider).currencySymbol;
  final now = DateTime.now();

  if (vaultId == null) {
    return ref.watch(netMaxBalanceProvider);
  }

  final rawVaultId = int.tryParse(vaultId.replaceFirst('v_', ''));
  if (rawVaultId == null) {
    return ref.watch(netMaxBalanceProvider);
  }

  final allVaults = ref.watch(allVaultsProvider);
  final vault = allVaults.where((v) => v.id == rawVaultId).firstOrNull;
  final vaultCurrency = vault?.currency ?? 'AUTO';
  final vaultInitialBalance = vault != null
      ? CurrencyUtils.convert(vault.balance, vaultCurrency == 'AUTO' ? targetCurrency : vaultCurrency, targetCurrency, rates)
      : 0.0;

  final allTx = ref.watch(allTransactionsProvider);
  final filteredTx = allTx.where((t) => t.vaultIds.contains(rawVaultId) && (t.date.isBefore(now) || t.date.isAtSameMomentAs(now)));

  double balance = vaultInitialBalance;
  for (final t in filteredTx) {
    if (t.isIncome) {
      final val = t.maxAmount ?? t.amount;
      balance += CurrencyUtils.convert(val, t.currency ?? '₺', targetCurrency, rates);
    } else {
      final val = t.minAmount ?? t.amount;
      balance -= CurrencyUtils.convert(val, t.currency ?? '₺', targetCurrency, rates);
    }
  }
  return balance;
});

/// Ekranda gösterilecek toplam bakiye: Gerçek Bakiye (DB) + Zaman Makinesi Bonusu
final displayBalanceProvider = Provider<double>((ref) {
  final realBalance = ref.watch(homeRealBalanceProvider);
  final bonus = ref.watch(simulationBonusProvider);
  return realBalance + bonus;
});

/// Renklerin artık sadece Ayarlar'dan gelmesini sağlayan Provider (Zaman çarkından bağımsızlaştırıldı)
final rotaryColorProvider = Provider<Color>((ref) {
  final accentColor = ref.watch(settingsProvider.select((s) => s.accentColorValue));
  if (accentColor == 0) {
    return ref.watch(dynamicColorProvider);
  }
  return Color(accentColor);
});

/// Zaman makinesinin şu an hangi "Ay/Yıl" ofsetinde olduğunu tutar (0 = Bugün)
final timeOffsetProvider = StateProvider<int>((ref) => 0);

/// Tüm periyodik işlemlerın günlük bazda net değişim hızını (velocity) hesaplayan Provider.
/// Bu, Zaman Makinesi'nin ne kadar hızlı artıp azalacağını belirler.
final dailyVelocityProvider = Provider<double>((ref) {
  final transactions = ref.watch(vaultTransactionsProvider);
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final globalCurrency = ref.watch(settingsProvider).currencySymbol;
  
  double dailyNet = 0;

  for (final t in transactions) {
    if (t.periodType == 0) continue; // Tek seferlik işlemler simülasyona dahil edilmez

    // monthlyEquivalent'i günlüğe çeviriyoruz (30.44 gün ortalama)
    // Önce global birime çeviriyoruz
    double monthlyConv = t.getConvertedMonthlyEquivalent(globalCurrency, rates);
    double dailyEffect = monthlyConv / 30;
    
    if (t.isIncome) {
      dailyNet += dailyEffect;
    } else {
      dailyNet -= dailyEffect;
    }
  }

  return dailyNet;
});
