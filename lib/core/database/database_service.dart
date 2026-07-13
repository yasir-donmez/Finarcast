import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/transaction_record.dart';
import 'models/recurring_template.dart';
import 'models/vault.dart';
import 'models/app_settings.dart';
import 'models/exchange_rate.dart';
import 'models/custom_category.dart';
import '../services/notification_service.dart';
import '../services/sync_coordinator.dart';
import '../services/materialization_service.dart';
import '../utils/currency_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
        RecurringTemplateSchema, // YENİ
        TransactionRecordSchema, // GÜNCELLENMİŞ
        VaultSchema,
        AppSettingsSchema,
        ExchangeRateSchema,
        CustomCategorySchema,
      ], directory: dir.path);
      debugPrint('✅ [DatabaseService] Isar başarıyla açıldı.');

      // İlk açılışta varsayılan kasaları ekle
      debugPrint('🌱 [DatabaseService] Varsayılan veriler kontrol ediliyor...');
      await _seedDefaultVaults();
      debugPrint('✅ [DatabaseService] Veri tohumlama tamamlandı.');

      // Eski işlemler için snapshotRate migrasyonunu çalıştır
      await _migrateSnapshotRates();


    } catch (e, stack) {
      debugPrint('❌ [DatabaseService ERROR] Başlatma hatası: $e');
      debugPrint('📜 [DatabaseService ERROR] Stack Trace:\n$stack');
      rethrow; // main.dart'ın yakalaması için
    }
  }

  /// İlk kullanımda varsayılan kasaları oluştur
  static Future<void> _seedDefaultVaults() async {
    final prefs = await SharedPreferences.getInstance();
    final isSeeded = prefs.getBool('is_default_vault_seeded') ?? false;
    if (isSeeded) return;

    final count = await isar.vaults.count();
    if (count == 0) {
      final defaultSettings = createDefaultSettings();
      
      String vaultName = 'Wallet';
      final lang = defaultSettings.languageCode;
      if (lang == 'tr') {
        vaultName = 'Cüzdan';
      } else if (lang == 'de') {
        vaultName = 'Brieftasche';
      } else if (lang == 'fr') {
        vaultName = 'Portefeuille';
      } else if (lang == 'es') {
        vaultName = 'Cartera';
      } else if (lang == 'it') {
        vaultName = 'Portafoglio';
      } else if (lang == 'pt') {
        vaultName = 'Carteira';
      } else if (lang == 'zh') {
        vaultName = '钱包';
      } else if (lang == 'ja') {
        vaultName = 'ウォレット';
      } else if (lang == 'ko') {
        vaultName = '지갑';
      }

      final defaultVault = Vault()
        ..name = vaultName
        ..currency = defaultSettings.currencySymbol
        ..remoteId = const Uuid().v4()
        ..syncStatus = 1;
      await isar.writeTxn(() async {
        await isar.vaults.put(defaultVault);
      });
      await prefs.setBool('is_default_vault_seeded', true);
    } else {
      await prefs.setBool('is_default_vault_seeded', true);
    }
  }

  // =====================
  // RECURRING TEMPLATE CRUD
  // =====================

  static Future<int> addTemplate(RecurringTemplate t) async {
    t.remoteId ??= const Uuid().v4();
    t.updatedAt = DateTime.now();
    t.syncStatus = 1; // Pending
    final id = await isar.writeTxn(() async {
      return await isar.recurringTemplates.put(t);
    });
    // Bildirimi zamanla (Master Switch kontrolü ile)
    final settings = await getSettings();
    if (settings.isNotificationsEnabled) {
      await NotificationService().scheduleTemplateNotification(t..id = id);
    }
    SyncCoordinator.scheduleSync();
    return id;
  }

  static Future<void> updateTemplate(RecurringTemplate t) async {
    t.updatedAt = DateTime.now();
    t.syncStatus = 1; // Pending
    await isar.writeTxn(() async {
      await isar.recurringTemplates.put(t);
    });
    // Bildirimi güncelle (Master Switch kontrolü ile)
    final settings = await getSettings();
    if (settings.isNotificationsEnabled) {
      await NotificationService().scheduleTemplateNotification(t);
    } else {
      await NotificationService().cancelNotification(t.id);
    }
    SyncCoordinator.scheduleSync();
  }

  static Future<void> deleteTemplate(int id) async {
    final template = await isar.recurringTemplates.get(id);
    if (template == null) return;

    final settings = await getSettings();
    final shouldTombstone = settings.isSyncEnabled && template.remoteId != null;

    if (shouldTombstone) {
      template.syncStatus = 2;
      template.updatedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.recurringTemplates.put(template);
      });
    } else {
      await isar.writeTxn(() async {
        await isar.recurringTemplates.delete(id);
      });
    }
    await NotificationService().cancelNotification(id);
    await MaterializationService.onTemplateDeleted(id);
    SyncCoordinator.scheduleSync();
  }

  static Future<RecurringTemplate?> getTemplate(int id) async {
    return await isar.recurringTemplates.get(id);
  }

  static Future<List<RecurringTemplate>> getAllTemplates() async {
    return await isar.recurringTemplates
        .filter()
        .syncStatusLessThan(2)
        .findAll();
  }

  static Stream<List<RecurringTemplate>> watchAllTemplates() {
    return isar.recurringTemplates
        .filter()
        .syncStatusLessThan(2)
        .watch(fireImmediately: true);
  }

  // =====================
  // TRANSACTION CRUD
  // =====================

  static Future<int> addTransaction(TransactionRecord tx) async {
    tx.remoteId ??= const Uuid().v4();
    if (tx.occurrenceKey.isEmpty) {
      tx.occurrenceKey = TransactionRecord.generateManualKey();
    }
    tx.occurrenceDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
    tx.updatedAt = DateTime.now();
    tx.syncStatus = 1; // Pending
    tx.snapshotRate ??= await _getExchangeRateFor(tx.currency);
    final id = await isar.writeTxn(() async {
      return await isar.transactionRecords.put(tx);
    });
    SyncCoordinator.scheduleSync();
    return id;
  }

  /// İşlemi güncelle
  static Future<void> updateTransaction(TransactionRecord tx) async {
    tx.occurrenceDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
    tx.updatedAt = DateTime.now();
    tx.syncStatus = 1; // Pending
    await isar.writeTxn(() async {
      await isar.transactionRecords.put(tx);
    });
    SyncCoordinator.scheduleSync();
  }

  /// İşlemi sil (buluta işlendiyse tombstone, değilse doğrudan sil)
  static Future<void> deleteTransaction(int id) async {
    final tx = await isar.transactionRecords.get(id);
    if (tx == null) return;

    final settings = await getSettings();
    final shouldTombstone = settings.isSyncEnabled && tx.remoteId != null;

    if (shouldTombstone) {
      tx.syncStatus = 2;
      tx.updatedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.transactionRecords.put(tx);
      });
    } else {
      await isar.writeTxn(() async {
        await isar.transactionRecords.delete(id);
      });
    }
    SyncCoordinator.scheduleSync();
  }

  /// Birden fazla işlemi sil
  static Future<void> deleteTransactions(List<int> ids) async {
    for (final id in ids) {
      await deleteTransaction(id);
    }
  }

  /// Birden fazla işlemi tek işlemde güncelle
  static Future<void> updateAllTransactions(List<TransactionRecord> txs) async {
    final now = DateTime.now();
    for (final tx in txs) {
      tx.occurrenceDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (tx.syncStatus != 2) {
        tx.updatedAt = now;
        tx.syncStatus = 1;
      }
    }
    await isar.writeTxn(() async {
      await isar.transactionRecords.putAll(txs);
    });
    SyncCoordinator.scheduleSync();
  }

  /// Tek bir işlemi ID ile getir
  static Future<TransactionRecord?> getTransaction(int id) async {
    return await isar.transactionRecords.get(id);
  }

  /// Tüm işlemleri getir
  static Future<List<TransactionRecord>> getAllTransactions() async {
    return await isar.transactionRecords
        .filter()
        .syncStatusLessThan(2)
        .findAll();
  }

  /// İşlemleri canlı dinle (Stream)
  static Stream<List<TransactionRecord>> watchAllTransactions() {
    return isar.transactionRecords
        .filter()
        .syncStatusLessThan(2)
        .watch(fireImmediately: true);
  }

  // =====================
  // TRANSACTION BATCH & SPECIFIC QUERIES
  // =====================

  static Future<List<TransactionRecord>> getRecordsForTemplate(int templateId) async {
    return await isar.transactionRecords
        .filter()
        .templateIdEqualTo(templateId)
        .syncStatusLessThan(2)
        .findAll();
  }

  static Future<Set<String>> getOccurrenceKeysForTemplate(int templateId) async {
    final records = await isar.transactionRecords
        .filter()
        .templateIdEqualTo(templateId)
        .syncStatusLessThan(2)
        .findAll();
    return records.map((r) => r.occurrenceKey).toSet();
  }

  static Future<void> addTransactionsBatch(List<TransactionRecord> records) async {
    final now = DateTime.now();
    for (final r in records) {
      r.remoteId ??= const Uuid().v4();
      r.occurrenceDate = DateTime(r.date.year, r.date.month, r.date.day);
      r.updatedAt = now;
      r.syncStatus = 1; // Pending
      r.snapshotRate ??= await _getExchangeRateFor(r.currency);
    }
    await isar.writeTxn(() async {
      await isar.transactionRecords.putAll(records);
    });
    SyncCoordinator.scheduleSync();
  }

  static Future<DateTime?> getLatestReviewedDateForTemplate(int templateId) async {
    final lastRecord = await isar.transactionRecords
        .filter()
        .templateIdEqualTo(templateId)
        .isReviewedEqualTo(true)
        .syncStatusLessThan(2)
        .sortByDateDesc()
        .findFirst();
    return lastRecord?.date;
  }

  static Future<int> getUnreviewedRecordsCountForTemplate(int templateId) async {
    return await isar.transactionRecords
        .filter()
        .templateIdEqualTo(templateId)
        .isReviewedEqualTo(false)
        .syncStatusLessThan(2)
        .count();
  }

  static Future<void> approveAllUnreviewedRecordsForTemplate(int templateId) async {
    final unreviewed = await isar.transactionRecords
        .filter()
        .templateIdEqualTo(templateId)
        .isReviewedEqualTo(false)
        .syncStatusLessThan(2)
        .findAll();

    if (unreviewed.isEmpty) return;

    await isar.writeTxn(() async {
      for (final r in unreviewed) {
        r.isReviewed = true;
        r.updatedAt = DateTime.now();
        if (r.syncStatus != 2) {
          r.syncStatus = 1; // Pending update for sync
        }
        await isar.transactionRecords.put(r);
      }
    });
    SyncCoordinator.scheduleSync();
  }

  static Future<void> deleteUnreviewedRecordsForTemplate(int templateId) async {
    final unreviewed = await isar.transactionRecords
        .filter()
        .templateIdEqualTo(templateId)
        .isReviewedEqualTo(false)
        .syncStatusLessThan(2)
        .findAll();

    if (unreviewed.isEmpty) return;

    final settings = await getSettings();
    final isSyncEnabled = settings.isSyncEnabled;

    final toDelete = <int>[];
    final toTombstone = <TransactionRecord>[];

    for (final r in unreviewed) {
      if (isSyncEnabled && r.remoteId != null) {
        r.syncStatus = 2;
        r.updatedAt = DateTime.now();
        toTombstone.add(r);
      } else {
        toDelete.add(r.id);
      }
    }

    await isar.writeTxn(() async {
      if (toTombstone.isNotEmpty) {
        await isar.transactionRecords.putAll(toTombstone);
      }
      if (toDelete.isNotEmpty) {
        await isar.transactionRecords.deleteAll(toDelete);
      }
    });
    SyncCoordinator.scheduleSync();
  }

  static Future<bool> occurrenceKeyExists(String key) async {
    final count = await isar.transactionRecords
        .filter()
        .occurrenceKeyEqualTo(key)
        .syncStatusLessThan(2)
        .count();
    return count > 0;
  }

  // =====================
  // VAULT CRUD
  // =====================

  /// Tüm kasaları getir
  static Future<List<Vault>> getAllVaults() async {
    final list = await isar.vaults.where().syncStatusNotEqualTo(2).findAll();
    return list..sort((a, b) => a.id.compareTo(b.id));
  }

  /// Tek bir kasayı ID ile getir
  static Future<Vault?> getVault(int id) async {
    return await isar.vaults.get(id);
  }

  static Future<int> addVault(Vault vault) async {
    vault.remoteId ??= const Uuid().v4();
    vault.updatedAt = DateTime.now();
    vault.syncStatus = 1; // Pending
    final id = await isar.writeTxn(() async {
      return await isar.vaults.put(vault);
    });
    SyncCoordinator.scheduleSync();
    return id;
  }

  /// Kasa güncelle
  static Future<void> updateVault(Vault vault) async {
    vault.updatedAt = DateTime.now();
    vault.syncStatus = 1; // Pending
    await isar.writeTxn(() async {
      await isar.vaults.put(vault);
    });
    SyncCoordinator.scheduleSync();
  }

  /// Birden fazla kasayı tek işlemde güncelle
  static Future<void> updateAllVaults(List<Vault> vaults) async {
    final now = DateTime.now();
    for (final vault in vaults) {
      if (vault.syncStatus != 2) {
        vault.updatedAt = now;
        vault.syncStatus = 1;
      }
    }
    await isar.writeTxn(() async {
      await isar.vaults.putAll(vaults);
    });
    SyncCoordinator.scheduleSync();
  }

  /// Kasa sil
  static Future<void> deleteVault(int id) async {
    final vault = await isar.vaults.get(id);
    if (vault == null) return;

    final settings = await getSettings();
    final isSyncEnabled = settings.isSyncEnabled;

    // Fetch all active transactions associated with this vault
    final transactions = await isar.transactionRecords
        .filter()
        .syncStatusLessThan(2)
        .findAll();

    final txsToDelete = <int>[];
    final txsToTombstone = <TransactionRecord>[];

    for (final tx in transactions) {
      if (tx.vaultId == id) {
        final shouldTombstoneTx = isSyncEnabled && tx.remoteId != null;
        if (shouldTombstoneTx) {
          tx.syncStatus = 2;
          tx.updatedAt = DateTime.now();
          txsToTombstone.add(tx);
        } else {
          txsToDelete.add(tx.id);
        }
      }
    }

    // Fetch all active templates associated with this vault
    final templates = await isar.recurringTemplates
        .filter()
        .syncStatusLessThan(2)
        .findAll();

    final templatesToDelete = <int>[];
    final templatesToTombstone = <RecurringTemplate>[];

    for (final t in templates) {
      if (t.vaultId == id) {
        final shouldTombstoneT = isSyncEnabled && t.remoteId != null;
        if (shouldTombstoneT) {
          t.syncStatus = 2;
          t.updatedAt = DateTime.now();
          templatesToTombstone.add(t);
        } else {
          templatesToDelete.add(t.id);
        }
      }
    }

    final shouldTombstoneVault = isSyncEnabled && vault.remoteId != null;

    await isar.writeTxn(() async {
      // Put/Delete transactions
      if (txsToTombstone.isNotEmpty) {
        await isar.transactionRecords.putAll(txsToTombstone);
      }
      if (txsToDelete.isNotEmpty) {
        await isar.transactionRecords.deleteAll(txsToDelete);
      }

      // Put/Delete templates
      if (templatesToTombstone.isNotEmpty) {
        await isar.recurringTemplates.putAll(templatesToTombstone);
      }
      if (templatesToDelete.isNotEmpty) {
        await isar.recurringTemplates.deleteAll(templatesToDelete);
      }

      // Put/Delete vault
      if (shouldTombstoneVault) {
        vault.syncStatus = 2;
        vault.updatedAt = DateTime.now();
        await isar.vaults.put(vault);
      } else {
        await isar.vaults.delete(id);
      }
    });

    // Cancel notifications for deleted templates
    for (final t in templatesToTombstone) {
      await NotificationService().cancelNotification(t.id);
    }
    for (final tId in templatesToDelete) {
      await NotificationService().cancelNotification(tId);
    }

    SyncCoordinator.scheduleSync();
  }

  /// Kasaları canlı dinle
  static Stream<List<Vault>> watchAllVaults() {
    return isar.vaults
        .where()
        .syncStatusNotEqualTo(2)
        .watch(fireImmediately: true);
  }

  // =====================
  // APP SETTINGS
  // =====================

  /// Cihazın dil ve bölge ayarlarına göre dinamik varsayılan ayar nesnesi üretir
  static AppSettings createDefaultSettings() {
    final locale = PlatformDispatcher.instance.locale;
    final lang = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toUpperCase();

    String defaultLang = 'en';
    String defaultCurrency = r'$';

    if (lang == 'tr') {
      defaultLang = 'tr';
      defaultCurrency = '₺';
    } else if (lang == 'de') {
      defaultLang = 'de';
      defaultCurrency = '€';
    } else if (lang == 'fr') {
      defaultLang = 'fr';
      defaultCurrency = '€';
    } else if (lang == 'it') {
      defaultLang = 'it';
      defaultCurrency = '€';
    } else if (lang == 'es') {
      defaultLang = 'es';
      defaultCurrency = '€';
    } else if (lang == 'pt') {
      defaultLang = 'pt';
      if (country == 'BR') {
        defaultCurrency = r'R$';
      } else {
        defaultCurrency = '€';
      }
    } else if (lang == 'ja') {
      defaultLang = 'ja';
      defaultCurrency = '¥';
    } else if (lang == 'zh') {
      defaultLang = 'zh';
      defaultCurrency = '元';
    } else if (lang == 'ko') {
      defaultLang = 'ko';
      defaultCurrency = '₩';
    } else {
      if (country == 'TR') {
        defaultLang = 'tr';
        defaultCurrency = '₺';
      } else if (country == 'GB') {
        defaultCurrency = '£';
      } else if (country == 'DE' || country == 'FR' || country == 'IT' || country == 'ES' || country == 'NL' || country == 'BE' || country == 'AT') {
        defaultCurrency = '€';
      } else if (country == 'CH') {
        defaultCurrency = 'Fr';
      } else if (country == 'JP') {
        defaultCurrency = '¥';
      } else if (country == 'KR') {
        defaultCurrency = '₩';
      } else if (country == 'CN') {
        defaultCurrency = '元';
      } else if (country == 'BR') {
        defaultCurrency = r'R$';
      } else if (country == 'SA') {
        defaultCurrency = 'SR';
      } else if (country == 'KW') {
        defaultCurrency = 'KD';
      }
    }

    return AppSettings()
      ..languageCode = defaultLang
      ..currencySymbol = defaultCurrency;
  }

  static Future<AppSettings> getSettings() async {
    final existing = await isar.appSettings.get(1);
    if (existing != null) return existing;

    final defaults = createDefaultSettings()..id = 1;
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
    SyncCoordinator.scheduleSync();
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

  /// Özel kategorileri canlı dinle
  static Stream<List<CustomCategory>> watchAllCustomCategories() {
    return isar.customCategorys.where().watch(fireImmediately: true);
  }

  // =====================
  // GLOBAL RESET
  // =====================

  /// Tüm veritabanını tamamen sıfırla
  static Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.recurringTemplates.clear();
      await isar.transactionRecords.clear();
      await isar.vaults.clear();
      await isar.appSettings.clear();
      await isar.exchangeRates.clear();
      await isar.customCategorys.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_default_vault_seeded');
    await prefs.remove('ai_transaction_drafts');
    await prefs.remove('last_sync_time');
    await prefs.remove('last_checked_notifications_time');
    await prefs.remove('Finarcast_last_ai_usage_timestamp');
    await prefs.remove('home_widget_layout');
    await prefs.remove('dismissed_in_app_notifications');
    await prefs.setBool('Finarcast_is_pro_user', false);

    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('Finarcast_ai_usage_')) {
        await prefs.remove(key);
      }
    }

    await _seedDefaultVaults();
  }



  /// Veritabanı dosyalarını diskten tamamen sil
  static Future<void> deleteDatabaseFiles() async {
    try {
      if (_isar != null) {
        await _isar!.close();
        _isar = null;
      }
      final dir = await getApplicationDocumentsDirectory();
      final isarDir = Directory(dir.path);
      if (await isarDir.exists()) {
        final files = isarDir.listSync();
        for (final file in files) {
          final name = file.path.split(Platform.pathSeparator).last;
          if (name.endsWith('.isar') || name.endsWith('.isar.lock')) {
            await file.delete();
            debugPrint('🗑️ [DatabaseService] Silindi: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [DatabaseService] Dosyalar silinirken hata: $e');
      rethrow;
    }
  }

  static Future<double?> _getExchangeRateFor(String? currency) async {
    if (currency == null) return null;
    final code = CurrencyUtils.symbolToCode(currency);
    if (code == 'TRY' || code == '₺') return null;
    final rateRecord = await isar.exchangeRates.filter().currencyCodeEqualTo(code).findFirst();
    return rateRecord?.rate;
  }

  /// snapshotRate alanı null olan eski dövizli işlemlerin kurunu doldur
  static Future<void> _migrateSnapshotRates() async {
    try {
      final records = await isar.transactionRecords.filter().snapshotRateIsNull().findAll();
      if (records.isEmpty) return;

      debugPrint('🔧 [DatabaseService] ${records.length} eski işlem için snapshotRate güncellemesi başlatılıyor...');
      
      final rates = await getAllExchangeRates();
      final List<TransactionRecord> recordsToUpdate = [];

      for (final r in records) {
        if (r.currency != null) {
          final code = CurrencyUtils.symbolToCode(r.currency!);
          if (code != 'TRY' && code != '₺') {
            final rateRecord = rates.where((rate) => rate.currencyCode == code).firstOrNull;
            if (rateRecord != null && rateRecord.rate > 0) {
              r.snapshotRate = rateRecord.rate;
              recordsToUpdate.add(r);
            }
          }
        }
      }

      if (recordsToUpdate.isNotEmpty) {
        await isar.writeTxn(() async {
          await isar.transactionRecords.putAll(recordsToUpdate);
        });
        debugPrint('✅ [DatabaseService] ${recordsToUpdate.length} eski işlem snapshotRate ile güncellendi.');
      }
    } catch (e) {
      debugPrint('❌ [DatabaseService ERROR] _migrateSnapshotRates hatası: $e');
    }
  }
}
