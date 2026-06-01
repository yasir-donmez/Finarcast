import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/models/transaction_record.dart';

class DraftTransaction {
  final String id;
  final String title;
  final double amount;
  final double? minAmount;
  final double? maxAmount;
  final String? categoryId;
  final DateTime date;
  final bool isIncome;
  final String? note;
  final String? reason;
  final String? currency;
  final bool isNotificationEnabled;
  final int notificationReminderDays;
  final int notificationHour;
  final int notificationMinute;
  final String? vaultName;
  final int periodType;
  final int? remainingInstallments;
  final int? recurrenceDay;
  final int? recurrenceDuration;

  DraftTransaction({
    required this.id,
    required this.title,
    required this.amount,
    this.minAmount,
    this.maxAmount,
    this.categoryId,
    required this.date,
    this.isIncome = false,
    this.note,
    this.reason,
    this.currency,
    this.isNotificationEnabled = false,
    this.notificationReminderDays = 0,
    this.notificationHour = 9,
    this.notificationMinute = 0,
    this.vaultName,
    this.periodType = 0,
    this.remainingInstallments,
    this.recurrenceDay,
    this.recurrenceDuration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'minAmount': minAmount,
        'maxAmount': maxAmount,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'isIncome': isIncome,
        'note': note,
        'reason': reason,
        'currency': currency,
        'isNotificationEnabled': isNotificationEnabled,
        'notificationReminderDays': notificationReminderDays,
        'notificationHour': notificationHour,
        'notificationMinute': notificationMinute,
        'vaultName': vaultName,
        'periodType': periodType,
        'remainingInstallments': remainingInstallments,
        'recurrenceDay': recurrenceDay,
        'recurrenceDuration': recurrenceDuration,
      };

  factory DraftTransaction.fromJson(Map<String, dynamic> json) => DraftTransaction(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        minAmount: json['minAmount'] != null ? (json['minAmount'] as num).toDouble() : null,
        maxAmount: json['maxAmount'] != null ? (json['maxAmount'] as num).toDouble() : null,
        categoryId: json['categoryId'] as String?,
        date: DateTime.parse(json['date'] as String),
        isIncome: json['isIncome'] as bool? ?? false,
        note: json['note'] as String?,
        reason: json['reason'] as String?,
        currency: json['currency'] as String?,
        isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? false,
        notificationReminderDays: json['notificationReminderDays'] as int? ?? 0,
        notificationHour: json['notificationHour'] as int? ?? 9,
        notificationMinute: json['notificationMinute'] as int? ?? 0,
        vaultName: json['vaultName'] as String?,
        periodType: json['periodType'] as int? ?? 0,
        remainingInstallments: json['remainingInstallments'] as int?,
        recurrenceDay: json['recurrenceDay'] as int?,
        recurrenceDuration: json['recurrenceDuration'] as int?,
      );
}

class DraftService {
  static const String _draftsKey = 'ai_transaction_drafts';

  /// Taslak listesini SharedPreferences'tan okur
  static Future<List<DraftTransaction>> getDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? draftsJson = prefs.getString(_draftsKey);
      if (draftsJson == null || draftsJson.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(draftsJson);
      return decoded.map((item) => DraftTransaction.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [DraftService] getDrafts hatası: $e');
      return [];
    }
  }

  /// Taslak listesini SharedPreferences'a kaydeder
  static Future<void> saveDrafts(List<DraftTransaction> drafts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String draftsJson = jsonEncode(drafts.map((e) => e.toJson()).toList());
      await prefs.setString(_draftsKey, draftsJson);
    } catch (e) {
      debugPrint('❌ [DraftService] saveDrafts hatası: $e');
    }
  }

  /// Yeni bir taslak ekler
  static Future<void> addDraft(DraftTransaction draft) async {
    final drafts = await getDrafts();
    drafts.insert(0, draft); // En yeni taslağı başa ekle
    await saveDrafts(drafts);
  }

  /// Havuzdan belirli bir taslağı siler (Yoksay)
  static Future<void> deleteDraft(String id) async {
    final drafts = await getDrafts();
    drafts.removeWhere((d) => d.id == id);
    await saveDrafts(drafts);
  }

  /// Taslağı onaylayıp gerçek bir harcamaya dönüştürür
  static Future<bool> promoteToTransaction(String draftId, int? vaultId, String categoryName) async {
    try {
      final drafts = await getDrafts();
      final index = drafts.indexWhere((d) => d.id == draftId);
      if (index == -1) return false;

      final draft = drafts[index];
      
      // Kullanıcı ayarlarından varsayılan para birimini al
      final settings = await DatabaseService.getSettings();
      final currency = settings.currencySymbol;

      // Prepend merchant name (draft.title) to note if it's a specific merchant
      String? finalNote;
      if (draft.title.isNotEmpty && 
          draft.title != 'Boş Taslak' && 
          draft.title != 'Fiş Harcaması' && 
          draft.title != categoryName) {
        finalNote = draft.note != null && draft.note!.isNotEmpty
            ? '${draft.title} - ${draft.note}'
            : draft.title;
      } else {
        finalNote = draft.note;
      }

      // Varsayılan kasayı veritabanından al (Eğer belirtilmemişse)
      final vaults = await DatabaseService.getAllVaults();
      final finalVaultId = vaultId ?? vaults.firstOrNull?.id;

      // Gerçek işlem modelini oluştur
      final tx = TransactionRecord()
        ..title = categoryName
        ..amount = draft.amount
        ..minAmount = draft.minAmount
        ..maxAmount = draft.maxAmount
        ..categoryId = draft.categoryId
        ..date = draft.date
        ..isIncome = draft.isIncome
        ..vaultIds = finalVaultId != null ? [finalVaultId] : []
        ..currency = draft.currency ?? currency
        ..note = finalNote
        ..isNotificationEnabled = draft.isNotificationEnabled
        ..hasNotification = draft.isNotificationEnabled
        ..notificationReminderDays = draft.notificationReminderDays
        ..notificationHour = draft.notificationHour
        ..notificationMinute = draft.notificationMinute
        ..periodType = draft.periodType
        ..remainingInstallments = draft.remainingInstallments
        ..recurrenceDay = draft.recurrenceDay
        ..recurrenceDuration = draft.recurrenceDuration;

      // Veritabanına kaydet
      await DatabaseService.addTransaction(tx);

      // Taslağı listeden sil
      drafts.removeAt(index);
      await saveDrafts(drafts);

      return true;
    } catch (e) {
      debugPrint('❌ [DraftService] promoteToTransaction hatası: $e');
      return false;
    }
  }
}
