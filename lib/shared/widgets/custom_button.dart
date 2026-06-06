import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';
import '../../core/utils/string_utils.dart';
import 'clickable_action.dart';

/// Finarcast Standart "Ghost & Precision" Butonu.
/// Arka planı olmayan, sadece metin ve vurgulu parlamadan oluşan premium buton.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary; // Olumlu (renkli) mi yoksa nötr (beyaz) mi?
  final Color? activeColor;
  final double? width;
  final double? height;
  final double fontSize;
  final double letterSpacing;
  final bool isFilled;
  final Widget? leading;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.isFilled = false,
    this.leading,
    this.activeColor,
    this.width,
    this.height = 60,
    this.fontSize = 16,
    this.letterSpacing = 2.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Renk belirleme: Olumlu ise aktif renk, olumsuz/nötr ise beyaz
    final Color color = activeColor ?? (isPrimary 
        ? AppColors.getPrimary(context) 
        : (Theme.of(context).brightness == Brightness.dark 
            ? Colors.white.withValues(alpha: 0.9) 
            : AppColors.getTextPrimary(context).withValues(alpha: 0.8)));

    return ClickableAction(
      onTap: isLoading ? () {} : onTap,
      width: width ?? double.infinity,
      height: height,
      color: Colors.transparent,
      pressedColor: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(100),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 12),
                      ],
                      Text(
                        label.toSafeUpperCase(context),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: fontSize,
                          letterSpacing: letterSpacing,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
