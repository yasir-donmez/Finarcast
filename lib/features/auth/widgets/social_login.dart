import 'package:flutter/material.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';

class SocialLogin extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final bool isLoading;

  const SocialLogin({
    super.key,
    required this.onGoogleSignIn,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.getTextSecondary(context).withValues(alpha: 0.1))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.authOr, 
                style: TextStyle(
                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.4), 
                  fontSize: (screenHeight * 0.015).clamp(10.0, 12.0),
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.getTextSecondary(context).withValues(alpha: 0.1))),
          ],
        ),
        SizedBox(height: screenHeight * 0.025),
        CustomButton(
          label: l10n.authGoogleSignIn,
          onTap: onGoogleSignIn,
          isPrimary: false,
          activeColor: AppColors.getTextPrimary(context).withValues(alpha: 0.75),
          isLoading: isLoading,
          leading: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 3,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontWeight: FontWeight.w900,
                fontSize: 13,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
