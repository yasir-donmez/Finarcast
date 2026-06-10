import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
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
      // 1. Buluttaki duplikat kasaları temizle (eski hatalı sync kalıntıları)
      // 2. Önce buluttan çek ki mevcut veriler yerele gelsin
      // 3. Orphan seed kasaları temizle
      // 4. Yereldeki yeni/değişen kayıtları buluta gönder
      debugPrint('[SyncService] 🔄 İlk sync: Dedup → Pull → Dedup → Push sırası');
      await _deduplicateCloudVaults(user.id, result);
      await _deduplicateCloudTemplates(user.id, result);
      await _deduplicateCloudTransactions(user.id, result);
      await _pullRemoteChanges(user.id, result, lastSyncTime: null);
      await _cleanOrphanedSeedVaults(result);
      await _deduplicateLocalTemplates(result);
      await _deduplicateLocalTransactions(result);
      await _pushLocalChanges(user.id, result);
    } else {
      // Normal delta sync: Önce push, sonra pull
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

  /// Buluttaki duplikat kasaları birleştir.
  /// Aynı isimli birden fazla kasa varsa, en eskisini tut,
  /// diğerlerinin işlemlerini ona taşı, duplikatları sil.
  Future<void> _deduplicateCloudVaults(String userId, SyncResult result) async {
    try {
      final remoteVaults = await _supabase
          .from('vaults')
          .select()
          .eq('user_id', userId);

      if (remoteVaults.length <= 1) return; // Duplikat yok

      // İsme göre grupla
      final Map<String, List<Map<String, dynamic>>> byName = {};
      for (final v in remoteVaults) {
        final name = (v['name'] as String?)?.toLowerCase().trim() ?? '';
        byName.putIfAbsent(name, () => []).add(v);
      }

      for (final entry in byName.entries) {
        final vaults = entry.value;
        if (vaults.length <= 1) continue;

        // En eskisini tut (ilk oluşturulan)
        vaults.sort((a, b) {
          final aTime = DateTime.tryParse(a['updated_at']?.toString() ?? '') ?? DateTime.now();
          final bTime = DateTime.tryParse(b['updated_at']?.toString() ?? '') ?? DateTime.now();
          return aTime.compareTo(bTime);
        });

        final keeper = vaults.first;
        final keeperId = keeper['id'] as String;
        final duplicates = vaults.skip(1).toList();

        for (final dup in duplicates) {
          final dupId = dup['id'] as String;
          debugPrint('[SyncService] 🔀 Bulut duplikat birleştiriliyor: '
              '"${dup['name']}" ($dupId) → ($keeperId)');

          // Duplikatın işlemlerini ana kasaya taşı
          try {
            await _supabase
                .from('transaction_records')
                .update({'vault_id': keeperId})
                .eq('vault_id', dupId)
                .eq('user_id', userId);
          } catch (e) {
            debugPrint('[SyncService] ⚠️ İşlem taşıma hatası: $e');
          }

          // Duplikatın şablonlarını ana kasaya taşı
          try {
            await _supabase
                .from('recurring_templates')
                .update({'vault_id': keeperId})
                .eq('vault_id', dupId)
                .eq('user_id', userId);
          } catch (e) {
            debugPrint('[SyncService] ⚠️ Şablon taşıma hatası: $e');
          }

          // Duplikat kasayı sil
          try {
            await _supabase
                .from('vaults')
                .delete()
                .eq('id', dupId)
                .eq('user_id', userId);
          } catch (e) {
            result.addError('Dedup', 'Duplikat kasa silinemedi ($dupId): $e');
          }
        }

        debugPrint('[SyncService] ✅ "${entry.key}" kasası birleştirildi: '
            '${duplicates.length} duplikat silindi, keeper=$keeperId');
      }
    } catch (e) {
      debugPrint('[SyncService] ⚠️ Dedup hatası (atlanıyor): $e');
    }
  }

  /// İlk pull'dan sonra, buluttan gelen kasalarla eşleşmeyen
  /// yerel seed kasaları (remoteId == null) temizle.
  /// Bu kasalar push edilirse bulutta gereksiz duplikasyon olur.
  /// Bir kasanın boş bir varsayılan tohum (seed) cüzdan olup olmadığını doğrular.
  /// Eğer kasada herhangi bir işlem veya şablon varsa, ya da adı varsayılan isimlerden farklıysa tohum kabul edilmez.
  Future<bool> _isSeedVault(Vault vault) async {
    if (vault.remoteId != null) return false;

    // Bağlı işlem var mı?
    final txCount = await DatabaseService.isar.transactionRecords
        .filter()
        .vaultIdEqualTo(vault.id)
        .count();
    if (txCount > 0) return false;

    // Bağlı şablon var mı?
    final templateCount = await DatabaseService.isar.recurringTemplates
        .filter()
        .vaultIdEqualTo(vault.id)
        .count();
    if (templateCount > 0) return false;

    // Varsayılan isimlerden biri mi?
    const defaultNames = {
      'cüzdan', 'wallet', 'brieftasche', 'portefeuille', 
      'cartera', 'portafoglio', 'carteira', '钱包', 'ウォレット', '지갑'
    };
    return defaultNames.contains(vault.name.trim().toLowerCase());
  }

  /// İlk pull'dan sonra, buluttan gelen kasalarla eşleşmeyen
  /// yerel seed kasaları (remoteId == null) temizle.
  /// Bu kasalar push edilirse bulutta gereksiz duplikasyon olur.
  Future<void> _cleanOrphanedSeedVaults(SyncResult result) async {
    final orphans = await DatabaseService.isar.vaults
        .filter()
        .remoteIdIsNull()
        .findAll();

    if (orphans.isEmpty) return;

    // Yerelde remoteId'si olan (pull'dan gelen) kasa var mı kontrol et
    final syncedVaults = await DatabaseService.isar.vaults
        .filter()
        .remoteIdIsNotNull()
        .findAll();

    if (syncedVaults.isNotEmpty) {
      // Buluttan kasalar geldi, sadece gerçekten seed/boş olan orphan kasaları sil
      final List<int> idsToDelete = [];
      for (final orphan in orphans) {
        if (await _isSeedVault(orphan)) {
          debugPrint('[SyncService] 🧹 Orphan seed kasa siliniyor: ${orphan.name} (id=${orphan.id})');
          idsToDelete.add(orphan.id);
        } else {
          debugPrint('[SyncService] 🛡️ Kasa korunuyor (işlem/şablon var veya adı değiştirilmiş): ${orphan.name} (id=${orphan.id})');
        }
      }
      if (idsToDelete.isNotEmpty) {
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.vaults.deleteAll(idsToDelete);
        });
      }
    }
  }

  /// Buluttaki duplikat şablonları temizle.
  Future<void> _deduplicateCloudTemplates(String userId, SyncResult result) async {
    try {
      final remoteTemplates = await _supabase
          .from('recurring_templates')
          .select()
          .eq('user_id', userId);

      if (remoteTemplates.length <= 1) return; // Duplikat yok

      final Map<String, List<Map<String, dynamic>>> groups = {};
      for (final t in remoteTemplates) {
        final title = (t['title'] as String?)?.toLowerCase().trim() ?? '';
        final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
        final isIncome = t['is_income'] as bool? ?? false;
        final vaultId = t['vault_id'] as String? ?? 'null';
        final periodType = t['period_type'] as int? ?? 301;
        final recurrenceDay = t['recurrence_day'] as int? ?? -1;

        final key = '${title}_${amount}_${isIncome}_${vaultId}_${periodType}_$recurrenceDay';
        groups.putIfAbsent(key, () => []).add(t);
      }

      for (final entry in groups.entries) {
        final templates = entry.value;
        if (templates.length <= 1) continue;

        // Güncelleme tarihine göre sırala, en eskisini tutalım.
        templates.sort((a, b) {
          final aTime = DateTime.tryParse(a['updated_at']?.toString() ?? '') ?? DateTime.now();
          final bTime = DateTime.tryParse(b['updated_at']?.toString() ?? '') ?? DateTime.now();
          return aTime.compareTo(bTime);
        });

        final keeper = templates.first;
        final keeperId = keeper['id'] as String;
        final duplicates = templates.skip(1).toList();

        for (final dup in duplicates) {
          final dupId = dup['id'] as String;
          debugPrint('[SyncService] 🔀 Bulut duplikat şablon siliniyor: '
              '"${dup['title']}" ($dupId) → ($keeperId)');

          // Duplikatın işlemlerini ana şablona taşı
          try {
            await _supabase
                .from('transaction_records')
                .update({'template_id': keeperId})
                .eq('template_id', dupId)
                .eq('user_id', userId);
          } catch (e) {
            debugPrint('[SyncService] ⚠️ İşlem şablon güncelleme hatası: $e');
          }

          try {
            await _supabase
                .from('recurring_templates')
                .delete()
                .eq('id', dupId)
                .eq('user_id', userId);
          } catch (e) {
            result.addError('Dedup Şablon', 'Duplikat şablon silinemedi ($dupId): $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[SyncService] ⚠️ Şablon dedup hatası (atlanıyor): $e');
    }
  }

  /// Yereldeki duplikat şablonları temizle.
  Future<void> _deduplicateLocalTemplates(SyncResult result) async {
    try {
      final localTemplates = await DatabaseService.isar.recurringTemplates
          .filter()
          .not()
          .syncStatusEqualTo(2) // Silinenleri hariç tut
          .findAll();

      if (localTemplates.length <= 1) return;

      final Map<String, List<RecurringTemplate>> groups = {};
      for (final t in localTemplates) {
        final title = t.title.toLowerCase().trim();
        final amount = t.amount;
        final isIncome = t.isIncome;
        final vaultId = t.vaultId != null ? t.vaultId.toString() : 'null';
        final periodType = t.periodType;
        final recurrenceDay = t.recurrenceDay ?? -1;

        final key = '${title}_${amount}_${isIncome}_${vaultId}_${periodType}_$recurrenceDay';
        groups.putIfAbsent(key, () => []).add(t);
      }

      final user = _supabase.auth.currentUser;
      final List<int> idsToDelete = [];

      for (final entry in groups.entries) {
        final templates = entry.value;
        if (templates.length <= 1) continue;

        // Öncelik sıralaması:
        // 1. remoteId'si olanlar başa
        // 2. syncStatus == 0 (synced) olanlar başa
        // 3. Daha eski updatedAt olanlar başa
        templates.sort((a, b) {
          final aHasRemote = a.remoteId != null ? 1 : 0;
          final bHasRemote = b.remoteId != null ? 1 : 0;
          if (aHasRemote != bHasRemote) {
            return bHasRemote.compareTo(aHasRemote);
          }

          final aSynced = a.syncStatus == 0 ? 1 : 0;
          final bSynced = b.syncStatus == 0 ? 1 : 0;
          if (aSynced != bSynced) {
            return bSynced.compareTo(aSynced);
          }

          return a.updatedAt.compareTo(b.updatedAt);
        });

        final keeper = templates.first;
        final duplicates = templates.skip(1).toList();

        for (final dup in duplicates) {
          debugPrint('[SyncService] 🧹 Yerel duplikat şablon siliniyor: '
              '"${dup.title}" (id=${dup.id}, remoteId=${dup.remoteId}) → keeper(id=${keeper.id}, remoteId=${keeper.remoteId})');

          // Yerel işlemleri ana şablona taşıyalım
          final txsToMigrate = await DatabaseService.isar.transactionRecords
              .filter()
              .templateIdEqualTo(dup.id)
              .findAll();
          if (txsToMigrate.isNotEmpty) {
            await DatabaseService.isar.writeTxn(() async {
              for (final tx in txsToMigrate) {
                tx.templateId = keeper.id;
                tx.syncStatus = 1; // Değişikliği buluta itmek için
                tx.updatedAt = DateTime.now();
                await DatabaseService.isar.transactionRecords.put(tx);
              }
            });
          }

          // Eğer silinen duplikatın remoteId'si varsa ve bulut kullanıcısı aktifse buluttan da sil
          if (dup.remoteId != null && user != null) {
            // Önce buluttaki işlemleri de güncellemeye çalışalım
            if (keeper.remoteId != null) {
              try {
                await _supabase
                    .from('transaction_records')
                    .update({'template_id': keeper.remoteId})
                    .eq('template_id', dup.remoteId!)
                    .eq('user_id', user.id);
              } catch (e) {
                debugPrint('[SyncService] ⚠️ Yerel duplikat işlemleri bulutta keeper şablona taşınamadı: $e');
              }
            }

            try {
              await _supabase
                  .from('recurring_templates')
                  .delete()
                  .eq('id', dup.remoteId!)
                  .eq('user_id', user.id);
            } catch (e) {
              debugPrint('[SyncService] ⚠️ Yerel duplikat şablon buluttan silinemedi: $e');
            }
          }

          idsToDelete.add(dup.id);
        }
      }

      if (idsToDelete.isNotEmpty) {
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.recurringTemplates.deleteAll(idsToDelete);
        });
      }
    } catch (e) {
      debugPrint('[SyncService] ⚠️ Yerel şablon dedup hatası: $e');
    }
  }

  /// Buluttaki duplikat işlemleri temizle.
  Future<void> _deduplicateCloudTransactions(String userId, SyncResult result) async {
    try {
      final remoteTxs = await _supabase
          .from('transaction_records')
          .select()
          .eq('user_id', userId);

      if (remoteTxs.length <= 1) return; // Duplikat yok

      final List<String> deletedIds = [];

      // 1. Aşama: occurrence_key'e göre dedup (boş olmayan ve manual_ ile başlamayanlar)
      final Map<String, List<Map<String, dynamic>>> byOccurrenceKey = {};
      for (final tx in remoteTxs) {
        final occKey = tx['occurrence_key'] as String? ?? '';
        if (occKey.isNotEmpty && !occKey.startsWith('manual_')) {
          byOccurrenceKey.putIfAbsent(occKey, () => []).add(tx);
        }
      }

      for (final entry in byOccurrenceKey.entries) {
        final txs = entry.value;
        if (txs.length <= 1) continue;

        // Güncelleme tarihine göre azalan sırala (en yeniyi tutalım)
        txs.sort((a, b) {
          final aTime = DateTime.tryParse(a['updated_at']?.toString() ?? '') ?? DateTime.now();
          final bTime = DateTime.tryParse(b['updated_at']?.toString() ?? '') ?? DateTime.now();
          return bTime.compareTo(aTime);
        });

        final keeper = txs.first;
        final keeperId = keeper['id'] as String;
        final duplicates = txs.skip(1).toList();

        for (final dup in duplicates) {
          final dupId = dup['id'] as String;
          debugPrint('[SyncService] 🔀 Bulut duplikat işlem siliniyor (occurrence_key): '
              '"${dup['title']}" ($dupId) → keeper="${keeper['title']}" ($keeperId)');

          try {
            await _supabase
                .from('transaction_records')
                .delete()
                .eq('id', dupId)
                .eq('user_id', userId);
            deletedIds.add(dupId);
          } catch (e) {
            result.addError('Dedup İşlem', 'Duplikat işlem silinemedi ($dupId): $e');
          }
        }
      }

      // Silinenleri listeden çıkaralım
      final remainingTxs = remoteTxs.where((tx) => !deletedIds.contains(tx['id'])).toList();

      // 2. Aşama: Benzerliğe göre dedup (Başlık, miktar, kasa ve tarih)
      final Map<String, List<Map<String, dynamic>>> groups = {};
      for (final tx in remainingTxs) {
        final title = (tx['title'] as String?)?.toLowerCase().trim() ?? '';
        final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
        final isIncome = tx['is_income'] as bool? ?? false;
        final vaultId = tx['vault_id'] as String? ?? 'null';
        
        // Tarihin sadece YYYY-MM-DD kısmını al (gün düzeyinde dedup)
        final dateStr = tx['date']?.toString() ?? '';
        final datePart = dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;

        final key = '${title}_${amount}_${isIncome}_${vaultId}_$datePart';
        groups.putIfAbsent(key, () => []).add(tx);
      }

      for (final entry in groups.entries) {
        final txs = entry.value;
        if (txs.length <= 1) continue;

        // Güncelleme tarihine göre azalan sırala (en yeniyi tutalım)
        txs.sort((a, b) {
          final aTime = DateTime.tryParse(a['updated_at']?.toString() ?? '') ?? DateTime.now();
          final bTime = DateTime.tryParse(b['updated_at']?.toString() ?? '') ?? DateTime.now();
          return bTime.compareTo(aTime);
        });

        final keeper = txs.first;
        final keeperId = keeper['id'] as String;
        final duplicates = txs.skip(1).toList();

        for (final dup in duplicates) {
          final dupId = dup['id'] as String;
          debugPrint('[SyncService] 🔀 Bulut duplikat işlem siliniyor (benzerlik): '
              '"${dup['title']}" ($dupId) → keeper="${keeper['title']}" ($keeperId)');

          try {
            await _supabase
                .from('transaction_records')
                .delete()
                .eq('id', dupId)
                .eq('user_id', userId);
          } catch (e) {
            result.addError('Dedup İşlem', 'Duplikat işlem silinemedi ($dupId): $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[SyncService] ⚠️ İşlem dedup hatası (atlanıyor): $e');
    }
  }


  /// Yereldeki duplikat işlemleri temizle.
  Future<void> _deduplicateLocalTransactions(SyncResult result) async {
    try {
      final localTxs = await DatabaseService.isar.transactionRecords
          .filter()
          .not()
          .syncStatusEqualTo(2) // Silinenleri hariç tut
          .findAll();

      if (localTxs.length <= 1) return;

      final List<int> idsToDelete = [];
      final user = _supabase.auth.currentUser;

      // 1. Aşama: occurrenceKey'e göre dedup (boş olmayan ve manual_ ile başlamayanlar)
      final Map<String, List<TransactionRecord>> byOccurrenceKey = {};
      for (final tx in localTxs) {
        if (tx.occurrenceKey.isNotEmpty && !tx.occurrenceKey.startsWith('manual_')) {
          byOccurrenceKey.putIfAbsent(tx.occurrenceKey, () => []).add(tx);
        }
      }

      for (final entry in byOccurrenceKey.entries) {
        final txs = entry.value;
        if (txs.length <= 1) continue;

        // Öncelik sıralaması:
        // 1. remoteId'si olanlar başa
        // 2. syncStatus == 0 (synced) olanlar başa
        // 3. Daha yeni updatedAt olanlar başa (descending)
        txs.sort((a, b) {
          final aHasRemote = a.remoteId != null ? 1 : 0;
          final bHasRemote = b.remoteId != null ? 1 : 0;
          if (aHasRemote != bHasRemote) {
            return bHasRemote.compareTo(aHasRemote);
          }

          final aSynced = a.syncStatus == 0 ? 1 : 0;
          final bSynced = b.syncStatus == 0 ? 1 : 0;
          if (aSynced != bSynced) {
            return bSynced.compareTo(aSynced);
          }

          return b.updatedAt.compareTo(a.updatedAt);
        });

        final keeper = txs.first;
        final duplicates = txs.skip(1).toList();

        for (final dup in duplicates) {
          debugPrint('[SyncService] 🧹 Yerel duplikat işlem siliniyor (occurrenceKey): '
              '"${dup.title}" (id=${dup.id}, remoteId=${dup.remoteId}) → keeper(id=${keeper.id}, remoteId=${keeper.remoteId})');

          if (dup.remoteId != null && user != null) {
            try {
              await _supabase
                  .from('transaction_records')
                  .delete()
                  .eq('id', dup.remoteId!)
                  .eq('user_id', user.id);
            } catch (e) {
              debugPrint('[SyncService] ⚠️ Yerel duplikat buluttan silinemedi: $e');
            }
          }

          idsToDelete.add(dup.id);
        }
      }

      // Kalan işlemlerle benzerlik dedup
      final remainingTxs = localTxs.where((tx) => !idsToDelete.contains(tx.id)).toList();

      final Map<String, List<TransactionRecord>> groups = {};
      for (final tx in remainingTxs) {
        final title = tx.title.toLowerCase().trim();
        final amount = tx.amount;
        final isIncome = tx.isIncome;
        final vaultId = tx.vaultId != null ? tx.vaultId.toString() : 'null';
        
        // Tarihin YYYY-MM-DD kısmını al
        final dateStr = tx.date.toUtc().toIso8601String();
        final datePart = dateStr.substring(0, 10);

        final key = '${title}_${amount}_${isIncome}_${vaultId}_$datePart';
        groups.putIfAbsent(key, () => []).add(tx);
      }

      for (final entry in groups.entries) {
        final txs = entry.value;
        if (txs.length <= 1) continue;

        txs.sort((a, b) {
          final aHasRemote = a.remoteId != null ? 1 : 0;
          final bHasRemote = b.remoteId != null ? 1 : 0;
          if (aHasRemote != bHasRemote) {
            return bHasRemote.compareTo(aHasRemote);
          }

          final aSynced = a.syncStatus == 0 ? 1 : 0;
          final bSynced = b.syncStatus == 0 ? 1 : 0;
          if (aSynced != bSynced) {
            return bSynced.compareTo(aSynced);
          }

          return b.updatedAt.compareTo(a.updatedAt);
        });

        final keeper = txs.first;
        final duplicates = txs.skip(1).toList();

        for (final dup in duplicates) {
          debugPrint('[SyncService] 🧹 Yerel duplikat işlem siliniyor (benzerlik): '
              '"${dup.title}" (id=${dup.id}, remoteId=${dup.remoteId}) → keeper(id=${keeper.id}, remoteId=${keeper.remoteId})');

          // Eğer silinen duplikatın remoteId'si varsa ve bulut kullanıcısı aktifse buluttan da sil
          if (dup.remoteId != null && user != null) {
            try {
              await _supabase
                  .from('transaction_records')
                  .delete()
                  .eq('id', dup.remoteId!)
                  .eq('user_id', user.id);
            } catch (e) {
              debugPrint('[SyncService] ⚠️ Yerel duplikat buluttan silinemedi: $e');
            }
          }

          idsToDelete.add(dup.id);
        }
      }

      if (idsToDelete.isNotEmpty) {
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.transactionRecords.deleteAll(idsToDelete);
        });
      }
    } catch (e) {
      debugPrint('[SyncService] ⚠️ Yerel işlem dedup hatası: $e');
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
        // FK Güvenliği: İşlemin bağlı olduğu cüzdanın bulutta var olduğunu doğrula
        bool hasUnsyncedVault = false;
        if (tx.vaultId != null) {
          final vault = await DatabaseService.isar.vaults.get(tx.vaultId!);
          if (vault != null) {
            if (vault.syncStatus == 1) {
              hasUnsyncedVault = true;
            }
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
    dest.note = source.note;
    dest.currency = source.currency;
    dest.updatedAt = source.updatedAt;
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

          // Eşleşme bulunamazsa, remoteId'si null olan (seed) kasayı adopt et
          // Bu, çıkış→giriş sonrası kasa duplikasyonunu önler
          if (existing == null) {
            final unsyncedVaults = await DatabaseService.isar.vaults
                .filter()
                .remoteIdIsNull()
                .findAll();
            
            Vault? adoptable;
            for (final v in unsyncedVaults) {
              if (await _isSeedVault(v)) {
                adoptable = v;
                break;
              }
            }

            if (adoptable != null) {
              debugPrint('[SyncService] 🔗 Seed kasa adopt ediliyor: '
                  '${adoptable.name} → remoteId=$remoteId');
              existing = adoptable;
            }
          }

          if (existing != null) {
            if (existing.syncStatus == 1 && existing.remoteId != null) {
              continue; // Yerelde bekleyen değişiklik var (ve zaten eşitlenmiş)
            }
            if (existing.syncStatus == 2) continue; // Yerelde silinmiş

            // Seed kasayı adopt ediyorsak, her zaman bulut verisini uygula
            final isAdoption = existing.remoteId == null;
            if (!isAdoption && !_shouldApplyRemote(existing.updatedAt, remoteUpdated)) {
              continue;
            }

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
      'balance': vault.balance,
      'updated_at': vault.updatedAt.toUtc().toIso8601String(),
    };
  }

  void _applyVaultFromRemote(Vault vault, Map<String, dynamic> raw) {
    vault.name = raw['name'] ?? vault.name;
    vault.currency = raw['currency'] ?? vault.currency;
    vault.balance = (raw['balance'] as num?)?.toDouble() ?? vault.balance;
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
      'has_notification': t.isNotificationEnabled,
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
}

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

/// Senkron durumu (UI geri bildirimi için).
final syncStateProvider = StateProvider<SyncState>((ref) => SyncState.idle);

enum SyncState { idle, syncing, success, error }
