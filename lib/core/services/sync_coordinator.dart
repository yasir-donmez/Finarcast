import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_service.dart';
import 'sync_service.dart';

class SyncCoordinator {
  SyncCoordinator._();

  static Timer? _debounce;
  static bool _isRunning = false;
  static final SyncService _syncService = SyncService();

  /// Son senkronizasyon sonucu (UI'dan okunabilir)
  static SyncResult? lastResult;
  static String? lastError;

  static void scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      unawaited(syncNow());
    });
  }

  static Future<bool> syncNow() async {
    if (_isRunning) return false;
    lastError = null;
    lastResult = null;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      lastError = "Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.";
      return false;
    }

    final settings = await DatabaseService.getSettings();
    if (!settings.isSyncEnabled) {
      lastError = "Eşitleme ayarı kapalı.";
      return false;
    }

    // Pro üyelik kontrolü (Sadece Pro üyeler eşitleyebilir)
    final prefs = await SharedPreferences.getInstance();
    final isPro = prefs.getBool('Finarcast_is_pro_user') ?? false;
    if (!isPro) {
      lastError = "Bulut eşitleme özelliği sadece Premium üyeler içindir.";
      return false;
    }

    _isRunning = true;
    try {
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
        return true;
      } else {
        lastError = result.summary;
        return result.hasPartialErrors;
      }
    } catch (e, stack) {
      debugPrint('[SyncCoordinator] Kritik sync hatası: $e');
      if (kDebugMode) debugPrint('$stack');
      lastError = _parseError(e);
      return false;
    } finally {
      _isRunning = false;
    }
  }

  static String _parseError(dynamic e) {
    if (e is PostgrestException) {
      return "Bulut Hatası (${e.code}): ${e.message} ${e.details ?? ''}".trim();
    }
    if (e is AuthException) {
      return "Kimlik Doğrulama Hatası (${e.statusCode}): ${e.message}";
    }

    final errStr = e.toString().toLowerCase();

    if (errStr.contains('540') || errStr.contains('paused') || errStr.contains('project_paused')) {
      return "Bulut veritabanı projesi duraklatılmış (Project Paused). Lütfen Supabase panelinizden projeyi tekrar aktifleştirin.";
    }
    if (errStr.contains('401') || errStr.contains('unauthorized') || errStr.contains('jwt expired') || errStr.contains('invalid token')) {
      return "Oturum süreniz dolmuş olabilir. Lütfen Ayarlar > Oturumu Kapat seçeneğiyle çıkış yapıp tekrar giriş yapın.";
    }
    if (errStr.contains('socketexception') || errStr.contains('network') || errStr.contains('connection failed') || errStr.contains('httpclientexception') || errStr.contains('host lookup failed')) {
      return "İnternet bağlantısı kurulamadı. Lütfen internet bağlantınızı kontrol edin.";
    }
    if (errStr.contains('relation') && errStr.contains('does not exist')) {
      return "Veritabanı tabloları bulunamadı. Lütfen Supabase SQL Editor'da setup.sql betiğini çalıştırın.";
    }
    if (errStr.contains('permission denied') || errStr.contains('42501') || errStr.contains('row level security') || errStr.contains('rls')) {
      return "Veritabanı erişim yetki hatası (RLS). Lütfen Supabase tablolarında RLS politikalarını doğru yapılandırdığınızdan emin olun.";
    }

    return "Beklenmeyen hata: $e";
  }
}
