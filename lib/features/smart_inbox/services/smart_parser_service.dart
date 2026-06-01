import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'draft_service.dart';
import '../../../core/services/custom_category_service.dart';

class SmartParserService {
  static bool get isAvailable => true;

  static Exception _handleException(Object e) {
    final errorStr = e.toString().toLowerCase();
    
    if (errorStr.contains('quota') || errorStr.contains('limit') || errorStr.contains('rate') || errorStr.contains('429')) {
      return Exception('Yapay Zeka kullanım limitiniz (kota) doldu. Lütfen biraz bekleyip tekrar deneyin.');
    }
    if (errorStr.contains('high demand') || errorStr.contains('503') || errorStr.contains('unavailable') || errorStr.contains('busy')) {
      return Exception('Yapay Zeka sunucusu şu an çok yoğun. Lütfen birkaç saniye sonra tekrar deneyin.');
    }
    if (errorStr.contains('api key') || errorStr.contains('key bulunamadı') || errorStr.contains('key not found') || errorStr.contains('api_key')) {
      return Exception('Yapay Zeka API Anahtarı geçersiz veya bulunamadı. Lütfen ayarlarınızı kontrol edin.');
    }
    if (errorStr.contains('timeout') || errorStr.contains('zaman aşımı')) {
      return Exception('İstek zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.');
    }
    
    return Exception('Yapay Zeka analizi başarısız oldu: ${e.toString().replaceAll('Exception: ', '')}');
  }

  /// Serbest metni veya ses transkripsiyonunu analiz eder
  static Future<DraftTransaction> parseText(String text) async {
    final id = const Uuid().v4();
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return DraftTransaction(
        id: id,
        title: 'Boş Taslak',
        amount: 0.0,
        date: DateTime.now(),
      );
    }

    try {
      final customCategories = await CustomCategoryService.getAllCustomSubcategories();
      
      final response = await Supabase.instance.client.functions.invoke(
        'parse_transaction',
        body: {
          'text': cleanText,
          'customCategories': customCategories,
        },
      ).timeout(const Duration(seconds: 25));

      if (response.status != 200) {
        throw Exception(response.data?['error'] ?? 'Hata kodu: ${response.status}');
      }

      final Map<String, dynamic> data = response.data;

      return DraftTransaction(
        id: id,
        title: data['title'] ?? _capitalize(cleanText),
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        minAmount: data['minAmount'] != null ? (data['minAmount'] as num).toDouble() : null,
        maxAmount: data['maxAmount'] != null ? (data['maxAmount'] as num).toDouble() : null,
        categoryId: data['categoryId'] ?? 'exp_other_general',
        date: data['date'] != null ? DateTime.tryParse(data['date']) ?? DateTime.now() : DateTime.now(),
        isIncome: data['isIncome'] ?? false,
        note: data['note'],
        reason: 'Hızlı Metin Girişi',
        currency: data['currency'],
        isNotificationEnabled: data['isNotificationEnabled'] ?? false,
        notificationReminderDays: data['notificationReminderDays'] ?? 0,
        notificationHour: data['notificationHour'] ?? 9,
        notificationMinute: data['notificationMinute'] ?? 0,
        vaultName: data['vaultName'],
        periodType: data['periodType'] ?? 0,
        remainingInstallments: data['remainingInstallments'],
        recurrenceDay: data['recurrenceDay'],
        recurrenceDuration: data['recurrenceDuration'],
      );
    } catch (e) {
      debugPrint('❌ [SmartParserService] AI Parse hatası: $e');
      throw _handleException(e);
    }
  }

  /// Fiş görselini analiz edip harcama bilgisi çıkarır (Gemini Vision)
  static Future<DraftTransaction?> parseReceiptImage(Uint8List imageBytes, String mimeType) async {
    try {
      final customCategories = await CustomCategoryService.getAllCustomSubcategories();
      final base64Image = base64Encode(imageBytes);

      final response = await Supabase.instance.client.functions.invoke(
        'parse_transaction',
        body: {
          'image': base64Image,
          'mimeType': mimeType,
          'customCategories': customCategories,
        },
      ).timeout(const Duration(seconds: 35));

      if (response.status != 200) {
        throw Exception(response.data?['error'] ?? 'Hata kodu: ${response.status}');
      }

      final Map<String, dynamic> data = response.data;
      final id = const Uuid().v4();

      return DraftTransaction(
        id: id,
        title: data['title'] ?? 'Fiş Harcaması',
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        categoryId: data['categoryId'] ?? 'exp_grocery_food',
        date: data['date'] != null ? DateTime.tryParse(data['date']) ?? DateTime.now() : DateTime.now(),
        isIncome: false,
        note: data['note'],
        reason: 'Fiş Fotoğrafı',
        currency: data['currency'],
      );
    } catch (e) {
      debugPrint('❌ [SmartParserService] Fiş görseli analiz hatası: $e');
      throw _handleException(e);
    }
  }

  /// Panodaki (Clipboard) metni analiz edip banka SMS'i veya harcama bildirimi olup olmadığını kontrol eder
  static Future<DraftTransaction?> checkAndParseClipboard(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || cleanText.length < 15) return null;

    // Basit bir ön kontrol: İçinde "harcama", "ödeme", "tutar", "TL", "lira", "nolu kart", "hesabınızdan" vb. geçiyor mu?
    final trText = cleanText.toLowerCase();
    final isFinancial = trText.contains('tl') ||
        trText.contains('lira') ||
        trText.contains('harcama') ||
        trText.contains('ödeme') ||
        trText.contains('kart') ||
        trText.contains('hesabından') ||
        trText.contains('para transferi');

    if (!isFinancial) return null;

    try {
      // AI yardımıyla bu SMS'i çözümleriz
      final parsed = await parseText(cleanText);
      if (parsed.amount > 0 || parsed.minAmount != null) {
        return DraftTransaction(
          id: parsed.id,
          title: parsed.title,
          amount: parsed.amount,
          minAmount: parsed.minAmount,
          maxAmount: parsed.maxAmount,
          categoryId: parsed.categoryId,
          date: parsed.date,
          isIncome: parsed.isIncome,
          note: parsed.note ?? 'Kopyalanan Metinden Yakalandı',
          reason: 'Pano Bildirimi',
          currency: parsed.currency,
          isNotificationEnabled: parsed.isNotificationEnabled,
          notificationReminderDays: parsed.notificationReminderDays,
          notificationHour: parsed.notificationHour,
          notificationMinute: parsed.notificationMinute,
          vaultName: parsed.vaultName,
          periodType: parsed.periodType,
          remainingInstallments: parsed.remainingInstallments,
          recurrenceDay: parsed.recurrenceDay,
          recurrenceDuration: parsed.recurrenceDuration,
        );
      }
    } catch (_) {}
    return null;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
