import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';
import 'custom_button.dart';
import 'glass_surface.dart';

/// Finarcast "Precision" Serisi Diyalog.
/// CustomBottomSheet tasarım diliyle uyumlu, temiz ve premium bir onay ekranı.
class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<PrecisionDialogAction> actions;
  final Color? accentColor;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = accentColor ?? AppColors.getPrimary(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24.0),
      child: GlassSurface(
        width: double.infinity,
        borderRadius: 28,
        blurSigma: 20,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
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
                          child: CustomButton(
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

Future<T?> showCustomDialog<T>({
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
    barrierLabel: "CustomDialog",
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: CustomDialog(
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
