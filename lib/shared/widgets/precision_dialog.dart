import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_constants.dart';
import 'precision_button.dart';

/// Finarcast "Precision" Serisi Diyalog.
/// PrecisionSheet tasarım diliyle uyumlu, temiz ve premium bir onay ekranı.
class PrecisionDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<PrecisionDialogAction> actions;
  final Color? accentColor;

  const PrecisionDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = accentColor ?? AppColors.getPrimary(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24.0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.getSurface(context).withValues(alpha: isDark ? 0.9 : 1.0),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.4),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sheet Stilinde Handle
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    children: [
                      // Başlık
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.getTextPrimary(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // İçerik
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getTextSecondary(context),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Butonlar
                      Row(
                        children: actions.map((action) {
                          final bool isLast = action == actions.last;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: isLast ? 0 : 12),
                              child: PrecisionButton(
                                label: action.label,
                                onTap: action.onTap,
                                isPrimary: action.isPrimary,
                                activeColor: action.isPrimary ? activeColor : AppColors.getTextSecondary(context),
                                height: 52,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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

class PrecisionDialogAction {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  PrecisionDialogAction({
    required this.label,
    required this.onTap,
    this.isPrimary = true,
  });
}

Future<T?> showPrecisionDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required List<PrecisionDialogAction> actions,
  Color? accentColor,
}) {
  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
    barrierDismissible: true,
    barrierLabel: "PrecisionDialog",
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: PrecisionDialog(
            title: title,
            content: content,
            actions: actions,
            accentColor: accentColor,
          ),
        ),
      );
    },
  );
}
