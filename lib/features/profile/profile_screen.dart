import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_constants.dart';
import '../../shared/widgets/custom_bottom_sheet.dart';
import '../../shared/widgets/custom_dialog.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/clickable_action.dart';
import 'widgets/settings/theme_setting.dart';
import 'widgets/settings/color_theme_setting.dart';
import 'widgets/settings/background_setting.dart';

import '../../shared/widgets/custom_button.dart';
import '../../core/services/subscription_service.dart';
import '../auth/screens/auth_screen.dart';
import 'widgets/etched_liquid_text.dart';
import 'widgets/settings/subscription_setting.dart';
import 'widgets/profile_list_items.dart';

// Modular Settings
import 'widgets/settings/language_setting.dart';
import 'widgets/settings/currency_setting.dart';
import 'widgets/settings/exchange_rate_setting.dart';
import 'widgets/settings/notification_setting.dart';
import 'widgets/settings/sync_setting.dart';
import 'widgets/settings/retention_setting.dart';
import 'widgets/settings/purge_setting.dart';
import 'widgets/settings/reset_setting.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    final subscription = ref.watch(subscriptionServiceProvider);

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
                ProfileListItems.buildSectionTitle("Üyelik ve Hesap", activeColor),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // Profile Header Row (Expandable for logged in user)
                      () {
                        if (user == null) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.getTextSecondary(context).withValues(alpha: 0.1),
                                        border: Border.all(
                                          color: AppColors.getTextSecondary(context).withValues(alpha: 0.15),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.person_outline_rounded,
                                        color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Misafir Kullanıcı",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.getTextPrimary(context),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Verilerinizi yedeklemek ve premium özellikleri açmak için giriş yapın.",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  label: "Giriş Yap / Kayıt Ol",
                                  onTap: () {
                                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                                      (route) => false,
                                    );
                                  },
                                  activeColor: activeColor,
                                  height: 40,
                                  fontSize: 13,
                                ),
                              ],
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
                          displayNameVal = "Kullanıcı";
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
                                      child: Row(
                                        children: [
                                          Text(
                                            displayNameVal,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.getTextPrimary(context),
                                            ),
                                          ),
                                          if (subscription.isPro) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: activeColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: activeColor.withValues(alpha: 0.15),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.stars_rounded,
                                                    color: activeColor,
                                                    size: 10,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "PREMIUM",
                                                    style: TextStyle(
                                                      color: activeColor,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
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
                                        ProfileListItems.buildDivider(isDark),
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
                                                    "E-posta",
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
                                                        "Şifre",
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
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        );
                      }(),

                      ProfileListItems.buildDivider(isDark),
                      const SubscriptionSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                ProfileListItems.buildSectionTitle("Görünüm ve Stil", activeColor),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const ThemeSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const ColorThemeSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const BackgroundSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                ProfileListItems.buildSectionTitle(l10n.preferences, activeColor, key: _preferencesKey),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const LanguageSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const CurrencySetting(),
                      ProfileListItems.buildDivider(isDark),
                      const ExchangeRateSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const NotificationSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                ProfileListItems.buildSectionTitle("Veri ve Bulut Eşitleme", activeColor, key: _dataAiKey),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const SyncSetting(),
                      ProfileListItems.buildDivider(isDark),
                      ProfileListItems.buildSetting(
                        icon: Icons.cloud_upload_outlined,
                        title: l10n.driveBackup,
                        onTap: () => _showComingSoon(l10n.driveBackup, l10n),
                        activeColor: ProfileListItems.getSettingColor(context, SettingType.backup, activeColor),
                        context: context,
                        isAction: true,
                      ),
                      ProfileListItems.buildDivider(isDark),
                      ProfileListItems.buildSetting(
                        icon: Icons.table_view_rounded,
                        title: l10n.exportExcel,
                        onTap: () => _showComingSoon(l10n.exportExcel, l10n),
                        activeColor: ProfileListItems.getSettingColor(context, SettingType.export, activeColor),
                        context: context,
                        isAction: true,
                      ),
                      ProfileListItems.buildDivider(isDark),
                      const RetentionSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const PurgeSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const ResetSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                ProfileListItems.buildSectionTitle(l10n.support, activeColor, key: _supportKey),
                const SizedBox(height: 12),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ProfileListItems.buildSetting(
                        icon: Icons.support_agent_rounded,
                        title: l10n.contact,
                        onTap: _launchEmail,
                        activeColor: ProfileListItems.getSettingColor(context, SettingType.contact, activeColor),
                        context: context,
                        isAction: true,
                      ),
                      ProfileListItems.buildDivider(isDark),
                      ProfileListItems.buildSetting(
                        icon: Icons.info_outline_rounded,
                        title: l10n.about,
                        trailing: "v1.0.0",
                        onTap: () => _showAboutDialog(l10n),
                        activeColor: ProfileListItems.getSettingColor(context, SettingType.about, activeColor),
                        context: context,
                      ),
                    ],
                  ),
                ),

                if (user != null) ...[
                  const SizedBox(height: 50),
                  ProfileListItems.buildSectionTitle("Oturum ve Güvenlik", activeColor),
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
                              title: "Çıkış Yap",
                              content: "Oturumu kapatmak istediğinize emin misiniz?",
                              actions: [
                                PrecisionDialogAction(
                                  label: l10n.cancel,
                                  onTap: () => Navigator.pop(context),
                                  isPrimary: false,
                                ),
                                PrecisionDialogAction(
                                  label: "Çıkış Yap",
                                  onTap: () async {
                                    await ref.read(authServiceProvider).signOut();
                                    if (context.mounted) Navigator.pop(context);
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
                                const Expanded(
                                  child: Text(
                                    "Oturumu Kapat",
                                    style: TextStyle(
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
                        ProfileListItems.buildDivider(isDark),
                        // Hesabımı Kalıcı Olarak Sil Row
                        ClickableAction(
                          onTap: () {
                            showCustomDialog(
                              context: context,
                              accentColor: Colors.redAccent,
                              title: "Hesabımı Sil",
                              content: "Hesabınızı ve buluttaki tüm verilerinizi kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
                              actions: [
                                PrecisionDialogAction(
                                  label: l10n.cancel,
                                  onTap: () => Navigator.pop(context),
                                  isPrimary: false,
                                ),
                                PrecisionDialogAction(
                                  label: "Hesabımı Sil",
                                  onTap: () async {
                                    await ref.read(authServiceProvider).signOut();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Hesap silme talebiniz alındı ve oturumunuz kapatıldı.'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
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
                                const Expanded(
                                  child: Text(
                                    "Hesabımı Kalıcı Olarak Sil",
                                    style: TextStyle(
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
    showCustomDialog(
      context: context,
      title: "Şifre Sıfırlama",
      content: "Şifrenizi sıfırlamak için kayıtlı e-posta adresinize ($email) bir bağlantı gönderilecektir. Devam etmek istiyor musunuz?",
      actions: [
        PrecisionDialogAction(
          label: l10n.cancel,
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: "Gönder",
          onTap: () async {
            try {
              await authService.resetPassword(email);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şifre sıfırlama e-postası başarıyla gönderildi.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hata oluştu: ${e.toString()}'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }
          },
          isPrimary: true,
        ),
      ],
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
            "v1.0.0 • Made with ❤️",
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
      content: "$feature özelliği çok yakında sizlerle olacak.",
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
      path: 'support@Finarcast.app',
      queryParameters: {
        'subject': 'Finarcast Feedback',
      },
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}
