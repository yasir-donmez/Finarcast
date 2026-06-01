import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'l10n/app_localizations.dart';
import 'features/home/main_scaffold.dart';
import 'features/auth/auth_screen.dart';
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
import 'core/widgets/sync_bootstrap.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'shared/widgets/custom_notification.dart';

void main() async {
  try {
    debugPrint('🚀 [Finarcast] Uygulama başlatılıyor...');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('✅ [Finarcast] Flutter Binding hazır.');

    // Çevresel değişkenleri yükle (.env)
    debugPrint('🔑 [Finarcast] .env ayarları yükleniyor...');
    await dotenv.load(fileName: ".env");
    debugPrint('✅ [Finarcast] .env yüklendi.');

    // Supabase başlat
    debugPrint('☁️ [Finarcast] Supabase başlatılıyor...');
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL', fallback: ''),
      anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
    );
    debugPrint('✅ [Finarcast] Supabase hazır.');

    // Isar veritabanını başlat
    debugPrint('📦 [Finarcast] Veritabanı başlatılıyor...');
    await DatabaseService.init();
    debugPrint('✅ [Finarcast] Veritabanı başarıyla başlatıldı.');

    // Bildirimleri başlat
    debugPrint('🔔 [Finarcast] Bildirim servisi başlatılıyor...');
    await NotificationService().init();
    final settings = await DatabaseService.getSettings();
    if (settings.isNotificationsEnabled) {
      await NotificationService().requestPermissions();
    }

    // Döviz kurlarını güncelle (Async - Fire & Forget)
    CurrencyService.updateRates();

    // Süresi dolan işlemleri arşivle
    debugPrint('🧹 [Finarcast] Arşivleme işlemi başlatılıyor...');
    await DataRetentionService.archiveExpiredTransactions();
    debugPrint('✅ [Finarcast] Arşivleme tamamlandı.');

    // Yerelleştirme (intl)
    debugPrint('🌍 [Finarcast] Yerelleştirme başlatılıyor...');
    await initializeDateFormatting('tr_TR', null);
    debugPrint('✅ [Finarcast] Yerelleştirme hazır.');

    // SharedPreferences (Abonelik durumu için)
    debugPrint('💾 [Finarcast] SharedPreferences başlatılıyor...');
    final prefs = await SharedPreferences.getInstance();
    debugPrint('✅ [Finarcast] SharedPreferences hazır.');

    final isGuest = prefs.getBool('Finarcast_is_guest_mode') ?? false;

    debugPrint('🏁 [Finarcast] runApp() çağrılıyor...');
    runApp(
      ProviderScope(
        overrides: [
          subscriptionServiceProvider.overrideWith((ref) => SubscriptionService(prefs)),
          guestModeProvider.overrideWith((ref) => isGuest),
        ],
        child: const FinarcastApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('❌ [Finarcast FATAL] Başlangıç hatası: $e');
    debugPrint('📜 [Finarcast FATAL] Stack Trace:\n$stack');
    
    // Uygulama kritik bir hata aldığında kurtarma arayüzünü gösterelim
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: DatabaseCrashScreen(error: e, stackTrace: stack),
      ),
    );
  }
}

class FinarcastApp extends ConsumerWidget {
  const FinarcastApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to authentication state changes and identify/logout user in RevenueCat
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      if (next.hasValue) {
        final authState = next.value!;
        final user = authState.session?.user;
        if (user != null) {
          ref.read(subscriptionServiceProvider).logIn(user.id);
        } else {
          ref.read(subscriptionServiceProvider).logOut();
        }
      }
    });

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

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        Color? accentColor;
        if (settings.accentColorValue != 0) {
          accentColor = Color(settings.accentColorValue);
        }

        final theme = AppTheme.buildLightTheme(accentColor ?? lightDynamic?.primary ?? const Color(0xFF00BCD4));
        final darkTheme = AppTheme.buildDarkTheme(accentColor ?? darkDynamic?.primary ?? const Color(0xFF00BCD4));

        // Dinamik rengi güncelle (Diğer bileşenlerin erişebilmesi için)
        final dynamicColor = lightDynamic?.primary ?? const Color(0xFF00BCD4);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ref.read(dynamicColorProvider) != dynamicColor) {
            ref.read(dynamicColorProvider.notifier).state = dynamicColor;
          }
        });

        return RepaintBoundary(
          key: rootRepaintBoundaryKey,
          child: MaterialApp(
            title: 'Finarcast',
            debugShowCheckedModeBanner: false,
      
            // Tema Yapılandırması (Karanlık Neumorphism)
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            
            // Dil Yapılandırması
            locale: appLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
      
            builder: (context, child) {
              final brightness = MediaQuery.platformBrightnessOf(context);
              final isSystemDark = brightness == Brightness.dark;
              final isDark = themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && isSystemDark);
              
              return Material(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                child: child,
              );
            },
      
            home: Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authStateProvider);
                final isGuest = ref.watch(guestModeProvider);
                
                return authState.when(
                  data: (state) {
                    if (state.session != null || isGuest) {
                      return const SyncBootstrap(child: MainScaffold());
                    }
                    return const AuthScreen();
                  },
                  loading: () => const Scaffold(
                    backgroundColor: Colors.transparent, // Builder'daki renk görünecek
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, st) => Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Center(child: Text('Hata: $e')),
                  ),
                );
              },
            ),
          ),
        );
      },
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

class DatabaseCrashScreen extends StatefulWidget {
  final Object error;
  final StackTrace stackTrace;

  const DatabaseCrashScreen({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  @override
  State<DatabaseCrashScreen> createState() => _DatabaseCrashScreenState();
}

class _DatabaseCrashScreenState extends State<DatabaseCrashScreen> {
  bool _isResetting = false;

  Future<void> _resetDatabase() async {
    setState(() {
      _isResetting = true;
    });
    try {
      debugPrint('🚨 [DatabaseCrashScreen] Veritabanı dosyaları siliniyor...');
      await DatabaseService.deleteDatabaseFiles();
      debugPrint('✅ [DatabaseCrashScreen] Veritabanı dosyaları silindi. Yeniden başlatılıyor...');
      
      // Tekrar başlatma adımları
      await DatabaseService.init();
      await DataRetentionService.archiveExpiredTransactions();
      await initializeDateFormatting('tr_TR', null);
      final prefs = await SharedPreferences.getInstance();

      if (mounted) {
        runApp(
          ProviderScope(
            overrides: [
              subscriptionServiceProvider.overrideWith((ref) => SubscriptionService(prefs)),
            ],
            child: const FinarcastApp(),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('❌ [DatabaseCrashScreen] Kurtarma sırasında hata: $e\n$stack');
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
        CustomNotification.error(context, 'Sıfırlama başarısız oldu: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kritik Veritabanı Hatası',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Uygulama veritabanında okunamayan/bozuk veriler tespit edildi. Aşağıdaki butona basarak veritabanını temizleyip uygulamayı sıfırdan başlatabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              if (_isResetting)
                const CircularProgressIndicator(color: Colors.redAccent)
              else
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _resetDatabase,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text(
                      'Veritabanını Sıfırla ve Yeniden Başlat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hata Ayrıntısı:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SelectableText(
                      '${widget.error}\n\n${widget.stackTrace}',
                      style: TextStyle(
                        color: Colors.redAccent.withValues(alpha: 0.8),
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
