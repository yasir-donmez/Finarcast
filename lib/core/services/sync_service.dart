import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database_service.dart';
import '../database/models/transaction_record.dart';
import '../database/models/vault.dart';
import '../database/models/financial_goal.dart';
import '../database/models/app_settings.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncService {
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Ana Senkronizasyon Fonksiyonu
  Future<void> syncAll() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await pushLocalChanges(user.id);
      await pullRemoteChanges(user.id);
    } catch (e) {
      // ignore: avoid_print
      // print('❌ Sync Error: $e');
      rethrow;
    }
  }

  /// Yerel değişiklikleri (syncStatus = 1) buluta gönder
  Future<void> pushLocalChanges(String userId) async {
    // 1. Vaults
    final pendingVaults = await DatabaseService.isar.vaults
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

    for (var vault in pendingVaults) {
      // Eğer remoteId yoksa oluştur (İlk kez senkronize oluyor)
      vault.remoteId ??= _uuid.v4();
      
      final data = {
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
      };

      await _supabase.from('vaults').upsert(data);
      
      // Kaydı "senkronize edildi" olarak işaretle
      await DatabaseService.isar.writeTxn(() async {
        vault.syncStatus = 0;
        await DatabaseService.isar.vaults.put(vault);
      });
    }

    // 2. Transactions
    final pendingTxs = await DatabaseService.isar.transactionRecords
        .filter()
        .syncStatusEqualTo(1)
        .findAll();

    for (var tx in pendingTxs) {
      tx.remoteId ??= _uuid.v4();
      
      final data = {
        'id': tx.remoteId,
        'user_id': userId,
        'title': tx.title,
        'is_income': tx.isIncome,
        'category_id': tx.categoryId,
        'icon_code': tx.iconCode,
        'amount': tx.amount,
        'date': tx.date.toIso8601String(),
        'period_type': tx.periodType,
        'is_archived': tx.isArchived,
        'vault_id': (await DatabaseService.isar.vaults.filter().idEqualTo(tx.vaultIds.isNotEmpty ? tx.vaultIds.first : -1).findFirst())?.remoteId,
      };

      await _supabase.from('transaction_records').upsert(data);
      
      await DatabaseService.isar.writeTxn(() async {
        tx.syncStatus = 0;
        await DatabaseService.isar.transactionRecords.put(tx);
      });
    }
  }

  /// Buluttaki güncel verileri çek ve yerele işle
  Future<void> pullRemoteChanges(String userId) async {
    // 1. Vaults Çek
    final remoteVaults = await _supabase.from('vaults').select().eq('user_id', userId);
    for (var raw in remoteVaults) {
      final remoteId = raw['id'];
      final existing = await DatabaseService.isar.vaults.filter().remoteIdEqualTo(remoteId).findFirst();

      if (existing == null) {
        final newVault = Vault()
          ..remoteId = remoteId
          ..name = raw['name']
          ..currency = raw['currency']
          ..balance = (raw['balance'] as num).toDouble()
          ..iconCode = raw['icon_code']
          ..isIncludedInTotal = raw['is_included_in_total']
          ..showOnDashboard = raw['show_on_dashboard']
          ..dashboardOrder = raw['dashboard_order']
          ..dashboardLayoutType = raw['dashboard_layout_type']
          ..syncStatus = 0;
        
        await DatabaseService.isar.writeTxn(() async => await DatabaseService.isar.vaults.put(newVault));
      }
    }

    // 3. Financial Goals Çek
    final remoteGoals = await _supabase.from('financial_goals').select().eq('user_id', userId);
    for (var raw in remoteGoals) {
      final remoteId = raw['id'];
      final existing = await DatabaseService.isar.financialGoals.filter().remoteIdEqualTo(remoteId).findFirst();

      if (existing == null) {
        final newGoal = FinancialGoal()
          ..remoteId = remoteId
          ..targetAmount = (raw['target_amount'] as num).toDouble()
          ..targetDate = raw['target_date'] != null ? DateTime.parse(raw['target_date']) : null
          ..aiPersonaText = raw['ai_persona_text']
          ..aiStrategyText = raw['ai_strategy_text']
          ..userApproved = raw['user_approved']
          ..syncStatus = 0;
        
        await DatabaseService.isar.writeTxn(() async => await DatabaseService.isar.financialGoals.put(newGoal));
      }
    }

    // 4. App Settings Çek (Tekil Kayıt)
    final remoteSettings = await _supabase.from('app_settings').select().eq('user_id', userId).maybeSingle();
    if (remoteSettings != null) {
      final settings = await DatabaseService.getSettings();
      settings.languageCode = remoteSettings['language_code'];
      settings.themeModeIndex = remoteSettings['theme_mode_index'];
      settings.dataRetentionDays = remoteSettings['data_retention_days'];
      settings.isNotificationsEnabled = remoteSettings['is_ai_notifications_enabled'];
      settings.isSyncEnabled = remoteSettings['is_sync_enabled'];
      settings.syncStatus = 0;
      
      await DatabaseService.isar.writeTxn(() async => await DatabaseService.isar.appSettings.put(settings));
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());
