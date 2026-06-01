import 'package:flutter/material.dart';

/// Hızlı İşlem Ekleme Widget'ı (1x1)
class QuickActionWidget extends StatelessWidget {
  const QuickActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_rounded,
            color: theme.colorScheme.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'EKLE',
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
