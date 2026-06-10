import 'package:flutter/foundation.dart';
import '../database/database_service.dart';
import '../database/models/recurring_template.dart';
import '../database/models/transaction_record.dart';
import '../database/models/transaction_status.dart';
import '../domain/recurrence_engine.dart';

class MaterializationService {
  /// Ufuk Politikası: startDate → bugün (gelecekteki işlemler veritabanına yazılmaz, engine ile hesaplanır)
  static Future<void> materializeAll() async {
    try {
      final templates = await DatabaseService.getAllTemplates();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      debugPrint('⚙️ [MaterializationService] materializeAll başlatılıyor... Bugün: $today');

      for (final template in templates) {
        if (template.isPaused || template.isArchived) continue;
        await _materializeTemplate(template, until: today);
      }
      debugPrint('✅ [MaterializationService] materializeAll tamamlandı.');
    } catch (e, stack) {
      debugPrint('❌ [MaterializationService ERROR] materializeAll hatası: $e');
      debugPrint(stack.toString());
    }
  }

  static Future<void> _materializeTemplate(RecurringTemplate template, {required DateTime until}) async {
    final existingKeys = await DatabaseService.getOccurrenceKeysForTemplate(template.id);
    final latestReviewedDate = await DatabaseService.getLatestReviewedDateForTemplate(template.id);

    // recurrence rule oluştur
    var dates = RecurrenceEngine.occurrenceDates(
      template.recurrenceRule,
      until,
    );

    if (latestReviewedDate != null) {
      final normalizedLatest = DateTime(latestReviewedDate.year, latestReviewedDate.month, latestReviewedDate.day);
      dates = dates.where((d) => d.isAfter(normalizedLatest)).toList();
    }

    final newRecords = <TransactionRecord>[];
    for (final date in dates) {
      final key = _buildOccurrenceKey(template, date);
      if (existingKeys.contains(key)) continue;

      newRecords.add(_createRecordFromTemplate(template, date, key));
    }

    if (newRecords.isNotEmpty) {
      debugPrint('🌱 [MaterializationService] "${template.title}" için ${newRecords.length} yeni işlem kaydediliyor.');
      await DatabaseService.addTransactionsBatch(newRecords);
    }
  }

  static TransactionRecord _createRecordFromTemplate(
    RecurringTemplate template, DateTime date, String occurrenceKey,
  ) {
    final installment = RecurrenceEngine.installmentNumber(
      template.recurrenceRule,
      date,
    );

    return TransactionRecord()
      ..title = template.title
      ..categoryId = template.categoryId
      ..iconCode = template.iconCode
      ..isIncome = template.isIncome
      ..amount = template.amount
      ..minAmount = template.minAmount
      ..maxAmount = template.maxAmount
      ..date = date
      ..occurrenceDate = DateTime(date.year, date.month, date.day)
      ..vaultId = template.vaultId
      ..note = template.note
      ..currency = template.currency
      ..templateId = template.id
      ..occurrenceKey = occurrenceKey
      ..installmentNumber = installment
      ..totalInstallments = template.totalInstallments
      ..status = TransactionStatus.confirmed // varsayılan onaylı
      ..isReviewed = false; // görülmedi
  }

  /// Şablon oluşturulduğunda veya güncellendiğinde tetiklenir
  static Future<void> onTemplateChanged(RecurringTemplate template) async {
    try {
      debugPrint('⚙️ [MaterializationService] Şablon değişti: "${template.title}".');
      // 1. isReviewed=false olan gelecek kayıtları sil
      await DatabaseService.deleteUnreviewedRecordsForTemplate(template.id);
      
      // 2. startDate'den bugüne kadar tekrar materialize et
      if (!template.isPaused && !template.isArchived) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        await _materializeTemplate(template, until: today);
      }
    } catch (e) {
      debugPrint('❌ [MaterializationService ERROR] onTemplateChanged hatası: $e');
    }
  }

  /// Şablon silindiğinde tetiklenir
  static Future<void> onTemplateDeleted(int templateId) async {
    try {
      debugPrint('⚙️ [MaterializationService] Şablon silindi, templateId: $templateId.');
      await DatabaseService.deleteUnreviewedRecordsForTemplate(templateId);
    } catch (e) {
      debugPrint('❌ [MaterializationService ERROR] onTemplateDeleted hatası: $e');
    }
  }

  static String _buildOccurrenceKey(RecurringTemplate t, DateTime d) {
    final id = t.remoteId ?? t.id.toString();
    final yyyyMMdd = '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    return '${id}_$yyyyMMdd';
  }
}
