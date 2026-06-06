import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';
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
        onProcessingError!('LIMIT_EXCEEDED', '');
      }
      return;
    }

    final settings = ref.read(settingsProvider);
    final l10n = await AppLocalizations.delegate.load(Locale(settings.languageCode));

    if (onProcessingStarted != null) {
      onProcessingStarted!(l10n.aiAnalyzingExpense);
    }

    debugPrint('🔍 Parsing shared text: "$cleanText"');
    try {
      final draft = await SmartParserService.parseText(cleanText, l10n);
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
          l10n.error,
          errorMsg.isNotEmpty ? errorMsg : l10n.analysisError,
        );
      }
    }
  }

  Future<void> _processSharedImage(String path) async {
    // Check AI Limits
    final subService = ref.read(subscriptionServiceProvider);
    if (subService.usedAiCount >= subService.dailyAiLimit) {
      if (onProcessingError != null) {
        onProcessingError!('LIMIT_EXCEEDED', '');
      }
      return;
    }

    final settings = ref.read(settingsProvider);
    final l10n = await AppLocalizations.delegate.load(Locale(settings.languageCode));

    try {
      final ioFile = File(path);
      if (!await ioFile.exists()) {
        debugPrint('❌ Shared file does not exist: $path');
        if (onProcessingError != null) {
          onProcessingError!(l10n.error, l10n.receiptReadError);
        }
        return;
      }

      if (onProcessingStarted != null) {
        onProcessingStarted!(l10n.scanningReceipt);
      }

      final bytes = await ioFile.readAsBytes();
      final extension = path.split('.').last.toLowerCase();
      
      String mimeType = 'image/jpeg';
      if (extension == 'png') mimeType = 'image/png';
      if (extension == 'webp') mimeType = 'image/webp';

      debugPrint('🔍 Parsing shared image file: $path ($mimeType)');
      final draft = await SmartParserService.parseReceiptImage(bytes, mimeType, l10n);
      if (draft != null) {
        if (draft.amount < 0) {
          if (onProcessingError != null) {
            onProcessingError!(
              l10n.receiptUnreadable,
              draft.note ?? l10n.receiptUnreadableDesc,
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
            l10n.error,
            l10n.receiptReadError,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error processing shared media file: $e');
      if (onProcessingError != null) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        onProcessingError!(
          l10n.error,
          errorMsg.isNotEmpty ? errorMsg : l10n.imageUploadError,
        );
      }
    }
  }
}
