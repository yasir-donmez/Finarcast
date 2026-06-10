import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/balance_service.dart';

/// Zaman makinesi tekerleği çevrildiğinde eklenen sanal (gelecek) bakiye bonusu
final simulationBonusProvider = StateProvider<double>((ref) => 0.0);

/// Seçili kasa filtresi (Ana ekran genel bakiye alanı için)
final homeMainBalanceVaultIdProvider = StateProvider<String?>((ref) => null);

/// Seçili kasa filtresine göre gerçek bakiyeyi hesaplar (Ana ekran için)
final homeRealBalanceProvider = Provider<double>((ref) {
  final vaultId = ref.watch(homeMainBalanceVaultIdProvider);
  if (vaultId == null) {
    return ref.watch(netBalanceProvider);
  }

  final rawVaultId = int.tryParse(vaultId.replaceFirst('v_', ''));
  if (rawVaultId == null) {
    return ref.watch(netBalanceProvider);
  }

  final allVaults = ref.watch(allVaultsProvider);
  final vault = allVaults.where((v) => v.id == rawVaultId).firstOrNull;
  if (vault == null) {
    return ref.watch(netBalanceProvider);
  }

  return BalanceService.calculateVaultBalance(
    vault: vault,
    records: ref.watch(allTransactionsProvider),
    targetCurrency: ref.watch(settingsProvider).currencySymbol,
    rates: ref.watch(exchangeRatesProvider).value ?? [],
  );
});

/// Seçili kasa filtresine göre esnek bütçe alt limitini hesaplar
final homeMinBalanceProvider = Provider<double>((ref) {
  final vaultId = ref.watch(homeMainBalanceVaultIdProvider);
  if (vaultId == null) {
    return ref.watch(netMinBalanceProvider);
  }

  final rawVaultId = int.tryParse(vaultId.replaceFirst('v_', ''));
  if (rawVaultId == null) {
    return ref.watch(netMinBalanceProvider);
  }

  final allVaults = ref.watch(allVaultsProvider);
  final vault = allVaults.where((v) => v.id == rawVaultId).firstOrNull;
  if (vault == null) {
    return ref.watch(netMinBalanceProvider);
  }

  return BalanceService.calculateVaultMinBalance(
    vault: vault,
    records: ref.watch(allTransactionsProvider),
    targetCurrency: ref.watch(settingsProvider).currencySymbol,
    rates: ref.watch(exchangeRatesProvider).value ?? [],
  );
});

/// Seçili kasa filtresine göre esnek bütçe üst limitini hesaplar
final homeMaxBalanceProvider = Provider<double>((ref) {
  final vaultId = ref.watch(homeMainBalanceVaultIdProvider);
  if (vaultId == null) {
    return ref.watch(netMaxBalanceProvider);
  }

  final rawVaultId = int.tryParse(vaultId.replaceFirst('v_', ''));
  if (rawVaultId == null) {
    return ref.watch(netMaxBalanceProvider);
  }

  final allVaults = ref.watch(allVaultsProvider);
  final vault = allVaults.where((v) => v.id == rawVaultId).firstOrNull;
  if (vault == null) {
    return ref.watch(netMaxBalanceProvider);
  }

  return BalanceService.calculateVaultMaxBalance(
    vault: vault,
    records: ref.watch(allTransactionsProvider),
    targetCurrency: ref.watch(settingsProvider).currencySymbol,
    rates: ref.watch(exchangeRatesProvider).value ?? [],
  );
});

/// Ekranda gösterilecek toplam bakiye: Gerçek Bakiye (DB) + Zaman Makinesi Bonusu
final displayBalanceProvider = Provider<double>((ref) {
  final realBalance = ref.watch(homeRealBalanceProvider);
  final bonus = ref.watch(simulationBonusProvider);
  return realBalance + bonus;
});

/// Renklerin artık sadece Ayarlar'dan gelmesini sağlayan Provider
final rotaryColorProvider = Provider<Color>((ref) {
  final accentColor = ref.watch(settingsProvider.select((s) => s.accentColorValue));
  if (accentColor == 0) {
    return ref.watch(dynamicColorProvider);
  }
  return Color(accentColor);
});

/// Zaman makinesinin şu an hangi "Ay/Yıl" ofsetinde olduğunu tutar (0 = Bugün)
final timeOffsetProvider = StateProvider<int>((ref) => 0);

/// Tüm periyodik işlemlerin günlük bazda net değişim hızını (velocity) hesaplayan Provider.
final dailyVelocityProvider = Provider<double>((ref) {
  final templates = ref.watch(allTemplatesProvider);
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final globalCurrency = ref.watch(settingsProvider).currencySymbol;
  
  double dailyNet = 0;

  for (final t in templates) {
    if (t.isPaused || t.isArchived) continue;

    // monthlyEquivalent'i günlüğe çeviriyoruz (30.44 gün ortalama)
    double monthlyConv = t.getConvertedMonthlyEquivalent(globalCurrency, rates);
    double dailyEffect = monthlyConv / 30.44;
    
    if (t.isIncome) {
      dailyNet += dailyEffect;
    } else {
      dailyNet -= dailyEffect;
    }
  }

  return dailyNet;
});
