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

    final allTx = await DatabaseService.getAllTransactions();
    final allTemplates = await DatabaseService.getAllTemplates();
    final now = DateTime.now();

    // 1. Arşiv Durumu Güncellemeleri (Arşivleme ve Geri Çıkartma)
    final toUpdateTx = getTransactionsToUpdateArchiveStatus(
      allTransactions: allTx,
      dataRetentionDays: retentionDays,
      now: now,
    );
    if (toUpdateTx.isNotEmpty) {
      await DatabaseService.updateAllTransactions(toUpdateTx);
    }

    final toUpdateTemplates = getTemplatesToUpdateArchiveStatus(
      allTemplates: allTemplates,
      dataRetentionDays: retentionDays,
      now: now,
    );
    if (toUpdateTemplates.isNotEmpty) {
      for (final t in toUpdateTemplates) {
        await DatabaseService.updateTemplate(t);
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

  /// Hangi işlemlerin arşiv durumunun güncellenmesi gerektiğini hesaplar (arşivleme + geri çıkartma)
  static List<TransactionRecord> getTransactionsToUpdateArchiveStatus({
    required List<TransactionRecord> allTransactions,
    required int dataRetentionDays,
    required DateTime now,
  }) {
    final toUpdate = <TransactionRecord>[];
    
    if (dataRetentionDays == -1) {
      // Eğer sonsuz ise, arşivlenmiş olan tüm işlemleri aktif hale getir
      for (final tx in allTransactions) {
        if (tx.isArchived) {
          tx.isArchived = false;
          toUpdate.add(tx);
        }
      }
    } else {
      final cutoff = now.subtract(Duration(days: dataRetentionDays));
      for (final tx in allTransactions) {
        final shouldBeArchived = tx.date.isBefore(cutoff);
        if (tx.isArchived != shouldBeArchived) {
          tx.isArchived = shouldBeArchived;
          toUpdate.add(tx);
        }
      }
    }
    return toUpdate;
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

  /// Hangi şablonların (planların) arşiv durumunun güncellenmesi gerektiğini hesaplar (arşivleme + geri çıkartma)
  static List<RecurringTemplate> getTemplatesToUpdateArchiveStatus({
    required List<RecurringTemplate> allTemplates,
    required int dataRetentionDays,
    required DateTime now,
  }) {
    final toUpdate = <RecurringTemplate>[];
    final farFuture = DateTime(2100, 12, 31);

    if (dataRetentionDays == -1) {
      // Eğer sonsuz ise, arşivlenmiş olan tüm planları aktif hale getir
      for (final t in allTemplates) {
        if (t.isArchived) {
          t.isArchived = false;
          toUpdate.add(t);
        }
      }
    } else {
      final cutoff = now.subtract(Duration(days: dataRetentionDays));
      for (final t in allTemplates) {
        if (t.totalInstallments == null) {
          // Sonsuz planlar asla otomatik arşivlenmez veya unarchive edilmez
          continue;
        }

        final dates = RecurrenceEngine.occurrenceDates(t.recurrenceRule, farFuture);
        if (dates.isEmpty) continue;

        final completionDate = dates.last;
        final shouldBeArchived = completionDate.isBefore(cutoff);

        if (t.isArchived != shouldBeArchived) {
          t.isArchived = shouldBeArchived;
          toUpdate.add(t);
        }
      }
    }
    return toUpdate;
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


