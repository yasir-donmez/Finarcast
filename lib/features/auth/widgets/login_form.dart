import 'package:flutter/material.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import 'social_login.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final bool obscurePassword;
  final VoidCallback onObscurePasswordToggle;
  final VoidCallback onForgotPasswordPressed;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool isGoogleLoading;
  final VoidCallback onGoogleSignIn;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.obscurePassword,
    required this.onObscurePasswordToggle,
    required this.onForgotPasswordPressed,
    required this.onSubmit,
    required this.isLoading,
    required this.isGoogleLoading,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authWelcome,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authLoginSubtitle,
          style: TextStyle(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.7), 
            fontSize: (screenHeight * 0.016).clamp(11.0, 14.0),
            height: 1.35,
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
        CustomTextField(
          controller: emailController,
          hintText: l10n.authEmail,
          icon: Icons.email_rounded,
          errorText: emailError,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: screenHeight * 0.02),
        CustomTextField(
          controller: passwordController,
          hintText: l10n.authPassword,
          icon: Icons.lock_rounded,
          obscureText: obscurePassword,
          errorText: passwordError,
          suffix: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
            icon: Icon(
              obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.getPrimary(context).withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: onObscurePasswordToggle,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onForgotPasswordPressed,
            child: Text(
              l10n.authForgotPassword,
              style: TextStyle(
                color: AppColors.getPrimary(context).withValues(alpha: 0.8), 
                fontSize: (screenHeight * 0.015).clamp(10.0, 13.0),
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        CustomButton(
          label: l10n.authLogin,
          onTap: onSubmit,
          isLoading: isLoading,
        ),
        SizedBox(height: screenHeight * 0.035),
        SocialLogin(
          onGoogleSignIn: onGoogleSignIn,
          isLoading: isGoogleLoading,
        ),
      ],
    );
  }
}
