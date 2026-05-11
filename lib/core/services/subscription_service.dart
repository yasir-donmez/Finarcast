import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionTier { free, pro }
enum SubscriptionPeriod { monthly, yearly }

/// FinCast Abonelik Servisi (Subscription Service).
/// Kullanıcının abonelik durumunu yönetir ve özellik bazlı erişim yetkilerini kontrol eder.
class SubscriptionService extends ChangeNotifier {
  static const String _isProKey = 'fincast_is_pro_user';
  static const String _periodKey = 'fincast_subscription_period';
  
  final SharedPreferences _prefs;
  
  SubscriptionService(this._prefs);

  /// Mevcut abonelik tipini döner.
  SubscriptionTier get currentTier {
    final isPro = _prefs.getBool(_isProKey) ?? false;
    return isPro ? SubscriptionTier.pro : SubscriptionTier.free;
  }

  /// Mevcut abonelik periyodunu döner.
  SubscriptionPeriod get currentPeriod {
    final periodIndex = _prefs.getInt(_periodKey) ?? 0;
    return SubscriptionPeriod.values[periodIndex];
  }

  /// Kullanıcının Pro olup olmadığını hızlıca kontrol eder.
  bool get isPro => currentTier == SubscriptionTier.pro;

  /// Deneme amaçlı veya satın alım sonrası Pro durumunu günceller.
  Future<void> setProStatus(bool isPro, {SubscriptionPeriod period = SubscriptionPeriod.monthly}) async {
    await _prefs.setBool(_isProKey, isPro);
    await _prefs.setInt(_periodKey, period.index);
    notifyListeners(); // UI'ı bilgilendir
  }

  // --- Özellik Bazlı Limitler ---
  // ... (limit getters remain the same)
  int get maxVaults => isPro ? 999 : 2;
  int get dailyAiLimit => 9999; // Test amaçlı limit kaldırıldı
  int get usedAiCount => _prefs.getInt('fincast_ai_usage_$_today') ?? 0;

  Future<void> incrementAiUsage() async {
    await _prefs.setInt('fincast_ai_usage_$_today', usedAiCount + 1);
    notifyListeners();
  }

  String get _today => DateTime.now().toIso8601String().substring(0, 10);
  bool get shouldShowAds => !isPro;
}

/// SharedPreferences yüklendikten sonra servisi sunan provider.
final subscriptionServiceProvider = ChangeNotifierProvider<SubscriptionService>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized first');
});
