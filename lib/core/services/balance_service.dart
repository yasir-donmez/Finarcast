import '../database/models/transaction_record.dart';
import '../database/models/vault.dart';
import '../database/models/exchange_rate.dart';
import '../database/models/transaction_status.dart';
import '../utils/currency_utils.dart';

class BalanceService {
  /// Ana formül: vault başlangıç + Σ(kayıt) where status≠skipped AND date <= today
  static double calculateNetBalance({
    required List<Vault> vaults,
    required List<TransactionRecord> records,
    required String targetCurrency,
    required List<ExchangeRate> rates,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    double balance = vaults.fold(0.0, (sum, v) {
      final cur = v.currency == 'AUTO' ? targetCurrency : v.currency;
      return sum + CurrencyUtils.convert(v.balance, cur, targetCurrency, rates);
    });

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;

      // Ensure transaction belongs to one of the vaults being summed
      final vaultExists = vaults.any((v) => v.id == r.vaultId);
      if (!vaultExists) continue;

      // Sadece bugüne kadar veya bugün gerçekleşmiş olanları dahil et (hybrid model)
      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(today)) continue;

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

    double balance = CurrencyUtils.convert(
      vault.balance, 
      vault.currency == 'AUTO' ? targetCurrency : vault.currency, 
      targetCurrency, 
      rates
    );

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;
      if (r.vaultId != vault.id) continue;

      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(limitDate)) continue;

      final amt = r.getConvertedAmount(targetCurrency, rates);
      balance += r.isIncome ? amt : -amt;
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

    double balance = vaults.fold(0.0, (sum, v) {
      final cur = v.currency == 'AUTO' ? targetCurrency : v.currency;
      return sum + CurrencyUtils.convert(v.balance, cur, targetCurrency, rates);
    });

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;
      
      final vaultExists = vaults.any((v) => v.id == r.vaultId);
      if (!vaultExists) continue;

      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(today)) continue;

      if (r.isIncome) {
        final val = r.minAmount ?? r.amount;
        balance += CurrencyUtils.convert(val, r.currency ?? '₺', targetCurrency, rates);
      } else {
        final val = r.maxAmount ?? r.amount;
        balance -= CurrencyUtils.convert(val, r.currency ?? '₺', targetCurrency, rates);
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

    double balance = vaults.fold(0.0, (sum, v) {
      final cur = v.currency == 'AUTO' ? targetCurrency : v.currency;
      return sum + CurrencyUtils.convert(v.balance, cur, targetCurrency, rates);
    });

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;

      final vaultExists = vaults.any((v) => v.id == r.vaultId);
      if (!vaultExists) continue;

      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(today)) continue;

      if (r.isIncome) {
        final val = r.maxAmount ?? r.amount;
        balance += CurrencyUtils.convert(val, r.currency ?? '₺', targetCurrency, rates);
      } else {
        final val = r.minAmount ?? r.amount;
        balance -= CurrencyUtils.convert(val, r.currency ?? '₺', targetCurrency, rates);
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

    double balance = CurrencyUtils.convert(
      vault.balance,
      vault.currency == 'AUTO' ? targetCurrency : vault.currency,
      targetCurrency,
      rates,
    );

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;
      if (r.vaultId != vault.id) continue;
      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(limitDate)) continue;

      if (r.isIncome) {
        final val = r.minAmount ?? r.amount;
        balance += CurrencyUtils.convert(val, r.currency ?? '₺', targetCurrency, rates);
      } else {
        final val = r.maxAmount ?? r.amount;
        balance -= CurrencyUtils.convert(val, r.currency ?? '₺', targetCurrency, rates);
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

    double balance = CurrencyUtils.convert(
      vault.balance,
      vault.currency == 'AUTO' ? targetCurrency : vault.currency,
      targetCurrency,
      rates,
    );

    for (final r in records) {
      if (r.status == TransactionStatus.skipped) continue;
      if (r.vaultId != vault.id) continue;
      final paymentDate = DateTime(r.date.year, r.date.month, r.date.day);
      if (paymentDate.isAfter(limitDate)) continue;

      if (r.isIncome) {
        final val = r.maxAmount ?? r.amount;
        balance += CurrencyUtils.convert(val, r.currency ?? '₺', targetCurrency, rates);
      } else {
        final val = r.minAmount ?? r.amount;
        balance -= CurrencyUtils.convert(val, r.currency ?? '₺', targetCurrency, rates);
      }
    }
    return balance;
  }
}
