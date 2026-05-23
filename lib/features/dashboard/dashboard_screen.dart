import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_constants.dart';
import '../../core/providers/db_providers.dart';
import 'dashboard_providers.dart';
import 'widgets/rotary_time_dial.dart';
import 'widgets/dashboard_widget_board.dart';
import 'widgets/animated_currency_selector.dart';

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
    final minBalance = ref.watch(netMinBalanceProvider) + bonus;
    final maxBalance = ref.watch(netMaxBalanceProvider) + bonus;

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
                const DashboardWidgetBoard(),
                
                const Spacer(flex: 2),

                // 2. Bakiye Alanı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                  child: AnimatedCurrencySelector(
                    fontSize: 28,
                    totalBalance: totalBalance,
                    minBalance: hasFlexibleRange ? minBalance : null,
                    maxBalance: hasFlexibleRange ? maxBalance : null,
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
