import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_service.dart';
import 'sync_service.dart';
import 'materialization_service.dart';
import 'currency_service.dart';
import '../../l10n/app_localizations.dart';

class SyncCoordinator {
  SyncCoordinator._();

  static Timer? _debounce;
  static bool _isRunning = false;
  static final SyncService _syncService = SyncService();

  /// Son senkronizasyon sonucu (UI'dan okunabilir)
  static SyncResult? lastResult;
  static String? lastError;

  // Yeniden deneme (retry) yönetimi
  static int _retryCount = 0;
  static Timer? _retryTimer;

  static void scheduleSync() {
    _debounce?.cancel();
    _retryTimer?.cancel();
    _retryCount = 0; // Manuel veya tetiklemeli yeni istek geldiğinde sayacı sıfırla
    _debounce = Timer(const Duration(seconds: 2), () {
      unawaited(syncNow());
    });
  }

  static Future<bool> syncNow([AppLocalizations? l10n]) async {
    if (_isRunning) return false;
    _isRunning = true;

    try {
      lastError = null;
      lastResult = null;

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        lastError = l10n != null
            ? l10n.sessionNotFound
            : "Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.";
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final isPro = prefs.getBool('Finarcast_is_pro_user') ?? false;
      final settings = await DatabaseService.getSettings();

      // Eğer kullanıcı Premium değilse veya genel veri eşitleme kapalıysa sadece ayarları eşitleriz.
      // Premium ve veri eşitleme açık olan kullanıcılar için syncAll zaten bu işlemi yapacaktır.
      if (!isPro || !settings.isSyncEnabled) {
        try {
          debugPrint('[SyncCoordinator] Arka planda sadece ayarlar eşitleniyor...');
          final settingsResult = await _syncService.syncSettingsOnly(user.id);
          lastResult = settingsResult;
        } catch (e) {
          debugPrint('[SyncCoordinator] syncSettingsOnly hatası: $e');
        }
      }

      if (!settings.isSyncEnabled) {
        lastError = l10n != null
            ? l10n.syncErrorDisabled
            : "Eşitleme ayarı kapalı.";
        return false;
      }

      if (!isPro) {
        lastError = l10n != null
            ? l10n.syncErrorPremiumRequired
            : "Bulut eşitleme özelliği sadece Premium üyeler içindir.";
        return false;
      }

      // Delta sync: son başarılı senkronizasyon zamanını al
      final lastSyncStr = prefs.getString('last_sync_time');
      DateTime? lastSyncTime;
      if (lastSyncStr != null) {
        lastSyncTime = DateTime.tryParse(lastSyncStr);
      }

      final result = await _syncService.syncAll(lastSyncTime: lastSyncTime);
      lastResult = result;

      if (kDebugMode) {
        debugPrint('[SyncCoordinator] ${result.summary}');
        for (final err in result.errors) {
          debugPrint('[SyncCoordinator] Hata: $err');
        }
      }

      if (result.isFullySuccessful) {
        // Sadece tamamen başarılı olunca zamanı kaydet.
        // Kısmi hata varsa kaydetme → sonraki sync full sync yapıp
        // başarısız kayıtları tekrar dener.
        await prefs.setString('last_sync_time', DateTime.now().toIso8601String());
        
        // Eşitleme sonrası yeni şablonlar geldiyse tekrarlı işlemleri somutlaştır
        debugPrint('[SyncCoordinator] Eşitleme sonrası materialization tetikleniyor...');
        await MaterializationService.materializeAll();

        // Eşitleme sonrası yeni para birimleri gelebileceği için kurları arka planda güncelle
        debugPrint('[SyncCoordinator] Eşitleme sonrası kurlar güncelleniyor...');
        unawaited(CurrencyService.updateRates(force: false));

        _retryCount = 0;
        _retryTimer?.cancel();
        return true;
      } else {
        lastError = l10n != null ? result.getLocalizedSummary(l10n) : result.summary;
        _scheduleRetry(l10n);
        return result.hasPartialErrors;
      }
    } catch (e, stack) {
      debugPrint('[SyncCoordinator] Kritik sync hatası: $e');
      if (kDebugMode) debugPrint('$stack');
      lastError = _parseError(e, l10n);
      _scheduleRetry(l10n);
      return false;
    } finally {
      _isRunning = false;
    }
  }

  /// Giriş yapıldığında veya premium statüsü doğrulandığında ayarları senkronize et
  static Future<void> syncSettingsOnLoginOrPro() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      debugPrint('[SyncCoordinator] Giriş/Premium algılandı, ayarlar buluttan çekiliyor...');
      final settingsUpdated = await _syncService.pullSettingsOnLogin(user.id);
      if (settingsUpdated) {
        debugPrint('[SyncCoordinator] Bulut ayarları başarıyla yerel veritabanına uygulandı.');
        final settings = await DatabaseService.getSettings();
        if (settings.isSyncEnabled) {
          debugPrint('[SyncCoordinator] Ayarlarda bulut eşitleme etkin, tam senkronizasyon başlatılıyor...');
          unawaited(syncNow());
        }
      }
    } catch (e) {
      debugPrint('[SyncCoordinator] syncSettingsOnLoginOrPro hatası: $e');
    }
  }

  static String _parseError(dynamic e, [AppLocalizations? l10n]) {
    if (e is PostgrestException) {
      return l10n != null
          ? l10n.syncErrorPostgrest(e.code ?? '500', e.message)
          : "Bulut Hatası (${e.code}): ${e.message} ${e.details ?? ''}".trim();
    }
    if (e is AuthException) {
      return l10n != null
          ? l10n.syncErrorAuth(e.statusCode ?? '500', e.message)
          : "Kimlik Doğrulama Hatası (${e.statusCode}): ${e.message}";
    }

    final errStr = e.toString().toLowerCase();

    if (errStr.contains('540') || errStr.contains('paused') || errStr.contains('project_paused')) {
      return l10n != null
          ? l10n.syncErrorProjectPaused
          : "Bulut veritabanı projesi duraklatılmış (Project Paused). Lütfen Supabase panelinizden projeyi tekrar aktifleştirin.";
    }
    if (errStr.contains('401') || errStr.contains('unauthorized') || errStr.contains('jwt expired') || errStr.contains('invalid token')) {
      return l10n != null
          ? l10n.syncErrorSessionExpired
          : "Oturum süreniz dolmuş olabilir. Lütfen Ayarlar > Oturumu Kapat seçeneğiyle çıkış yapıp tekrar giriş yapın.";
    }
    if (errStr.contains('socketexception') || errStr.contains('network') || errStr.contains('connection failed') || errStr.contains('httpclientexception') || errStr.contains('host lookup failed')) {
      return l10n != null
          ? l10n.syncErrorNoInternet
          : "İnternet bağlantısı kurulamadı. Lütfen internet bağlantınızı kontrol edin.";
    }
    if (errStr.contains('relation') && errStr.contains('does not exist')) {
      return l10n != null
          ? l10n.syncErrorTablesMissing
          : "Veritabanı tabloları bulunamadı. Lütfen Supabase SQL Editor'da setup.sql betiğini çalıştırın.";
    }
    if (errStr.contains('permission denied') || errStr.contains('42501') || errStr.contains('row level security') || errStr.contains('rls')) {
      return l10n != null
          ? l10n.syncErrorPermissionDenied
          : "Veritabanı erişim yetki hatası (RLS). Lütfen Supabase tablolarında RLS politikalarını doğru yapılandırdığınızdan emin olun.";
    }

    return l10n != null ? l10n.syncErrorUnexpected(e.toString()) : "Beklenmeyen hata: $e";
  }

  /// Hatanın yeniden denenebilir (retryable) bir hata olup olmadığını belirler
  static bool _isRetryableError(String? error, AppLocalizations? l10n) {
    if (error == null) return false;

    final nonRetryableKeywords = [
      'oturumu bulunamadı', // sessionNotFound
      'ayarı kapalı', // syncErrorDisabled
      'sadece premium üyeler', // syncErrorPremiumRequired
      'duraklatılmış', // syncErrorProjectPaused
      'tabloları bulunamadı', // syncErrorTablesMissing
      'yetki hatası', // syncErrorPermissionDenied
      'süreniz dolmuş olabilir', // syncErrorSessionExpired
    ];

    if (l10n != null) {
      if (error == l10n.sessionNotFound ||
          error == l10n.syncErrorDisabled ||
          error == l10n.syncErrorPremiumRequired ||
          error == l10n.syncErrorProjectPaused ||
          error == l10n.syncErrorTablesMissing ||
          error == l10n.syncErrorPermissionDenied ||
          error == l10n.syncErrorSessionExpired) {
        return false;
      }
    }

    final errLower = error.toLowerCase();
    for (final keyword in nonRetryableKeywords) {
      if (errLower.contains(keyword)) {
        return false;
      }
    }

    return true;
  }

  /// Exponential backoff ile yeniden deneme planlar
  static void _scheduleRetry([AppLocalizations? l10n]) {
    if (!_isRetryableError(lastError, l10n)) {
      debugPrint('[SyncCoordinator] Kalıcı hata nedeniyle otomatik yeniden deneme iptal edildi: $lastError');
      return;
    }

    _retryTimer?.cancel();
    if (_retryCount >= 5) {
      debugPrint('[SyncCoordinator] Maksimum yeniden deneme sınırına ulaşıldı (5). Otomatik yeniden deneme durduruldu.');
      return;
    }

    _retryCount++;
    // Exponential backoff: 5s, 10s, 20s, 40s, 80s
    final seconds = 5 * (1 << (_retryCount - 1));
    debugPrint('[SyncCoordinator] Senkronizasyon başarısız. Geri çekilme süresiyle ($seconds sn) yeniden deneme planlanıyor (Deneme: $_retryCount)...');

    _retryTimer = Timer(Duration(seconds: seconds), () {
      unawaited(syncNow(l10n));
    });
  }
}
