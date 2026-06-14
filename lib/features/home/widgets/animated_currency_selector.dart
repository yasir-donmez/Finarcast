import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../shared/widgets/knob_surface.dart';
import '../home_providers.dart';
import '../../../core/providers/settings_provider.dart';

class AnimatedCurrencySelector extends ConsumerWidget {
  final double fontSize;
  final double totalBalance;
  final double? minBalance;
  final double? maxBalance;

  const AnimatedCurrencySelector({
    super.key,
    this.fontSize = 24,
    required this.totalBalance,
    this.minBalance,
    this.maxBalance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rotaryColor = ref.watch(rotaryColorProvider);
    final activeColor = isDark ? rotaryColor : AppColors.getAccentDeep(context, rotaryColor);
    final currencySymbol = ref.watch(settingsProvider.select((s) => s.currencySymbol));

    return Container(
      height: 106,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sol: Para Birimi Simgesi (Sabit Boyut)
          KnobSurface(
            size: 54,
            child: Center(
              child: Text(
                currencySymbol,
                style: TextStyle(
                  color: activeColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Sağ: Tutar + Min/Max
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        CurrencyUtils.formatFullAmount(totalBalance, symbol: ''),
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppCurrency.getCode(currencySymbol),
                        style: TextStyle(
                          color: activeColor.withValues(alpha: isDark ? 0.35 : 0.55),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (minBalance != null && maxBalance != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          _buildRangeIndicator(
                            context: context,
                            icon: Icons.south_east_rounded,
                            amount: minBalance!,
                            color: AppColors.getExpense(context),
                            currencySymbol: currencySymbol,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeColor.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildRangeIndicator(
                            context: context,
                            icon: Icons.north_east_rounded,
                            amount: maxBalance!,
                            color: AppColors.getIncome(context),
                            currencySymbol: currencySymbol,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeIndicator({required BuildContext context, required IconData icon, required double amount, required Color color, required String currencySymbol}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Text(
          CurrencyUtils.formatAmount(amount, currencySymbol: currencySymbol),
          style: TextStyle(
            color: color.withValues(alpha: isDark ? 0.9 : 1.0), // Aydınlıkta tam opak
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
