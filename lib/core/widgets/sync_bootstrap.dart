import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/settings_provider.dart';
import '../providers/db_providers.dart';
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
  Timer? _syncDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _trySyncSettings();
      await _trySync();
    });
  }

  @override
  void dispose() {
    _syncDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _debouncedSync();
      // Uygulama arka plandan geldiğinde döviz kurlarını güncelle
      CurrencyService.updateRates();
    }
  }

  /// Birden fazla kaynaktan gelen eşzamanlı sync tetiklemelerini önler.
  /// 500ms debounce ile son tetiklemeyi bekleyip tek bir sync çalıştırır.
  void _debouncedSync() {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(milliseconds: 500), () async {
      await _trySyncSettings();
      await _trySync();
    });
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
    ref.listen(exchangeRatesProvider, (prev, next) {
      if (next.hasValue) {
        final rates = next.value!;
        final now = DateTime.now();
        if (rates.isEmpty) {
          debugPrint('ℹ️ [SyncBootstrap] Döviz kurları veritabanında bulunamadı. Otomatik güncelleniyor...');
          CurrencyService.updateRates(force: false);
        } else {
          final lastUpdate = rates.first.lastUpdated;
          if (now.difference(lastUpdate).inHours >= 24) {
            debugPrint('ℹ️ [SyncBootstrap] Döviz kurları 24 saatten eski. Otomatik güncelleniyor...');
            CurrencyService.updateRates(force: false);
          }
        }
      }
    });

    ref.listen<bool>(settingsProvider.select((s) => s.isSyncEnabled),
        (prev, next) {
      if (next && prev != next) {
        _debouncedSync();
      }
    });

    // Premium durumu değiştiğinde tam senkronizasyon başlat.
    // Önceki hatalı davranış: sadece _trySyncSettings çağrılıyordu ve
    // ayarlar zaten çekilmişse syncNow asla tetiklenmiyordu.
    ref.listen<bool>(subscriptionServiceProvider.select((s) => s.isPro),
        (prev, next) {
      if (next && prev != next) {
        debugPrint('[SyncBootstrap] ✅ Premium aktif oldu, tam senkronizasyon tetikleniyor...');
        _debouncedSync();
      }
    });

    ref.listen(authStateProvider, (prev, next) {
      if (next.hasValue && next.value!.session != null) {
        _debouncedSync();
      }
    });

    return widget.child;
  }
}

