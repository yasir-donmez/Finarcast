import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/selector_field.dart';
import '../../../shared/widgets/picker_field.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/home_widget_layout_provider.dart';
import '../home_providers.dart';
import '../../../core/providers/db_providers.dart';
import 'home_widget.dart';

class HomeWidgetManagerSheet extends ConsumerWidget {
  const HomeWidgetManagerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pages = ref.watch(widgetLayoutProvider);
    final activeColor = AppColors.getPrimary(context);
    final scalingFactor = (MediaQuery.of(context).size.height / 812.0).clamp(0.85, 1.0);

    // Flat widgets list to find configs
    final flatList = pages.expand((p) => p).toList();
    final timelineConfig = flatList.firstWhere(
      (w) => w.type == 'timeline',
      orElse: () => WidgetConfig(id: '1', type: 'timeline', size: HomeWidgetSize.large, page: 0),
    );
    final radarConfig = flatList.firstWhere(
      (w) => w.type == 'radar',
      orElse: () => WidgetConfig(id: '2', type: 'radar', size: HomeWidgetSize.large, page: 1),
    );
    final spendingConfig = flatList.firstWhere(
      (w) => w.type == 'spending',
      orElse: () => WidgetConfig(id: '3', type: 'spending', size: HomeWidgetSize.large, page: 2),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        // 1. Total Balance Card
        _buildBalanceCard(context, ref, activeColor, scalingFactor, l10n),
        const SizedBox(height: 10),
        // 2. Timeline Card
        _buildWidgetCard(context, ref, timelineConfig, l10n.historyTitle, Icons.history_rounded, activeColor, scalingFactor, l10n),
        const SizedBox(height: 10),
        // 3. Radar Card
        _buildWidgetCard(context, ref, radarConfig, l10n.radarTitle, Icons.radar_rounded, activeColor, scalingFactor, l10n),
        const SizedBox(height: 10),
        // 4. Spending Card
        _buildWidgetCard(context, ref, spendingConfig, l10n.giantsTitle, Icons.bar_chart_rounded, activeColor, scalingFactor, l10n),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    WidgetRef ref,
    Color activeColor,
    double scalingFactor,
    AppLocalizations l10n,
  ) {
    final vaults = ref.watch(allVaultsProvider);
    final selectedVaultId = ref.watch(homeMainBalanceVaultIdProvider);

    final List<String> vaultItems = [l10n.allVaults];
    for (var vault in vaults) {
      vaultItems.add(vault.name);
    }

    int selectedIdx = 0;
    if (selectedVaultId != null) {
      final foundIdx = vaults.indexWhere((v) => 'v_${v.id}' == selectedVaultId);
      if (foundIdx != -1) {
        selectedIdx = foundIdx + 1;
      }
    }

    return CustomCard(
      scalingFactor: scalingFactor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_rounded,
                color: activeColor,
                size: 20 * scalingFactor,
              ),
              SizedBox(width: 12 * scalingFactor),
              Expanded(
                child: Text(
                  l10n.totalBalance,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15 * scalingFactor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PickerField(
            icon: Icons.account_balance_wallet_rounded,
            label: l10n.vault,
            pickerWidth: 160,
            items: vaultItems,
            selectedIndex: selectedIdx.clamp(0, vaultItems.length - 1),
            scalingFactor: scalingFactor,
            onChanged: (newIdx) {
              String? newVaultId;
              if (newIdx > 0 && newIdx < vaultItems.length) {
                newVaultId = 'v_${vaults[newIdx - 1].id}';
              }
              ref.read(homeMainBalanceVaultIdProvider.notifier).state = newVaultId;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetCard(
    BuildContext context,
    WidgetRef ref,
    WidgetConfig config,
    String title,
    IconData icon,
    Color activeColor,
    double scalingFactor,
    AppLocalizations l10n,
  ) {
    final vaults = ref.watch(allVaultsProvider);
    final List<String> vaultItems = [l10n.allVaults];
    for (var vault in vaults) {
      vaultItems.add(vault.name);
    }

    int selectedIdx = 0;
    if (config.selectedVaultId != null) {
      final foundIdx = vaults.indexWhere((v) => 'v_${v.id}' == config.selectedVaultId);
      if (foundIdx != -1) {
        selectedIdx = foundIdx + 1;
      }
    }

    return CustomCard(
      scalingFactor: scalingFactor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: activeColor,
                size: 20 * scalingFactor,
              ),
              SizedBox(width: 12 * scalingFactor),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15 * scalingFactor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Page selector (sıralama 1 2 3)
          SelectorField(
            icon: Icons.dashboard_rounded,
            label: l10n.pageLabel,
            pickerWidth: 160,
            items: const ['1', '2', '3'],
            selectedIndex: config.page.clamp(0, 2),
            scalingFactor: scalingFactor,
            onChanged: (newIdx) {
              ref.read(widgetLayoutProvider.notifier).changeWidgetPage(config.id, newIdx);
            },
          ),
          SizedBox(height: 6 * scalingFactor),
          // Vault selector
          PickerField(
            icon: Icons.account_balance_wallet_rounded,
            label: l10n.vault,
            pickerWidth: 160,
            items: vaultItems,
            selectedIndex: selectedIdx.clamp(0, vaultItems.length - 1),
            scalingFactor: scalingFactor,
            onChanged: (newIdx) {
              String? newVaultId;
              if (newIdx > 0 && newIdx < vaultItems.length) {
                newVaultId = 'v_${vaults[newIdx - 1].id}';
              }
              ref.read(widgetLayoutProvider.notifier).setWidgetVault(config.id, newVaultId);
            },
          ),
        ],
      ),
    );
  }
}
