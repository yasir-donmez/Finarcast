import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/subscription_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../shared/widgets/segmented_control.dart';
import '../../../../shared/widgets/custom_notification.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../home/home_providers.dart';
import '../settings_list_items.dart';
import '../../../../core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionSetting extends ConsumerStatefulWidget {
  const SubscriptionSetting({super.key});

  @override
  ConsumerState<SubscriptionSetting> createState() => _SubscriptionSettingState();
}

class _SubscriptionSettingState extends ConsumerState<SubscriptionSetting> {
  bool _isExpanded = false;
  SubscriptionPeriod _selectedPeriod = SubscriptionPeriod.yearly;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionServiceProvider);
    final activeColor = SettingsListItems.getSettingColor(context, SettingType.membership, ref.watch(rotaryColorProvider));
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildExpandableHeader(context, activeColor, subscription, l10n),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: _buildExpandedContent(context, activeColor, subscription, isDark),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 400),
          firstCurve: Curves.easeOutCubic,
          secondCurve: Curves.easeInCubic,
        ),
        SettingsListItems.buildDivider(isDark),
        SettingsListItems.buildSetting(
          icon: Icons.restore_rounded,
          title: l10n.restorePurchases,
          onTap: () async {
            await ref.read(subscriptionServiceProvider).restorePurchases();
            if (context.mounted) {
              CustomNotification.success(context, l10n.done);
            }
          },
          activeColor: activeColor,
          context: context,
          isAction: true,
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context, Color activeColor, SubscriptionService subscription, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsListItems.buildDivider(isDark),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!subscription.isPro) ...[
                SegmentedControl(
                  tabs: [l10n.monthly, l10n.yearlyDiscount],
                  selectedIndex: _selectedPeriod == SubscriptionPeriod.monthly ? 0 : 1,
                  onTabChanged: (index) {
                    setState(() {
                      _selectedPeriod = index == 0 ? SubscriptionPeriod.monthly : SubscriptionPeriod.yearly;
                    });
                  },
                  activeColor: activeColor,
                  scalingFactor: 0.9,
                ),
                const SizedBox(height: 12),
                _buildPremiumCheckoutCard(context, activeColor, subscription, l10n),
                const SizedBox(height: 24),
              ],
              
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  l10n.comparisonTitle,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.4),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              _buildComparisonHeader(context),
              const SizedBox(height: 8),
              _buildComparisonRow(context, l10n.limitVaults, l10n.limitVaultsFree, l10n.limitVaultsPro, activeColor),
              _buildComparisonRow(context, l10n.limitAiAnalysis, l10n.basicAnalysis, l10n.advancedAnalysis, activeColor),
              _buildComparisonRow(context, l10n.limitCloudSync, "-", l10n.yes, activeColor),
              _buildComparisonRow(context, l10n.limitDataRetention, "-", l10n.limitDataRetentionPro, activeColor),
              _buildComparisonRow(context, l10n.limitCustomThemes, "-", l10n.yes, activeColor),
              _buildComparisonRow(context, l10n.limitAdFree, "-", l10n.yes, activeColor),
              
              if (subscription.isPro) ...[
                const SizedBox(height: 24),
                Center(
                  child: CustomButton(
                    label: l10n.cancelSubscriptionTest,
                    onTap: () async => await ref.read(subscriptionServiceProvider).setProStatus(false),
                    isPrimary: false,
                    height: 40,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildComparisonHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const Expanded(flex: 4, child: SizedBox()),
          Expanded(
            flex: 3,
            child: Text(
              "FREE",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.getTextSecondary(context).withValues(alpha: 0.5)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "PREMIUM",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ref.watch(rotaryColorProvider)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(BuildContext context, String feature, String free, String pro, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              feature,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.getTextPrimary(context).withValues(alpha: 0.8)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  free,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.getTextSecondary(context).withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  pro,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: activeColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCheckoutCard(BuildContext context, Color activeColor, SubscriptionService subscription, AppLocalizations l10n) {
    final isYearly = _selectedPeriod == SubscriptionPeriod.yearly;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isYearly ? l10n.yearlyAccess : l10n.monthlyAccess,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    isYearly ? l10n.yearlyPriceDetail : l10n.monthlyPriceDetail,
                    style: TextStyle(fontSize: 11, color: AppColors.getTextSecondary(context).withValues(alpha: 0.6)),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (subscription.offerings?.current != null) ...[
                    Text(
                      subscription.offerings!.current!.availablePackages.firstWhere(
                        (p) => isYearly ? p.packageType == PackageType.annual : p.packageType == PackageType.monthly,
                        orElse: () => subscription.offerings!.current!.availablePackages.first,
                      ).storeProduct.priceString,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ] else ...[
                    Text("₺", style: TextStyle(fontSize: 14, color: activeColor, fontWeight: FontWeight.w800)),
                    Text(isYearly ? "1.190" : "149", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: l10n.upgradeToPro,
            onTap: () {
              final currentUser = Supabase.instance.client.auth.currentUser;
              if (currentUser == null) {
                showCustomDialog(
                  context: context,
                  accentColor: activeColor,
                  title: l10n.loginRequiredTitle,
                  content: l10n.loginRequiredPurchaseDesc,
                  actions: [
                    PrecisionDialogAction(
                      label: l10n.cancel,
                      onTap: () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                    PrecisionDialogAction(
                      label: l10n.loginOrRegister,
                      onTap: () async {
                        Navigator.pop(context);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('Finarcast_is_guest_mode', false);
                        ref.read(guestModeProvider.notifier).state = false;
                      },
                      isPrimary: true,
                    ),
                  ],
                );
                return;
              }

              final subService = ref.read(subscriptionServiceProvider);
              final offerings = subService.offerings;
              
              if (offerings?.current != null) {
                // Eğer gerçek ürünler varsa en uygun paketi bul (Aylık/Yıllık seçimine göre)
                final package = offerings!.current!.availablePackages.firstWhere(
                  (p) => isYearly ? p.packageType == PackageType.annual : p.packageType == PackageType.monthly,
                  orElse: () => offerings.current!.availablePackages.first,
                );
                subService.purchasePackage(package);
              } else {
                // Fallback: Mock status
                subService.setProStatus(true);
              }
            },
            activeColor: activeColor,
            height: 48,
            fontSize: 13,
            letterSpacing: 1.0,
          ),
        ],
      ),
    );
  }



  Widget _buildExpandableHeader(
    BuildContext context, 
    Color activeColor, 
    SubscriptionService subscription, 
    AppLocalizations l10n
  ) {
    final isPro = subscription.isPro;
    return ClickableAction(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(16),
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
                isPro ? Icons.stars_rounded : Icons.stars_outlined, 
                size: 22, 
                color: activeColor
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPro ? "Premium" : l10n.freePlan,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPro ? l10n.privilegesActive : l10n.tapToUnlock,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isPro ? activeColor : AppColors.getTextSecondary(context)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isPro ? "PREMIUM" : "FREE",
                style: TextStyle(
                  color: isPro ? activeColor : AppColors.getTextSecondary(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _isExpanded ? 0.25 : 0.0,
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
    );
  }

}


