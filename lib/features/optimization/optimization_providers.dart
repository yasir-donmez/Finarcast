import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/transaction_record.dart';
import '../../core/database/models/vault.dart';
import '../../core/database/models/financial_goal.dart';
import 'ai_service.dart';
import '../../core/database/models/exchange_rate.dart';
import '../../core/database/models/app_settings.dart';
import '../../core/utils/currency_utils.dart';
import 'dart:math';

// =====================
// SAĞLAYICILAR (PROVIDERS)
// =====================

/// Son 3 analiz hedefini dinleyen provider
final goalsProvider = StreamProvider<List<FinancialGoal>>((ref) {
  return DatabaseService.watchGoals();
});

/// Tüm aktif (arşivlenmemiş) işlemleri dinleyen provider
final activeTransactionsProvider = StreamProvider<List<TransactionRecord>>((ref) {
  return DatabaseService.watchAllTransactions().map(
    (all) => all.where((t) => !t.isArchived).toList(),
  );
});

/// Tüm kasaları dinleyen provider
final vaultsProvider = StreamProvider<List<Vault>>((ref) {
  return DatabaseService.watchAllVaults();
});

// =====================
// OPTİMİZASYON MOTORU
// =====================

/// Analizin temel matematiksel sonuçlarını tutar
class AnalysisSnapshot {
  final double currentBalance;   // Mevcut toplam bakiye (seçilen kapsama göre)
  final double targetAmount;     // Hedeflenen bakiye
  final double gap;              // Açık = Hedef - Mevcut
  final double monthlyIncome;    // Aylık gelir
  final double monthlyExpense;   // Aylık gider (tümü)
  final double monthlySurplus;   // Aylık fazla = Gelir - Gider
  final int months;              // Hedefe kalan ay
  final double requiredMonthlySaving; // Kapatmak için gereken ayl. tasarruf
  final bool isAlreadyOnTrack;   // Mevcut hşz ile hedefe zaten ulaşılıyor mu

  const AnalysisSnapshot({
    required this.currentBalance,
    required this.targetAmount,
    required this.gap,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySurplus,
    required this.months,
    required this.requiredMonthlySaving,
    required this.isAlreadyOnTrack,
  });
}

/// Optimization Engine — Tüm hesaplamaları yapar
class OptimizationEngine {
  /// Ana analiz: Matematiği hesaplar ve AI için bağlam paketi hazırlar
  static Future<AnalysisResult> analyze({
    required double targetAmount,
    required DateTime targetDate,
    required int? scopeVaultId,        // null = tüm kasalar
    required List<TransactionRecord> allTransactions,
    required List<Vault> allVaults,
    required List<ExchangeRate> allRates,
    required AppSettings settings,
    required Set<int> userLockedIds,   // Kullanıcının "Dokunulmasın" dediği ID'ler
    required Set<int> userFlexibleIds, // Kullanıcının "Değiştirilebilir" dediği ID'ler
    required List<String> vetoedCategories,
    required List<FinancialGoal> previousGoals,
  }) async {
    // 1. Kapsama göre filtrele
    final List<TransactionRecord> scopedTxs = scopeVaultId == null
        ? allTransactions
        : allTransactions.where((t) => t.vaultIds.contains(scopeVaultId)).toList();

    final List<Vault> scopedVaults = scopeVaultId == null
        ? allVaults
        : allVaults.where((v) => v.id == scopeVaultId).toList();

    final String baseCurrency = settings.currencySymbol;

    // 2. Mevcut bakiyeyi hesapla — tüm işlemleri baz para birimine çevirerek topla
    final double txBalance = scopedTxs.fold(0.0, (sum, t) {
      if (t.periodType != 0) return sum; // Sadece tek seferlik işlemler bakiyeyi etkiler
      final amount = t.getConvertedAmount(baseCurrency, allRates);
      return t.isIncome ? sum + amount : sum - amount;
    });

    // Vault bakiyesi varsa onu da ekle (DİKKAT: Vault'ların da para birimi çevrilmeli)
    final double vaultBalance = scopedVaults.fold(0.0, (sum, v) {
      return sum + CurrencyUtils.convert(v.balance, v.currency, baseCurrency, allRates);
    });
    final double currentBalance = txBalance + vaultBalance;

    final double monthlyIncome = scopedTxs
        .where((t) => t.isIncome && t.periodType != 0)
        .fold(0.0, (sum, t) => sum + t.getConvertedMonthlyEquivalent(baseCurrency, allRates));

    final double monthlyExpense = scopedTxs
        .where((t) => !t.isIncome && t.periodType != 0)
        .fold(0.0, (sum, t) => sum + t.getConvertedMonthlyEquivalent(baseCurrency, allRates));

    final double monthlySurplus = monthlyIncome - monthlyExpense;

    // 4. Hedef ve süre
    final now = DateTime.now();
    final months = max(1, targetDate.difference(now).inDays ~/ 30);
    final double gap = max(0, targetAmount - currentBalance);
    final double requiredMonthlySaving = months > 0 ? gap / months : gap;

    final bool isAlreadyOnTrack = monthlySurplus >= requiredMonthlySaving;

    final snapshot = AnalysisSnapshot(
      currentBalance: currentBalance,
      targetAmount: targetAmount,
      gap: gap,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      monthlySurplus: monthlySurplus,
      months: months,
      requiredMonthlySaving: requiredMonthlySaving,
      isAlreadyOnTrack: isAlreadyOnTrack,
    );

    // 5. Eğer zaten ulaşılıyorsa AI çağrılmaz
    if (isAlreadyOnTrack) {
      return AnalysisResult(
        snapshot: snapshot,
        optimizationResult: null,
        persona: null,
        usedAi: false,
      );
    }

    // 6. Esnek kategorileri belirle
    final List<TransactionRecord> flexibleTxs = scopedTxs.where((t) {
      if (t.isIncome) return false;
      if (t.periodType == 0) return false; // Sadece periyodik olanlar
      if (t.isLocked) return false;        // Model seviyesinde kilitli
      if (userLockedIds.contains(t.id)) return false; // Kullanıcı kitlediyse
      // Kullanıcı esnek diye işaretlediyse kesin dahil et, yoksa genel kural
      return true;
    }).toList();

    // 7. Bağlam paketini oluştur (varyans hesapla)
    final List<CategoryContext> contextCategories = [];
    // Arşivlenen işlemlerden de geçmiş verisi topla (varyans için)
    final allHistoric = await DatabaseService.getAllTransactions();

    for (final tx in flexibleTxs) {
      // Bu kategori için arşivdeki geçmiş işlemleri bul
      final historic = allHistoric
          .where((h) => h.title == tx.title && !h.isIncome)
          .map((h) => h.effectiveAmount)
          .toList();

      double? cv;
      if (historic.length >= 3) {
        final mean = historic.reduce((a, b) => a + b) / historic.length;
        if (mean > 0) {
          final variance = historic.fold(0.0, (sum, v) => sum + pow(v - mean, 2)) / historic.length;
          cv = sqrt(variance) / mean;
        }
      }

      contextCategories.add(CategoryContext(
        name: tx.title,
        currentAmount: tx.getConvertedMonthlyEquivalent(baseCurrency, allRates),
        minAmount: tx.minAmount != null ? tx.getConvertedAmount(baseCurrency, allRates) : null,
        maxAmount: tx.maxAmount != null ? tx.getConvertedAmount(baseCurrency, allRates) : null,
        coefficientOfVariation: cv,
        periodType: tx.periodType,
        remainingInstallments: tx.remainingInstallments,
      ));
    }

    // 8. AI varsa stratejiyi üret, yoksa yerel fallback
    OptimizationResult? optimizationResult;
    bool usedAi = false;
    String? aiError;

    if (AiService.isAvailable) {
      try {
        optimizationResult = await AiService.generateStrategy(
          requiredMonthlySaving: requiredMonthlySaving - monthlySurplus,
          flexibleCategories: contextCategories,
          rejectedCategories: vetoedCategories,
          targetAmount: targetAmount,
          monthsToGoal: months,
          countryName: settings.countryName,
          languageCode: settings.languageCode,
          baseCurrency: baseCurrency,
        );
        usedAi = true;
      } catch (e) {
        // API başarısız → yerel fallback
        debugPrint('❌ [OptimizationEngine] AI Analiz Hatası: $e');
        aiError = e.toString();
        optimizationResult = _localFallback(
          required: requiredMonthlySaving - monthlySurplus,
          categories: contextCategories,
          vetoedCategories: vetoedCategories,
        );
      }
    } else {
      aiError = 'API anahtarı bulunamadı';
      optimizationResult = _localFallback(
        required: requiredMonthlySaving - monthlySurplus,
        categories: contextCategories,
        vetoedCategories: vetoedCategories,
      );
    }

    return AnalysisResult(
      snapshot: snapshot,
      optimizationResult: optimizationResult,
      persona: null, // Persona ayrı çağrılır (analiz başında)
      usedAi: usedAi,
      aiError: aiError,
    );
  }

  /// Offline / API Hata → Basit Yerel Kesinti Dağılımı
  static OptimizationResult _localFallback({
    required double required,
    required List<CategoryContext> categories,
    required List<String> vetoedCategories,
  }) {
    if (categories.isEmpty) {
      return OptimizationResult(
        cuts: [],
        coachMessage: 'Esnek harcama bulunamadı. Hedefe ulaşmak için gelir artırımı veya hedef tarihini uzatmayı düşünebilirsin.',
        isFeasible: false,
      );
    }

    // Veto edilmeyen kategoriler önce
    final prioritized = categories
        .where((c) => !vetoedCategories.contains(c.name))
        .toList();
    final vetoed = categories
        .where((c) => vetoedCategories.contains(c.name))
        .toList();
    final ordered = [...prioritized, ...vetoed];

    // Ağırlıklı dağılım: Büyük ve değişken kategoriler daha fazla kesilir
    final weights = ordered.map((c) {
      final sizeWeight = c.currentAmount;
      final varWeight = (c.coefficientOfVariation ?? 0.3) * 2;
      return sizeWeight * (1 + varWeight);
    }).toList();

    final totalWeight = weights.fold(0.0, (a, b) => a + b);
    final cuts = <CutSuggestion>[];
    double remaining = required;

    for (int i = 0; i < ordered.length; i++) {
      if (remaining <= 0) break;
      final c = ordered[i];
      final share = totalWeight > 0 ? (weights[i] / totalWeight) * required : 0.0;
      
      // KESİN KURAL: minAmount altına inilemez
      final double current = c.currentAmount;
      final double floor = c.minAmount ?? 0.0;
      final double possibleCut = max(0.0, current - floor);
      
      final cut = min(share, min(remaining, possibleCut));
      final suggested = current - cut;

      cuts.add(CutSuggestion(
        category: c.name,
        currentAmount: current,
        suggestedAmount: suggested,
        suggestedMin: floor > 0 ? floor : suggested * 0.9,
        suggestedMax: suggested * 1.1,
        saving: cut,
        reason: 'Hedefe ulaşmak için önerilen tasarruf (Hard limit: ${floor.toStringAsFixed(0)})',
      ));
      remaining -= cut;
    }

    return OptimizationResult(
      cuts: cuts,
      coachMessage: 'İnternet bağlantısı olmadan yerel hesaplama yapıldı. Bu öneriler matematiksel dağılım ile üretildi.',
      isFeasible: remaining <= 0,
    );
  }
}

/// Analiz sonuç objesi
class AnalysisResult {
  final AnalysisSnapshot snapshot;
  final OptimizationResult? optimizationResult;
  final String? persona;
  final bool usedAi;
  final String? aiError;

  const AnalysisResult({
    required this.snapshot,
    required this.optimizationResult,
    required this.persona,
    required this.usedAi,
    this.aiError,
  });
}
