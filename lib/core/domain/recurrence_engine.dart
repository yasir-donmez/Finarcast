import 'recurrence_rule.dart';

abstract class RecurrenceEngine {
  /// Generates all occurrence dates starting from rule.startDate up to and including until.
  /// Dates are normalized to yyyy-MM-dd (time components are set to zero).
  static List<DateTime> occurrenceDates(RecurrenceRule rule, DateTime until) {
    final normalizedStart = RecurrenceRule.normalize(rule.startDate);
    final normalizedUntil = RecurrenceRule.normalize(until);

    if (normalizedUntil.isBefore(normalizedStart)) {
      return [];
    }

    final maxLimit = rule.totalInstallments;
    final list = <DateTime>[];

    if (rule.periodType == 250) {
      // Weekdays (Hafta içi)
      DateTime current = normalizedStart;
      while (!current.isAfter(normalizedUntil)) {
        if (current.weekday >= 1 && current.weekday <= 5) {
          list.add(current);
          if (maxLimit != null && list.length >= maxLimit) {
            break;
          }
        }
        current = current.add(const Duration(days: 1));
      }
    } else if (rule.periodType == 251) {
      // Weekends (Hafta sonu)
      DateTime current = normalizedStart;
      while (!current.isAfter(normalizedUntil)) {
        if (current.weekday == 6 || current.weekday == 7) {
          list.add(current);
          if (maxLimit != null && list.length >= maxLimit) {
            break;
          }
        }
        current = current.add(const Duration(days: 1));
      }
    } else {
      final unit = rule.periodType ~/ 100;
      final interval = rule.periodType % 100;

      if (interval <= 0) {
        // One-time or invalid interval
        list.add(normalizedStart);
      } else {
        int k = 0;
        while (true) {
          if (maxLimit != null && k >= maxLimit) {
            break;
          }

          DateTime candidate;
          if (unit == 1) {
            // Days
            candidate = normalizedStart.add(Duration(days: k * interval));
          } else if (unit == 2) {
            // Weeks
            candidate = normalizedStart.add(Duration(days: k * interval * 7));
          } else if (unit == 3) {
            // Months
            final monthOffset = k * interval;
            int targetYear = normalizedStart.year + (normalizedStart.month - 1 + monthOffset) ~/ 12;
            int targetMonth = (normalizedStart.month - 1 + monthOffset) % 12 + 1;
            int targetDay = rule.recurrenceDate?.day ?? normalizedStart.day;
            final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
            final day = targetDay > lastDay ? lastDay : targetDay;
            candidate = DateTime(targetYear, targetMonth, day);
          } else if (unit == 4) {
            // Years
            final yearOffset = k * interval;
            int targetYear = normalizedStart.year + yearOffset;
            int targetMonth = rule.recurrenceDate?.month ?? normalizedStart.month;
            int targetDay = rule.recurrenceDate?.day ?? normalizedStart.day;
            final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
            final day = targetDay > lastDay ? lastDay : targetDay;
            candidate = DateTime(targetYear, targetMonth, day);
          } else {
            // Fallback
            candidate = normalizedStart;
          }

          final normalizedCandidate = RecurrenceRule.normalize(candidate);
          if (normalizedCandidate.isAfter(normalizedUntil)) {
            break;
          }

          list.add(normalizedCandidate);
          k++;
        }
      }
    }

    return list;
  }

  /// Finds the first occurrence date strictly after 'after'.
  static DateTime? nextOccurrence(RecurrenceRule rule, {required DateTime after}) {
    final normalizedStart = RecurrenceRule.normalize(rule.startDate);
    final normalizedAfter = RecurrenceRule.normalize(after);

    final maxLimit = rule.totalInstallments;

    if (rule.periodType == 250) {
      // Weekdays
      DateTime current = normalizedStart;
      int count = 0;
      while (true) {
        if (current.weekday >= 1 && current.weekday <= 5) {
          count++;
          if (current.isAfter(normalizedAfter)) {
            return current;
          }
          if (maxLimit != null && count >= maxLimit) {
            return null;
          }
        }
        current = current.add(const Duration(days: 1));
      }
    } else if (rule.periodType == 251) {
      // Weekends
      DateTime current = normalizedStart;
      int count = 0;
      while (true) {
        if (current.weekday == 6 || current.weekday == 7) {
          count++;
          if (current.isAfter(normalizedAfter)) {
            return current;
          }
          if (maxLimit != null && count >= maxLimit) {
            return null;
          }
        }
        current = current.add(const Duration(days: 1));
      }
    } else {
      final unit = rule.periodType ~/ 100;
      final interval = rule.periodType % 100;

      if (interval <= 0) {
        if (normalizedStart.isAfter(normalizedAfter)) {
          return normalizedStart;
        }
        return null;
      }

      int k = 0;
      while (true) {
        if (maxLimit != null && k >= maxLimit) {
          return null;
        }

        DateTime candidate;
        if (unit == 1) {
          candidate = normalizedStart.add(Duration(days: k * interval));
        } else if (unit == 2) {
          candidate = normalizedStart.add(Duration(days: k * interval * 7));
        } else if (unit == 3) {
          final monthOffset = k * interval;
          int targetYear = normalizedStart.year + (normalizedStart.month - 1 + monthOffset) ~/ 12;
          int targetMonth = (normalizedStart.month - 1 + monthOffset) % 12 + 1;
          int targetDay = rule.recurrenceDate?.day ?? normalizedStart.day;
          final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
          final day = targetDay > lastDay ? lastDay : targetDay;
          candidate = DateTime(targetYear, targetMonth, day);
        } else if (unit == 4) {
          final yearOffset = k * interval;
          int targetYear = normalizedStart.year + yearOffset;
          int targetMonth = rule.recurrenceDate?.month ?? normalizedStart.month;
          int targetDay = rule.recurrenceDate?.day ?? normalizedStart.day;
          final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
          final day = targetDay > lastDay ? lastDay : targetDay;
          candidate = DateTime(targetYear, targetMonth, day);
        } else {
          candidate = normalizedStart;
        }

        final normalizedCandidate = RecurrenceRule.normalize(candidate);
        if (normalizedCandidate.isAfter(normalizedAfter)) {
          return normalizedCandidate;
        }
        k++;
      }
    }
  }

  /// Calculates the number of times this rule triggers in a specific year and month.
  static int occurrencesInMonth(RecurrenceRule rule, int year, int month) {
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0); // Last day of month

    final list = occurrenceDates(rule, monthEnd);
    return list.where((d) => !d.isBefore(monthStart) && !d.isAfter(monthEnd)).length;
  }

  /// Calculates the 1-based installment index for a given occurrenceDate.
  /// Returns null if this is not an installment rule, or if the date doesn't match an occurrence.
  static int? installmentNumber(RecurrenceRule rule, DateTime occurrenceDate) {
    if (rule.totalInstallments == null) {
      return null;
    }

    final normalizedOcc = RecurrenceRule.normalize(occurrenceDate);
    final list = occurrenceDates(rule, normalizedOcc);

    for (int i = 0; i < list.length; i++) {
      if (list[i].isAtSameMomentAs(normalizedOcc)) {
        return i + 1;
      }
    }

    return null;
  }
}
