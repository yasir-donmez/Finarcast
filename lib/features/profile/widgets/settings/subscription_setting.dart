import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/services/subscription_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/precision_button.dart';
import '../../../../shared/widgets/precision_card.dart';
import '../../../../shared/widgets/precision_membership_orb.dart';
import '../../../../shared/widgets/precision_action.dart';
import '../../../../shared/widgets/precision_segmented_control.dart';
import '../../../dashboard/dashboard_providers.dart';
import '../profile_list_items.dart';

class SubscriptionSetting extends ConsumerStatefulWidget {
  const SubscriptionSetting({super.key});

  @override
  ConsumerState<SubscriptionSetting> createState() => _SubscriptionSettingState();
}

class _SubscriptionSettingState extends ConsumerState<SubscriptionSetting> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  SubscriptionPeriod _selectedPeriod = SubscriptionPeriod.yearly;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionServiceProvider);
    final activeColor = ref.watch(rotaryColorProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildPremiumHeroCard(context, subscription, activeColor, l10n),
        const SizedBox(height: 16),
        PrecisionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildExpandableHeader(context, activeColor, l10n),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: _buildExpandedContent(context, activeColor, subscription, isDark),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 400),
                firstCurve: Curves.easeOutCubic,
                secondCurve: Curves.easeInCubic,
              ),
              if (!_isExpanded) ProfileListItems.buildDivider(isDark),
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
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
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
                PrecisionSegmentedControl(
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
                  child: PrecisionButton(
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
              "PRO",
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
          PrecisionButton(
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

  Widget _buildPremiumHeroCard(
    BuildContext context, 
    SubscriptionService subscription, 
    Color activeColor, 
    AppLocalizations l10n
  ) {
    final isPro = subscription.isPro;
    final cardColor = isPro ? activeColor : AppColors.getTextSecondary(context).withValues(alpha: 0.08);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor.withValues(alpha: isPro ? 0.9 : 0.08),
                cardColor.withValues(alpha: isPro ? 0.5 : 0.03),
              ],
            ),
            boxShadow: isPro ? [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              )
            ] : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -30,
                    child: PrecisionMembershipOrb(
                      color: isPro ? Colors.white : activeColor,
                      size: 150,
                      morphFactor: isPro ? 1.0 : 0.2,
                      showParticles: isPro,
                    ),
                  ),
                  if (isPro)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _PremiumRimPainter(
                            progress: _glowController.value,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isPro ? Colors.white : activeColor).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isPro ? "PRO" : "FREE",
                            style: TextStyle(
                              color: isPro ? Colors.white : activeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          isPro ? "Ayrıcalıklar Sizinle" : "Pro'ya Geçin",
                          style: TextStyle(
                            color: isPro ? Colors.white : AppColors.getTextPrimary(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          isPro 
                            ? "Premium özellikler aktif."
                            : "Sınırları kaldırın.",
                          style: TextStyle(
                            color: (isPro ? Colors.white : AppColors.getTextSecondary(context)).withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PrecisionAction(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(24),
                    child: const SizedBox(width: double.infinity, height: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableHeader(BuildContext context, Color activeColor, AppLocalizations l10n) {
    return PrecisionAction(
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
                border: Border.all(
                  color: activeColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(Icons.stars_rounded, size: 22, color: activeColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Ayrıcalıkları İncele",
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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

class _PremiumRimPainter extends CustomPainter {
  final double progress;
  final Color color;
  _PremiumRimPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.4),
          color.withValues(alpha: 0.0),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }
  @override
  bool shouldRepaint(covariant _PremiumRimPainter oldDelegate) => oldDelegate.progress != progress;
}
