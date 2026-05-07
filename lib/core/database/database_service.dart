import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/transaction_record.dart';
import 'models/vault.dart';
import 'models/financial_goal.dart';
import 'models/app_settings.dart';
import 'models/exchange_rate.dart';

/// Isar Veritabanı Servisi — Singleton
class DatabaseService {
  static Isar? _isar;

  /// Isar veritabanı instance'ı
  static Isar get isar {
    if (_isar == null) throw Exception('DatabaseService.init() çağrılmamış!');
    return _isar!;
  }

  /// DB'yi başlat (main.dart'ta çağrılacak)
  static Future<void> init() async {
    try {
      if (_isar != null) return; // Zaten açık

      debugPrint('📂 [DatabaseService] Belgeler dizini alınıyor...');
      final dir = await getApplicationDocumentsDirectory();
      debugPrint('📂 [DatabaseService] Dizin: ${dir.path}');

      debugPrint('⚙️ [DatabaseService] Isar.open() çağrılıyor...');
      _isar = await Isar.open([
        TransactionRecordSchema,
        VaultSchema,
        FinancialGoalSchema,
        AppSettingsSchema,
        ExchangeRateSchema,
      ], directory: dir.path);
      debugPrint('✅ [DatabaseService] Isar başarıyla açıldı.');

      // İlk açılışta varsayılan kasaları ekle
      debugPrint('🌱 [DatabaseService] Varsayılan veriler kontrol ediliyor...');
      await _seedDefaultVaults();
      debugPrint('✅ [DatabaseService] Veri tohumlama tamamlandı.');
    } catch (e, stack) {
      debugPrint('❌ [DatabaseService ERROR] Başlatma hatası: $e');
      debugPrint('📜 [DatabaseService ERROR] Stack Trace:\n$stack');
      rethrow; // main.dart'ın yakalaması için
    }
  }

  /// İlk kullanımda varsayılan kasaları oluştur (Artık boş, kullanıcı grup oluşturunca eklenecek)
  static Future<void> _seedDefaultVaults() async {
    // mock verileri sildik
  }

  // =====================
  // TRANSACTION CRUD
  // =====================

  /// Yeni işlem ekle
  static Future<int> addTransaction(TransactionRecord tx) async {
    tx.updatedAt = DateTime.now();
    tx.syncStatus = 1; // Pending
    return await isar.writeTxn(() async {
      return await isar.transactionRecords.put(tx);
    });
  }

  /// İşlemi güncelle
  static Future<void> updateTransaction(TransactionRecord tx) async {
    tx.updatedAt = DateTime.now();
    tx.syncStatus = 1; // Pending
    await isar.writeTxn(() async {
      await isar.transactionRecords.put(tx);
    });
  }

  /// İşlemi sil
  static Future<void> deleteTransaction(int id) async {
    await isar.writeTxn(() async {
      await isar.transactionRecords.delete(id);
    });
  }

  /// Birden fazla işlemi sil
  static Future<void> deleteTransactions(List<int> ids) async {
    await isar.writeTxn(() async {
      await isar.transactionRecords.deleteAll(ids);
    });
  }

  /// Birden fazla işlemi tek işlemde güncelle
  static Future<void> updateAllTransactions(List<TransactionRecord> txs) async {
    await isar.writeTxn(() async {
      await isar.transactionRecords.putAll(txs);
    });
  }

  /// Tek bir işlemi ID ile getir
  static Future<TransactionRecord?> getTransaction(int id) async {
    return await isar.transactionRecords.get(id);
  }

  /// Tüm işlemleri getir
  static Future<List<TransactionRecord>> getAllTransactions() async {
    return await isar.transactionRecords.where().findAll();
  }

  /// Gelir işlemlerini getir
  static Future<List<TransactionRecord>> getIncomeTransactions() async {
    return await isar.transactionRecords
        .filter()
        .isIncomeEqualTo(true)
        .findAll();
  }

  /// Gider işlemlerini getir
  static Future<List<TransactionRecord>> getExpenseTransactions() async {
    return await isar.transactionRecords
        .filter()
        .isIncomeEqualTo(false)
        .findAll();
  }

  /// İşlemleri canlı dinle (Stream)
  static Stream<List<TransactionRecord>> watchAllTransactions() {
    return isar.transactionRecords.where().watch(fireImmediately: true);
  }

  // =====================
  // VAULT CRUD
  // =====================

  /// Tüm kasaları getir
  static Future<List<Vault>> getAllVaults() async {
    return await isar.vaults.where().findAll();
  }

  /// Tek bir kasayı ID ile getir
  static Future<Vault?> getVault(int id) async {
    return await isar.vaults.get(id);
  }

  /// Kasa ekle
  static Future<int> addVault(Vault vault) async {
    vault.updatedAt = DateTime.now();
    vault.syncStatus = 1; // Pending
    return await isar.writeTxn(() async {
      return await isar.vaults.put(vault);
    });
  }

  /// Kasa güncelle
  static Future<void> updateVault(Vault vault) async {
    vault.updatedAt = DateTime.now();
    vault.syncStatus = 1; // Pending
    await isar.writeTxn(() async {
      await isar.vaults.put(vault);
    });
  }

  /// Birden fazla kasayı tek işlemde güncelle
  static Future<void> updateAllVaults(List<Vault> vaults) async {
    await isar.writeTxn(() async {
      await isar.vaults.putAll(vaults);
    });
  }

  /// Kasa sil
  static Future<void> deleteVault(int id) async {
    await isar.writeTxn(() async {
      await isar.vaults.delete(id);
    });
  }

  /// Kasaları canlı dinle
  static Stream<List<Vault>> watchAllVaults() {
    return isar.vaults.where().watch(fireImmediately: true);
  }

  // =====================
  // FINANCIAL GOAL CRUD
  // =====================

  /// Yeni analiz hedefi kaydet
  static Future<int> addGoal(FinancialGoal goal) async {
    goal.updatedAt = DateTime.now();
    goal.syncStatus = 1; // Pending
    return await isar.writeTxn(() async {
      return await isar.financialGoals.put(goal);
    });
  }

  /// Hedefi güncelle (onay durumu vb.)
  static Future<void> updateGoal(FinancialGoal goal) async {
    goal.updatedAt = DateTime.now();
    goal.syncStatus = 1; // Pending
    await isar.writeTxn(() async {
      await isar.financialGoals.put(goal);
    });
  }

  /// ID ile tek hedef getir
  static Future<FinancialGoal?> getGoal(int id) async {
    return await isar.financialGoals.get(id);
  }

  /// Son 3 analizi getir (tarih sırası)
  static Future<List<FinancialGoal>> getRecentGoals() async {
    return await isar.financialGoals
        .where()
        .sortByCreatedAtDesc()
        .limit(3)
        .findAll();
  }

  /// Tüm analizleri getir
  static Future<List<FinancialGoal>> getAllGoals() async {
    return await isar.financialGoals
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Analiz sil
  static Future<void> deleteGoal(int id) async {
    await isar.writeTxn(() async {
      await isar.financialGoals.delete(id);
    });
  }

  /// Analizleri canlı dinle
  static Stream<List<FinancialGoal>> watchGoals() {
    return isar.financialGoals
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  // =====================
  // APP SETTINGS
  // =====================

  /// Ayarları getir (her zaman bir kayıt döner, yoksa varsayılanla oluşturur)
  static Future<AppSettings> getSettings() async {
    final existing = await isar.appSettings.get(1);
    if (existing != null) return existing;
    // İlk kullanım: varsayılan ayarları oluştur ve kaydet
    final defaults = AppSettings();
    await isar.writeTxn(() async => await isar.appSettings.put(defaults));
    return defaults;
  }

  /// Ayarları kaydet
  static Future<void> saveSettings(AppSettings settings) async {
    settings.updatedAt = DateTime.now();
    settings.syncStatus = 1; // Pending
    await isar.writeTxn(() async {
      await isar.appSettings.put(settings);
    });
  }

  // =====================
  // EXCHANGE RATES
  // =====================

  /// Tüm kurları getir
  static Future<List<ExchangeRate>> getAllExchangeRates() async {
    return await isar.exchangeRates.where().findAll();
  }

  /// Tek bir kuru kaydet veya güncelle
  static Future<void> saveExchangeRate(ExchangeRate rate) async {
    rate.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.exchangeRates.put(rate);
    });
  }

  /// Birden fazla kuru topluca kaydet
  static Future<void> saveAllExchangeRates(List<ExchangeRate> rates) async {
    final now = DateTime.now();
    for (var r in rates) {
      r.updatedAt = now;
    }
    await isar.writeTxn(() async {
      await isar.exchangeRates.putAll(rates);
    });
  }

  /// Kurları canlı dinle
  static Stream<List<ExchangeRate>> watchAllExchangeRates() {
    return isar.exchangeRates.where().watch(fireImmediately: true);
  }

  /// =====================
  /// GLOBAL RESET
  /// =====================

  /// Tüm veritabanını tamamen sıfırla
  static Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.transactionRecords.clear();
      await isar.vaults.clear();
      await isar.financialGoals.clear();
      await isar.appSettings.clear();
      await isar.exchangeRates.clear();
    });
  }
}
