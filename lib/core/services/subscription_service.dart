import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum SubscriptionTier { free, pro }

enum SubscriptionPeriod { monthly, yearly }

/// Finarcast Abonelik Servisi (Subscription Service).
/// RevenueCat entegrasyonu ile gerçek ödeme işlemlerini yönetir.
class SubscriptionService extends ChangeNotifier {
  static const String _isProKey = 'Finarcast_is_pro_user';

  // RevenueCat API Anahtarları (Buraya kendi anahtarlarınızı girmelisiniz)
  static const String _appleApiKey = 'appl_YOUR_APPLE_API_KEY';
  static const String _googleApiKey = 'goog_YOUR_GOOGLE_API_KEY';

  final SharedPreferences _prefs;
  bool _isInitializing = true;
  bool _isPro = false;
  Offerings? _offerings;

  SubscriptionService(this._prefs) {
    _initRevenueCat();
  }

  bool get isInitializing => _isInitializing;
  bool get isPro => _isPro;
  Offerings? get offerings => _offerings;

  /// RevenueCat Başlatma
  Future<void> _initRevenueCat() async {
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      PurchasesConfiguration? configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      }

      if (configuration != null) {
        await Purchases.configure(configuration);
        
        // Mevcut abonelik durumunu kontrol et
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        _updateProStatus(customerInfo);
        
        // Ürünleri (Offerings) çek
        _offerings = await Purchases.getOfferings();
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
    // 'pro' burada RevenueCat dashboard'unda tanımladığınız "Entitlement ID" olmalıdır.
    _isPro = customerInfo.entitlements.all['pro']?.isActive ?? false;
    _prefs.setBool(_isProKey, _isPro);
    notifyListeners();
  }

  /// Satın Alma İşlemini Başlat
  Future<bool> purchasePackage(Package package) async {
    try {
      // purchasePackage artık PurchaseResult döner
      final result = await Purchases.purchasePackage(package);
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

  /// --- Manuel Pro Ayarlama (Test/Debug Amaçlı) ---
  Future<void> setProStatus(bool isPro) async {
    _isPro = isPro;
    await _prefs.setBool(_isProKey, isPro);
    notifyListeners();
  }

  // --- Özellik Bazlı Limitler ---
  int get maxVaults => _isPro ? 999 : 2;
  int get dailyAiLimit => 9999; 
  int get usedAiCount => _prefs.getInt('Finarcast_ai_usage_$_today') ?? 0;

  Future<void> incrementAiUsage() async {
    await _prefs.setInt('Finarcast_ai_usage_$_today', usedAiCount + 1);
    notifyListeners();
  }

  String get _today => DateTime.now().toIso8601String().substring(0, 10);
  bool get shouldShowAds => !_isPro;
}

/// SharedPreferences yüklendikten sonra servisi sunan provider.
final subscriptionServiceProvider = ChangeNotifierProvider<SubscriptionService>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized first');
});
