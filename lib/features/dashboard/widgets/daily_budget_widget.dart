import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';

/// Günlük bütçe durumunu gösteren yatay widget (2x1)
class DailyBudgetWidget extends StatelessWidget {
  const DailyBudgetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.speed_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GÜNLÜK LİMİT',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 9,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              const Text(
                '₺ 450.00',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Harcanabilir Kalan',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
