import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/transaction_record.dart';
import 'models/vault.dart';
import 'models/app_settings.dart';
import 'models/exchange_rate.dart';
import 'models/custom_category.dart';
import '../services/notification_service.dart';
import '../services/sync_coordinator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        AppSettingsSchema,
        ExchangeRateSchema,
        CustomCategorySchema,
      ], directory: dir.path);
      debugPrint('✅ [DatabaseService] Isar başarıyla açıldı.');

      // İlk açılışta varsayılan kasaları ekle
      debugPrint('🌱 [DatabaseService] Varsayılan veriler kontrol ediliyor...');
      await _seedDefaultVaults();
      debugPrint('✅ [DatabaseService] Veri tohumlama tamamlandı.');

      // Eski periodType değerlerini yeni düzenli yapıya göç ettir
      await _migratePeriodTypes();

      // Yetim işlemleri temizle (hiçbir kasaya bağlı olmayanları sil)
      await _cleanupOrphanTransactions();
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
        ..balance = 0.0
        ..iconCode = 'account_balance_wallet_rounded'
        ..isIncludedInTotal = true
        ..showOnDashboard = true
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
  // TRANSACTION CRUD
  // =====================

  /// Tek periyot değerini yeni şemaya göç ettirir
  static int migrateSinglePeriodType(int oldType) {
    if (oldType >= 1 && oldType <= 10) {
      switch (oldType) {
        case 8: return 101; // Daily -> 1 Day
        case 9: return 102; // 2 Days
        case 10: return 103; // 3 Days
        case 1: return 201; // Weekly -> 1 Week
        case 4: return 202; // 2 Weeks
        case 5: return 203; // 3 Weeks
        case 2: return 301; // Monthly -> 1 Month
        case 6: return 303; // 3 Months
        case 7: return 306; // 6 Months
        case 3: return 401; // Yearly -> 1 Year
      }
    }
    return oldType;
  }

  /// Yeni işlem ekle
  static Future<int> addTransaction(TransactionRecord tx) async {
    tx.periodType = migrateSinglePeriodType(tx.periodType);
    tx.updatedAt = DateTime.now();
    tx.syncStatus = 1; // Pending
    final id = await isar.writeTxn(() async {
      return await isar.transactionRecords.put(tx);
    });
    // Bildirimi zamanla (Master Switch kontrolü ile)
    final settings = await getSettings();
    if (settings.isNotificationsEnabled) {
      await NotificationService().scheduleTransactionNotification(tx..id = id);
    }
    SyncCoordinator.scheduleSync();
    return id;
  }

  /// İşlemi güncelle
  static Future<void> updateTransaction(TransactionRecord tx) async {
    tx.periodType = migrateSinglePeriodType(tx.periodType);
    tx.updatedAt = DateTime.now();
    tx.syncStatus = 1; // Pending
    await isar.writeTxn(() async {
      await isar.transactionRecords.put(tx);
    });
    // Bildirimi güncelle (Master Switch kontrolü ile)
    final settings = await getSettings();
    if (settings.isNotificationsEnabled) {
      await NotificationService().scheduleTransactionNotification(tx);
    } else {
      await NotificationService().cancelNotification(tx.id);
    }
    SyncCoordinator.scheduleSync();
  }

  /// İşlemi sil (buluta işlendiyse tombstone, değilse doğrudan sil)
  static Future<void> deleteTransaction(int id) async {
    final tx = await isar.transactionRecords.get(id);
    if (tx == null) return;

    final settings = await getSettings();
    final shouldTombstone =
        settings.isSyncEnabled && tx.remoteId != null;

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
    await NotificationService().cancelNotification(id);
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
      tx.periodType = migrateSinglePeriodType(tx.periodType);
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
    return isar.transactionRecords
        .filter()
        .syncStatusLessThan(2)
        .watch(fireImmediately: true);
  }

  // =====================
  // VAULT CRUD
  // =====================

  /// Tüm kasaları getir
  static Future<List<Vault>> getAllVaults() async {
    return await isar.vaults.where().syncStatusNotEqualTo(2).findAll();
  }

  /// Tek bir kasayı ID ile getir
  static Future<Vault?> getVault(int id) async {
    return await isar.vaults.get(id);
  }

  /// Kasa ekle
  static Future<int> addVault(Vault vault) async {
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
      if (tx.vaultIds.contains(id)) {
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

    final shouldTombstoneVault = isSyncEnabled && vault.remoteId != null;

    await isar.writeTxn(() async {
      // Put/Delete transactions
      if (txsToTombstone.isNotEmpty) {
        await isar.transactionRecords.putAll(txsToTombstone);
      }
      if (txsToDelete.isNotEmpty) {
        await isar.transactionRecords.deleteAll(txsToDelete);
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

    // Cancel notifications for deleted transactions
    for (final tx in txsToTombstone) {
      await NotificationService().cancelNotification(tx.id);
    }
    for (final txId in txsToDelete) {
      await NotificationService().cancelNotification(txId);
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
      // Dil İngilizce veya bilinmeyen ise ülke koduna göre ikincil kontrol
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
      ..currencySymbol = defaultCurrency
      ..countryName = country;
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

  /// Eski periodType kodlarını yeni düzenli yapıya göç ettirir
  static Future<void> _migratePeriodTypes() async {
    try {
      final transactions = await isar.transactionRecords.where().findAll();
      bool needsMigration = false;
      for (var tx in transactions) {
        if (tx.periodType >= 1 && tx.periodType <= 10) {
          needsMigration = true;
          break;
        }
      }

      if (needsMigration) {
        debugPrint('⚙️ [DatabaseService] Eski periyot tipleri yeni düzenli kodlama yapısına göç ettiriliyor...');
        await isar.writeTxn(() async {
          for (var tx in transactions) {
            int oldType = tx.periodType;
            int newType = oldType;
            switch (oldType) {
              case 8: newType = 101; break; // Daily -> 1 Day
              case 9: newType = 102; break; // 2 Days
              case 10: newType = 103; break; // 3 Days
              case 1: newType = 201; break; // Weekly -> 1 Week
              case 4: newType = 202; break; // 2 Weeks
              case 5: newType = 203; break; // 3 Weeks
              case 2: newType = 301; break; // Monthly -> 1 Month
              case 6: newType = 303; break; // 3 Months
              case 7: newType = 306; break; // 6 Months
              case 3: newType = 401; break; // Yearly -> 1 Year
            }
            if (newType != oldType) {
              tx.periodType = newType;
              await isar.transactionRecords.put(tx);
            }
          }
        });
        debugPrint('✅ [DatabaseService] Periyot tipleri başarıyla göç ettirildi.');
      }
    } catch (e) {
      debugPrint('⚠️ [DatabaseService] Periyot göçü sırasında hata (yutuldu): $e');
    }
  }

  /// =====================
  /// GLOBAL RESET
  /// =====================

  /// Tüm veritabanını tamamen sıfırla
  static Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.transactionRecords.clear();
      await isar.vaults.clear();
      await isar.appSettings.clear();
      await isar.exchangeRates.clear();
      await isar.customCategorys.clear();
    });

    // Sıfırlama sonrası SharedPreferences'taki kullanıcıya özel/geçici verileri de temizle
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_default_vault_seeded');
    await prefs.remove('ai_transaction_drafts');
    await prefs.remove('last_sync_time');
    await prefs.remove('last_checked_notifications_time');
    await prefs.remove('Finarcast_last_ai_usage_timestamp');
    await prefs.setBool('Finarcast_is_pro_user', false);

    // Bugün veya geçmiş günlerdeki AI kullanım limit sayaçlarını temizle
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('Finarcast_ai_usage_')) {
        await prefs.remove(key);
      }
    }

    // Varsayılan kasayı hemen yeniden oluştur
    await _seedDefaultVaults();
  }

  /// Yetim işlemleri sil (hiçbir kasaya ait olmayanları veritabanından temizle)
  static Future<void> _cleanupOrphanTransactions() async {
    try {
      final transactions = await isar.transactionRecords.where().findAll();
      final orphanIds = <int>[];
      for (final tx in transactions) {
        if (tx.vaultIds.isEmpty) {
          orphanIds.add(tx.id);
        }
      }
      if (orphanIds.isNotEmpty) {
        debugPrint('🧹 [DatabaseService] Yetim kalan ${orphanIds.length} işlem tespit edildi ve siliniyor...');
        for (final id in orphanIds) {
          await deleteTransaction(id);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [DatabaseService] Yetim temizliği sırasında hata (yutuldu): $e');
    }
  }

  /// Veritabanı dosyalarını diskten tamamen sil (bozulma durumunda kurtarma için)
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
}
