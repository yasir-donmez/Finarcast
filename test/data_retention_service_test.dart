import 'package:flutter_test/flutter_test.dart';
import 'package:finarcast/core/services/data_retention_service.dart';
import 'package:finarcast/core/database/models/transaction_record.dart';
import 'package:finarcast/core/database/models/recurring_template.dart';

void main() {
  group('DataRetentionService - getTransactionsToUpdateArchiveStatus', () {
    final now = DateTime(2026, 6, 14);

    test('Should unarchive all archived transactions when dataRetentionDays is -1', () {
      final tx1 = TransactionRecord()
        ..id = 1
        ..date = now.subtract(const Duration(days: 100))
        ..isArchived = true;

      final tx2 = TransactionRecord()
        ..id = 2
        ..date = now.subtract(const Duration(days: 10))
        ..isArchived = false;

      final txs = [tx1, tx2];

      final result = DataRetentionService.getTransactionsToUpdateArchiveStatus(
        allTransactions: txs,
        dataRetentionDays: -1,
        now: now,
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
      expect(result.first.isArchived, isFalse);
    });

    test('Should correctly archive expired and unarchive active transactions based on cutoff', () {
      final tx1 = TransactionRecord()
        ..id = 1
        ..date = now.subtract(const Duration(days: 95))
        ..isArchived = false; // Expired, active -> should archive

      final tx2 = TransactionRecord()
        ..id = 2
        ..date = now.subtract(const Duration(days: 95))
        ..isArchived = true; // Expired, archived -> keep archived (no update)

      final tx3 = TransactionRecord()
        ..id = 3
        ..date = now.subtract(const Duration(days: 45))
        ..isArchived = true; // Active, archived -> should unarchive

      final tx4 = TransactionRecord()
        ..id = 4
        ..date = now.subtract(const Duration(days: 45))
        ..isArchived = false; // Active, active -> keep active (no update)

      final txs = [tx1, tx2, tx3, tx4];

      final result = DataRetentionService.getTransactionsToUpdateArchiveStatus(
        allTransactions: txs,
        dataRetentionDays: 90,
        now: now,
      );

      expect(result.length, 2);
      expect(result.any((tx) => tx.id == 1 && tx.isArchived == true), isTrue);
      expect(result.any((tx) => tx.id == 3 && tx.isArchived == false), isTrue);
    });
  });

  group('DataRetentionService - getTransactionsToDelete', () {
    final now = DateTime(2026, 6, 14);

    test('Should return empty list when permanentDeletionDays is -1', () {
      final txs = [
        TransactionRecord()..date = now.subtract(const Duration(days: 200)),
      ];

      final result = DataRetentionService.getTransactionsToDelete(
        allTransactions: txs,
        permanentDeletionDays: -1,
        now: now,
      );

      expect(result, isEmpty);
    });

    test('Should only return manual records older than permanentDeletionDays', () {
      final tx1 = TransactionRecord()
        ..id = 1
        ..date = now.subtract(const Duration(days: 121))
        ..templateId = null; // Manual, older than 120 days -> delete

      final tx2 = TransactionRecord()
        ..id = 2
        ..date = now.subtract(const Duration(days: 119))
        ..templateId = null; // Manual, newer than 120 days -> keep

      final tx3 = TransactionRecord()
        ..id = 3
        ..date = now.subtract(const Duration(days: 150))
        ..templateId = 42; // Recurring (has templateId), older -> keep (do not delete recurring!)

      final txs = [tx1, tx2, tx3];

      final result = DataRetentionService.getTransactionsToDelete(
        allTransactions: txs,
        permanentDeletionDays: 120,
        now: now,
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
    });
  });

  group('DataRetentionService - getTemplatesToUpdateArchiveStatus', () {
    final now = DateTime(2026, 6, 14);

    test('Should unarchive all archived templates when dataRetentionDays is -1', () {
      final t1 = RecurringTemplate()
        ..id = 1
        ..startDate = now.subtract(const Duration(days: 100))
        ..totalInstallments = 1
        ..periodType = 301
        ..isArchived = true; // Archived -> should unarchive

      final t2 = RecurringTemplate()
        ..id = 2
        ..startDate = now.subtract(const Duration(days: 10))
        ..totalInstallments = 1
        ..periodType = 301
        ..isArchived = false;

      final templates = [t1, t2];

      final result = DataRetentionService.getTemplatesToUpdateArchiveStatus(
        allTemplates: templates,
        dataRetentionDays: -1,
        now: now,
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
      expect(result.first.isArchived, isFalse);
    });

    test('Should correctly archive expired and unarchive active templates based on cutoff', () {
      final t1 = RecurringTemplate()
        ..id = 1
        ..startDate = now.subtract(const Duration(days: 95))
        ..totalInstallments = 1
        ..periodType = 301 // Completed 95 days ago
        ..isArchived = false; // Expired, active -> archive

      final t2 = RecurringTemplate()
        ..id = 2
        ..startDate = now.subtract(const Duration(days: 95))
        ..totalInstallments = 1
        ..periodType = 301
        ..isArchived = true; // Expired, archived -> keep archived (no update)

      final t3 = RecurringTemplate()
        ..id = 3
        ..startDate = now.subtract(const Duration(days: 45))
        ..totalInstallments = 1
        ..periodType = 301 // Completed 45 days ago
        ..isArchived = true; // Active, archived -> unarchive

      final t4 = RecurringTemplate()
        ..id = 4
        ..startDate = now.subtract(const Duration(days: 45))
        ..totalInstallments = 1
        ..periodType = 301
        ..isArchived = false; // Active, active -> keep active (no update)

      final t5 = RecurringTemplate()
        ..id = 5
        ..startDate = now.subtract(const Duration(days: 95))
        ..totalInstallments = null // Infinite template -> skip
        ..periodType = 301
        ..isArchived = false;

      final templates = [t1, t2, t3, t4, t5];

      final result = DataRetentionService.getTemplatesToUpdateArchiveStatus(
        allTemplates: templates,
        dataRetentionDays: 90,
        now: now,
      );

      expect(result.length, 2);
      expect(result.any((t) => t.id == 1 && t.isArchived == true), isTrue);
      expect(result.any((t) => t.id == 3 && t.isArchived == false), isTrue);
    });
  });

  group('DataRetentionService - getTemplatesToDelete', () {
    final now = DateTime(2026, 6, 14);

    test('Should return empty list when permanentDeletionDays is -1', () {
      final templates = [
        RecurringTemplate()
          ..startDate = now.subtract(const Duration(days: 200))
          ..totalInstallments = 1
          ..periodType = 301,
      ];

      final result = DataRetentionService.getTemplatesToDelete(
        allTemplates: templates,
        permanentDeletionDays: -1,
        now: now,
      );

      expect(result, isEmpty);
    });

    test('Should only delete completed templates that passed permanentDeletionDays', () {
      final t1 = RecurringTemplate()
        ..id = 1
        ..startDate = now.subtract(const Duration(days: 125))
        ..totalInstallments = 1
        ..periodType = 301; // Completed 125 days ago -> delete

      final t2 = RecurringTemplate()
        ..id = 2
        ..startDate = now.subtract(const Duration(days: 10))
        ..totalInstallments = 1
        ..periodType = 301; // Completed 10 days ago -> keep

      final t3 = RecurringTemplate()
        ..id = 3
        ..startDate = now.subtract(const Duration(days: 150))
        ..totalInstallments = null // Infinite template -> keep
        ..periodType = 301;

      final templates = [t1, t2, t3];

      final result = DataRetentionService.getTemplatesToDelete(
        allTemplates: templates,
        permanentDeletionDays: 120,
        now: now,
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
    });
  });
}
