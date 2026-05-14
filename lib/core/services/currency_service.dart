import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../database/database_service.dart';
import '../database/models/exchange_rate.dart';

class CurrencyService {
  // Ücretsiz ve Anahtar Gerektirmeyen API
  static const String _baseUrl = 'https://finans.truncgil.com/today.json';

  /// Kurları internetten çeker ve veritabanını günceller
  static Future<bool> updateRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // final lastUpdatedStr = data['Update_Date'] ?? DateTime.now().toString();
        final lastUpdated = DateTime.now(); // Truncgil'den gelen tarih formatı değişken olabilir, anlık alalım

        List<ExchangeRate> exchangeRates = [];

        // USD
        if (data['USD'] != null && data['USD']['Satış'] != null) {
          final val = double.tryParse(data['USD']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'USD'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // EUR
        if (data['EUR'] != null && data['EUR']['Satış'] != null) {
          final val = double.tryParse(data['EUR']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'EUR'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // GBP
        if (data['GBP'] != null && data['GBP']['Satış'] != null) {
          final val = double.tryParse(data['GBP']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'GBP'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // CHF (İsviçre Frangı)
        if (data['CHF'] != null && data['CHF']['Satış'] != null) {
          final val = double.tryParse(data['CHF']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'CHF'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // CNY (Çin Yuanı)
        if (data['CNY'] != null && data['CNY']['Satış'] != null) {
          final val = double.tryParse(data['CNY']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'CNY'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // BRL (Brezilya Reali)
        if (data['BRL'] != null && data['BRL']['Satış'] != null) {
          final val = double.tryParse(data['BRL']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'BRL'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // KRW (Kore Wonu)
        if (data['KRW'] != null && data['KRW']['Satış'] != null) {
          final val = double.tryParse(data['KRW']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'KRW'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // JPY (Japon Yeni)
        if (data['JPY'] != null && data['JPY']['Satış'] != null) {
          final val = double.tryParse(data['JPY']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'JPY'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // SAR (Suudi Arabistan Riyali)
        if (data['SAR'] != null && data['SAR']['Satış'] != null) {
          final val = double.tryParse(data['SAR']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'SAR'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // KWD (Kuveyt Dinarı)
        if (data['KWD'] != null && data['KWD']['Satış'] != null) {
          final val = double.tryParse(data['KWD']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'KWD'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // SILVER (Gümüş)
        if (data['gumus'] != null && data['gumus']['Satış'] != null) {
          final val = double.tryParse(data['gumus']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'SILVER'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        // GOLD (Gram Altın)
        if (data['gram-altin'] != null && data['gram-altin']['Satış'] != null) {
          final val = double.tryParse(data['gram-altin']['Satış'].toString().replaceAll('.', '').replaceAll(',', '.'));
          if (val != null) {
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'GOLD'
              ..rate = val
              ..lastUpdated = lastUpdated);
            
            // G simgesi için de aynısını ekle
            exchangeRates.add(ExchangeRate()
              ..currencyCode = 'G'
              ..rate = val
              ..lastUpdated = lastUpdated);
          }
        }

        await DatabaseService.saveAllExchangeRates(exchangeRates);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('CurrencyService Error: $e');
      return false;
    }
  }

  /// Belirli bir birimin TL karşılığını getir
  static Future<double> getRate(String currencyCode) async {
    if (currencyCode == 'TRY' || currencyCode == '₺' || currencyCode == 'AUTO') return 1.0;
    
    final rates = await DatabaseService.getAllExchangeRates();
    final rateObj = rates.where((r) => r.currencyCode == currencyCode).firstOrNull;
    
    return rateObj?.rate ?? 1.0;
  }
}
