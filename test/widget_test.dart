import 'package:flutter_test/flutter_test.dart';
import 'package:finarcast/core/database/models/transaction_record.dart';

void main() {
  group('TransactionRecord Period & Monthly Equivalent Tests', () {
    test('monthlyEquivalent for one-time transaction should be 0', () {
      final tx = TransactionRecord()
        ..amount = 100.0
        ..periodType = 0;
      expect(tx.monthlyEquivalent, 0.0);
    });

    test('monthlyEquivalent for daily transaction (101) should be amount * 30', () {
      final tx = TransactionRecord()
        ..amount = 10.0
        ..periodType = 101;
      expect(tx.monthlyEquivalent, 300.0);
    });

    test('monthlyEquivalent for 2 days transaction (102) should be amount * 15', () {
      final tx = TransactionRecord()
        ..amount = 10.0
        ..periodType = 102;
      expect(tx.monthlyEquivalent, 150.0);
    });

    test('monthlyEquivalent for weekly transaction (201) should be amount * 4.33', () {
      final tx = TransactionRecord()
        ..amount = 10.0
        ..periodType = 201;
      expect(tx.monthlyEquivalent, 43.3);
    });

    test('monthlyEquivalent for weekdays transaction (250) should be amount * 21.67', () {
      final tx = TransactionRecord()
        ..amount = 10.0
        ..periodType = 250;
      expect(tx.monthlyEquivalent, 216.7);
    });

    test('monthlyEquivalent for weekends transaction (251) should be amount * 8.67', () {
      final tx = TransactionRecord()
        ..amount = 10.0
        ..periodType = 251;
      expect(tx.monthlyEquivalent, 86.7);
    });
  });
}
