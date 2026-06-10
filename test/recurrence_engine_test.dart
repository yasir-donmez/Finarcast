import 'package:flutter_test/flutter_test.dart';
import 'package:finarcast/core/domain/recurrence_rule.dart';
import 'package:finarcast/core/domain/recurrence_engine.dart';

void main() {
  group('RecurrenceEngine - occurrenceDates', () {
    test('One-time transaction (interval = 0)', () {
      final rule = RecurrenceRule(
        periodType: 0,
        startDate: DateTime(2026, 6, 1),
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 6, 30));
      expect(dates.length, 1);
      expect(dates.first, DateTime(2026, 6, 1));
    });

    test('Daily interval (101 - daily)', () {
      final rule = RecurrenceRule(
        periodType: 101,
        startDate: DateTime(2026, 6, 1),
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 6, 5));
      expect(dates.length, 5);
      expect(dates[0], DateTime(2026, 6, 1));
      expect(dates[1], DateTime(2026, 6, 2));
      expect(dates[2], DateTime(2026, 6, 3));
      expect(dates[3], DateTime(2026, 6, 4));
      expect(dates[4], DateTime(2026, 6, 5));
    });

    test('Every 2 days (102)', () {
      final rule = RecurrenceRule(
        periodType: 102,
        startDate: DateTime(2026, 6, 1),
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 6, 6));
      expect(dates.length, 3);
      expect(dates[0], DateTime(2026, 6, 1));
      expect(dates[1], DateTime(2026, 6, 3));
      expect(dates[2], DateTime(2026, 6, 5));
    });

    test('Weekly interval (201)', () {
      final rule = RecurrenceRule(
        periodType: 201,
        startDate: DateTime(2026, 6, 1), // Monday
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 6, 15));
      expect(dates.length, 3);
      expect(dates[0], DateTime(2026, 6, 1));
      expect(dates[1], DateTime(2026, 6, 8));
      expect(dates[2], DateTime(2026, 6, 15));
    });

    test('Weekdays only (250) - includes only Monday-Friday', () {
      final rule = RecurrenceRule(
        periodType: 250,
        startDate: DateTime(2026, 6, 5), // Friday
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 6, 9)); // Tuesday
      // 5th (Fri), 6th (Sat - skip), 7th (Sun - skip), 8th (Mon), 9th (Tue)
      expect(dates.length, 3);
      expect(dates[0], DateTime(2026, 6, 5));
      expect(dates[1], DateTime(2026, 6, 8));
      expect(dates[2], DateTime(2026, 6, 9));
    });

    test('Weekends only (251) - includes only Saturday-Sunday', () {
      final rule = RecurrenceRule(
        periodType: 251,
        startDate: DateTime(2026, 6, 5), // Friday
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 6, 9)); // Tuesday
      // 5th (Fri - skip), 6th (Sat), 7th (Sun), 8th (Mon - skip), 9th (Tue - skip)
      expect(dates.length, 2);
      expect(dates[0], DateTime(2026, 6, 6));
      expect(dates[1], DateTime(2026, 6, 7));
    });

    test('Monthly interval (301)', () {
      final rule = RecurrenceRule(
        periodType: 301,
        startDate: DateTime(2026, 1, 15),
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 4, 15));
      expect(dates.length, 4);
      expect(dates[0], DateTime(2026, 1, 15));
      expect(dates[1], DateTime(2026, 2, 15));
      expect(dates[2], DateTime(2026, 3, 15));
      expect(dates[3], DateTime(2026, 4, 15));
    });

    test('Monthly interval with day overflow (Jan 31st)', () {
      final rule = RecurrenceRule(
        periodType: 301,
        startDate: DateTime(2026, 1, 31),
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 3, 31));
      // Jan 31, Feb 28 (non-leap year), Mar 31
      expect(dates.length, 3);
      expect(dates[0], DateTime(2026, 1, 31));
      expect(dates[1], DateTime(2026, 2, 28));
      expect(dates[2], DateTime(2026, 3, 31));
    });

    test('Monthly interval with leap year day overflow (Jan 31st, 2024)', () {
      final rule = RecurrenceRule(
        periodType: 301,
        startDate: DateTime(2024, 1, 31),
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2024, 2, 29));
      expect(dates.length, 2);
      expect(dates[0], DateTime(2024, 1, 31));
      expect(dates[1], DateTime(2024, 2, 29));
    });

    test('Yearly interval (401)', () {
      final rule = RecurrenceRule(
        periodType: 401,
        startDate: DateTime(2026, 6, 1),
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2028, 6, 1));
      expect(dates.length, 3);
      expect(dates[0], DateTime(2026, 6, 1));
      expect(dates[1], DateTime(2027, 6, 1));
      expect(dates[2], DateTime(2028, 6, 1));
    });

    test('Max occurrences limit', () {
      final rule = RecurrenceRule(
        periodType: 101, // daily
        startDate: DateTime(2026, 6, 1),
        totalInstallments: 3,
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 6, 10));
      expect(dates.length, 3);
      expect(dates.last, DateTime(2026, 6, 3));
    });

    test('Total installments limit', () {
      final rule = RecurrenceRule(
        periodType: 301, // monthly
        startDate: DateTime(2026, 6, 1),
        totalInstallments: 3,
      );
      final dates = RecurrenceEngine.occurrenceDates(rule, DateTime(2026, 10, 1));
      expect(dates.length, 3);
      expect(dates[0], DateTime(2026, 6, 1));
      expect(dates[1], DateTime(2026, 7, 1));
      expect(dates[2], DateTime(2026, 8, 1));
    });
  });

  group('RecurrenceEngine - nextOccurrence', () {
    test('Finds next occurrence daily', () {
      final rule = RecurrenceRule(
        periodType: 101,
        startDate: DateTime(2026, 6, 1),
      );
      final next = RecurrenceEngine.nextOccurrence(rule, after: DateTime(2026, 6, 3));
      expect(next, DateTime(2026, 6, 4));
    });

    test('Finds next occurrence monthly', () {
      final rule = RecurrenceRule(
        periodType: 301,
        startDate: DateTime(2026, 6, 15),
      );
      final next = RecurrenceEngine.nextOccurrence(rule, after: DateTime(2026, 6, 20));
      expect(next, DateTime(2026, 7, 15));
    });

    test('Next occurrence respects max limit', () {
      final rule = RecurrenceRule(
        periodType: 101,
        startDate: DateTime(2026, 6, 1),
        totalInstallments: 3,
      );
      final nextValid = RecurrenceEngine.nextOccurrence(rule, after: DateTime(2026, 6, 2));
      expect(nextValid, DateTime(2026, 6, 3));

      final nextInvalid = RecurrenceEngine.nextOccurrence(rule, after: DateTime(2026, 6, 3));
      expect(nextInvalid, isNull);
    });
  });

  group('RecurrenceEngine - occurrencesInMonth', () {
    test('Calculates count in a specific month', () {
      final rule = RecurrenceRule(
        periodType: 101, // daily
        startDate: DateTime(2026, 6, 1),
      );
      final count = RecurrenceEngine.occurrencesInMonth(rule, 2026, 6);
      expect(count, 30); // 30 days in June
    });

    test('Calculates count in a specific month with offsets', () {
      final rule = RecurrenceRule(
        periodType: 201, // weekly
        startDate: DateTime(2026, 6, 1), // Monday
      );
      // Mondays in June 2026: 1, 8, 15, 22, 29
      final count = RecurrenceEngine.occurrencesInMonth(rule, 2026, 6);
      expect(count, 5);
    });
  });

  group('RecurrenceEngine - installmentNumber', () {
    test('Calculates correct installment index', () {
      final rule = RecurrenceRule(
        periodType: 301,
        startDate: DateTime(2026, 6, 1),
        totalInstallments: 12,
      );

      final index1 = RecurrenceEngine.installmentNumber(rule, DateTime(2026, 6, 1));
      expect(index1, 1);

      final index3 = RecurrenceEngine.installmentNumber(rule, DateTime(2026, 8, 1));
      expect(index3, 3);

      final indexOut = RecurrenceEngine.installmentNumber(rule, DateTime(2027, 7, 1)); // Month 14
      expect(indexOut, isNull);
    });
  });
}
