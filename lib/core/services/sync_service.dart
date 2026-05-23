import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/database_service.dart';
import '../database/models/app_settings.dart';
import '../database/models/transaction_record.dart';
import '../database/models/vault.dart';

/// Yerel-first senkron: önce push (silme + güncelleme), sonra pull.
/// Çakışma: `updated_at` — en yeni kazanır (last-write-wins).
class SyncService {
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<void> syncAll() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final settings = await DatabaseService.getSettings();
    if (!settings.isSyncEnabled) return;

    await pushLocalChanges(user.id);
    await pullRemoteChanges(user.id);
  }

  Future<void> pushLocalChanges(String userId) async {
    await _pushDeletedVaults(userId);
    await _pushDeletedTransactions(userId);
    await _pushPendingVaults(userId);
    await _pushPendingTransactions(userId);
    await _pushPendingSettings(userId);
  }

  Future<void> pullRemoteChanges(String userId) async {
    await _pullVaults(userId);
    await _pullTransactions(userId);
    await _pullSettings(userId);
  }

  // --- Push: silinenler (syncStatus = 2) ---

  Future<void> _pushDeletedVaults(String userId) async {
    final tombstones = await DatabaseService.isar.vaults
        .filter()
        .syncStatusEqualTo(2)
        .findAll();

    for (final vault in tombstones) {
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
    }
  }

  Future<void> _pushDeletedTransactions(String userId) async {
    final tombstones = await DatabaseService.isar.transactionRecords
        .filter()
        .syncStatusEqualTo(2)
        .findAll();

    for (final tx in tombstones) {
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
    }
  }

  // --- Push: bekleyenler (syncStatus = 1) ---

  Future<void> _pushPendingVaults(String userId) async {
    final pending = await DatabaseService.isar.vaults
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

    for (final vault in pending) {
      vault.remoteId ??= _uuid.v4();
      final data = _vaultToRemote(vault, userId);
      await _supabase.from('vaults').upsert(data);
      await DatabaseService.isar.writeTxn(() async {
        vault.syncStatus = 0;
        await DatabaseService.isar.vaults.put(vault);
      });
    }
  }

  Future<void> _pushPendingTransactions(String userId) async {
    final pending = await DatabaseService.isar.transactionRecords
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

    for (final tx in pending) {
      tx.remoteId ??= _uuid.v4();
      final data = await _transactionToRemote(tx, userId);
      await _supabase.from('transaction_records').upsert(data);
      await DatabaseService.isar.writeTxn(() async {
        tx.syncStatus = 0;
        await DatabaseService.isar.transactionRecords.put(tx);
      });
    }
  }

  Future<void> _pushPendingSettings(String userId) async {
    final settings = await DatabaseService.getSettings();
    if (settings.syncStatus != 1) return;

    settings.remoteId ??= userId;
    final data = {
      'user_id': userId,
      'language_code': settings.languageCode,
      'theme_mode_index': settings.themeModeIndex,
      'data_retention_days': settings.dataRetentionDays,
      'is_ai_notifications_enabled': settings.isNotificationsEnabled,
      'is_sync_enabled': settings.isSyncEnabled,
      'updated_at': settings.updatedAt.toUtc().toIso8601String(),
    };

    await _supabase.from('app_settings').upsert(data);
    await DatabaseService.isar.writeTxn(() async {
      settings.syncStatus = 0;
      await DatabaseService.isar.appSettings.put(settings);
    });
  }

  // --- Pull ---

  Future<void> _pullVaults(String userId) async {
    final remoteVaults =
        await _supabase.from('vaults').select().eq('user_id', userId);

    for (final raw in remoteVaults) {
      final remoteId = raw['id'] as String?;
      if (remoteId == null) continue;

      final remoteUpdated = _parseRemoteTime(raw['updated_at']);
      final existing = await DatabaseService.isar.vaults
          .filter()
          .remoteIdEqualTo(remoteId)
          .findFirst();

      if (existing != null) {
        if (existing.syncStatus == 1) continue;
        if (existing.syncStatus == 2) continue;
        if (!_shouldApplyRemote(existing.updatedAt, remoteUpdated)) continue;
        _applyVaultFromRemote(existing, raw);
        existing.syncStatus = 0;
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.vaults.put(existing);
        });
      } else {
        final vault = Vault()
          ..remoteId = remoteId
          ..syncStatus = 0;
        _applyVaultFromRemote(vault, raw);
        if (remoteUpdated != null) vault.updatedAt = remoteUpdated;
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.isar.vaults.put(vault);
        });
      }
    }
  }

  Future<void> _pullTransactions(String userId) async {
    final remoteTxs = await _supabase
        .from('transaction_records')
        .select()
        .eq('user_id', userId);

    for (final raw in remoteTxs) {
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
    }
  }

  Future<void> _pullSettings(String userId) async {
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
    if (remoteUpdated != null) settings.updatedAt = remoteUpdated;
    settings.syncStatus = 0;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.appSettings.put(settings);
    });
  }

  // --- Helpers ---

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
