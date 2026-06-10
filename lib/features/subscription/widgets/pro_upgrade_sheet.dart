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

/// Finarcast "Pro Üyelik" (Paywall) Sayfası.
class ProUpgradeSheet extends ConsumerWidget {
  const ProUpgradeSheet({super.key});

  static void show(BuildContext context) {
    CustomBottomSheet.show(
      context: context,
      child: const ProUpgradeSheet(),
    );
  }

  static void _showLoginRequiredDialog(BuildContext context, WidgetRef ref) {
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
            Navigator.pop(context); // Dialogu kapat
            Navigator.pop(context); // Sheet'i kapat
            await ref.read(authControllerProvider.notifier).exitGuestMode();
          },
          isPrimary: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    child: MembershipOrb(
                      color: primaryColor,
                      size: isSmallScreen ? 44 : 52,
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
                  const SizedBox(height: 6),
                  Text(
                    l10n.unlockFinancialPotential,
                    style: TextStyle(
                      fontSize: 14, 
                      color: secondaryTextColor.withValues(alpha: isDark ? 0.65 : 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 🚀 Avantajlar Hepsini Göster
            _buildFeatureItem(context, Icons.analytics_rounded, l10n.aiAnalysis, l10n.aiAnalysisDesc, isSmallScreen),
            _buildFeatureItem(context, Icons.account_balance_wallet_rounded, l10n.unlimitedVaults, l10n.unlimitedVaultsDesc, isSmallScreen),
            _buildFeatureItem(context, Icons.sync_rounded, l10n.cloudSync, l10n.cloudSyncDesc, isSmallScreen),
            _buildFeatureItem(context, Icons.palette_rounded, l10n.customThemes, l10n.customThemesDesc, isSmallScreen),
            _buildFeatureItem(context, Icons.block_rounded, l10n.zeroAds, l10n.zeroAdsDesc, isSmallScreen),
            
            SizedBox(height: verticalSpacing * 1.5),
            
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
            else if (subService.offerings?.current != null)
              // 💎 GERÇEK MAĞAZA ÜRÜNLERİ (RevenueCat)
              ...subService.offerings!.current!.availablePackages.map((package) {
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
                    onTap: () async {
                      final currentUser = Supabase.instance.client.auth.currentUser;
                      if (currentUser == null) {
                        _showLoginRequiredDialog(context, ref);
                        return;
                      }
                      final success = await subService.purchasePackage(package);
                      if (success && context.mounted) Navigator.pop(context);
                    },
                  ),
                );
              })
            else
              // 🛠 FALLBACK (Mock/Simulated UI)
              Column(
                children: [
                  _buildPlanCard(
                    context: context,
                    title: l10n.yearlyPremiumSimulated,
                    price: l10n.yearlyPremiumSimulatedPrice,
                    subtitle: l10n.yearlyPremiumSimulatedSubtitle,
                    badge: l10n.bestValue,
                    isPopular: true,
                    isSmall: isSmallScreen,
                    onTap: () {
                      final currentUser = Supabase.instance.client.auth.currentUser;
                      if (currentUser == null) {
                        _showLoginRequiredDialog(context, ref);
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
                    onTap: () {
                      final currentUser = Supabase.instance.client.auth.currentUser;
                      if (currentUser == null) {
                        _showLoginRequiredDialog(context, ref);
                        return;
                      }
                      subService.setProStatus(true);
                      Navigator.pop(context);
                    },
                  ),
                ],
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
          ],
        );
      },
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle, bool isSmall) {
    final primaryColor = AppColors.getPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 9),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: isSmall ? 16 : 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.w800, 
                    fontSize: isSmall ? 13 : 15,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle, 
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12, 
                    color: AppColors.getTextSecondary(context).withValues(alpha: isDark ? 0.65 : 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? price,
    String? badge,
    bool isCurrent = false,
    bool isPopular = false,
    bool isSmall = false,
  }) {
    final primaryColor = AppColors.getPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClickableAction(
      onTap: onTap,
      width: double.infinity,
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GlassSurface(
            borderRadius: 24,
            blurSigma: 15,
            borderWidth: isPopular ? 2.0 : 1.0,
            borderColor: isCurrent
                ? Colors.grey.withValues(alpha: 0.3)
                : (isPopular
                    ? primaryColor.withValues(alpha: 0.8)
                    : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1))),
            backgroundColor: isCurrent
                ? (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01))
                : (isPopular
                    ? (isDark ? primaryColor.withValues(alpha: 0.12) : primaryColor.withValues(alpha: 0.06))
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: isSmall ? 14 : 18),
            boxShadow: [
              if (isPopular)
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
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
                            fontSize: isSmall ? 15 : 17,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle, 
                          style: TextStyle(
                            fontSize: 12, 
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
                        fontSize: isSmall ? 16 : 19,
                        color: isPopular ? primaryColor : AppColors.getTextPrimary(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (badge != null)
            Positioned(
              top: -10,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, AppColors.getThemeSecondary(primaryColor)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4), 
                      blurRadius: 10, 
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white, 
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
