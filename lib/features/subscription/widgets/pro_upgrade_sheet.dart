import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/services/subscription_service.dart';
import '../../../shared/widgets/clickable_action.dart';
import '../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../shared/widgets/membership_orb.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/custom_notification.dart';

/// Finarcast "Pro Üyelik" (Paywall) Sayfası.
class ProUpgradeSheet extends ConsumerStatefulWidget {
  const ProUpgradeSheet({super.key});

  static void show(BuildContext context) {
    CustomBottomSheet.show(
      context: context,
      child: const ProUpgradeSheet(),
    );
  }

  @override
  ConsumerState<ProUpgradeSheet> createState() => _ProUpgradeSheetState();
}

class _ProUpgradeSheetState extends ConsumerState<ProUpgradeSheet> with SingleTickerProviderStateMixin {
  late AnimationController _sheenController;
  late Animation<double> _sheenAnimation;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _sheenAnimation = CurvedAnimation(
      parent: _sheenController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sheenController.dispose();
    super.dispose();
  }

  void _showLoginRequiredDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showCustomDialog(
      context: context,
      accentColor: AppColors.getPrimary(context),
      title: l10n.loginRequired,
      content: l10n.loginRequiredForPurchase,
      actions: [
        PrecisionDialogAction(
          label: l10n.cancel,
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        PrecisionDialogAction(
          label: l10n.loginOrSignUp,
          onTap: () async {
            Navigator.of(context).popUntil((route) => route.isFirst);
            await ref.read(authControllerProvider.notifier).exitGuestMode();
          },
          isPrimary: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subService = ref.watch(subscriptionServiceProvider);
    final primaryColor = AppColors.getPrimary(context);
    final secondaryTextColor = AppColors.getTextSecondary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenHeight < 700;
        final verticalSpacing = isSmallScreen ? 10.0 : 16.0;
        final headerSpacing = isSmallScreen ? 12.0 : 20.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Üst Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0, 
                vertical: isSmallScreen ? 12.0 : 20.0
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'pro_orb',
                    child: AnimatedBuilder(
                      animation: _sheenAnimation,
                      builder: (context, child) {
                        return MembershipOrb(
                          color: const Color(0xFFFFB300),
                          sheenVal: _sheenAnimation.value,
                          size: isSmallScreen ? 44 : 52,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: headerSpacing),
                  Text(
                    l10n.upgradeToPremiumTitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 22 : 26, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: -0.8
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 🚀 Avantajlar Izgarası (Grid - Kompakt, ekrana sığan, temiz ve performanslı statik tasarım)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: isSmallScreen ? 4.2 : 3.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildFeatureItem(context, Icons.analytics_rounded, l10n.limitAiAnalysis),
                _buildFeatureItem(context, Icons.account_balance_wallet_rounded, l10n.unlimitedVaults),
                _buildFeatureItem(context, Icons.sync_rounded, l10n.cloudSync),
                _buildFeatureItem(context, Icons.palette_rounded, l10n.customThemes),
                _buildFeatureItem(context, Icons.table_view_rounded, l10n.exportExcel),
              ],
            ),
            
            SizedBox(height: verticalSpacing),
            
            // PLANLAR
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  l10n.availablePlans, 
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.5,
                    color: secondaryTextColor.withValues(alpha: isDark ? 0.4 : 0.7),
                  ),
                ),
              ),
            ),
            SizedBox(height: verticalSpacing),
            
            if (subService.isInitializing)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )
            else
              AnimatedBuilder(
                animation: _sheenAnimation,
                builder: (context, child) {
                  final sheenVal = _sheenAnimation.value;
                  
                  if (subService.offerings?.current != null) {
                    // 💎 GERÇEK MAĞAZA ÜRÜNLERİ (RevenueCat)
                    return Column(
                      children: subService.offerings!.current!.availablePackages.map((package) {
                        final isYearly = package.packageType == PackageType.annual;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                          child: _buildPlanCard(
                            context: context,
                            title: isYearly ? l10n.yearlyPremium : l10n.monthlyPremium,
                            price: package.storeProduct.priceString,
                            subtitle: isYearly ? l10n.bestValueFreeTrialSubtitle : l10n.cancelAnytime,
                            badge: isYearly ? l10n.bestValue : null,
                            isPopular: isYearly,
                            isSmall: isSmallScreen,
                            sheenVal: sheenVal,
                            onTap: () async {
                              final currentUser = Supabase.instance.client.auth.currentUser;
                              if (currentUser == null) {
                                _showLoginRequiredDialog(context);
                                return;
                              }
                              final success = await subService.purchasePackage(package);
                              if (success && context.mounted) Navigator.pop(context);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    // 🛠 FALLBACK (Mock/Simulated UI)
                    return Column(
                      children: [
                        _buildPlanCard(
                          context: context,
                          title: l10n.yearlyPremiumSimulated,
                          price: l10n.yearlyPremiumSimulatedPrice,
                          subtitle: l10n.yearlyPremiumSimulatedSubtitle,
                          badge: l10n.bestValue,
                          isPopular: true,
                          isSmall: isSmallScreen,
                          sheenVal: sheenVal,
                          onTap: () {
                            final currentUser = Supabase.instance.client.auth.currentUser;
                            if (currentUser == null) {
                              _showLoginRequiredDialog(context);
                              return;
                            }
                            subService.setProStatus(true);
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        _buildPlanCard(
                          context: context,
                          title: l10n.monthlyPremiumSimulated,
                          price: l10n.monthlyPremiumSimulatedPrice,
                          subtitle: l10n.cancelAnytime,
                          isSmall: isSmallScreen,
                          sheenVal: sheenVal,
                          onTap: () {
                            final currentUser = Supabase.instance.client.auth.currentUser;
                            if (currentUser == null) {
                              _showLoginRequiredDialog(context);
                              return;
                            }
                            subService.setProStatus(true);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            
            SizedBox(height: verticalSpacing),
            Text(
              l10n.subscriptionAutoRenewalNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10, 
                color: secondaryTextColor.withValues(alpha: isDark ? 0.45 : 0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                await ref.read(subscriptionServiceProvider).restorePurchases();
                if (context.mounted) {
                  CustomNotification.success(context, l10n.done);
                }
              },
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.restorePurchases,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title) {
    final primaryColor = AppColors.getPrimary(context);
    final premiumColor = const Color(0xFFFFB300);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.08),
                premiumColor.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: premiumColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Icon(
            icon, 
            color: premiumColor,
            size: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title, 
            style: const TextStyle(
              fontWeight: FontWeight.w700, 
              fontSize: 12.5,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double sheenVal,
    String? price,
    String? badge,
    bool isCurrent = false,
    bool isPopular = false,
    bool isSmall = false,
  }) {
    final premiumColor = const Color(0xFFFFB300); // Gold
    final shineColor = Colors.white; // Shine highlight
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final beginAlignment = Alignment(-3.5 + sheenVal * 5.5, -0.5);
    final endAlignment = Alignment(-2.0 + sheenVal * 5.5, 0.5);

    return ClickableAction(
      onTap: onTap,
      width: double.infinity,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GlassSurface(
            borderRadius: 16,
            blurSigma: 15,
            borderWidth: isPopular ? 0.0 : 1.0,
            borderColor: isCurrent
                ? Colors.grey.withValues(alpha: 0.3)
                : (isPopular
                    ? Colors.transparent
                    : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1))),
            backgroundColor: isCurrent
                ? (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01))
                : (isPopular
                    ? (isDark ? premiumColor.withValues(alpha: 0.06) : premiumColor.withValues(alpha: 0.03))
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmall ? 10 : 12),
            showShadow: true,
            boxShadow: [
              if (isPopular)
                BoxShadow(
                  color: premiumColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
            ],
            child: Opacity(
              opacity: isCurrent ? 0.5 : 1.0,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title, 
                          style: TextStyle(
                            fontWeight: FontWeight.w800, 
                            fontSize: isSmall ? 14 : 16,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle, 
                          style: TextStyle(
                            fontSize: 11, 
                            color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.7 : 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (price != null)
                    Text(
                      price,
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: isSmall ? 15 : 18,
                        color: isPopular ? premiumColor : AppColors.getTextPrimary(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (isPopular)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: GradientBorderPainter(
                    width: 1.5,
                    radius: 16,
                    gradient: LinearGradient(
                      colors: [
                        premiumColor,
                        shineColor,
                        premiumColor,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: beginAlignment,
                      end: endAlignment,
                    ),
                  ),
                ),
              ),
            ),
          
          if (badge != null)
            Positioned(
              top: -8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      premiumColor,
                      const Color(0xFFFFD54F),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: premiumColor.withValues(alpha: 0.2), 
                      blurRadius: 6, 
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.black, 
                    fontSize: 9, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final double width;
  final double radius;
  final Gradient gradient;

  GradientBorderPainter({
    required this.width,
    required this.radius,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);
    
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(GradientBorderPainter oldDelegate) =>
      oldDelegate.width != width ||
      oldDelegate.radius != radius ||
      oldDelegate.gradient != gradient;
}
