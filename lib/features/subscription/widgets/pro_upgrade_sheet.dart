import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/services/subscription_service.dart';
import '../../../shared/widgets/precision_action.dart';
import '../../../shared/widgets/precision_sheet.dart';
import '../../../shared/widgets/precision_membership_orb.dart';

/// Finarcast "Pro Üyelik" (Paywall) Sayfası.
class ProUpgradeSheet extends ConsumerWidget {
  const ProUpgradeSheet({super.key});

  static void show(BuildContext context) {
    PrecisionSheet.show(
      context: context,
      child: const ProUpgradeSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subService = ref.watch(subscriptionServiceProvider);
    final primaryColor = AppColors.getPrimary(context);
    final secondaryTextColor = AppColors.getTextSecondary(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenHeight < 700;
        final verticalSpacing = isSmallScreen ? 8.0 : 16.0;
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
                    child: PrecisionMembershipOrb(
                      color: primaryColor,
                      size: isSmallScreen ? 36 : 44,
                    ),
                  ),
                  SizedBox(height: headerSpacing),
                  Text(
                    'Finarcast Premium\'a Geçin',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 22 : 26, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: -0.5
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isSmallScreen) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Finansal potansiyelinizi %100 açığa çıkarın.',
                      style: TextStyle(
                        fontSize: 14, 
                        color: secondaryTextColor.withValues(alpha: 0.6)
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            // 🚀 Avantajlar
            _buildFeatureItem(context, Icons.analytics_rounded, 'AI Analizleri', 'Günlük sınırsız derin analiz.', isSmallScreen),
            _buildFeatureItem(context, Icons.account_balance_wallet_rounded, 'Sınırsız Kasa', 'Dilediğiniz kadar kasa.', isSmallScreen),
            _buildFeatureItem(context, Icons.block_rounded, 'Sıfır Reklam', 'Kesintisiz deneyim.', isSmallScreen),
            
            SizedBox(height: verticalSpacing * 1.5),
            
            // PLANLAR
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MEVCUT PLANLAR', 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.2,
                  color: secondaryTextColor.withValues(alpha: 0.4),
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
                    title: isYearly ? 'Yıllık Premium' : 'Aylık Premium',
                    price: package.storeProduct.priceString,
                    subtitle: isYearly ? 'En iyi değer' : 'İstediğin zaman iptal et',
                    badge: isYearly ? 'AVANTAJLI' : null,
                    isPopular: isYearly,
                    isSmall: isSmallScreen,
                    backgroundColor: isYearly ? Colors.pinkAccent.withValues(alpha: 0.08) : null,
                    borderColor: isYearly ? primaryColor.withValues(alpha: 0.5) : null,
                    onTap: () async {
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
                    title: 'Yıllık Premium (Simüle)',
                    price: '₺199.99 / yıl',
                    subtitle: 'Aylık ₺16.66',
                    badge: 'AVANTAJLI',
                    isPopular: true,
                    isSmall: isSmallScreen,
                    backgroundColor: Colors.pinkAccent.withValues(alpha: 0.08),
                    borderColor: primaryColor.withValues(alpha: 0.5),
                    onTap: () {
                      subService.setProStatus(true);
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildPlanCard(
                    context: context,
                    title: 'Aylık Premium (Simüle)',
                    price: '₺24.99 / ay',
                    subtitle: 'İstediğin zaman iptal et',
                    isSmall: isSmallScreen,
                    onTap: () {
                      subService.setProStatus(true);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            
            SizedBox(height: verticalSpacing),
            
            // 🔘 Alt Bilgi ve Restore
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '7 gün ücretsiz deneme içerir.',
                  style: TextStyle(
                    fontSize: 10, 
                    color: secondaryTextColor.withValues(alpha: 0.3)
                  ),
                ),
                TextButton(
                  onPressed: () => subService.restorePurchases(),
                  child: Text(
                    'Satın Almaları Geri Yükle',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle, bool isSmall) {
    final primaryColor = AppColors.getPrimary(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 4 : 8),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: isSmall ? 18 : 20),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmall ? 14 : 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subtitle, 
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12, 
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.5)
                    ),
                    overflow: TextOverflow.ellipsis,
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
    Color? borderColor,
    Color? backgroundColor,
    bool isSmall = false,
  }) {
    final primaryColor = AppColors.getPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PrecisionAction(
      onTap: onTap,
      width: double.infinity,
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmall ? 10 : 14),
            decoration: BoxDecoration(
              color: backgroundColor ?? (isCurrent 
                  ? (isDark ? Colors.white : Colors.black).withValues(alpha: 0.002) 
                  : (isPopular 
                      ? (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.04) 
                      : (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.04 : 0.02))),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: borderColor ?? (isCurrent 
                    ? (isDark ? Colors.white : Colors.black).withValues(alpha: 0.01) 
                    : (isPopular ? primaryColor : (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.12))),
                width: isPopular ? 2.5 : 1.2,
              ),
              boxShadow: [
                if (isPopular)
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Opacity(
              opacity: isCurrent ? 0.4 : 1.0,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? Colors.grey : (isPopular ? primaryColor : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25)),
                        width: 1.5,
                      ),
                    ),
                    child: isCurrent ? const Center(
                      child: Icon(Icons.check_rounded, size: 12, color: Colors.grey),
                    ) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title, 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmall ? 14 : 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle, 
                          style: TextStyle(fontSize: 12, color: AppColors.getTextSecondary(context).withValues(alpha: 0.5)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (price != null)
                    Text(
                      price,
                      style: TextStyle(
                        fontWeight: FontWeight.w900, 
                        fontSize: isSmall ? 15 : 18,
                        color: AppColors.getTextPrimary(context)
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (badge != null)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3), 
                      blurRadius: 8, 
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 8, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
