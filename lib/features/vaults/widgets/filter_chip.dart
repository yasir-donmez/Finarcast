import 'package:flutter/material.dart';
import '../../../shared/widgets/solid_surface.dart';
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
      child: SolidSurface(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 16,
        color: null, // Parlamayı kaldırdık
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            color: isActive ? AppColors.getAccentDeep(context, activeColor) : AppColors.getTextSecondary(context).withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
