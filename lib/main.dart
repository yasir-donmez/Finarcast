import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'l10n/app_localizations.dart';
import 'features/dashboard/main_scaffold.dart';
import 'features/auth/screens/auth_screen.dart';
import 'core/database/database_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_constants.dart';
import 'core/services/data_retention_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/currency_service.dart';
import 'core/providers/settings_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/subscription_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  try {
    debugPrint('🚀 [FinCast] Uygulama başlatılıyor...');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('✅ [FinCast] Flutter Binding hazır.');

    // Çevresel değişkenleri yükle (.env)
    debugPrint('🔑 [FinCast] .env ayarları yükleniyor...');
    await dotenv.load(fileName: ".env");
    debugPrint('✅ [FinCast] .env yüklendi.');

    // Supabase başlat
    debugPrint('☁️ [FinCast] Supabase başlatılıyor...');
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL', fallback: ''),
      anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
    );
    debugPrint('✅ [FinCast] Supabase hazır.');

    // Isar veritabanını başlat
    debugPrint('📦 [FinCast] Veritabanı başlatılıyor...');
    await DatabaseService.init();
    debugPrint('✅ [FinCast] Veritabanı başarıyla başlatıldı.');

    // Bildirimleri başlat
    debugPrint('🔔 [FinCast] Bildirim servisi başlatılıyor...');
    await NotificationService().init();

    // Döviz kurlarını güncelle (Async - Fire & Forget)
    CurrencyService.updateRates();

    // Süresi dolan işlemleri arşivle
    debugPrint('🧹 [FinCast] Arşivleme işlemi başlatılıyor...');
    await DataRetentionService.archiveExpiredTransactions();
    debugPrint('✅ [FinCast] Arşivleme tamamlandı.');

    // Yerelleştirme (intl)
    debugPrint('🌍 [FinCast] Yerelleştirme başlatılıyor...');
    await initializeDateFormatting('tr_TR', null);
    debugPrint('✅ [FinCast] Yerelleştirme hazır.');

    // SharedPreferences (Abonelik durumu için)
    debugPrint('💾 [FinCast] SharedPreferences başlatılıyor...');
    final prefs = await SharedPreferences.getInstance();
    debugPrint('✅ [FinCast] SharedPreferences hazır.');

    debugPrint('🏁 [FinCast] runApp() çağrılıyor...');
    runApp(
      ProviderScope(
        overrides: [
          subscriptionServiceProvider.overrideWith((ref) => SubscriptionService(prefs)),
        ],
        child: const FinCastApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('❌ [FinCast FATAL] Başlangıç hatası: $e');
    debugPrint('📜 [FinCast FATAL] Stack Trace:\n$stack');
    
    // Uygulama kritik bir hata aldığında en azından bir hata ekranı gösterelim
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SelectableText(
                'Kritik Başlangıç Hatası\n\n$e\n\n$stack',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FinCastApp extends ConsumerWidget {
  const FinCastApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = _getThemeMode(settings.themeModeIndex);

    // Dil kodunu temizle (tr_TR -> tr)
    final langCode = settings.languageCode.split('_')[0].toLowerCase();
    
    // Geçerli bir locale nesnesi oluştur, hata durumunda varsayılan 'tr'
    Locale? appLocale;
    try {
      if (langCode.isNotEmpty) {
        appLocale = Locale(langCode);
      }
    } catch (_) {}
    appLocale ??= const Locale('tr');

    return RepaintBoundary(
      key: rootRepaintBoundaryKey,
      child: MaterialApp(
        title: 'FinCast',
        debugShowCheckedModeBanner: false,
  
        // Tema Yapılandırması (Karanlık Neumorphism)
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        
        // Dil Yapılandırması
        locale: appLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
  
        home: Consumer(
          builder: (context, ref, child) {
            final authState = ref.watch(authStateProvider);
            
            return authState.when(
              data: (state) {
                if (state.session != null) {
                  return const MainScaffold();
                }
                return const AuthScreen();
              },
              loading: () => Scaffold(
                backgroundColor: AppColors.getBackground(context),
                body: const Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => Scaffold(
                backgroundColor: AppColors.getBackground(context),
                body: Center(child: Text('Hata: $e')),
              ),
            );
          },
        ),
      ),
    );
  }

  ThemeMode _getThemeMode(int index) {
    switch (index) {
      case 0: return ThemeMode.system;
      case 1: return ThemeMode.light;
      case 2: return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}
