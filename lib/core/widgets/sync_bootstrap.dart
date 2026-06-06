import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import '../services/sync_coordinator.dart';
import '../services/currency_service.dart';
import '../services/subscription_service.dart';

class SyncBootstrap extends ConsumerStatefulWidget {
  const SyncBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncBootstrap> createState() => _SyncBootstrapState();
}

class _SyncBootstrapState extends ConsumerState<SyncBootstrap>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _trySync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _trySync();
      // Uygulama arka plandan geldiğinde döviz kurlarını güncelle
      CurrencyService.updateRates();
    }
  }

  Future<void> _trySync() async {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    if (!isLoggedIn) return;
    await SyncCoordinator.syncNow();
    if (mounted) {
      await ref.read(settingsProvider.notifier).reloadFromDb();
    }
  }

  Future<void> _trySyncSettings() async {
    await SyncCoordinator.syncSettingsOnLoginOrPro();
    if (mounted) {
      await ref.read(settingsProvider.notifier).reloadFromDb();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(settingsProvider.select((s) => s.isSyncEnabled),
        (prev, next) {
      if (next && prev != next) {
        unawaited(_trySync());
      }
    });

    ref.listen<bool>(subscriptionServiceProvider.select((s) => s.isPro),
        (prev, next) {
      if (next && prev != next) {
        unawaited(_trySyncSettings());
      }
    });

    ref.listen(authStateProvider, (prev, next) {
      if (next.hasValue && next.value!.session != null) {
        unawaited(_trySyncSettings());
        unawaited(_trySync());
      }
    });

    return widget.child;
  }
}
