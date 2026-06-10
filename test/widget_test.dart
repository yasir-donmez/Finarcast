import 'package:flutter_test/flutter_test.dart';
import 'package:finarcast/core/database/models/recurring_template.dart';

void main() {
  group('RecurringTemplate Period & Monthly Equivalent Tests', () {
    test('monthlyEquivalent for zero period template should be 0', () {
      final t = RecurringTemplate()
        ..amount = 100.0
        ..periodType = 0;
      expect(t.monthlyEquivalent, 0.0);
    });

    test('monthlyEquivalent for daily template (101) should be amount * 30', () {
      final t = RecurringTemplate()
        ..amount = 10.0
        ..periodType = 101;
      expect(t.monthlyEquivalent, 300.0);
    });

    test('monthlyEquivalent for 2 days template (102) should be amount * 15', () {
      final t = RecurringTemplate()
        ..amount = 10.0
        ..periodType = 102;
      expect(t.monthlyEquivalent, 150.0);
    });

    test('monthlyEquivalent for weekly template (201) should be amount * 4.33', () {
      final t = RecurringTemplate()
        ..amount = 10.0
        ..periodType = 201;
      expect(t.monthlyEquivalent, 43.3);
    });

    test('monthlyEquivalent for weekdays template (250) should be amount * 21.67', () {
      final t = RecurringTemplate()
        ..amount = 10.0
        ..periodType = 250;
      expect(t.monthlyEquivalent, 216.7);
    });

    test('monthlyEquivalent for weekends template (251) should be amount * 8.67', () {
      final t = RecurringTemplate()
        ..amount = 10.0
        ..periodType = 251;
      expect(t.monthlyEquivalent, 86.7);
    });
  });
}
