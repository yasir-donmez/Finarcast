import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../database/database_service.dart';
import 'db_providers.dart';
import 'settings_provider.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuthController(this._ref) : super(const AsyncData<void>(null));

  Future<void> signOut() async {
    state = const AsyncLoading<void>();
    try {
      // 1. Önce abonelikten çık
      await _ref.read(subscriptionServiceProvider).logOut();
      
      // 2. Veritabanını temizle
      await DatabaseService.clearAllData();
      
      // 3. Tercihleri sıfırla
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('Finarcast_is_guest_mode', false);
      
      _ref.read(guestModeProvider.notifier).state = false;
      _ref.invalidate(transactionsStreamProvider);
      _ref.invalidate(vaultsStreamProvider);
      _ref.invalidate(settingsProvider);
      _ref.invalidate(subscriptionServiceProvider);

      // 4. En son oturumu kapat (bu işlem UI'ı değiştirecektir)
      await _ref.read(authServiceProvider).signOut();
      state = const AsyncData<void>(null);
    } catch (e, stack) {
      state = AsyncError<void>(e, stack);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading<void>();
    try {
      // 1. Önce abonelikten çık
      await _ref.read(subscriptionServiceProvider).logOut();
      
      // 2. Veritabanını temizle
      await DatabaseService.clearAllData();
      
      // 3. Tercihleri sıfırla
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('Finarcast_is_guest_mode', false);
      
      _ref.read(guestModeProvider.notifier).state = false;
      _ref.invalidate(transactionsStreamProvider);
      _ref.invalidate(vaultsStreamProvider);
      _ref.invalidate(settingsProvider);
      _ref.invalidate(subscriptionServiceProvider);

      // 4. Hesabı ve oturumu sil (bu işlem UI'ı değiştirecektir)
      await _ref.read(authServiceProvider).deleteAccount();
      state = const AsyncData<void>(null);
    } catch (e, stack) {
      state = AsyncError<void>(e, stack);
      rethrow;
    }
  }

  Future<void> continueAsGuest() async {
    state = const AsyncLoading<void>();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('Finarcast_is_pro_user', false);
      await prefs.setBool('Finarcast_is_guest_mode', true);
      
      try {
        await _ref.read(subscriptionServiceProvider).setProStatus(false);
      } catch (_) {}
      
      _ref.read(guestModeProvider.notifier).state = true;
      _ref.invalidate(settingsProvider);
      state = const AsyncData<void>(null);
    } catch (e, stack) {
      state = AsyncError<void>(e, stack);
      rethrow;
    }
  }

  Future<void> exitGuestMode() async {
    state = const AsyncLoading<void>();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('Finarcast_is_guest_mode', false);
      _ref.read(guestModeProvider.notifier).state = false;
      state = const AsyncData<void>(null);
    } catch (e, stack) {
      state = AsyncError<void>(e, stack);
      rethrow;
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});
