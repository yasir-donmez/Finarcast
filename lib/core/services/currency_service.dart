import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../database/database_service.dart';
import '../database/models/exchange_rate.dart';

class CurrencyService {
  // Ücretsiz ve Anahtar Gerektirmeyen Yerel API (Emtialar ve yedek kurlar için)
  static const String _baseUrl = 'https://finans.truncgil.com/today.json';

  /// Kurları internetten çeker ve veritabanını günceller
  static Future<bool> updateRates() async {
    final lastUpdated = DateTime.now();
    final Map<String, double> mergedRates = {};
    bool anySuccessfulFetch = false;

    // 1. FRANKFURTER API FETCH (Küresel Kurlar için Birincil Kaynak)
    try {
      debugPrint('🌍 [CurrencyService] Frankfurter API kurları çekiliyor...');
      final response = await http
          .get(Uri.parse('https://api.frankfurter.app/latest'))
          .timeout(const Duration(seconds: 8));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final base = data['base'] as String? ?? 'EUR';
        final ratesObj = data['rates'] as Map<String, dynamic>?;
        
        if (ratesObj != null) {
          // Kurları TRY tabanına eşitlemek için TRY'nin baz birimdeki değerini buluyoruz
          double? tryRate;
          if (base == 'TRY') {
            tryRate = 1.0;
          } else if (ratesObj.containsKey('TRY')) {
            tryRate = (ratesObj['TRY'] as num).toDouble();
          }

          if (tryRate != null && tryRate > 0) {
            anySuccessfulFetch = true;
            debugPrint('✅ [CurrencyService] Frankfurter API başarıyla alındı. TRY Baz Oranı: $tryRate');
            
            // Baz para biriminin TRY cinsinden değeri
            if (base != 'TRY') {
              mergedRates[base] = tryRate;
            }

            // Diğer desteklenen kurların TRY cinsinden değerleri
            final targetCodes = ['USD', 'EUR', 'GBP', 'CHF', 'CNY', 'BRL', 'KRW', 'JPY'];
            for (final code in targetCodes) {
              if (code == base) continue;
              if (ratesObj.containsKey(code)) {
                final cVal = (ratesObj[code] as num).toDouble();
                if (cVal > 0) {
                  mergedRates[code] = tryRate / cVal;
                }
              }
            }
          }
        }
      } else {
        debugPrint('⚠️ [CurrencyService] Frankfurter API hata kodu döndürdü: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [CurrencyService] Frankfurter API başarısız oldu (Truncgil yedeklenecek): $e');
    }

    // 2. TRUNCGIL API FETCH (Gram Altın, Gümüş, SAR, KWD ve Genel Yedek için)
    try {
      debugPrint('🇹🇷 [CurrencyService] Truncgil API kurları çekiliyor...');
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        anySuccessfulFetch = true;
        debugPrint('✅ [CurrencyService] Truncgil API başarıyla alındı.');

        // Gram Altın ve Gümüş (Emtialar)
        final goldVal = _parseTruncgilValue(data['gram-altin']);
        if (goldVal != null && goldVal > 0) {
          mergedRates['GOLD'] = goldVal;
        }
        
        final silverVal = _parseTruncgilValue(data['gumus']);
        if (silverVal != null && silverVal > 0) {
          mergedRates['SILVER'] = silverVal;
        }

        // Frankfurter'ın desteklemediği popüler kurlar (SAR, KWD)
        final sarVal = _parseTruncgilValue(data['SAR']);
        if (sarVal != null && sarVal > 0) {
          mergedRates['SAR'] = sarVal;
        }
        
        final kwdVal = _parseTruncgilValue(data['KWD']);
        if (kwdVal != null && kwdVal > 0) {
          mergedRates['KWD'] = kwdVal;
        }

        // Eğer Frankfurter başarısız olduysa veya eksik kur kaldıysa Truncgil kurlarını yedek olarak ekle
        final fallbackCodes = {
          'USD': 'USD',
          'EUR': 'EUR',
          'GBP': 'GBP',
          'CHF': 'CHF',
          'CNY': 'CNY',
          'BRL': 'BRL',
          'KRW': 'KRW',
          'JPY': 'JPY',
        };

        fallbackCodes.forEach((dbCode, apiCode) {
          if (!mergedRates.containsKey(dbCode)) {
            final val = _parseTruncgilValue(data[apiCode]);
            if (val != null && val > 0) {
              mergedRates[dbCode] = val;
            }
          }
        });
      } else {
        debugPrint('⚠️ [CurrencyService] Truncgil API hata kodu döndürdü: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [CurrencyService] Truncgil API başarısız oldu: $e');
    }

    // 3. VERİTABANINA KAYDETME VE ESKİ VERİLERİ KORUMA MANTIĞI
    if (anySuccessfulFetch && mergedRates.isNotEmpty) {
      try {
        final existingRates = await DatabaseService.getAllExchangeRates();
        List<ExchangeRate> ratesToSave = [];

        // Desteklenen tüm kur kodları listesi
        final allCodes = {
          'USD', 'EUR', 'GBP', 'CHF', 'CNY', 'BRL', 'KRW', 'JPY', 'SAR', 'KWD', 'GOLD', 'SILVER'
        };

        for (final code in allCodes) {
          double? rateVal = mergedRates[code];
          
          // Eğer son denemede bu kur hiçbir API'den çekilemediyse, veritabanındaki eski değerini koru
          if (rateVal == null || rateVal <= 0) {
            final oldRate = existingRates.where((r) => r.currencyCode == code).firstOrNull;
            if (oldRate != null && oldRate.rate > 0) {
              rateVal = oldRate.rate;
              debugPrint('ℹ️ [CurrencyService] $code için yeni veri alınamadı, eski kur korundu: $rateVal');
            }
          }

          if (rateVal != null && rateVal > 0) {
            ratesToSave.add(ExchangeRate()
              ..currencyCode = code
              ..rate = rateVal
              ..lastUpdated = lastUpdated);
          }
        }

        if (ratesToSave.isNotEmpty) {
          await DatabaseService.saveAllExchangeRates(ratesToSave);
          debugPrint('💾 [CurrencyService] Toplam ${ratesToSave.length} kur veritabanına başarıyla kaydedildi.');
          return true;
        }
      } catch (dbError) {
        debugPrint('❌ [CurrencyService] Veritabanı kayıt hatası: $dbError');
      }
    }

    return false;
  }

  /// Truncgil API'sinden gelen Türkçe formatlı sayıları parse eder
  static double? _parseTruncgilValue(dynamic valObj) {
    if (valObj == null || valObj['Satış'] == null) return null;
    try {
      final cleanStr = valObj['Satış']
          .toString()
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.tryParse(cleanStr);
    } catch (_) {
      return null;
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
