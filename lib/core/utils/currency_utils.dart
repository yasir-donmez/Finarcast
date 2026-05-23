import 'package:intl/intl.dart';
import '../database/models/exchange_rate.dart';

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
    final code = _symbolToCode(symbol ?? 'TRY');
    
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
    
    // 1. Tutar'ı TRY'ye (Baz birim) getir
    double tryAmount = amount;
    if (from != 'TRY' && from != '₺' && from != 'AUTO') {
      final fromCode = _symbolToCode(from);
      final fromRate = rates.where((r) => r.currencyCode == fromCode).firstOrNull;
      if (fromRate != null) {
        tryAmount = amount * fromRate.rate;
      }
    }
    
    // 2. TRY tutarını hedef birime çevir
    if (to == 'TRY' || to == '₺' || to == 'AUTO') return tryAmount;
    
    final toCode = _symbolToCode(to);
    final toRate = rates.where((r) => r.currencyCode == toCode).firstOrNull;
    if (toRate != null) {
      return tryAmount / toRate.rate;
    }
    
    return tryAmount;
  }

  /// Sembolleri API kodlarıyla eşleştirir
  static String _symbolToCode(String symbol) {
    switch (symbol) {
      case r'$': return 'USD';
      case '€': return 'EUR';
      case '£': return 'GBP';
      case '¥': return 'JPY';
      case '₩': return 'KRW';
      case '元': return 'CNY';
      case r'R$': return 'BRL';
      case 'Fr': return 'CHF';
      case '₺': return 'TRY';
      case 'G':
      case 'ALTIN': return 'GOLD';
      case 'Ag': return 'SILVER';
      case 'SR': return 'SAR';
      case 'KD': return 'KWD';
      default: return symbol;
    }
  }
}
