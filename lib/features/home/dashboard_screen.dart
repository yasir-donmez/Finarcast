import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_constants.dart';
import 'home_providers.dart';
import 'widgets/rotary_time_dial.dart';
import 'widgets/home_widget_board.dart';
import 'widgets/animated_currency_selector.dart';
import 'widgets/home_widget_manager_sheet.dart';
import '../../shared/widgets/custom_bottom_sheet.dart';
import '../../l10n/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final totalBalance = ref.watch(displayBalanceProvider);
    final bonus = ref.watch(simulationBonusProvider);
    final minBalance = ref.watch(homeMinBalanceProvider) + bonus;
    final maxBalance = ref.watch(homeMaxBalanceProvider) + bonus;

    final bool hasFlexibleRange = minBalance != totalBalance || maxBalance != totalBalance;

    return Stack(
      children: [
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: AppSizes.paddingSmall),
            
           
                
                
                // 1. Widget Board
                const HomeWidgetBoard(),
                
                const Spacer(flex: 2),

                // 2. Bakiye Alanı (Uzun basınca Widget Manager açılır)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                  child: GestureDetector(
                    onLongPress: () {
                      HapticFeedback.heavyImpact();
                      final l10n = AppLocalizations.of(context)!;
                      CustomBottomSheet.show(
                        context: context,
                        title: l10n.home,
                        child: const HomeWidgetManagerSheet(),
                      );
                    },
                    child: AnimatedCurrencySelector(
                      fontSize: 28,
                      totalBalance: totalBalance,
                      minBalance: hasFlexibleRange ? minBalance : null,
                      maxBalance: hasFlexibleRange ? maxBalance : null,
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),

                // 3. Zaman Kadranı
                Expanded(
                  flex: 48,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: const RotaryTimeDial(),
                      ),
                    ),
                  ),
                ),
                
                // 4. Alt Boşluk
                const Spacer(flex: 8), 
              ],
            ),
          ),
        ),
      ],
    );
  }
}
