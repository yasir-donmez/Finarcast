import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/database_service.dart';
import '../database/models/app_settings.dart';
import '../database/models/transaction_record.dart';
import '../database/models/recurring_template.dart';
import '../database/models/vault.dart';
import '../database/models/custom_category.dart';
import '../../l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// SyncResult — Senkronizasyon sonucu
// ---------------------------------------------------------------------------

class SyncResult {
  int pushedCount = 0;
  int pulledCount = 0;
  int deletedCount = 0;
  int errorCount = 0;
  final List<String> errors = [];

  bool get isFullySuccessful => errorCount == 0;
  bool get hasPartialErrors => errorCount > 0 && (pushedCount > 0 || pulledCount > 0);

  String getLocalizedSummary(AppLocalizations l10n) {
    if (isFullySuccessful) {
      return l10n.syncSuccess;
    }
    return l10n.syncSuccessWithErrors(errorCount);
  }

  String get summary {
    if (isFullySuccessful) {
      return 'Senkronizasyon tamamlandı.';
    }
    return 'Senkronizasyon sırasında $errorCount hata oluştu.';
  }

  void addError(String table, String detail) {
    errorCount++;
    errors.add('[$table] $detail');
    debugPrint('[SyncService] ❌ $table hatası: $detail');
  }
}

// ---------------------------------------------------------------------------
// SyncService — Yerel-first senkron: önce push (silme + upsert), sonra pull.
// Çakışma: `updated_at` — en yeni kazanır (last-write-wins).
// ---------------------------------------------------------------------------

class SyncService {
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Ana senkronizasyon metodu.
  /// [lastSyncTime] verilirse delta sync (sadece değişenler), verilmezse full sync.
  Future<SyncResult> syncAll({DateTime? lastSyncTime}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return SyncResult()..addError('Auth', 'Kullanıcı oturumu bulunamadı.');
    }

    final settings = await DatabaseService.getSettings();
    if (!settings.isSyncEnabled) {
      return SyncResult()..addError('Settings', 'Eşitleme ayarı kapalı.');
    }

    final result = SyncResult();

    if (lastSyncTime == null) {
      // İlk senkronizasyon (yeni cihaz veya yeniden giriş):
      // Önce buluttan çek ki mevcut veriler yerele gelsin,
      // sonra yereldeki yeni/değişen kayıtları buluta gönder.
      debugPrint('[SyncService] 🔄 İlk sync: Pull → Push sırası');
      await _pullRemoteChanges(user.id, result, lastSyncTime: null);
      await _cleanupEmptyLocalVaults();
      await _pushLocalChanges(user.id, result);
    } else {
      // Normal delta sync: Önce push, sonra pull
      await _cleanupEmptyLocalVaults();
      await _pushLocalChanges(user.id, result);
      await _pullRemoteChanges(user.id, result, lastSyncTime: lastSyncTime);
    }

    return result;
  }

  /// Sadece ayarları senkronize et (ücretsiz arka plan eşitlemesi için).
  Future<SyncResult> syncSettingsOnly(String userId) async {
    final result = SyncResult();
    await _pushPendingSettings(userId, result);
    await _pullSettings(userId, result);
    return result;
  }

  Future<bool> pullSettingsOnLogin(String userId) async {
    try {
      final settings = await DatabaseService.getSettings();

      final remote = await _supabase
          .from('app_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (remote == null) return false;

      final remoteUpdated = _parseRemoteTime(remote['updated_at']);
      final isNewInstall = settings.remoteId == null;
      if (!isNewInstall && !_shouldApplyRemote(settings.updatedAt, remoteUpdated)) return false;

      settings.languageCode = remote['language_code'] ?? settings.languageCode;
      settings.themeModeIndex =
          remote['theme_mode_index'] ?? settings.themeModeIndex;
      settings.dataRetentionDays =
          remote['data_retention_days'] ?? settings.dataRetentionDays;
      settings.isNotificationsEnabled =
          remote['is_ai_notifications_enabled'] ?? settings.isNotificationsEnabled;
      settings.isSyncEnabled =
          remote['is_sync_enabled'] ?? settings.isSyncEnabled;
      settings.bgColorStyle =
          remote['bg_color_style'] ?? settings.bgColorStyle;
      settings.accentColorValue =
          remote['accent_color_value'] ?? settings.accentColorValue;
      settings.currencySymbol =
          remote['currency_symbol'] ?? settings.currencySymbol;
      settings.permanentDeletionDays =
          remote['permanent_deletion_days'] ?? settings.permanentDeletionDays;
      if (remoteUpdated != null) settings.updatedAt = remoteUpdated;
      settings.remoteId = userId;
      settings.syncStatus = 0;

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.appSettings.put(settings);
      });
      return true;
    } catch (e) {
      debugPrint('[SyncService] pullSettingsOnLogin Hatası: $e');
      return false;
    }
  }

  // ==========================================================================
  // PUSH — Yerelden buluta gönderme
  // ==========================================================================

  Future<void> _pushLocalChanges(String userId, SyncResult result) async {
    await _pushDeletedVaults(userId, result);
    await _pushDeletedTemplates(userId, result);
    await _pushDeletedTransactions(userId, result);
    await _pushDeletedCustomCategories(userId, result);
    await _pushPendingVaults(userId, result);
    await _pushPendingTemplates(userId, result);
    await _pushPendingTransactions(userId, result);
    await _pushPendingCustomCategories(userId, result);
    await _pushPendingSettings(userId, result);
  }

  // --- Push: silinenler (syncStatus = 2) ---

  Future<void> _pushDeletedVaults(String userId, SyncResult result) async {
    final tombstones = await DatabaseService.isar.vaults
        .filter()
        .syncStatusEqualTo(2)
        .findAll();

    final List<int> idsToDelete = [];
    for (final vault in tombstones) {
      try {
        if (vault.remoteId != null) {
          await _supabase
              .from('vaults')
              .delete()
              .eq('id', vault.remoteId!)
              .eq('user_id', userId);
        }
        idsToDelete.add(vault.id);
        result.deletedCount++;
      } catch (e) {
        // RLS yetki hatası ise yerelden sil, devam et
        if (_isRlsError(e)) {
          idsToDelete.add(vault.id);
          result.deletedCount++;
        } else {
          result.addError('Vault Silme', '${vault.name}: $e');
        }
      }
    }

    if (idsToDelete.isNotEmpty) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.vaults.deleteAll(idsToDelete);
      });
    }
  }

  Future<void> _pushDeletedTransactions(String userId, SyncResult result) async {
    final tombstones = await DatabaseService.isar.transactionRecords
        .filter()
        .syncStatusEqualTo(2)
        .findAll();

    final List<int> idsToDelete = [];
    for (final tx in tombstones) {
      try {
        if (tx.remoteId != null) {
          await _supabase
              .from('transaction_records')
              .delete()
              .eq('id', tx.remoteId!)
              .eq('user_id', userId);
        }
        idsToDelete.add(tx.id);
        result.deletedCount++;
      } catch (e) {
        if (_isRlsError(e)) {
          idsToDelete.add(tx.id);
          result.deletedCount++;
        } else {
          result.addError('İşlem Silme', '${tx.title}: $e');
        }
      }
    }

    if (idsToDelete.isNotEmpty) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.transactionRecords.deleteAll(idsToDelete);
      });
    }
  }

  Future<void> _pushDeletedTemplates(String userId, SyncResult result) async {
    final tombstones = await DatabaseService.isar.recurringTemplates
        .filter()
        .syncStatusEqualTo(2)
        .findAll();

    final List<int> idsToDelete = [];
    for (final template in tombstones) {
      try {
        if (template.remoteId != null) {
          await _supabase
              .from('recurring_templates')
              .delete()
              .eq('id', template.remoteId!)
              .eq('user_id', userId);
        }
        idsToDelete.add(template.id);
        result.deletedCount++;
      } catch (e) {
        if (_isRlsError(e)) {
          idsToDelete.add(template.id);
          result.deletedCount++;
        } else {
          result.addError('Şablon Silme', '${template.title}: $e');
        }
      }
    }

    if (idsToDelete.isNotEmpty) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.recurringTemplates.deleteAll(idsToDelete);
      });
    }
  }

  // --- Push: bekleyenler (syncStatus = 1) ---

  Future<void> _pushPendingVaults(String userId, SyncResult result) async {
    final pending = await DatabaseService.isar.vaults
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

    final List<Vault> pushedVaults = [];
    for (final vault in pending) {
      try {
        vault.remoteId ??= _uuid.v4();
        final data = _vaultToRemote(vault, userId);

        try {
          await _supabase.from('vaults').upsert(data);
        } on PostgrestException catch (pe) {
          // RLS yetki hatası ise yeni UUID ile tekrar dene
          if (_isRlsError(pe)) {
            vault.remoteId = _uuid.v4();
            final newData = _vaultToRemote(vault, userId);
            await _supabase.from('vaults').upsert(newData);
          } else {
            rethrow;
          }
        }

        vault.syncStatus = 0;
        pushedVaults.add(vault);
        result.pushedCount++;
      } catch (e) {
        result.addError('Vault Push', '${vault.name}: $e');
      }
    }

    if (pushedVaults.isNotEmpty) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.vaults.putAll(pushedVaults);
      });
    }
  }

  Future<void> _pushPendingTemplates(String userId, SyncResult result) async {
    final pending = await DatabaseService.isar.recurringTemplates
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

    final List<RecurringTemplate> pushedTemplates = [];
    for (final template in pending) {
      try {
        // FK Güvenliği: Şablonun bağlı olduğu cüzdanın bulutta var olduğunu doğrula
        String? vaultRemoteId;
        bool hasUnsyncedVault = false;
        if (template.vaultId != null) {
          final vault = await DatabaseService.isar.vaults.get(template.vaultId!);
          if (vault != null) {
            if (vault.syncStatus == 1) {
              hasUnsyncedVault = true;
            } else if (vault.remoteId != null) {
              vaultRemoteId = vault.remoteId;
            }
          }
        }
        if (hasUnsyncedVault) {
          result.addError('Şablon Push', '${template.title}: Bağlı cüzdan henüz senkronize edilmedi, sonraki turda denenecek.');
          continue;
        }

        final hadNoRemoteId = template.remoteId == null;
        template.remoteId ??= _uuid.v4();
        final data = _templateToRemote(template, userId, vaultRemoteId);

        try {
          await _supabase.from('recurring_templates').upsert(data);
        } on PostgrestException catch (pe) {
          if (_isRlsError(pe)) {
            template.remoteId = _uuid.v4();
            final newData = _templateToRemote(template, userId, vaultRemoteId);
            await _supabase.from('recurring_templates').upsert(newData);
          } else {
            rethrow;
          }
        }

        // Şablon ilk kez remoteId aldıysa, bağlı yerel işlemlerin occurrenceKey'lerini güncelle
        if (hadNoRemoteId) {
          await _updateOccurrenceKeysForTemplate(template);
        }

        template.syncStatus = 0;
        pushedTemplates.add(template);
        result.pushedCount++;
      } catch (e) {
        result.addError('Şablon Push', '${template.title}: $e');
      }
    }

    if (pushedTemplates.isNotEmpty) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.recurringTemplates.putAll(pushedTemplates);
      });
    }
  }

  Future<void> _pushPendingTransactions(String userId, SyncResult result) async {
    final pending = await DatabaseService.isar.transactionRecords
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

    final List<TransactionRecord> pushedTxs = [];
    for (final tx in pending) {
      try {
        bool hasUnsyncedVault = false;
        if (tx.vaultId != null) {
          final vault = await DatabaseService.isar.vaults.get(tx.vaultId!);
          if (vault != null) {
            if (vault.syncStatus == 1) {
              hasUnsyncedVault = true;
            }
          }
        }
        if (tx.targetVaultId != null) {
          final targetVault = await DatabaseService.isar.vaults.get(tx.targetVaultId!);
          if (targetVault != null && targetVault.syncStatus == 1) {
            hasUnsyncedVault = true;
          }
        }
        if (hasUnsyncedVault) {
          result.addError('İşlem Push', '${tx.title}: Bağlı cüzdan henüz senkronize edilmedi, sonraki turda denenecek.');
          continue;
        }

        tx.remoteId ??= _uuid.v4();
        final data = await _transactionToRemote(tx, userId);

        try {
          await _supabase.from('transaction_records').upsert(data);
          tx.syncStatus = 0;
          pushedTxs.add(tx);
          result.pushedCount++;
        } on PostgrestException catch (pe) {
          if (_isRlsError(pe)) {
            tx.remoteId = _uuid.v4();
            final newData = await _transactionToRemote(tx, userId);
            await _supabase.from('transaction_records').upsert(newData);
            tx.syncStatus = 0;
            pushedTxs.add(tx);
            result.pushedCount++;
          } else if (pe.code == '23505' &&
              (pe.message.contains('transaction_records_user_id_occurrence_key_key') ||
               pe.message.contains('occurrence_key'))) {
            // occurrence_key üzerinde unique key kısıtlaması ihlal edildi!
            debugPrint('[SyncService] ⚠️ duplicate key constraint detected on push for: ${tx.title}. Resolving...');
            final resolved = await _resolveOccurrenceKeyConflict(tx, userId);
            if (resolved) {
              result.pushedCount++;
            } else {
              result.addError('İşlem Push', '${tx.title}: Benzersiz anahtar çakışması çözülemedi.');
            }
          } else {
            rethrow;
          }
        }
      } catch (e) {
        result.addError('İşlem Push', '${tx.title}: $e');
      }
    }

    if (pushedTxs.isNotEmpty) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.transactionRecords.putAll(pushedTxs);
      });
    }
  }

  Future<void> _pushPendingSettings(String userId, SyncResult result) async {
    final settings = await DatabaseService.getSettings();
    if (settings.syncStatus != 1) return;

    try {
      settings.remoteId ??= userId;
      final data = {
        'user_id': userId,
        'language_code': settings.languageCode,
        'theme_mode_index': settings.themeModeIndex,
        'data_retention_days': settings.dataRetentionDays,
        'is_ai_notifications_enabled': settings.isNotificationsEnabled,
        'is_sync_enabled': settings.isSyncEnabled,
        'bg_color_style': settings.bgColorStyle,
        'accent_color_value': settings.accentColorValue,
        'currency_symbol': settings.currencySymbol,
        'permanent_deletion_days': settings.permanentDeletionDays,
        'updated_at': settings.updatedAt.toUtc().toIso8601String(),
      };

      await _supabase.from('app_settings').upsert(data);
      await DatabaseService.isar.writeTxn(() async {
        settings.syncStatus = 0;
        await DatabaseService.isar.appSettings.put(settings);
      });
      result.pushedCount++;
    } catch (e) {
      result.addError('Ayarlar Push', '$e');
    }
  }

  Future<void> _pushDeletedCustomCategories(String userId, SyncResult result) async {
    final tombstones = await DatabaseService.isar.customCategorys
        .filter()
        .syncStatusEqualTo(2)
        .findAll();

    final List<int> idsToDelete = [];
    for (final category in tombstones) {
      try {
        await _supabase
            .from('custom_categories')
            .delete()
            .eq('unique_id', category.uniqueId)
            .eq('user_id', userId);

        idsToDelete.add(category.id);
        result.deletedCount++;
      } catch (e) {
        if (_isRlsError(e)) {
          idsToDelete.add(category.id);
          result.deletedCount++;
        } else {
          result.addError('Özel Kategori Sil', '$e');
        }
      }
    }

    if (idsToDelete.isNotEmpty) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.customCategorys.deleteAll(idsToDelete);
      });
    }
  }

  Future<void> _pushPendingCustomCategories(String userId, SyncResult result) async {
    final pending = await DatabaseService.isar.customCategorys
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

    final List<CustomCategory> pushedCats = [];
    for (final category in pending) {
      try {
        final map = _customCategoryToMap(category, userId);
        await _supabase.from('custom_categories').upsert(map, onConflict: 'unique_id');

        category.syncStatus = 0;
        pushedCats.add(category);
        result.pushedCount++;
      } catch (e) {
        result.addError('Özel Kategori Push', '$e');
      }
    }

    if (pushedCats.isNotEmpty) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.customCategorys.putAll(pushedCats);
      });
    }
  }

  // ==========================================================================
  // Eşitleme Sırasında Hata & Çakışma Çözme Yardımcıları
  // ==========================================================================

  /// Şablonun remoteId'si güncellendiğinde (ilk senkron sonrası), yereldeki eski
  /// işlemlerin occurrenceKey'lerini bu yeni UUID'ye göre günceller.
  Future<void> _updateOccurrenceKeysForTemplate(RecurringTemplate template) async {
    final txs = await DatabaseService.isar.transactionRecords
        .filter()
        .templateIdEqualTo(template.id)
        .findAll();

    if (txs.isEmpty) return;

    final List<TransactionRecord> updatedTxs = [];
    final prefix = '${template.id}_';

    for (final tx in txs) {
      if (tx.occurrenceKey.startsWith(prefix)) {
        final datePart = tx.occurrenceKey.substring(prefix.length);
        tx.occurrenceKey = '${template.remoteId}_$datePart';
        tx.updatedAt = DateTime.now();
        if (tx.syncStatus == 0) {
          tx.syncStatus = 1; // Mark as pending sync to update in Supabase
        }
        updatedTxs.add(tx);
      }
    }

    if (updatedTxs.isNotEmpty) {
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.transactionRecords.putAll(updatedTxs);
      });
      debugPrint('[SyncService] 🔄 Şablon "${template.title}" için ${updatedTxs.length} işlemin occurrenceKey değeri güncellendi.');
    }
  }

  /// occurrence_key çakışması durumunda Supabase'deki mevcut işlemi sorgulayıp
  /// yerel kayıtla en yeni olanı koruyacak şekilde uzlaştırma (reconciliation) yapar.
  Future<bool> _resolveOccurrenceKeyConflict(TransactionRecord tx, String userId) async {
    try {
      final remoteTx = await _supabase
          .from('transaction_records')
          .select()
          .eq('user_id', userId)
          .eq('occurrence_key', tx.occurrenceKey)
          .maybeSingle();

      if (remoteTx == null) {
        debugPrint('[SyncService] ⚠️ Çakışan bulut kaydı bulunamadı.');
        return false;
      }

      final remoteId = remoteTx['id'] as String;
      final remoteUpdated = _parseRemoteTime(remoteTx['updated_at']) ?? DateTime.fromMillisecondsSinceEpoch(0);

      // 1. Aynı remoteId değerine sahip yerel kayıt var mı?
      final localDup = await DatabaseService.isar.transactionRecords
          .filter()
          .remoteIdEqualTo(remoteId)
          .findFirst();

      if (localDup != null) {
        // Çakışan yerel kayıt var, LWW (Last-Write-Wins) uygula
        if (tx.updatedAt.isAfter(remoteUpdated)) {
          // Yerel değişiklik yeni, bunu buluta güncelle
          _applyLocalChangesToDup(localDup, tx);
          localDup.remoteId = remoteId;
          localDup.syncStatus = 0; // Doğrudan buluta yazıp 0 yapacağız
          localDup.updatedAt = DateTime.now();

          final data = await _transactionToRemote(localDup, userId);
          await _supabase.from('transaction_records').upsert(data);

          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.isar.transactionRecords.delete(tx.id);
            await DatabaseService.isar.transactionRecords.put(localDup);
          });
        } else {
          // Buluttaki veri yeni, yerel kopyayı güncelle ve mevcut tx'i sil
          await _applyTransactionFromRemote(localDup, remoteTx);
          localDup.syncStatus = 0;

          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.isar.transactionRecords.delete(tx.id);
            await DatabaseService.isar.transactionRecords.put(localDup);
          });
        }
      } else {
        // Yerelde remoteId yok, mevcut tx'in remoteId'sini güncelle (adopt et)
        if (tx.updatedAt.isAfter(remoteUpdated)) {
          // Yerel yeni, bulutu güncelle
          tx.remoteId = remoteId;
          tx.syncStatus = 0;
          
          final data = await _transactionToRemote(tx, userId);
          await _supabase.from('transaction_records').upsert(data);

          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.isar.transactionRecords.put(tx);
          });
        } else {
          // Bulut yeni, yereli güncelle
          tx.remoteId = remoteId;
          await _applyTransactionFromRemote(tx, remoteTx);
          tx.syncStatus = 0;

          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.isar.transactionRecords.put(tx);
          });
        }
      }
      return true;
    } catch (e) {
      debugPrint('[SyncService] ❌ Çakışma çözme başarısız: $e');
      return false;
    }
  }

  void _applyLocalChangesToDup(TransactionRecord dest, TransactionRecord source) {
    dest.title = source.title;
    dest.isIncome = source.isIncome;
    dest.categoryId = source.categoryId;
    dest.iconCode = source.iconCode;
    dest.amount = source.amount;
    dest.minAmount = source.minAmount;
    dest.maxAmount = source.maxAmount;
    dest.date = source.date;
    dest.occurrenceDate = source.occurrenceDate;
    dest.templateId = source.templateId;
    dest.installmentNumber = source.installmentNumber;
    dest.totalInstallments = source.totalInstallments;
    dest.status = source.status;
    dest.isReviewed = source.isReviewed;
    dest.isArchived = source.isArchived;
    dest.vaultId = source.vaultId;
    dest.targetVaultId = source.targetVaultId;
    dest.note = source.note;
    dest.currency = source.currency;
    dest.updatedAt = source.updatedAt;
  }

  Future<void> _cleanupEmptyLocalVaults() async {
    try {
      final activeVaults = await DatabaseService.isar.vaults
          .filter()
          .not()
          .syncStatusEqualTo(2)
          .findAll();

      if (activeVaults.length <= 1) return; // En az bir aktif kasa kalmalı

      final defaultNames = {
        'Wallet',
        'Cüzdan',
        'Brieftasche',
        'Portefeuille',
        'Cartera',
        'Portafoglio',
        'Carteira',
        '钱包',
        'ウォレット',
        '지갑'
      };

      final List<int> idsToDelete = [];

      for (final vault in activeVaults) {
        // Sadece yerelde oluşturulmuş ve henüz buluta aktarılmamış (syncStatus == 1) olanları temizle
        if (vault.syncStatus == 1 && defaultNames.contains(vault.name)) {
          // Bu kasaya bağlı işlem var mı kontrol et
          final txCount = await DatabaseService.isar.transactionRecords
              .filter()
              .vaultIdEqualTo(vault.id)
              .count();

          // Bu kasaya bağlı şablon/plan var mı kontrol et
          final templateCount = await DatabaseService.isar.recurringTemplates
              .filter()
              .vaultIdEqualTo(vault.id)
              .count();

          if (txCount == 0 && templateCount == 0) {
            // Güvenlik kontrolü: bu kasayı sildiğimizde geriye en az bir kasa kalacak mı?
            final remainingCount = activeVaults.length - idsToDelete.length - 1;
            if (remainingCount >= 1) {
              debugPrint('[SyncService] 🧹 Kullanılmayan varsayılan yerel kasa siliniyor: ${vault.name} (id=${vault.id})');
              idsToDelete.add(vault.id);
            }
          }
        }
      }

      if (idsToDelete.isNotEmpty) {
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.vaults.deleteAll(idsToDelete);
        });
      }
    } catch (e) {
      debugPrint('[SyncService] ⚠️ Kullanılmayan boş kasaları temizleme hatası: $e');
    }
  }

  // ==========================================================================
  // PULL — Buluttan yerele çekme
  // ==========================================================================

  Future<void> _pullRemoteChanges(
    String userId,
    SyncResult result, {
    DateTime? lastSyncTime,
  }) async {
    await _pullVaults(userId, result, lastSyncTime: lastSyncTime);
    await _pullTemplates(userId, result, lastSyncTime: lastSyncTime);
    await _pullTransactions(userId, result, lastSyncTime: lastSyncTime);
    await _pullCustomCategories(userId, result, lastSyncTime: lastSyncTime);
    await _pullSettings(userId, result);
  }

  Future<void> _pullVaults(
    String userId,
    SyncResult result, {
    DateTime? lastSyncTime,
  }) async {
    try {
      var query = _supabase.from('vaults').select().eq('user_id', userId);

      // Delta sync: sadece son senkronizasyondan sonra güncellenen kayıtları çek
      if (lastSyncTime != null) {
        query = query.gt('updated_at', lastSyncTime.toUtc().toIso8601String());
      }

      final remoteVaults = await query;
      final List<Vault> vaultsToPut = [];

      for (final raw in remoteVaults) {
        try {
          final remoteId = raw['id'] as String?;
          if (remoteId == null) continue;

          final remoteUpdated = _parseRemoteTime(raw['updated_at']);

          // Sadece remoteId ile eşle
          var existing = await DatabaseService.isar.vaults
              .filter()
              .remoteIdEqualTo(remoteId)
              .findFirst();

          if (existing != null) {
            if (existing.syncStatus == 1) continue; // Yerelde bekleyen değişiklik var
            if (existing.syncStatus == 2) continue; // Yerelde silinmiş
            if (!_shouldApplyRemote(existing.updatedAt, remoteUpdated)) continue;

            existing.remoteId = remoteId;
            _applyVaultFromRemote(existing, raw);
            existing.syncStatus = 0;
            vaultsToPut.add(existing);
          } else {
            // Bulutta var ama yerelde yok → yeni kayıt oluştur
            final vault = Vault()
              ..remoteId = remoteId
              ..syncStatus = 0;
            _applyVaultFromRemote(vault, raw);
            if (remoteUpdated != null) vault.updatedAt = remoteUpdated;
            vaultsToPut.add(vault);
          }
          result.pulledCount++;
        } catch (e) {
          result.addError('Vault Pull', '${raw['name'] ?? 'bilinmeyen'}: $e');
        }
      }

      if (vaultsToPut.isNotEmpty) {
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.vaults.putAll(vaultsToPut);
        });
      }
    } catch (e) {
      result.addError('Vault Pull', 'Sorgu hatası: $e');
    }
  }

  Future<void> _pullTemplates(
    String userId,
    SyncResult result, {
    DateTime? lastSyncTime,
  }) async {
    try {
      var query = _supabase.from('recurring_templates').select().eq('user_id', userId);

      if (lastSyncTime != null) {
        query = query.gt('updated_at', lastSyncTime.toUtc().toIso8601String());
      }

      final remoteTemplates = await query;
      final List<RecurringTemplate> templatesToPut = [];

      for (final raw in remoteTemplates) {
        try {
          final remoteId = raw['id'] as String?;
          if (remoteId == null) continue;

          final remoteUpdated = _parseRemoteTime(raw['updated_at']);

          var existing = await DatabaseService.isar.recurringTemplates
              .filter()
              .remoteIdEqualTo(remoteId)
              .findFirst();

          if (existing != null) {
            if (existing.syncStatus == 1) continue;
            if (existing.syncStatus == 2) continue;
            if (!_shouldApplyRemote(existing.updatedAt, remoteUpdated)) continue;

            await _applyTemplateFromRemote(existing, raw);
            existing.syncStatus = 0;
            templatesToPut.add(existing);
          } else {
            final template = RecurringTemplate()
              ..remoteId = remoteId
              ..syncStatus = 0;
            await _applyTemplateFromRemote(template, raw);
            if (remoteUpdated != null) template.updatedAt = remoteUpdated;
            templatesToPut.add(template);
          }
          result.pulledCount++;
        } catch (e) {
          result.addError('Şablon Pull', '${raw['title'] ?? 'bilinmeyen'}: $e');
        }
      }

      if (templatesToPut.isNotEmpty) {
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.recurringTemplates.putAll(templatesToPut);
        });
      }
    } catch (e) {
      result.addError('Şablon Pull', 'Sorgu hatası: $e');
    }
  }

  Future<void> _pullTransactions(
    String userId,
    SyncResult result, {
    DateTime? lastSyncTime,
  }) async {
    try {
      var query = _supabase
          .from('transaction_records')
          .select()
          .eq('user_id', userId);

      if (lastSyncTime != null) {
        query = query.gt('updated_at', lastSyncTime.toUtc().toIso8601String());
      }

      final remoteTxs = await query;
      final List<int> idsToDelete = [];
      final List<TransactionRecord> txsToPut = [];

      for (final raw in remoteTxs) {
        try {
          final remoteId = raw['id'] as String?;
          if (remoteId == null) continue;

          final remoteUpdated = _parseRemoteTime(raw['updated_at']);
          
          // Duplikat güvenliği: aynı remoteId'ye sahip TÜM kayıtları bul
          final existingList = await DatabaseService.isar.transactionRecords
              .filter()
              .remoteIdEqualTo(remoteId)
              .findAll();

          // Birden fazla kopya varsa fazlalıkları temizle
          if (existingList.length > 1) {
            debugPrint('[SyncService] ⚠️ Duplikat işlem tespit edildi: '
                'remoteId=$remoteId, kopya=${existingList.length}');
            // İlkini tut, geri kalanını sil
            final duplicates = existingList.skip(1).toList();
            for (final dup in duplicates) {
              idsToDelete.add(dup.id);
            }
          }

          final existing = existingList.isNotEmpty ? existingList.first : null;

          if (existing != null) {
            if (existing.syncStatus == 1) continue;
            if (existing.syncStatus == 2) continue;
            if (!_shouldApplyRemote(existing.updatedAt, remoteUpdated)) continue;

            await _applyTransactionFromRemote(existing, raw);
            existing.syncStatus = 0;
            txsToPut.add(existing);
          } else {
            final tx = TransactionRecord()
              ..remoteId = remoteId
              ..syncStatus = 0;
            await _applyTransactionFromRemote(tx, raw);
            if (remoteUpdated != null) tx.updatedAt = remoteUpdated;
            txsToPut.add(tx);
          }
          result.pulledCount++;
        } catch (e) {
          result.addError('İşlem Pull', '${raw['title'] ?? 'bilinmeyen'}: $e');
        }
      }

      if (idsToDelete.isNotEmpty || txsToPut.isNotEmpty) {
        await DatabaseService.isar.writeTxn(() async {
          if (idsToDelete.isNotEmpty) {
            await DatabaseService.isar.transactionRecords.deleteAll(idsToDelete);
          }
          if (txsToPut.isNotEmpty) {
            await DatabaseService.isar.transactionRecords.putAll(txsToPut);
          }
        });
      }
    } catch (e) {
      result.addError('İşlem Pull', 'Sorgu hatası: $e');
    }
  }

  Future<void> _pullSettings(String userId, SyncResult result) async {
    try {
      final settings = await DatabaseService.getSettings();
      if (settings.syncStatus == 1) return;

      final remote = await _supabase
          .from('app_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (remote == null) return;

      final remoteUpdated = _parseRemoteTime(remote['updated_at']);
      final isNewInstall = settings.remoteId == null;
      if (!isNewInstall && !_shouldApplyRemote(settings.updatedAt, remoteUpdated)) return;

      settings.languageCode = remote['language_code'] ?? settings.languageCode;
      settings.themeModeIndex =
          remote['theme_mode_index'] ?? settings.themeModeIndex;
      settings.dataRetentionDays =
          remote['data_retention_days'] ?? settings.dataRetentionDays;
      settings.isNotificationsEnabled =
          remote['is_ai_notifications_enabled'] ?? settings.isNotificationsEnabled;
      settings.isSyncEnabled =
          remote['is_sync_enabled'] ?? settings.isSyncEnabled;
      settings.bgColorStyle =
          remote['bg_color_style'] ?? settings.bgColorStyle;
      settings.accentColorValue =
          remote['accent_color_value'] ?? settings.accentColorValue;
      settings.currencySymbol =
          remote['currency_symbol'] ?? settings.currencySymbol;
      settings.permanentDeletionDays =
          remote['permanent_deletion_days'] ?? settings.permanentDeletionDays;
      if (remoteUpdated != null) settings.updatedAt = remoteUpdated;
      settings.remoteId = userId;
      settings.syncStatus = 0;

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.isar.appSettings.put(settings);
      });
      result.pulledCount++;
    } catch (e) {
      result.addError('Ayarlar Pull', '$e');
    }
  }

  // ==========================================================================
  // Yardımcılar
  // ==========================================================================

  bool _isRlsError(dynamic e) {
    if (e is PostgrestException) {
      if (e.code == '42501') return true;
      final msg = e.message.toLowerCase();
      if (msg.contains('row level security') || msg.contains('permission denied')) {
        return true;
      }
    }
    return false;
  }

  bool _shouldApplyRemote(DateTime local, DateTime? remote) {
    if (remote == null) return true;
    return remote.isAfter(local);
  }

  DateTime? _parseRemoteTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  Map<String, dynamic> _vaultToRemote(Vault vault, String userId) {
    return {
      'id': vault.remoteId,
      'user_id': userId,
      'name': vault.name,
      'currency': vault.currency,
      'updated_at': vault.updatedAt.toUtc().toIso8601String(),
    };
  }

  void _applyVaultFromRemote(Vault vault, Map<String, dynamic> raw) {
    vault.name = raw['name'] ?? vault.name;
    vault.currency = raw['currency'] ?? vault.currency;
    final remoteUpdated = _parseRemoteTime(raw['updated_at']);
    if (remoteUpdated != null) vault.updatedAt = remoteUpdated;
  }

  Future<Map<String, dynamic>> _transactionToRemote(
    TransactionRecord tx,
    String userId,
  ) async {
    String? vaultRemoteId;
    if (tx.vaultId != null) {
      final vault = await DatabaseService.isar.vaults.get(tx.vaultId!);
      if (vault?.remoteId != null) {
        vaultRemoteId = vault!.remoteId!;
      }
    }

    String? targetVaultRemoteId;
    if (tx.targetVaultId != null) {
      final targetVault = await DatabaseService.isar.vaults.get(tx.targetVaultId!);
      if (targetVault?.remoteId != null) {
        targetVaultRemoteId = targetVault!.remoteId!;
      }
    }

    String? templateRemoteId;
    if (tx.templateId != null) {
      final template = await DatabaseService.isar.recurringTemplates.get(tx.templateId!);
      templateRemoteId = template?.remoteId;
    }

    return {
      'id': tx.remoteId,
      'user_id': userId,
      'title': tx.title,
      'is_income': tx.isIncome,
      'category_id': tx.categoryId,
      'icon_code': tx.iconCode,
      'amount': tx.amount,
      'min_amount': tx.minAmount,
      'max_amount': tx.maxAmount,
      'date': tx.date.toUtc().toIso8601String(),
      'occurrence_date': tx.occurrenceDate.toUtc().toIso8601String().substring(0, 10),
      'template_id': templateRemoteId,
      'occurrence_key': tx.occurrenceKey,
      'installment_number': tx.installmentNumber,
      'total_installments': tx.totalInstallments,
      'status': tx.status,
      'is_reviewed': tx.isReviewed,
      'is_archived': tx.isArchived,
      'vault_id': vaultRemoteId,
      'target_vault_id': targetVaultRemoteId,
      'note': tx.note,
      'currency': tx.currency,
      'updated_at': tx.updatedAt.toUtc().toIso8601String(),
    };
  }

  Future<void> _applyTransactionFromRemote(
    TransactionRecord tx,
    Map<String, dynamic> raw,
  ) async {
    tx.title = raw['title'] ?? tx.title;
    tx.isIncome = raw['is_income'] ?? tx.isIncome;
    tx.categoryId = raw['category_id'];
    tx.iconCode = raw['icon_code'];
    tx.amount = (raw['amount'] as num?)?.toDouble() ?? tx.amount;
    tx.minAmount = (raw['min_amount'] as num?)?.toDouble();
    tx.maxAmount = (raw['max_amount'] as num?)?.toDouble();
    tx.occurrenceKey = raw['occurrence_key'] ?? tx.occurrenceKey;
    tx.installmentNumber = raw['installment_number'];
    tx.totalInstallments = raw['total_installments'];
    tx.status = raw['status'] ?? tx.status;
    tx.isReviewed = raw['is_reviewed'] ?? tx.isReviewed;
    tx.isArchived = raw['is_archived'] ?? tx.isArchived;
    tx.note = raw['note'];
    tx.currency = raw['currency'];

    final dateStr = raw['date']?.toString();
    if (dateStr != null) {
      tx.date = DateTime.tryParse(dateStr)?.toLocal() ?? tx.date;
    }

    final occurrenceDateStr = raw['occurrence_date']?.toString();
    if (occurrenceDateStr != null) {
      tx.occurrenceDate = DateTime.tryParse(occurrenceDateStr)?.toLocal() ?? tx.occurrenceDate;
    }

    final templateRemoteId = raw['template_id'] as String?;
    if (templateRemoteId != null) {
      final template = await DatabaseService.isar.recurringTemplates
          .filter()
          .remoteIdEqualTo(templateRemoteId)
          .findFirst();
      if (template != null) {
        tx.templateId = template.id;
      }
    } else {
      tx.templateId = null;
    }

    final vaultRemoteId = raw['vault_id'] as String?;
    if (vaultRemoteId != null) {
      final vault = await DatabaseService.isar.vaults
          .filter()
          .remoteIdEqualTo(vaultRemoteId)
          .findFirst();
      if (vault != null) {
        tx.vaultId = vault.id;
      } else {
        tx.vaultId = null;
      }
    } else {
      tx.vaultId = null;
    }

    final targetVaultRemoteId = raw['target_vault_id'] as String?;
    if (targetVaultRemoteId != null) {
      final targetVault = await DatabaseService.isar.vaults
          .filter()
          .remoteIdEqualTo(targetVaultRemoteId)
          .findFirst();
      if (targetVault != null) {
        tx.targetVaultId = targetVault.id;
      } else {
        tx.targetVaultId = null;
      }
    } else {
      tx.targetVaultId = null;
    }

    final remoteUpdated = _parseRemoteTime(raw['updated_at']);
    if (remoteUpdated != null) tx.updatedAt = remoteUpdated;
  }

  Map<String, dynamic> _templateToRemote(RecurringTemplate t, String userId, String? vaultRemoteId) {
    return {
      'id': t.remoteId,
      'user_id': userId,
      'title': t.title,
      'is_income': t.isIncome,
      'category_id': t.categoryId,
      'icon_code': t.iconCode,
      'amount': t.amount,
      'min_amount': t.minAmount,
      'max_amount': t.maxAmount,
      'period_type': t.periodType,
      'recurrence_day': t.recurrenceDay,
      'recurrence_date': t.recurrenceDate?.toUtc().toIso8601String(),
      'total_installments': t.totalInstallments,
      'start_date': t.startDate.toUtc().toIso8601String(),
      'note': t.note,
      'currency': t.currency,
      'is_paused': t.isPaused,
      'is_archived': t.isArchived,
      'is_notification_enabled': t.isNotificationEnabled,
      'has_notification': t.hasNotification,
      'notification_reminder_days': t.notificationReminderDays,
      'notification_hour': t.notificationHour,
      'notification_minute': t.notificationMinute,
      'vault_id': vaultRemoteId,
      'updated_at': t.updatedAt.toUtc().toIso8601String(),
    };
  }

  Future<void> _applyTemplateFromRemote(RecurringTemplate t, Map<String, dynamic> raw) async {
    t.title = raw['title'] ?? t.title;
    t.isIncome = raw['is_income'] ?? t.isIncome;
    t.categoryId = raw['category_id'];
    t.iconCode = raw['icon_code'];
    t.amount = (raw['amount'] as num?)?.toDouble() ?? t.amount;
    t.minAmount = (raw['min_amount'] as num?)?.toDouble();
    t.maxAmount = (raw['max_amount'] as num?)?.toDouble();
    t.periodType = raw['period_type'] ?? t.periodType;
    t.recurrenceDay = raw['recurrence_day'];
    
    final recDateStr = raw['recurrence_date']?.toString();
    if (recDateStr != null) {
      t.recurrenceDate = DateTime.tryParse(recDateStr)?.toLocal();
    }
    
    t.totalInstallments = raw['total_installments'];
    
    final startDateStr = raw['start_date']?.toString();
    if (startDateStr != null) {
      t.startDate = DateTime.tryParse(startDateStr)?.toLocal() ?? t.startDate;
    }
    
    t.note = raw['note'];
    t.currency = raw['currency'];
    t.isPaused = raw['is_paused'] ?? t.isPaused;
    t.isArchived = raw['is_archived'] ?? t.isArchived;
    t.isNotificationEnabled = raw['is_notification_enabled'] ?? t.isNotificationEnabled;
    t.hasNotification = raw['has_notification'] ?? t.hasNotification;
    t.notificationReminderDays = raw['notification_reminder_days'] ?? t.notificationReminderDays;
    t.notificationHour = raw['notification_hour'] ?? t.notificationHour;
    t.notificationMinute = raw['notification_minute'] ?? t.notificationMinute;

    final vaultRemoteId = raw['vault_id'] as String?;
    if (vaultRemoteId != null) {
      final vault = await DatabaseService.isar.vaults
          .filter()
          .remoteIdEqualTo(vaultRemoteId)
          .findFirst();
      if (vault != null) {
        t.vaultId = vault.id;
      } else {
        t.vaultId = null;
      }
    } else {
      t.vaultId = null;
    }

    final remoteUpdated = _parseRemoteTime(raw['updated_at']);
    if (remoteUpdated != null) t.updatedAt = remoteUpdated;
  }

  Future<void> _pullCustomCategories(
    String userId,
    SyncResult result, {
    DateTime? lastSyncTime,
  }) async {
    try {
      var query = _supabase.from('custom_categories').select().eq('user_id', userId);

      if (lastSyncTime != null) {
        query = query.gt('updated_at', lastSyncTime.toUtc().toIso8601String());
      }

      final List<dynamic> remoteData = await query;
      if (remoteData.isEmpty) return;

      final List<CustomCategory> catsToPut = [];

      for (final raw in remoteData) {
        final uniqueId = raw['unique_id'] as String?;
        if (uniqueId == null) continue;

        final local = await DatabaseService.isar.customCategorys
            .where()
            .uniqueIdEqualTo(uniqueId)
            .findFirst();

        final remoteUpdated = _parseRemoteTime(raw['updated_at']);

        if (local != null) {
          if (local.syncStatus == 2) {
            continue;
          }

          if (remoteUpdated != null && remoteUpdated.isAfter(local.updatedAt)) {
            _applyCustomCategoryFromRemote(local, raw);
            local.syncStatus = 0;
            local.updatedAt = remoteUpdated;
            catsToPut.add(local);
            result.pulledCount++;
          }
        } else {
          final newCat = CustomCategory();
          _applyCustomCategoryFromRemote(newCat, raw);
          newCat.syncStatus = 0;
          if (remoteUpdated != null) newCat.updatedAt = remoteUpdated;
          catsToPut.add(newCat);
          result.pulledCount++;
        }
      }

      if (catsToPut.isNotEmpty) {
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.customCategorys.putAll(catsToPut);
        });
      }
    } catch (e) {
      result.addError('Özel Kategoriler Pull', '$e');
    }
  }

  Map<String, dynamic> _customCategoryToMap(CustomCategory category, String userId) {
    return {
      'user_id': userId,
      'unique_id': category.uniqueId,
      'parent_id': category.parentId,
      'name': category.name,
      'icon_code': category.iconCode,
      'updated_at': category.updatedAt.toUtc().toIso8601String(),
    };
  }

  void _applyCustomCategoryFromRemote(CustomCategory category, Map<String, dynamic> raw) {
    category.uniqueId = raw['unique_id'] ?? category.uniqueId;
    category.parentId = raw['parent_id'] ?? category.parentId;
    category.name = raw['name'] ?? category.name;
    category.iconCode = raw['icon_code'] ?? category.iconCode;
  }

  /// Supabase'deki tüm kullanıcı verilerini temizle
  Future<void> clearRemoteData(String userId) async {
    try {
      debugPrint('[SyncService] 🗑️ Bulut verileri temizleniyor (User: $userId)...');
      await _supabase.from('transaction_records').delete().eq('user_id', userId);
      await _supabase.from('recurring_templates').delete().eq('user_id', userId);
      await _supabase.from('vaults').delete().eq('user_id', userId);
      await _supabase.from('custom_categories').delete().eq('user_id', userId);
      await _supabase.from('app_settings').delete().eq('user_id', userId);
      debugPrint('[SyncService] ✅ Bulut verileri başarıyla temizlendi.');
    } catch (e) {
      debugPrint('[SyncService] ❌ Bulut verileri temizlenirken hata: $e');
      rethrow;
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

/// Senkron durumu (UI geri bildirimi için).
final syncStateProvider = StateProvider<SyncState>((ref) => SyncState.idle);

enum SyncState { idle, syncing, success, error }
