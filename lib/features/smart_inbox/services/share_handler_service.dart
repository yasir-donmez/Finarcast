import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../../core/services/subscription_service.dart';
import 'draft_service.dart';
import 'smart_parser_service.dart';

class ShareHandlerService {
  final WidgetRef ref;
  StreamSubscription? _mediaSubscription;
  
  final Function(String message)? onProcessingStarted;
  final Function(DraftTransaction draft)? onProcessingSuccess;
  final Function(String title, String? detail)? onProcessingError;

  ShareHandlerService({
    required this.ref,
    this.onProcessingStarted,
    this.onProcessingSuccess,
    this.onProcessingError,
  });

  /// Listen to sharing intents
  void init() {
    // 1. Listen for intents while the app is in memory (running)
    _mediaSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> files) {
      if (files.isNotEmpty) {
        _handleSharedMedia(files);
      }
    }, onError: (err) {
      debugPrint("❌ ShareHandlerService.getMediaStream error: $err");
    });

    // 2. Handle intent when the app is opened from a cold start (closed)
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) {
      if (files.isNotEmpty) {
        _handleSharedMedia(files);
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  /// Cancel intent listeners
  void dispose() {
    _mediaSubscription?.cancel();
  }

  Future<void> _handleSharedMedia(List<SharedMediaFile> files) async {
    debugPrint('📩 Received shared media files: ${files.length}');
    for (final file in files) {
      final path = file.path;
      if (path.isEmpty) continue;

      if (file.type == SharedMediaType.text || file.type == SharedMediaType.url) {
        // Handle as shared text/url
        await _processSharedText(path);
      } else if (file.type == SharedMediaType.image) {
        // Handle as shared image file
        await _processSharedImage(path);
      } else {
        debugPrint('⚠️ Unsupported shared media type: ${file.type}');
      }
    }
  }

  Future<void> _processSharedText(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    // Check AI Limits
    final subService = ref.read(subscriptionServiceProvider);
    if (subService.usedAiCount >= subService.dailyAiLimit) {
      if (onProcessingError != null) {
        onProcessingError!(
          subService.isPro ? 'Sınırsız Erişim Limiti' : 'Standart Erişim Limiti',
          subService.isPro
              ? 'Sistem güvenliği gereği adil kullanım limitine ulaştınız. Yarın tekrar sınırsız olarak kullanabilirsiniz.'
              : 'Günlük standart yapay zeka analiz kotanızı doldurdunuz. Sınırsız analiz için Genişletilmiş Erişime geçin.',
        );
      }
      return;
    }

    if (onProcessingStarted != null) {
      onProcessingStarted!('Paylaşılan metin analiz ediliyor...');
    }

    debugPrint('🔍 Parsing shared text: "$cleanText"');
    try {
      final draft = await SmartParserService.parseText(cleanText);
      await DraftService.addDraft(draft);
      await ref.read(subscriptionServiceProvider).incrementAiUsage();
      debugPrint('✅ Shared text processed successfully.');
      if (onProcessingSuccess != null) {
        onProcessingSuccess!(draft);
      }
    } catch (e) {
      debugPrint('❌ Error parsing shared text: $e');
      if (onProcessingError != null) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        onProcessingError!(
          'Hata',
          errorMsg.isNotEmpty ? errorMsg : 'İşlem analiz edilirken bir hata oluştu.',
        );
      }
    }
  }

  Future<void> _processSharedImage(String path) async {
    // Check AI Limits
    final subService = ref.read(subscriptionServiceProvider);
    if (subService.usedAiCount >= subService.dailyAiLimit) {
      if (onProcessingError != null) {
        onProcessingError!(
          subService.isPro ? 'Sınırsız Erişim Limiti' : 'Standart Erişim Limiti',
          subService.isPro
              ? 'Sistem güvenliği gereği adil kullanım limitine ulaştınız. Yarın tekrar sınırsız olarak kullanabilirsiniz.'
              : 'Günlük standart yapay zeka analiz kotanızı doldurdunuz. Sınırsız analiz için Genişletilmiş Erişime geçin.',
        );
      }
      return;
    }

    try {
      final ioFile = File(path);
      if (!await ioFile.exists()) {
        debugPrint('❌ Shared file does not exist: $path');
        if (onProcessingError != null) {
          onProcessingError!('Hata', 'Paylaşılan dosya bulunamadı.');
        }
        return;
      }

      if (onProcessingStarted != null) {
        onProcessingStarted!('Fiş taranıyor, bilgiler çıkartılıyor...');
      }

      final bytes = await ioFile.readAsBytes();
      final extension = path.split('.').last.toLowerCase();
      
      String mimeType = 'image/jpeg';
      if (extension == 'png') mimeType = 'image/png';
      if (extension == 'webp') mimeType = 'image/webp';

      debugPrint('🔍 Parsing shared image file: $path ($mimeType)');
      final draft = await SmartParserService.parseReceiptImage(bytes, mimeType);
      if (draft != null) {
        if (draft.amount < 0) {
          if (onProcessingError != null) {
            onProcessingError!(
              'Fiş Okunamadı',
              draft.note ?? 'Yüklenen görselde herhangi bir fiş veya fatura bilgisi tespit edilemedi.',
            );
          }
          return;
        }

        await DraftService.addDraft(draft);
        await ref.read(subscriptionServiceProvider).incrementAiUsage();
        debugPrint('✅ Shared image file processed successfully.');
        if (onProcessingSuccess != null) {
          onProcessingSuccess!(draft);
        }
      } else {
        if (onProcessingError != null) {
          onProcessingError!(
            'Hata',
            'Fiş okunamadı. Lütfen bilgileri el ile girin veya daha net bir fotoğraf çekin.',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error processing shared media file: $e');
      if (onProcessingError != null) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        onProcessingError!(
          'Hata',
          errorMsg.isNotEmpty ? errorMsg : 'Görsel yüklenirken bir hata oluştu.',
        );
      }
    }
  }
}
