import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'draft_service.dart';
import '../../../core/services/custom_category_service.dart';
import '../../../l10n/app_localizations.dart';

class SmartParserService {
  static bool get isAvailable => true;

  static Exception _handleException(Object e, AppLocalizations l10n) {
    final errorStr = e.toString();
    final lowerErrorStr = errorStr.toLowerCase();
    
    // İnternet bağlantı hataları
    if (lowerErrorStr.contains('socketexception') ||
        lowerErrorStr.contains('failed host lookup') ||
        lowerErrorStr.contains('clientexception') ||
        lowerErrorStr.contains('httpexception') ||
        lowerErrorStr.contains('handshakeexception') ||
        lowerErrorStr.contains('network_error') ||
        lowerErrorStr.contains('network error') ||
        lowerErrorStr.contains('network') ||
        lowerErrorStr.contains('authretryablefetchexception')) {
      return Exception(l10n.syncErrorNoInternet);
    }
    
    // Server-side yetkilendirme veya kotalar (Edge Function'dan gelen)
    if (lowerErrorStr.contains('rate limit exceeded') || lowerErrorStr.contains('upgrade your plan')) {
      return Exception(l10n.aiErrorRateLimit);
    }
    if (lowerErrorStr.contains('unauthorized')) {
      return Exception(l10n.aiErrorUnauthorized);
    }
    
    if (lowerErrorStr.contains('quota') || lowerErrorStr.contains('limit') || lowerErrorStr.contains('rate') || lowerErrorStr.contains('429')) {
      return Exception(l10n.aiErrorQuota);
    }
    if (lowerErrorStr.contains('high demand') || lowerErrorStr.contains('503') || lowerErrorStr.contains('unavailable') || lowerErrorStr.contains('busy')) {
      return Exception(l10n.aiErrorBusy);
    }
    if (lowerErrorStr.contains('api key') || lowerErrorStr.contains('key bulunamadı') || lowerErrorStr.contains('key not found') || lowerErrorStr.contains('api_key')) {
      return Exception(l10n.aiErrorApiKey);
    }
    if (lowerErrorStr.contains('timeout') || lowerErrorStr.contains('zaman aşımı')) {
      return Exception(l10n.aiErrorTimeout);
    }
    
    return Exception(l10n.aiErrorGeneric(errorStr.replaceAll('Exception: ', '')));
  }

  /// Serbest metni veya ses transkripsiyonunu analiz eder
  static Future<DraftTransaction> parseText(String text, AppLocalizations l10n) async {
    final id = const Uuid().v4();
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      return DraftTransaction(
        id: id,
        title: '__EMPTY_DRAFT__',
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
        reason: l10n.reasonSmartInput,
        currency: data['currency'],
        isNotificationEnabled: data['isNotificationEnabled'] ?? false,
        notificationReminderDays: data['notificationReminderDays'] ?? 0,
        notificationHour: data['notificationHour'] ?? 9,
        notificationMinute: data['notificationMinute'] ?? 0,
        vaultName: data['vaultName'],
        periodType: _mapAiPeriodType(data['periodType'] ?? 0),
        remainingInstallments: data['remainingInstallments'],
        recurrenceDay: data['recurrenceDay'],
        recurrenceDuration: data['recurrenceDuration'],
      );
    } catch (e) {
      debugPrint('❌ [SmartParserService] AI Parse hatası: $e');
      throw _handleException(e, l10n);
    }
  }

  static int _mapAiPeriodType(int aiType) {
    // Eğer yapay zeka doğrudan 100 ile 499 arasında geçerli bir veri tabanı kodu döndürdüyse doğrudan kabul et
    if (aiType >= 100 && aiType <= 499) {
      return aiType;
    }
    switch (aiType) {
      case 8: // Günlük (eski)
        return 101;
      case 1: // Haftalık (eski)
        return 201;
      case 4: // İki haftada bir (eski)
        return 202;
      case 2: // Aylık (eski)
        return 301;
      case 3: // Yıllık (eski)
        return 401;
      default:
        return 0;
    }
  }

  /// Fiş görselini analiz edip harcama bilgisi çıkarır (Gemini Vision)
  static Future<DraftTransaction?> parseReceiptImage(Uint8List imageBytes, String mimeType, AppLocalizations l10n) async {
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
        title: data['title'] ?? '__RECEIPT_EXPENSE__',
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        categoryId: data['categoryId'] ?? 'exp_grocery_food',
        date: data['date'] != null ? DateTime.tryParse(data['date']) ?? DateTime.now() : DateTime.now(),
        isIncome: false,
        note: data['note'],
        reason: l10n.reasonReceiptScan,
        currency: data['currency'],
      );
    } catch (e) {
      debugPrint('❌ [SmartParserService] Fiş görseli analiz hatası: $e');
      throw _handleException(e, l10n);
    }
  }

  /// Panodaki (Clipboard) metni analiz edip banka SMS'i veya harcama bildirimi olup olmadığını kontrol eder
  static Future<DraftTransaction?> checkAndParseClipboard(String text, AppLocalizations l10n) async {
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
      final parsed = await parseText(cleanText, l10n);
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
          note: parsed.note ?? l10n.noteCapturedFromClipboard,
          reason: l10n.reasonClipboard,
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
    final first = s[0];
    if (first == 'i') return 'İ${s.substring(1)}';
    if (first == 'ı') return 'I${s.substring(1)}';
    return first.toUpperCase() + s.substring(1);
  }
}
