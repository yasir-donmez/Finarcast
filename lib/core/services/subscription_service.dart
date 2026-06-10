import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SubscriptionTier { free, pro }

enum SubscriptionPeriod { monthly, yearly }

/// Finarcast Abonelik Servisi (Subscription Service).
/// RevenueCat entegrasyonu ile gerçek ödeme işlemlerini yönetir.
class SubscriptionService extends ChangeNotifier {
  static const String _isProKey = 'Finarcast_is_pro_user';

  // RevenueCat API Anahtarları (Buraya kendi anahtarlarınızı girmelisiniz)
  static final String _appleApiKey = dotenv.get('REVENUECAT_APPLE_API_KEY', fallback: 'appl_YOUR_APPLE_API_KEY');
  static final String _googleApiKey = dotenv.get('REVENUECAT_GOOGLE_API_KEY', fallback: 'goog_YOUR_GOOGLE_API_KEY');

  final SharedPreferences _prefs;
  bool _isInitializing = true;
  bool _isLoggingIn = false;
  bool _isPro = false;
  Offerings? _offerings;

  SubscriptionService(this._prefs) {
    _isPro = _prefs.getBool(_isProKey) ?? false;
    _initRevenueCat();
  }

  bool get isInitializing => _isInitializing;
  bool get isLoggingIn => _isLoggingIn;
  bool get isPro => _isPro;
  Offerings? get offerings => _offerings;

  /// RevenueCat Başlatma
  Future<void> _initRevenueCat() async {
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      PurchasesConfiguration? configuration;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      if (Platform.isAndroid) {
        if ((_googleApiKey.startsWith('goog_') || _googleApiKey.startsWith('test_')) && _googleApiKey != 'goog_YOUR_GOOGLE_API_KEY') {
          configuration = PurchasesConfiguration(_googleApiKey);
        } else {
          debugPrint('⚠️ [SubscriptionService] Geçersiz Google API Anahtarı! RevenueCat devre dışı bırakılıyor.');
        }
      } else if (Platform.isIOS) {
        if ((_appleApiKey.startsWith('appl_') || _appleApiKey.startsWith('test_')) && _appleApiKey != 'appl_YOUR_APPLE_API_KEY') {
          configuration = PurchasesConfiguration(_appleApiKey);
        } else {
          debugPrint('⚠️ [SubscriptionService] Geçersiz Apple API Anahtarı! RevenueCat devre dışı bırakılıyor.');
        }
      }

      if (configuration != null) {
        await Purchases.configure(configuration);
        
        // Eğer kullanıcı giriş yapmışsa RevenueCat üzerinde de oturum açalım
        if (userId != null) {
          final logInResult = await Purchases.logIn(userId);
          _updateProStatus(logInResult.customerInfo);
          debugPrint('✅ [SubscriptionService] Startup: RevenueCat identified user: $userId');
        } else {
          // Mevcut abonelik durumunu kontrol et
          CustomerInfo customerInfo = await Purchases.getCustomerInfo();
          _updateProStatus(customerInfo);
        }
        
        // Ürünleri (Offerings) çek
        _offerings = await Purchases.getOfferings();
      } else {
        debugPrint('ℹ️ [SubscriptionService] RevenueCat yapılandırılmadı (Geçersiz API Anahtarı).');
      }
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Hata: $e');
      // Hata durumunda SharedPreferences'tan eski durumu yükle (Offline destek)
      _isPro = _prefs.getBool(_isProKey) ?? false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// CustomerInfo'ya göre PRO durumunu güncelle
  void _updateProStatus(CustomerInfo customerInfo) {
    debugPrint('ℹ️ [SubscriptionService] Active Entitlements in RevenueCat: ${customerInfo.entitlements.all.keys.toList()}');
    final entitlement = customerInfo.entitlements.all['premium'];
    debugPrint('ℹ️ [SubscriptionService] "premium" Entitlement details: ${entitlement != null ? "Active: ${entitlement.isActive}" : "NOT FOUND IN DASHBOARD"}');

    // 'premium' burada RevenueCat dashboard'unda tanımladığınız "Entitlement ID" olmalıdır.
    _isPro = entitlement?.isActive ?? false;
    _prefs.setBool(_isProKey, _isPro);
    notifyListeners();
  }

  /// Satın Alma İşlemini Başlat
  Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _updateProStatus(result.customerInfo);
      return _isPro;
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Satın alma hatası: $e');
      return false;
    }
  }

  /// Satın Almaları Geri Yükle (Restore)
  Future<void> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateProStatus(customerInfo);
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Restore hatası: $e');
    }
  }

  /// Log in to RevenueCat with a specific User ID (e.g. Supabase User ID)
  Future<void> logIn(String appUserId) async {
    _isLoggingIn = true;
    notifyListeners();
    try {
      final logInResult = await Purchases.logIn(appUserId);
      _updateProStatus(logInResult.customerInfo);
      debugPrint('✅ [SubscriptionService] RevenueCat identified user: $appUserId');
    } catch (e) {
      debugPrint('❌ [SubscriptionService] RevenueCat logIn error: $e');
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  /// Log out from RevenueCat (reverts to anonymous user ID)
  Future<void> logOut() async {
    try {
      // Clear pro status locally first to prevent race conditions during logout/re-initialization
      _isPro = false;
      await _prefs.setBool(_isProKey, false);
      notifyListeners();
      
      final customerInfo = await Purchases.logOut();
      _updateProStatus(customerInfo);
      debugPrint('✅ [SubscriptionService] RevenueCat logged out');
    } catch (e) {
      debugPrint('❌ [SubscriptionService] RevenueCat logOut error: $e');
    }
  }

  /// --- Manuel Pro Ayarlama (Test/Debug Amaçlı) ---
  Future<void> setProStatus(bool isPro) async {
    _isPro = isPro;
    await _prefs.setBool(_isProKey, isPro);
    notifyListeners();
  }

  static const String _lastAiUsageKey = 'Finarcast_last_ai_usage_timestamp';

  // --- Özellik Bazlı Limitler ---
  int get maxVaults => _isPro ? 999 : 2;
  int get dailyAiLimit => _isPro ? 50 : 5;
  int get usedAiCount => _prefs.getInt('Finarcast_ai_usage_$_today') ?? 0;
  int get aiCooldownMinutes => _isPro ? 0 : 1;

  DateTime? get lastAiUsageTime {
    final ms = _prefs.getInt(_lastAiUsageKey);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  int get remainingCooldownSeconds {
    if (_isPro) return 0;
    final lastTime = lastAiUsageTime;
    if (lastTime == null) return 0;
    final diff = DateTime.now().difference(lastTime);
    final cooldownDuration = Duration(minutes: aiCooldownMinutes);
    if (diff >= cooldownDuration) return 0;
    return cooldownDuration.inSeconds - diff.inSeconds;
  }

  bool get isAiCooldownActive => remainingCooldownSeconds > 0;

  String getFormattedRemainingCooldownTime() {
    final totalSeconds = remainingCooldownSeconds;
    if (totalSeconds <= 0) return '';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes > 0) {
      return '$minutes dakika $seconds saniye';
    }
    return '$seconds saniye';
  }

  Future<void> incrementAiUsage() async {
    await _prefs.setInt('Finarcast_ai_usage_$_today', usedAiCount + 1);
    await _prefs.setInt(_lastAiUsageKey, DateTime.now().millisecondsSinceEpoch);
    notifyListeners();
  }

  String get _today => DateTime.now().toIso8601String().substring(0, 10);
  bool get shouldShowAds => !_isPro;
}

/// SharedPreferences yüklendikten sonra servisi sunan provider.
final subscriptionServiceProvider = ChangeNotifierProvider<SubscriptionService>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized first');
});
