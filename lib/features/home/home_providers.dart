import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/utils/icon_utils.dart';
import '../../core/utils/currency_utils.dart';
import '../vaults/vaults_providers.dart';

/// Dashboard'daki bir öğeyi temsil eder (Kasa/Grup veya Tekil İşlem)
class HomeItem {
  final String id;
  final String name;
  final String? categoryId;
  final double balance;
  final String currency;
  final String? iconCode;
  final bool isGroup;
  final List<String> itemIconCodes;
  final List<double> itemAmounts;
  final int itemCount;
  final double? minLimit;
  final double? maxLimit;
  final int dashboardOrder;
  final int dashboardLayoutType;

  HomeItem({
    required this.id,
    required this.name,
    this.categoryId,
    required this.balance,
    required this.currency,
    this.iconCode,
    this.isGroup = false,
    this.itemIconCodes = const [],
    this.itemAmounts = const [],
    this.itemCount = 0,
    this.minLimit,
    this.maxLimit,
    this.dashboardOrder = 0,
    this.dashboardLayoutType = 4,
  });
}

/// Ana ekranda gösterilecek tüm öğeleri (Kasa/Grup + Tekil İşlem) birleştiren Provider
final homeItemsProvider = Provider<List<HomeItem>>((ref) {
  final vaults = ref.watch(allVaultsProvider);
  final transactions = ref.watch(vaultTransactionsProvider);
  final rates = ref.watch(exchangeRatesProvider).value ?? [];
  final globalCurrency = ref.watch(settingsProvider).currencySymbol;

  final List<HomeItem> items = [];

  // 1. Görünür Kasaları (Grupları) ekle
  final sortedVaults = vaults.where((v) => v.showOnDashboard).toList()
    ..sort((a, b) {
      int cmp = a.dashboardOrder.compareTo(b.dashboardOrder);
      if (cmp == 0) return a.id.compareTo(b.id);
      return cmp;
    });

  for (final v in sortedVaults) {
    final String vaultGroupId = 'v_${v.id}';
    final targetCurrency = v.currency == 'AUTO' ? globalCurrency : v.currency;

    // Kasa içindeki işlemleri bul
    final groupTx = transactions.where((t) => t.groupIds.contains(vaultGroupId)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    double groupBalance = v.balance;
    double groupMin = v.balance;
    double groupMax = v.balance;
    bool hasFlexibleTx = false;

    for (final t in groupTx) {
      final convAmount = t.getConvertedAmount(targetCurrency, rates);
      if (t.isIncome) {
        groupBalance += convAmount;
        if (t.minAmount != null || t.maxAmount != null) hasFlexibleTx = true;
        groupMin += CurrencyUtils.convert(t.minAmount ?? t.amount, t.currency ?? '₺', targetCurrency, rates);
        groupMax += CurrencyUtils.convert(t.maxAmount ?? t.amount, t.currency ?? '₺', targetCurrency, rates);
      } else {
        groupBalance -= convAmount;
        if (t.minAmount != null || t.maxAmount != null) hasFlexibleTx = true;
        groupMin -= CurrencyUtils.convert(t.maxAmount ?? t.amount, t.currency ?? '₺', targetCurrency, rates);
        groupMax -= CurrencyUtils.convert(t.minAmount ?? t.amount, t.currency ?? '₺', targetCurrency, rates);
      }
    }

    // En çok tekrar eden ikon kodunu bul
    final dominantIconCode =
        IconUtils.getDominantIconCode(groupTx.map((t) => t.iconCode ?? t.categoryId ?? '').toList()) ??
        v.iconCode;

    // Dominant categoryId'yi bul
    final dominantCategoryId = IconUtils.getDominantIconCode(
      groupTx.map((t) => t.categoryId ?? '').toList(),
    );

    items.add(
      HomeItem(
        id: vaultGroupId,
        name: v.name,
        categoryId: dominantCategoryId,
        balance: groupBalance,
        currency: targetCurrency,
        iconCode: dominantIconCode,
        isGroup: true,
        itemIconCodes: groupTx
            .map((t) => t.iconCode ?? t.categoryId ?? '')
            .where((c) => c.isNotEmpty)
            .take(50)
            .toList(),
        itemAmounts: groupTx
            .map((t) {
              final amt = t.getConvertedAmount(targetCurrency, rates);
              return t.isIncome ? amt : -amt;
            })
            .take(50)
            .toList(),
        itemCount: groupTx.length,
        minLimit: hasFlexibleTx ? groupMin : v.minLimit,
        maxLimit: hasFlexibleTx ? groupMax : v.maxLimit,
        dashboardOrder: v.dashboardOrder,
        dashboardLayoutType: v.dashboardLayoutType,
      ),
    );
  }

  // 2. Görünür Tekil İşlemleri ekle (Herhangi bir kasaya bağlı olmayan VE showOnDashboard olanlar)
  final standaloneTxs = transactions.where((t) => t.groupIds.isEmpty && t.showOnDashboard).toList();
  for (final t in standaloneTxs) {
    items.add(
      HomeItem(
        id: t.id, 
        name: t.name,
        categoryId: t.categoryId,
        balance: t.isIncome 
            ? t.getConvertedAmount(globalCurrency, rates) 
            : -t.getConvertedAmount(globalCurrency, rates),
        currency: globalCurrency,
        iconCode: t.iconCode ?? t.categoryId,
        isGroup: false,
        minLimit: t.minAmount != null 
            ? CurrencyUtils.convert(t.minAmount!, t.currency ?? '₺', globalCurrency, rates) 
            : null,
        maxLimit: t.maxAmount != null 
            ? CurrencyUtils.convert(t.maxAmount!, t.currency ?? '₺', globalCurrency, rates) 
            : null,
        dashboardOrder: 0,
        dashboardLayoutType: t.dashboardLayoutType,
      ),
    );
  }

  return items;
});

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
