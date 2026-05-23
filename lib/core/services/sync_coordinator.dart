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

  static void scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      unawaited(syncNow());
    });
  }

  static Future<void> syncNow() async {
    if (_isRunning) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final settings = await DatabaseService.getSettings();
    if (!settings.isSyncEnabled) return;

    _isRunning = true;
    try {
      await _syncService.syncAll();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_sync_time', DateTime.now().toIso8601String());
      } catch (e) {
        debugPrint('[SyncCoordinator] Error saving sync timestamp: $e');
      }
      if (kDebugMode) {
        debugPrint('[SyncCoordinator] Sync completed.');
      }
    } catch (e, stack) {
      debugPrint('[SyncCoordinator] Sync error: $e');
      if (kDebugMode) debugPrint('$stack');
    } finally {
      _isRunning = false;
    }
  }
}
