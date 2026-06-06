import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/providers/db_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Kasa durumunu gösteren küçük widget (1x1)
class VaultStatusWidget extends ConsumerWidget {
  const VaultStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final vaults = ref.watch(allVaultsProvider);
    final count = vaults.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.vaultsUpper,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 9,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          l10n.activeVaults(count),
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 9),
        ),
      ],
    );
  }
}
