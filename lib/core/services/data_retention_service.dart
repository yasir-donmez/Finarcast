import '../database/database_service.dart';
import '../database/models/transaction_record.dart';
import '../database/models/recurring_template.dart';
import '../domain/recurrence_engine.dart';

/// Süresi dolan işlem ve planları arşivleme/silme servisi
/// Uygulama açılışında ve ayar güncellemelerinde çağrılır.
class DataRetentionService {
  static Future<void> archiveExpiredTransactions() async {
    final settings = await DatabaseService.getSettings();
    final retentionDays = settings.dataRetentionDays;
    final permanentDeletionDays = settings.permanentDeletionDays;

    // Her iki ayar da devre dışı ise işlem yapma
    if (retentionDays == -1 && permanentDeletionDays == -1) return;

    final allTx = await DatabaseService.getAllTransactions();
    final allTemplates = await DatabaseService.getAllTemplates();
    final now = DateTime.now();

    // 1. Arşivleme İşlemi (dataRetentionDays != -1 ise)
    if (retentionDays != -1) {
      // 1.1. İşlem Arşivleme
      final toArchiveTx = getTransactionsToArchive(
        allTransactions: allTx,
        dataRetentionDays: retentionDays,
        now: now,
      );
      if (toArchiveTx.isNotEmpty) {
        for (final tx in toArchiveTx) {
          tx.isArchived = true;
        }
        await DatabaseService.updateAllTransactions(toArchiveTx);
      }

      // 1.2. Şablon (Plan) Arşivleme
      final toArchiveTemplates = getTemplatesToArchive(
        allTemplates: allTemplates,
        dataRetentionDays: retentionDays,
        now: now,
      );
      if (toArchiveTemplates.isNotEmpty) {
        for (final t in toArchiveTemplates) {
          t.isArchived = true;
          await DatabaseService.updateTemplate(t);
        }
      }
    }

    // 2. Kalıcı Silme İşlemi (permanentDeletionDays != -1 ise)
    if (permanentDeletionDays != -1) {
      // 2.1. Şablon (Plan) ve Plan İşlemlerini Kalıcı Silme
      final toDeleteTemplates = getTemplatesToDelete(
        allTemplates: allTemplates,
        permanentDeletionDays: permanentDeletionDays,
        now: now,
      );
      if (toDeleteTemplates.isNotEmpty) {
        final templateIds = toDeleteTemplates.map((t) => t.id).toList();
        final txIdsToDelete = allTx
            .where((tx) => templateIds.contains(tx.templateId))
            .map((tx) => tx.id)
            .toList();
        if (txIdsToDelete.isNotEmpty) {
          await DatabaseService.deleteTransactions(txIdsToDelete);
        }
        for (final t in toDeleteTemplates) {
          await DatabaseService.deleteTemplate(t.id);
        }
      }

      // 2.2. Tek Seferlik Manuel İşlemleri Kalıcı Silme
      final toDeleteTx = getTransactionsToDelete(
        allTransactions: allTx,
        permanentDeletionDays: permanentDeletionDays,
        now: now,
      );
      if (toDeleteTx.isNotEmpty) {
        final idsToDelete = toDeleteTx.map((tx) => tx.id).toList();
        await DatabaseService.deleteTransactions(idsToDelete);
      }
    }
  }

  /// Arşivlenmesi gereken işlemleri döner (Test edilebilirlik için pure fonksiyon)
  static List<TransactionRecord> getTransactionsToArchive({
    required List<TransactionRecord> allTransactions,
    required int dataRetentionDays,
    required DateTime now,
  }) {
    if (dataRetentionDays == -1) return [];
    final cutoff = now.subtract(Duration(days: dataRetentionDays));
    return allTransactions.where((tx) {
      if (tx.isArchived) return false; // Zaten arşivlenmiş
      return tx.date.isBefore(cutoff);
    }).toList();
  }

  /// Kalıcı olarak silinmesi gereken işlemleri döner (Test edilebilirlik için pure fonksiyon)
  static List<TransactionRecord> getTransactionsToDelete({
    required List<TransactionRecord> allTransactions,
    required int permanentDeletionDays,
    required DateTime now,
  }) {
    if (permanentDeletionDays == -1) return [];
    final deleteCutoff = now.subtract(Duration(days: permanentDeletionDays));
    
    // Sadece tek seferlik (templateId == null) işlemler silinebilir.
    // Tekrarlı işlem kayıtlarının silinmesi MaterializationService tarafından yeniden üretilmelerine yol açar.
    return allTransactions.where((tx) {
      if (tx.templateId != null) return false;
      return tx.date.isBefore(deleteCutoff);
    }).toList();
  }

  /// Arşivlenmesi gereken şablonları (planları) döner (Test edilebilirlik için pure fonksiyon)
  static List<RecurringTemplate> getTemplatesToArchive({
    required List<RecurringTemplate> allTemplates,
    required int dataRetentionDays,
    required DateTime now,
  }) {
    if (dataRetentionDays == -1) return [];
    final cutoff = now.subtract(Duration(days: dataRetentionDays));
    final farFuture = DateTime(2100, 12, 31);
    
    return allTemplates.where((t) {
      if (t.isArchived) return false; // Zaten arşivlenmiş
      if (t.totalInstallments == null) return false; // Sonsuz planlar otomatik arşivlenmez

      final dates = RecurrenceEngine.occurrenceDates(t.recurrenceRule, farFuture);
      if (dates.isEmpty) return false;

      final completionDate = dates.last;
      return completionDate.isBefore(cutoff);
    }).toList();
  }

  /// Kalıcı silinmesi gereken şablonları (planları) döner (Test edilebilirlik için pure fonksiyon)
  static List<RecurringTemplate> getTemplatesToDelete({
    required List<RecurringTemplate> allTemplates,
    required int permanentDeletionDays,
    required DateTime now,
  }) {
    if (permanentDeletionDays == -1) return [];
    final deleteCutoff = now.subtract(Duration(days: permanentDeletionDays));
    final farFuture = DateTime(2100, 12, 31);

    return allTemplates.where((t) {
      if (t.totalInstallments == null) return false; // Sonsuz planlar otomatik silinmez

      final dates = RecurrenceEngine.occurrenceDates(t.recurrenceRule, farFuture);
      if (dates.isEmpty) return false;

      final completionDate = dates.last;
      return completionDate.isBefore(deleteCutoff);
    }).toList();
  }
}


