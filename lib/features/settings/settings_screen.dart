import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_constants.dart';
import '../../shared/widgets/custom_bottom_sheet.dart';
import '../../shared/widgets/custom_dialog.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/clickable_action.dart';
import '../../shared/widgets/custom_notification.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import 'widgets/settings/theme_setting.dart';
import 'widgets/settings/color_theme_setting.dart';
import 'widgets/settings/background_setting.dart';
import '../auth/utils/auth_error_helper.dart';

import 'widgets/etched_liquid_text.dart';
import 'widgets/settings/subscription_setting.dart';
import 'widgets/settings_list_items.dart';
import '../../core/database/database_service.dart';
import '../../core/providers/db_providers.dart';
import '../../core/providers/settings_provider.dart';

// Modular Settings
import 'widgets/settings/language_setting.dart';
import 'widgets/settings/currency_setting.dart';
import 'widgets/settings/exchange_rate_setting.dart';
import 'widgets/settings/notification_setting.dart';
import 'widgets/settings/sync_setting.dart';
import 'widgets/settings/retention_setting.dart';
import 'widgets/settings/purge_setting.dart';
import 'widgets/settings/reset_setting.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late ScrollController _scrollController;
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);
  bool _isProfileExpanded = false;
  final _preferencesKey = GlobalKey();
  final _dataAiKey = GlobalKey();
  final _supportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        _scrollOffset.value = _scrollController.offset;
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeColor = ref.watch(rotaryColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 120, bottom: 40),
              child: Center(
                child: RepaintBoundary(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _scrollOffset,
                    builder: (context, offset, _) {
                      return EtchedLiquidText(
                        progress: (offset / 120).clamp(0.0, 1.0),
                        activeColor: activeColor,
                        text: l10n.settings,
                        fontSize: 44,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                SettingsListItems.buildSectionTitle(l10n.sectionMembershipAccount, activeColor),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // Profile Header Row (Expandable for logged in user)
                      () {
                        if (user == null) {
                          return ClickableAction(
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('Finarcast_is_guest_mode', false);
                              ref.read(guestModeProvider.notifier).state = false;
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: activeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.account_circle_outlined,
                                      size: 22,
                                      color: activeColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.guestUser,
                                          style: TextStyle(
                                            color: AppColors.getTextPrimary(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.tapToLogin,
                                          style: TextStyle(
                                            color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_outward_rounded,
                                    color: activeColor.withValues(alpha: 0.5),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Logged In State
                        final email = user.email ?? "";
                        final metadata = user.userMetadata;
                        final username = metadata?['username'] as String?;
                        String displayNameVal = "";
                        
                        if (username != null && username.isNotEmpty) {
                          displayNameVal = username[0].toUpperCase() + username.substring(1);
                        } else if (email.isNotEmpty) {
                          displayNameVal = email.split('@').first;
                        } else {
                          displayNameVal = l10n.defaultUser;
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Profile Collapsible Header (Shows Username only)
                            ClickableAction(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _isProfileExpanded = !_isProfileExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: activeColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.account_circle_outlined,
                                        size: 22,
                                        color: activeColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        displayNameVal,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.getTextPrimary(context),
                                        ),
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: _isProfileExpanded ? 0.25 : 0.0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                      child: Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _isProfileExpanded
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SettingsListItems.buildDivider(isDark),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // E-posta Detayı
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    l10n.email,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.55),
                                                    ),
                                                  ),
                                                  Text(
                                                    email,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.getTextPrimary(context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              () {
                                                final provider = user.appMetadata['provider'] as String? ?? 'email';
                                                final isEmailUser = provider == 'email';
                                                if (isEmailUser) {
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(height: 18),
                                                      // Şifre Detayı (Tıklanabilir Şifre Sıfırlama)
                                                      ClickableAction(
                                                        onTap: () {
                                                          _showPasswordResetDialog(context, email, authService, l10n);
                                                        },
                                                        borderRadius: BorderRadius.circular(8),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                l10n.password,
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.55),
                                                                ),
                                                              ),
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text(
                                                                    "••••••••",
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w700,
                                                                      color: AppColors.getTextPrimary(context),
                                                                      letterSpacing: 1.5,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  Icon(
                                                                    Icons.arrow_outward_rounded,
                                                                    color: activeColor.withValues(alpha: 0.6),
                                                                    size: 14,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  final providerName = provider == 'google' ? 'Google' : provider[0].toUpperCase() + provider.substring(1);
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(height: 18),
                                                      // Giriş Yöntemi Detayı
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            l10n.signInMethod,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color: AppColors.getTextSecondary(context).withValues(alpha: 0.55),
                                                            ),
                                                          ),
                                                          Text(
                                                            providerName,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w700,
                                                              color: AppColors.getTextPrimary(context),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                }
                                              }(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        );
                      }(),

                      SettingsListItems.buildDivider(isDark),
                      const SubscriptionSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                SettingsListItems.buildSectionTitle(l10n.sectionAppearanceStyle, activeColor),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const ThemeSetting(),
                      SettingsListItems.buildDivider(isDark),
                      const ColorThemeSetting(),
                      SettingsListItems.buildDivider(isDark),
                      const BackgroundSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                SettingsListItems.buildSectionTitle(l10n.preferences, activeColor, key: _preferencesKey),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const LanguageSetting(),
                      SettingsListItems.buildDivider(isDark),
                      const CurrencySetting(),
                      SettingsListItems.buildDivider(isDark),
                      const ExchangeRateSetting(),
                      SettingsListItems.buildDivider(isDark),
                      const NotificationSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                SettingsListItems.buildSectionTitle(l10n.sectionDataCloud, activeColor, key: _dataAiKey),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const SyncSetting(),
                      SettingsListItems.buildDivider(isDark),
                      SettingsListItems.buildSetting(
                        icon: Icons.cloud_upload_outlined,
                        title: l10n.driveBackup,
                        onTap: () => _showComingSoon(l10n.driveBackup, l10n),
                        activeColor: SettingsListItems.getSettingColor(context, SettingType.backup, activeColor),
                        context: context,
                        isAction: true,
                      ),
                      SettingsListItems.buildDivider(isDark),
                      SettingsListItems.buildSetting(
                        icon: Icons.table_view_rounded,
                        title: l10n.exportExcel,
                        onTap: () => _showComingSoon(l10n.exportExcel, l10n),
                        activeColor: SettingsListItems.getSettingColor(context, SettingType.export, activeColor),
                        context: context,
                        isAction: true,
                      ),
                      SettingsListItems.buildDivider(isDark),
                      const RetentionSetting(),
                      SettingsListItems.buildDivider(isDark),
                      const PurgeSetting(),
                      SettingsListItems.buildDivider(isDark),
                      const ResetSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                SettingsListItems.buildSectionTitle(l10n.support, activeColor, key: _supportKey),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SettingsListItems.buildSetting(
                        icon: Icons.support_agent_rounded,
                        title: l10n.contact,
                        onTap: _launchEmail,
                        activeColor: SettingsListItems.getSettingColor(context, SettingType.contact, activeColor),
                        context: context,
                        isAction: true,
                      ),
                      SettingsListItems.buildDivider(isDark),
                      SettingsListItems.buildSetting(
                        icon: Icons.info_outline_rounded,
                        title: l10n.about,
                        trailing: "v1.0.0",
                        onTap: () => _showAboutDialog(l10n),
                        activeColor: SettingsListItems.getSettingColor(context, SettingType.about, activeColor),
                        context: context,
                      ),
                    ],
                  ),
                ),

                if (user != null) ...[
                  const SizedBox(height: 50),
                  SettingsListItems.buildSectionTitle(l10n.sectionSessionSecurity, activeColor),
                  const SizedBox(height: 12),
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Oturumu Kapat Row
                        ClickableAction(
                          onTap: () {
                            showCustomDialog(
                              context: context,
                              accentColor: Colors.redAccent,
                              title: l10n.logout,
                              content: l10n.logoutConfirm,
                              actions: [
                                PrecisionDialogAction(
                                  label: l10n.cancel,
                                  onTap: () => Navigator.pop(context),
                                  isPrimary: false,
                                ),
                                PrecisionDialogAction(
                                  label: l10n.logout,
                                  onTap: () async {
                                    Navigator.pop(context);
                                    try {
                                      // 1. Önce abonelikten çık
                                      await ref.read(subscriptionServiceProvider).logOut();
                                      
                                      // 2. Veritabanını temizle
                                      await DatabaseService.clearAllData();
                                      
                                      // 3. Tercihleri ve durumları sıfırla
                                      final prefs = await SharedPreferences.getInstance();
                                      await prefs.setBool('Finarcast_is_guest_mode', false);
                                      
                                      ref.read(guestModeProvider.notifier).state = false;
                                      ref.invalidate(transactionsStreamProvider);
                                      ref.invalidate(vaultsStreamProvider);
                                      ref.invalidate(settingsProvider);
                                      ref.invalidate(subscriptionServiceProvider);

                                      // Navigator üzerindeki tüm katmanları temizle (dialog, sayfa vb.)
                                      if (context.mounted) {
                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                      }
 
                                      // 4. En son oturumu kapat (bu işlem UI'ı değiştirecektir)
                                      await ref.read(authServiceProvider).signOut();
                                    } catch (e) {
                                      debugPrint("Çıkış yaparken hata: $e");
                                      if (context.mounted) {
                                        CustomNotification.error(context, l10n.errorOccurred(AuthErrorHelper.getFriendlyErrorMessage(context, e)));
                                      }
                                    }
                                  },
                                  isPrimary: true,
                                ),
                              ],
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    size: 22,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    l10n.logout,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  color: Colors.redAccent.withValues(alpha: 0.5),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SettingsListItems.buildDivider(isDark),
                        // Hesabımı Kalıcı Olarak Sil Row
                        ClickableAction(
                          onTap: () {
                            showCustomDialog(
                              context: context,
                              accentColor: Colors.redAccent,
                              title: l10n.deleteAccount,
                              content: l10n.deleteAccountConfirmDesc,
                              actions: [
                                PrecisionDialogAction(
                                  label: l10n.cancel,
                                  onTap: () => Navigator.pop(context),
                                  isPrimary: false,
                                ),
                                PrecisionDialogAction(
                                  label: l10n.deleteAccount,
                                  onTap: () async {
                                    Navigator.pop(context);
                                    try {
                                      // 1. Önce abonelikten çık
                                      await ref.read(subscriptionServiceProvider).logOut();
                                      
                                      // 2. Veritabanını temizle
                                      await DatabaseService.clearAllData();
                                      
                                      // 3. Tercihleri ve durumları sıfırla
                                      final prefs = await SharedPreferences.getInstance();
                                      await prefs.setBool('Finarcast_is_guest_mode', false);
                                      
                                      ref.read(guestModeProvider.notifier).state = false;
                                      ref.invalidate(transactionsStreamProvider);
                                      ref.invalidate(vaultsStreamProvider);
                                      ref.invalidate(settingsProvider);
                                      ref.invalidate(subscriptionServiceProvider);

                                      // Navigator üzerindeki tüm katmanları temizle (dialog, sayfa vb.)
                                      if (context.mounted) {
                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                      }
 
                                      // 4. Hesabı ve oturumu sil (bu işlem UI'ı değiştirecektir)
                                      await ref.read(authServiceProvider).deleteAccount();
                                      
                                      if (context.mounted) {
                                        CustomNotification.success(context, l10n.done);
                                      }
                                    } catch (e) {
                                      debugPrint("Hesap silinirken hata: $e");
                                      if (context.mounted) {
                                        CustomNotification.error(context, l10n.errorOccurred(AuthErrorHelper.getFriendlyErrorMessage(context, e)));
                                      }
                                    }
                                  },
                                  isPrimary: true,
                                ),
                              ],
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.delete_forever_rounded,
                                    size: 22,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    l10n.deleteAccountPermanently,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  color: Colors.redAccent.withValues(alpha: 0.5),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetDialog(
    BuildContext context,
    String email,
    AuthService authService,
    AppLocalizations l10n,
  ) {
    final oldPasswordController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureOldPassword = true;
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    String? oldPasswordError;
    String? passwordError;
    String? confirmPasswordError;
    bool isLoading = false;

    CustomBottomSheet.show(
      context: context,
      title: l10n.changePassword,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                l10n.changePasswordDesc,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Eski Şifre
              CustomTextField(
                controller: oldPasswordController,
                hintText: l10n.currentPasswordHint,
                icon: Icons.lock_open_rounded,
                obscureText: obscureOldPassword,
                errorText: oldPasswordError,
                suffix: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    obscureOldPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.getPrimary(context).withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: () {
                    setSheetState(() => obscureOldPassword = !obscureOldPassword);
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Yeni Şifre
              CustomTextField(
                controller: passwordController,
                hintText: l10n.newPasswordHint,
                icon: Icons.lock_rounded,
                obscureText: obscurePassword,
                errorText: passwordError,
                suffix: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.getPrimary(context).withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: () {
                    setSheetState(() => obscurePassword = !obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Yeni Şifre Tekrar
              CustomTextField(
                controller: confirmPasswordController,
                hintText: l10n.confirmNewPasswordHint,
                icon: Icons.security_rounded,
                obscureText: obscureConfirmPassword,
                errorText: confirmPasswordError,
                suffix: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.getPrimary(context).withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: () {
                    setSheetState(() => obscureConfirmPassword = !obscureConfirmPassword);
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Güncelle Butonu
              CustomButton(
                label: l10n.updatePassword,
                isLoading: isLoading,
                onTap: () async {
                  final oldPassword = oldPasswordController.text;
                  final password = passwordController.text;
                  final confirmPassword = confirmPasswordController.text;
                  
                  // Reset Errors
                  setSheetState(() {
                    oldPasswordError = null;
                    passwordError = null;
                    confirmPasswordError = null;
                  });

                  bool isValid = true;
                  if (oldPassword.isEmpty) {
                    setSheetState(() => oldPasswordError = l10n.currentPasswordRequired);
                    isValid = false;
                  }
                  
                  if (password.isEmpty) {
                    setSheetState(() => passwordError = l10n.authPasswordRequired);
                    isValid = false;
                  } else if (password.length < 6) {
                    setSheetState(() => passwordError = l10n.authPasswordTooShort);
                    isValid = false;
                  } else if (password == oldPassword) {
                    setSheetState(() => passwordError = l10n.authPasswordDifferentError);
                    isValid = false;
                  }
                  
                  if (confirmPassword.isEmpty) {
                    setSheetState(() => confirmPasswordError = l10n.authConfirmPasswordRequired);
                    isValid = false;
                  } else if (password != confirmPassword) {
                    setSheetState(() => confirmPasswordError = l10n.authPasswordsDoNotMatch);
                    isValid = false;
                  }

                  if (!isValid) return;

                  setSheetState(() => isLoading = true);

                  // 1) Mevcut şifreyi doğrulamak için sisteme tekrar giriş yapmayı dene
                  try {
                    await authService.signIn(email: email, password: oldPassword);
                  } catch (e) {
                    String oldPassErrorMsg = l10n.authInvalidCredentials;
                    if (e is AuthException) {
                      final message = e.message.toLowerCase();
                      if (e.code == 'rate_limit_exceeded' || message.contains('rate limit') || message.contains('too many requests')) {
                        oldPassErrorMsg = l10n.authRateLimitExceeded;
                      }
                    }
                    setSheetState(() {
                      isLoading = false;
                      oldPasswordError = oldPassErrorMsg;
                    });
                    return;
                  }

                  // 2) Şifreyi güncelle
                  try {
                    await authService.updatePassword(password);
                    if (context.mounted) {
                      Navigator.pop(context); // Close bottom sheet
                      CustomNotification.success(
                        context,
                        l10n.done,
                      );
                    }
                  } catch (e) {
                    String updateErrorMsg = l10n.error;
                    if (e is AuthException) {
                      final message = e.message.toLowerCase();
                      if (e.code == 'same_password' || message.contains('different from the old password') || message.contains('should be different')) {
                        updateErrorMsg = l10n.authPasswordDifferentError;
                      } else if (e.code == 'weak_password') {
                        updateErrorMsg = l10n.authWeakPassword;
                      } else {
                        updateErrorMsg = e.message;
                      }
                    } else {
                      updateErrorMsg = e.toString();
                    }
                    setSheetState(() {
                      isLoading = false;
                      passwordError = updateErrorMsg;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog(AppLocalizations l10n) {
    CustomBottomSheet.show(
      context: context,
      title: 'Finarcast',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.aboutFinarcast,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              height: 1.6,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.aboutVersion("v1.0.0"),
            style: TextStyle(
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showComingSoon(String feature, AppLocalizations l10n) {
    showCustomDialog(
      context: context,
      title: l10n.comingSoon,
      content: l10n.comingSoonDesc(feature),
      actions: [
        PrecisionDialogAction(
          label: l10n.ok,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'finarcast.support@gmail.com',
      queryParameters: {
        'subject': 'Finarcast Feedback',
      },
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        await Clipboard.setData(const ClipboardData(text: 'finarcast.support@gmail.com'));
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          CustomNotification.info(context, l10n.supportEmailCopied);
        }
      }
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: 'finarcast.support@gmail.com'));
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        CustomNotification.info(context, l10n.supportEmailCopied);
      }
    }
  }
}
