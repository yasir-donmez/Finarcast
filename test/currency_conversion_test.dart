import 'package:flutter_test/flutter_test.dart';
import 'package:finarcast/core/utils/currency_utils.dart';
import 'package:finarcast/core/database/models/exchange_rate.dart';

void main() {
  group('CurrencyUtils Conversion Tests (Base TRY)', () {
    final mockRates = [
      ExchangeRate()
        ..currencyCode = 'USD'
        ..rate = 32.0, // 1 USD = 32 TRY
      ExchangeRate()
        ..currencyCode = 'EUR'
        ..rate = 35.0, // 1 EUR = 35 TRY
      ExchangeRate()
        ..currencyCode = 'GBP'
        ..rate = 40.0, // 1 GBP = 40 TRY
      ExchangeRate()
        ..currencyCode = 'GOLD'
        ..rate = 2400.0, // 1 Gram GOLD = 2400 TRY
      ExchangeRate()
        ..currencyCode = 'SILVER'
        ..rate = 30.0, // 1 Gram SILVER = 30 TRY
    ];

    test('Convert same currency should return identical amount', () {
      final result = CurrencyUtils.convert(100.0, 'USD', 'USD', mockRates);
      expect(result, 100.0);
    });

    test('Convert from USD to TRY (Base Currency)', () {
      final result = CurrencyUtils.convert(10.0, 'USD', 'TRY', mockRates);
      expect(result, 320.0); // 10 * 32
    });

    test('Convert from TRY (Base Currency) to EUR', () {
      final result = CurrencyUtils.convert(350.0, 'TRY', 'EUR', mockRates);
      expect(result, 10.0); // 350 / 35
    });

    test('Convert from USD to EUR (Cross Rate via TRY)', () {
      final result = CurrencyUtils.convert(70.0, 'USD', 'EUR', mockRates);
      // 70 USD = 70 * 32 = 2240 TRY
      // 2240 TRY = 2240 / 35 = 64 EUR
      expect(result, 64.0);
    });

    test('Fallback to source amount if rate is missing', () {
      final result = CurrencyUtils.convert(100.0, 'XYZ', 'TRY', mockRates);
      expect(result, 100.0);
    });

    test('Commodity (Gold) Gram conversion under TRY context (Local)', () {
      // 1 Gram Gold = 2400 TRY
      final result = CurrencyUtils.convert(1.0, 'GOLD', 'TRY', mockRates);
      expect(result, 2400.0);
    });

    test('Commodity (Gold) Ounce conversion under USD context (Global)', () {
      // 1 Ounce Gold in USD
      // 1 Ounce = 31.1034768 Grams
      // 31.1034768 Grams = 31.1034768 * 2400.0 = 74648.34432 TRY
      // 74648.34432 TRY = 74648.34432 / 32.0 = 2332.76076 USD
      final result = CurrencyUtils.convert(1.0, 'GOLD', 'USD', mockRates);
      expect(result, closeTo(2332.76076, 0.0001));
    });

    test('Commodity (Gold) conversion from USD context to Ounce (Global)', () {
      // Convert $2332.76076 back to Ounce Gold
      final result = CurrencyUtils.convert(2332.76076, 'USD', 'GOLD', mockRates);
      expect(result, closeTo(1.0, 0.0001));
    });
  });
}
