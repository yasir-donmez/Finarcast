import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/services/subscription_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/clickable_action.dart';
import '../../../../shared/widgets/segmented_control.dart';
import '../../../dashboard/dashboard_providers.dart';
import '../profile_list_items.dart';

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
    final activeColor = ProfileListItems.getSettingColor(context, SettingType.membership, ref.watch(rotaryColorProvider));
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
        ProfileListItems.buildDivider(isDark),
        ProfileListItems.buildSetting(
          icon: Icons.restore_rounded,
          title: l10n.restorePurchases,
          onTap: () async {
            await ref.read(subscriptionServiceProvider).restorePurchases();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.done)),
              );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileListItems.buildDivider(isDark),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!subscription.isPro) ...[
                SegmentedControl(
                  tabs: const ["Aylık", "Yıllık (-%33)"],
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
                _buildPremiumCheckoutCard(context, activeColor, subscription),
                const SizedBox(height: 24),
              ],
              
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  "KARŞILAŞTIRMA",
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
              _buildComparisonRow(context, "Kasa Sınırı", "2 Kasa", "Sınırsız", activeColor),
              _buildComparisonRow(context, "Yapay Zeka Analizi", "Temel", "Gelişmiş", activeColor),
              _buildComparisonRow(context, "Özel Temalar", "-", "Evet", activeColor),
              _buildComparisonRow(context, "Reklamsız Deneyim", "-", "Evet", activeColor),
              
              if (subscription.isPro) ...[
                const SizedBox(height: 24),
                Center(
                  child: CustomButton(
                    label: "Aboneliği İptal Et (Test)",
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
          const Expanded(flex: 2, child: SizedBox()),
          Expanded(
            child: Text(
              "FREE",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.getTextSecondary(context).withValues(alpha: 0.5)),
            ),
          ),
          Expanded(
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.getTextPrimary(context).withValues(alpha: 0.8)),
            ),
          ),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.getTextSecondary(context).withValues(alpha: 0.5)),
            ),
          ),
          Expanded(
            child: Text(
              pro,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: activeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCheckoutCard(BuildContext context, Color activeColor, SubscriptionService subscription) {
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
                    isYearly ? "Yıllık Erişim" : "Aylık Erişim",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    isYearly ? "Ayda ₺99'ye gelir" : "Her ay yenilenir",
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
            label: "PREMIUM'A YÜKSELT",
            onTap: () {
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
                    isPro ? "Premium Üyelik" : "Ücretsiz Üyelik",
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPro ? "Ayrıcalıklar aktif" : "Yükseltmek ve sınırları kaldırmak için dokunun",
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


