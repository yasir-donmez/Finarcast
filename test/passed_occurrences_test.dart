import 'package:flutter_test/flutter_test.dart';
import 'package:finarcast/features/vaults/vaults_providers.dart';
import 'package:finarcast/core/database/models/exchange_rate.dart';
import 'package:flutter/material.dart';

void main() {
  test('Calculate income and expense for mock transactions', () {
    final now = DateTime.now();
    final rates = <ExchangeRate>[];
    final targetCurrency = '\$';
    
    final txs = [
      TransactionUI(
        id: 'test_1',
        name: 'Rent',
        icon: Icons.abc,
        color: Colors.red,
        amount: 200,
        currency: 'SR',
        isIncome: false,
        periodType: 0, // One-time
        date: now,
      ),
      TransactionUI(
        id: 'test_2',
        name: 'Grocery',
        icon: Icons.abc,
        color: Colors.red,
        amount: 115600000,
        currency: 'KD',
        isIncome: false,
        periodType: 301, // Monthly
        date: now,
        recurrenceDuration: 3,
      ),
    ];

    final activeTxs = txs;
    final income = activeTxs.where((t) => t.isIncome).fold<double>(0, (sum, t) {
      final occurrencesThisMonth = t.getOccurrencesInMonth(now.year, now.month);
      return sum + (t.getConvertedAmount(targetCurrency, rates) * occurrencesThisMonth);
    });
    
    final expense = activeTxs.where((t) => !t.isIncome).fold<double>(0, (sum, t) {
      final occurrencesThisMonth = t.getOccurrencesInMonth(now.year, now.month);
      return sum + (t.getConvertedAmount(targetCurrency, rates) * occurrencesThisMonth);
    });

    debugPrint('Calculated income: $income');
    debugPrint('Calculated expense: $expense');
  });
}
