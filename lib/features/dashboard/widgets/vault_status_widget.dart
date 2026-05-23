import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';

/// Kasa durumunu gösteren küçük widget (1x1)
class VaultStatusWidget extends StatelessWidget {
  const VaultStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'KASALAR',
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 9,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '12',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'Aktif Kasa',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 9),
        ),
      ],
    );
  }
}
