import 'package:flutter/material.dart';
import '../../../shared/widgets/precision_glass_card.dart';
import '../../../core/theme/app_constants.dart';

class VaultFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  const VaultFilterChip({
    super.key,
    required this.label, 
    required this.isActive, 
    required this.onTap, 
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PrecisionGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 16,
        isGlass: true,
        color: null, // Parlamayı kaldırdık
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            color: isActive ? activeColor : AppColors.getTextSecondary(context).withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
