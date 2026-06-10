class RecurrenceRule {
  final int periodType;
  final DateTime startDate;
  final int? recurrenceDay;
  final DateTime? recurrenceDate;
  final int? totalInstallments;   // null = infinite

  RecurrenceRule({
    required this.periodType,
    required this.startDate,
    this.recurrenceDay,
    this.recurrenceDate,
    this.totalInstallments,
  });

  /// Helper to convert raw date to yyyy-MM-dd normalize format
  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
