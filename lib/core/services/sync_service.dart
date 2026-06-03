import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/database_service.dart';
import '../database/models/app_settings.dart';
import '../database/models/transaction_record.dart';
import '../database/models/vault.dart';

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
      debugPrint('[SyncService] 🔄 İlk sync: Dedup → Pull → Push sırası');
      await _deduplicateCloudVaults(user.id, result);
      await _pullRemoteChanges(user.id, result, lastSyncTime: null);
      await _cleanOrphanedSeedVaults(result);
      await _pushLocalChanges(user.id, result);
    } else {
      // Normal delta sync: Önce push, sonra pull
      await _pushLocalChanges(user.id, result);
      await _pullRemoteChanges(user.id, result, lastSyncTime: lastSyncTime);
    }

    return result;
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
      // Buluttan kasalar geldi, orphan seed kasaları sil
      for (final orphan in orphans) {
        debugPrint('[SyncService] 🧹 Orphan seed kasa siliniyor: ${orphan.name} (id=${orphan.id})');
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.vaults.delete(orphan.id);
        });
      }
    }
  }

  // ==========================================================================
  // PUSH — Yerelden buluta gönderme
  // ==========================================================================

  Future<void> _pushLocalChanges(String userId, SyncResult result) async {
    await _pushDeletedVaults(userId, result);
    await _pushDeletedTransactions(userId, result);
    await _pushPendingVaults(userId, result);
    await _pushPendingTransactions(userId, result);
    await _pushPendingSettings(userId, result);
  }

  // --- Push: silinenler (syncStatus = 2) ---

  Future<void> _pushDeletedVaults(String userId, SyncResult result) async {
    final tombstones = await DatabaseService.isar.vaults
        .filter()
        .syncStatusEqualTo(2)
        .findAll();

    for (final vault in tombstones) {
      try {
        if (vault.remoteId != null) {
          await _supabase
              .from('vaults')
              .delete()
              .eq('id', vault.remoteId!)
              .eq('user_id', userId);
        }
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.vaults.delete(vault.id);
        });
        result.deletedCount++;
      } catch (e) {
        // RLS yetki hatası ise yerelden sil, devam et
        if (_isRlsError(e)) {
          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.isar.vaults.delete(vault.id);
          });
          result.deletedCount++;
        } else {
          result.addError('Vault Silme', '${vault.name}: $e');
        }
      }
    }
  }

  Future<void> _pushDeletedTransactions(String userId, SyncResult result) async {
    final tombstones = await DatabaseService.isar.transactionRecords
        .filter()
        .syncStatusEqualTo(2)
        .findAll();

    for (final tx in tombstones) {
      try {
        if (tx.remoteId != null) {
          await _supabase
              .from('transaction_records')
              .delete()
              .eq('id', tx.remoteId!)
              .eq('user_id', userId);
        }
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.transactionRecords.delete(tx.id);
        });
        result.deletedCount++;
      } catch (e) {
        if (_isRlsError(e)) {
          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.isar.transactionRecords.delete(tx.id);
          });
          result.deletedCount++;
        } else {
          result.addError('İşlem Silme', '${tx.title}: $e');
        }
      }
    }
  }

  // --- Push: bekleyenler (syncStatus = 1) ---

  Future<void> _pushPendingVaults(String userId, SyncResult result) async {
    final pending = await DatabaseService.isar.vaults
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

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

        await DatabaseService.isar.writeTxn(() async {
          vault.syncStatus = 0;
          await DatabaseService.isar.vaults.put(vault);
        });
        result.pushedCount++;
      } catch (e) {
        result.addError('Vault Push', '${vault.name}: $e');
      }
    }
  }

  Future<void> _pushPendingTransactions(String userId, SyncResult result) async {
    final pending = await DatabaseService.isar.transactionRecords
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

    for (final tx in pending) {
      try {
        // FK Güvenliği: İşlemin bağlı olduğu cüzdanın bulutta var olduğunu doğrula
        if (tx.vaultIds.isNotEmpty) {
          final vault = await DatabaseService.isar.vaults.get(tx.vaultIds.first);
          if (vault != null && vault.syncStatus == 1) {
            // Bu cüzdan henüz push edilmemiş — bu işlemi şimdilik atla,
            // sonraki senkronizasyonda denenecek
            result.addError('İşlem Push', '${tx.title}: Bağlı cüzdan henüz senkronize edilmedi, sonraki turda denenecek.');
            continue;
          }
        }

        tx.remoteId ??= _uuid.v4();
        final data = await _transactionToRemote(tx, userId);

        try {
          await _supabase.from('transaction_records').upsert(data);
        } on PostgrestException catch (pe) {
          if (_isRlsError(pe)) {
            tx.remoteId = _uuid.v4();
            final newData = await _transactionToRemote(tx, userId);
            await _supabase.from('transaction_records').upsert(newData);
          } else {
            rethrow;
          }
        }

        await DatabaseService.isar.writeTxn(() async {
          tx.syncStatus = 0;
          await DatabaseService.isar.transactionRecords.put(tx);
        });
        result.pushedCount++;
      } catch (e) {
        result.addError('İşlem Push', '${tx.title}: $e');
      }
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
        'country_name': settings.countryName,
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

  // ==========================================================================
  // PULL — Buluttan yerele çekme
  // ==========================================================================

  Future<void> _pullRemoteChanges(
    String userId,
    SyncResult result, {
    DateTime? lastSyncTime,
  }) async {
    await _pullVaults(userId, result, lastSyncTime: lastSyncTime);
    await _pullTransactions(userId, result, lastSyncTime: lastSyncTime);
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
            final unsynced = await DatabaseService.isar.vaults
                .filter()
                .remoteIdIsNull()
                .findFirst();
            if (unsynced != null) {
              debugPrint('[SyncService] 🔗 Seed kasa adopt ediliyor: '
                  '${unsynced.name} → remoteId=$remoteId');
              existing = unsynced;
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
            await DatabaseService.isar.writeTxn(() async {
              await DatabaseService.isar.vaults.put(existing!);
            });
          } else {
            // Bulutta var ama yerelde yok → yeni kayıt oluştur
            final vault = Vault()
              ..remoteId = remoteId
              ..syncStatus = 0;
            _applyVaultFromRemote(vault, raw);
            if (remoteUpdated != null) vault.updatedAt = remoteUpdated;
            await DatabaseService.isar.writeTxn(() async {
              await DatabaseService.isar.vaults.put(vault);
            });
          }
          result.pulledCount++;
        } catch (e) {
          result.addError('Vault Pull', '${raw['name'] ?? 'bilinmeyen'}: $e');
        }
      }
    } catch (e) {
      result.addError('Vault Pull', 'Sorgu hatası: $e');
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

      for (final raw in remoteTxs) {
        try {
          final remoteId = raw['id'] as String?;
          if (remoteId == null) continue;

          final remoteUpdated = _parseRemoteTime(raw['updated_at']);
          final existing = await DatabaseService.isar.transactionRecords
              .filter()
              .remoteIdEqualTo(remoteId)
              .findFirst();

          if (existing != null) {
            if (existing.syncStatus == 1) continue;
            if (existing.syncStatus == 2) continue;
            if (!_shouldApplyRemote(existing.updatedAt, remoteUpdated)) continue;

            await _applyTransactionFromRemote(existing, raw);
            existing.syncStatus = 0;
            await DatabaseService.isar.writeTxn(() async {
              await DatabaseService.isar.transactionRecords.put(existing);
            });
          } else {
            final tx = TransactionRecord()
              ..remoteId = remoteId
              ..syncStatus = 0;
            await _applyTransactionFromRemote(tx, raw);
            if (remoteUpdated != null) tx.updatedAt = remoteUpdated;
            await DatabaseService.isar.writeTxn(() async {
              await DatabaseService.isar.transactionRecords.put(tx);
            });
          }
          result.pulledCount++;
        } catch (e) {
          result.addError('İşlem Pull', '${raw['title'] ?? 'bilinmeyen'}: $e');
        }
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
      if (!_shouldApplyRemote(settings.updatedAt, remoteUpdated)) return;

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
      settings.countryName =
          remote['country_name'] ?? settings.countryName;
      if (remoteUpdated != null) settings.updatedAt = remoteUpdated;
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
      'icon_code': vault.iconCode,
      'is_included_in_total': vault.isIncludedInTotal,
      'show_on_dashboard': vault.showOnDashboard,
      'min_limit': vault.minLimit,
      'max_limit': vault.maxLimit,
      'dashboard_order': vault.dashboardOrder,
      'dashboard_layout_type': vault.dashboardLayoutType,
      'updated_at': vault.updatedAt.toUtc().toIso8601String(),
    };
  }

  void _applyVaultFromRemote(Vault vault, Map<String, dynamic> raw) {
    vault.name = raw['name'] ?? vault.name;
    vault.currency = raw['currency'] ?? vault.currency;
    vault.balance = (raw['balance'] as num?)?.toDouble() ?? vault.balance;
    vault.iconCode = raw['icon_code'];
    vault.isIncludedInTotal =
        raw['is_included_in_total'] ?? vault.isIncludedInTotal;
    vault.showOnDashboard =
        raw['show_on_dashboard'] ?? vault.showOnDashboard;
    vault.minLimit = (raw['min_limit'] as num?)?.toDouble();
    vault.maxLimit = (raw['max_limit'] as num?)?.toDouble();
    vault.dashboardOrder = raw['dashboard_order'] ?? vault.dashboardOrder;
    vault.dashboardLayoutType =
        raw['dashboard_layout_type'] ?? vault.dashboardLayoutType;
    final remoteUpdated = _parseRemoteTime(raw['updated_at']);
    if (remoteUpdated != null) vault.updatedAt = remoteUpdated;
  }

  Future<Map<String, dynamic>> _transactionToRemote(
    TransactionRecord tx,
    String userId,
  ) async {
    String? vaultRemoteId;
    if (tx.vaultIds.isNotEmpty) {
      final vault = await DatabaseService.isar.vaults.get(tx.vaultIds.first);
      vaultRemoteId = vault?.remoteId;
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
      'period_type': tx.periodType,
      'is_archived': tx.isArchived,
      'vault_id': vaultRemoteId,
      'note': tx.note,
      'currency': tx.currency,
      'show_on_dashboard': tx.showOnDashboard,
      'dashboard_order': tx.dashboardOrder,
      'remaining_installments': tx.remainingInstallments,
      'recurrence_day': tx.recurrenceDay,
      'recurrence_date': tx.recurrenceDate?.toUtc().toIso8601String(),
      'recurrence_duration': tx.recurrenceDuration,
      'is_notification_enabled': tx.isNotificationEnabled,
      'has_notification': tx.hasNotification,
      'notification_reminder_days': tx.notificationReminderDays,
      'notification_hour': tx.notificationHour,
      'notification_minute': tx.notificationMinute,
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
    tx.periodType = raw['period_type'] ?? tx.periodType;
    tx.isArchived = raw['is_archived'] ?? tx.isArchived;
    tx.note = raw['note'];
    tx.currency = raw['currency'];
    tx.showOnDashboard =
        raw['show_on_dashboard'] ?? tx.showOnDashboard;
    tx.dashboardOrder = raw['dashboard_order'] ?? tx.dashboardOrder;
    tx.remainingInstallments = raw['remaining_installments'];
    tx.recurrenceDay = raw['recurrence_day'];
    final recDateStr = raw['recurrence_date']?.toString();
    if (recDateStr != null) {
      tx.recurrenceDate = DateTime.tryParse(recDateStr)?.toLocal();
    }
    tx.recurrenceDuration = raw['recurrence_duration'];
    tx.isNotificationEnabled = raw['is_notification_enabled'] ?? false;
    tx.hasNotification = raw['has_notification'] ?? false;
    tx.notificationReminderDays = raw['notification_reminder_days'] ?? 0;
    tx.notificationHour = raw['notification_hour'] ?? 9;
    tx.notificationMinute = raw['notification_minute'] ?? 0;

    final dateStr = raw['date']?.toString();
    if (dateStr != null) {
      tx.date = DateTime.tryParse(dateStr)?.toLocal() ?? tx.date;
    }

    final vaultRemoteId = raw['vault_id'] as String?;
    if (vaultRemoteId != null) {
      final vault = await DatabaseService.isar.vaults
          .filter()
          .remoteIdEqualTo(vaultRemoteId)
          .findFirst();
      if (vault != null) {
        tx.vaultIds = [vault.id];
      }
    }

    final remoteUpdated = _parseRemoteTime(raw['updated_at']);
    if (remoteUpdated != null) tx.updatedAt = remoteUpdated;
  }
}

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

/// Senkron durumu (UI geri bildirimi için).
final syncStateProvider = StateProvider<SyncState>((ref) => SyncState.idle);

enum SyncState { idle, syncing, success, error }
