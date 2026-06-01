import 'package:intl/intl.dart';
import '../database/models/exchange_rate.dart';
import '../theme/app_constants.dart';

/// Para birimi ve tutar formatlama yardımları
class CurrencyUtils {

  /// Tutar formatlama (Kısa gösterim)
  static String formatAmount(double val, {String? currencySymbol}) {
    if (val.abs() >= 1000000) {
      final formatted = (val / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return currencySymbol != null ? '$currencySymbol${formatted}M' : '${formatted}M';
    }
    
    // Eğer değer çok küçükse (özellikle altın gibi birimlerde 0 görünmemesi için) ondalıkları göster
    final bool showDecimals = val.abs() > 0 && val.abs() < 1;
    
    return formatFullAmount(val, symbol: currencySymbol, includeDecimals: showDecimals);
  }

  /// Ondalık bakiye gösterimi (Dashboard ve Detaylar için)
  static String formatFullAmount(double val, {String? symbol, bool includeDecimals = true}) {
    // Para birimi kodunu belirle
    final code = symbolToCode(symbol ?? 'TRY');
    
    // JPY ve KRW için ondalık basamak her zaman 0 olmalı
    int decimalDigits = includeDecimals ? 2 : 0;
    if (code == 'JPY' || code == 'KRW') {
      decimalDigits = 0;
    }

    // Locale tespiti (Basit bir mantık: EUR ise de_DE, USD ise en_US, TRY ise tr_TR vb.)
    // Aslında uygulama diline (Intl.defaultLocale) göre formatlamak daha doğru.
    final locale = Intl.defaultLocale ?? 'en_US';

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol ?? '₺',
      decimalDigits: decimalDigits,
    );

    return formatter.format(val);
  }

  /// Tutarı kurlara göre baz birime (TRY) veya başka bir birime çevirir
  static double convert(double amount, String from, String to, List<ExchangeRate> rates) {
    if (from == to) return amount;

    final fromCode = symbolToCode(from);
    final toCode = symbolToCode(to);
    if (fromCode == toCode) return amount;

    // Küresel para birimi (non-TRY) var mı kontrol et (Dinamik Ons tespiti için)
    bool isGlobalCode(String code) {
      return code != 'TRY' &&
             code != '₺' &&
             code != 'AUTO' &&
             code != 'GOLD' &&
             code != 'G' &&
             code != 'SILVER' &&
             code != 'Ag';
    }

    final isGlobal = isGlobalCode(fromCode) || isGlobalCode(toCode);

    // 1. Tutar'ı TRY'ye (Baz birim) getir
    double tryAmount = amount;
    if (fromCode != 'TRY') {
      final fromRate = rates.where((r) => r.currencyCode == fromCode).firstOrNull;
      if (fromRate != null && fromRate.rate > 0) {
        double multiplier = fromRate.rate;
        // Küresel kullanıcılar için altın/gümüşü ons biriminden grama (TRY tabanına) çevir
        if (isGlobal && (fromCode == 'GOLD' || fromCode == 'SILVER')) {
          multiplier *= 31.1034768;
        }
        tryAmount = amount * multiplier;
      }
    }
    
    // 2. TRY tutarını hedef birime çevir
    if (toCode == 'TRY') return tryAmount;
    
    final toRate = rates.where((r) => r.currencyCode == toCode).firstOrNull;
    if (toRate != null && toRate.rate > 0) {
      double divisor = toRate.rate;
      // Küresel kullanıcılar için altını/gümüşü gramdan (TRY tabanından) ons birimine çevir
      if (isGlobal && (toCode == 'GOLD' || toCode == 'SILVER')) {
        divisor *= 31.1034768;
      }
      return tryAmount / divisor;
    }
    
    return tryAmount;
  }

  /// Sembolleri API kodlarıyla eşleştirir
  static String symbolToCode(String symbol) {
    return AppCurrency.getCode(symbol);
  }
}
