import '../database/models/transaction_record.dart';
import '../database/models/vault.dart';
import '../database/models/exchange_rate.dart';
import '../database/models/transaction_status.dart';
import '../utils/currency_utils.dart';

class BalanceService {
  /// Ana formül: Σ(kayıt) where status≠skipped AND date <= today (Pure Ledger)
  static double calculateNetBalance({
    required List<Vault> vaults,
    required List<TransactionRecord> records,
    required String targetCurrency,
    required List<ExchangeRate> rates,
    DateTime? untilDate,
  }) {
    final now = DateTime.now();
    final limitDate = untilDate != null
        ? DateTime(untilDate.year, untilDate.month, untilDate.day)
        : DateTime(now.year, now.month, now.day);

    final vaultIds = vaults.map((v) => v.id).toSet();
    double balance = 0.0;

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;

      // Ensure transaction belongs to one of the vaults being summed
      if (!vaultIds.contains(r.vaultId)) continue;

      // Transfer işlemleri toplam bakiyeyi etkilemez (para yer değiştirmiştir)
      if (r.targetVaultId != null) continue;

      // Sadece limit tarihine kadar gerçekleşmiş olanları dahil et
      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(limitDate)) continue;

      final amt = r.getConvertedAmount(targetCurrency, rates);
      balance += r.isIncome ? amt : -amt;
    }
    return balance;
  }

  /// Kasa filtresi + tarih filtresi (home ekranı ve kasa detayları)
  static double calculateVaultBalance({
    required Vault vault,
    required List<TransactionRecord> records,
    required String targetCurrency,
    required List<ExchangeRate> rates,
    DateTime? untilDate,
  }) {
    final now = DateTime.now();
    final limitDate = untilDate != null 
        ? DateTime(untilDate.year, untilDate.month, untilDate.day)
        : DateTime(now.year, now.month, now.day);

    double balance = 0.0;

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;
      if (r.vaultId != vault.id && r.targetVaultId != vault.id) continue;

      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(limitDate)) continue;

      final amt = r.getConvertedAmount(targetCurrency, rates);
      if (r.targetVaultId != null) {
        // Transfer: kaynak kasadan düşür, hedef kasaya ekle
        if (r.vaultId == vault.id) balance -= amt;
        if (r.targetVaultId == vault.id) balance += amt;
      } else {
        balance += r.isIncome ? amt : -amt;
      }
    }
    return balance;
  }

  /// Min bakiye (kötü senaryo): gelirde minAmount, giderde maxAmount kullanılır
  static double calculateMinBalance({
    required List<Vault> vaults,
    required List<TransactionRecord> records,
    required String targetCurrency,
    required List<ExchangeRate> rates,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final vaultIds = vaults.map((v) => v.id).toSet();
    double balance = 0.0;

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;
      
      if (!vaultIds.contains(r.vaultId)) continue;

      // Transfer işlemleri toplam bakiyeyi etkilemez
      if (r.targetVaultId != null) continue;

      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(today)) continue;

      if (r.isIncome) {
        final val = r.minAmount ?? r.amount;
        balance += CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
      } else {
        final val = r.maxAmount ?? r.amount;
        balance -= CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
      }
    }
    return balance;
  }

  /// Max bakiye (iyi senaryo): gelirde maxAmount, giderde minAmount kullanılır
  static double calculateMaxBalance({
    required List<Vault> vaults,
    required List<TransactionRecord> records,
    required String targetCurrency,
    required List<ExchangeRate> rates,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final vaultIds = vaults.map((v) => v.id).toSet();
    double balance = 0.0;

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;

      if (!vaultIds.contains(r.vaultId)) continue;

      // Transfer işlemleri toplam bakiyeyi etkilemez
      if (r.targetVaultId != null) continue;

      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(today)) continue;

      if (r.isIncome) {
        final val = r.maxAmount ?? r.amount;
        balance += CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
      } else {
        final val = r.minAmount ?? r.amount;
        balance -= CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
      }
    }
    return balance;
  }

  /// Kasa bazlı min bakiye (kötü senaryo)
  static double calculateVaultMinBalance({
    required Vault vault,
    required List<TransactionRecord> records,
    required String targetCurrency,
    required List<ExchangeRate> rates,
    DateTime? untilDate,
  }) {
    final now = DateTime.now();
    final limitDate = untilDate != null
        ? DateTime(untilDate.year, untilDate.month, untilDate.day)
        : DateTime(now.year, now.month, now.day);

    double balance = 0.0;

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;
      if (r.vaultId != vault.id && r.targetVaultId != vault.id) continue;
      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(limitDate)) continue;

      if (r.targetVaultId != null) {
        final val = r.maxAmount ?? r.amount;
        final amt = CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
        if (r.vaultId == vault.id) balance -= amt;
        if (r.targetVaultId == vault.id) balance += amt;
      } else {
        if (r.isIncome) {
          final val = r.minAmount ?? r.amount;
          balance += CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
        } else {
          final val = r.maxAmount ?? r.amount;
          balance -= CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
        }
      }
    }
    return balance;
  }

  /// Kasa bazlı max bakiye (iyi senaryo)
  static double calculateVaultMaxBalance({
    required Vault vault,
    required List<TransactionRecord> records,
    required String targetCurrency,
    required List<ExchangeRate> rates,
    DateTime? untilDate,
  }) {
    final now = DateTime.now();
    final limitDate = untilDate != null
        ? DateTime(untilDate.year, untilDate.month, untilDate.day)
        : DateTime(now.year, now.month, now.day);

    double balance = 0.0;

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;
      if (r.vaultId != vault.id && r.targetVaultId != vault.id) continue;
      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(limitDate)) continue;

      if (r.targetVaultId != null) {
        final val = r.minAmount ?? r.amount;
        final amt = CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
        if (r.vaultId == vault.id) balance -= amt;
        if (r.targetVaultId == vault.id) balance += amt;
      } else {
        if (r.isIncome) {
          final val = r.maxAmount ?? r.amount;
          balance += CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
        } else {
          final val = r.minAmount ?? r.amount;
          balance -= CurrencyUtils.convertWithSnapshot(val, r.currency ?? '₺', targetCurrency, rates, snapshotRate: r.snapshotRate);
        }
      }
    }
    return balance;
  }
}
