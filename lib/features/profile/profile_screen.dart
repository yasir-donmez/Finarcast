import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_constants.dart';
import '../../shared/widgets/precision_sheet.dart';
import '../../shared/widgets/precision_dialog.dart';
import '../dashboard/dashboard_providers.dart';
import '../../shared/widgets/precision_card.dart';
import '../../shared/widgets/precision_theme_toggle.dart';

// Modular Widgets
import 'widgets/etched_liquid_text.dart';
import 'widgets/settings/subscription_setting.dart';
import 'widgets/profile_list_items.dart';

// Modular Settings
import 'widgets/settings/language_setting.dart';
import 'widgets/settings/currency_setting.dart';
import 'widgets/settings/exchange_rate_setting.dart';
import 'widgets/settings/notification_setting.dart';
import 'widgets/settings/location_setting.dart';
import 'widgets/settings/auth_setting.dart';
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

  final _preferencesKey = GlobalKey();
  final _dataAiKey = GlobalKey();
  final _managementKey = GlobalKey();
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
                        text: "Yasir Dönmez",
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
                ProfileListItems.buildSectionTitle(l10n.membership, activeColor),
                const SizedBox(height: 12),
                const SubscriptionSetting(),

                const SizedBox(height: 50),
                ProfileListItems.buildSectionTitle(l10n.preferences, activeColor, key: _preferencesKey),
                const SizedBox(height: 12),
                PrecisionCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      PrecisionThemeToggle(activeColor: activeColor),
                      ProfileListItems.buildDivider(isDark),
                      const LanguageSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const CurrencySetting(),
                      ProfileListItems.buildDivider(isDark),
                      const ExchangeRateSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const NotificationSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const LocationSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const AuthSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
                ProfileListItems.buildSectionTitle(l10n.dataAndAiSettings, activeColor, key: _dataAiKey),
                const SizedBox(height: 16),
                PrecisionCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const RetentionSetting(),
                      ProfileListItems.buildDivider(isDark),
                      const PurgeSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
                ProfileListItems.buildSectionTitle(
                  l10n.dataManagement, 
                  AppColors.getSecondary(context), 
                  key: _managementKey
                ),
                const SizedBox(height: 12),
                PrecisionCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const SyncSetting(),
                      ProfileListItems.buildDivider(isDark),
                      ProfileListItems.buildSetting(
                        icon: Icons.cloud_upload_rounded,
                        title: l10n.driveBackup,
                        onTap: () => _showComingSoon(l10n.driveBackup, l10n),
                        activeColor: AppColors.getSecondary(context),
                        context: context,
                        isAction: true,
                      ),
                      ProfileListItems.buildDivider(isDark),
                      ProfileListItems.buildSetting(
                        icon: Icons.table_view_rounded,
                        title: l10n.exportExcel,
                        onTap: () => _showComingSoon(l10n.exportExcel, l10n),
                        activeColor: AppColors.getSecondary(context),
                        context: context,
                        isAction: true,
                      ),
                      ProfileListItems.buildDivider(isDark),
                      const ResetSetting(),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
                ProfileListItems.buildSectionTitle(
                  l10n.support, 
                  AppColors.getPrimary(context), 
                  key: _supportKey
                ),
                const SizedBox(height: 12),
                PrecisionCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ProfileListItems.buildSetting(
                        icon: Icons.support_agent_rounded,
                        title: l10n.contact,
                        onTap: _launchEmail,
                        activeColor: AppColors.getPrimary(context),
                        context: context,
                        isAction: true,
                      ),
                      ProfileListItems.buildDivider(isDark),
                      ProfileListItems.buildSetting(
                        icon: Icons.info_outline_rounded,
                        title: l10n.about,
                        trailing: "v1.0.0",
                        onTap: () => _showAboutDialog(l10n),
                        activeColor: AppColors.getPrimary(context),
                        context: context,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(AppLocalizations l10n) {
    PrecisionSheet.show(
      context: context,
      title: 'FinCast',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.aboutFinCast,
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
    showPrecisionDialog(
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
      path: 'support@fincast.app',
      queryParameters: {
        'subject': 'FinCast Feedback',
      },
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}
