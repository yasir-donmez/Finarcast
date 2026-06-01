import 'package:flutter/material.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import 'social_login.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onObscurePasswordToggle;
  final VoidCallback onObscureConfirmPasswordToggle;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool isGoogleLoading;
  final VoidCallback onGoogleSignIn;

  const RegisterForm({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.usernameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onObscurePasswordToggle,
    required this.onObscureConfirmPasswordToggle,
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
      key: const ValueKey('register_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authNewAccount,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authRegisterSubtitle,
          style: TextStyle(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.7), 
            fontSize: (screenHeight * 0.016).clamp(11.0, 14.0),
            height: 1.35,
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
        CustomTextField(
          controller: usernameController,
          hintText: l10n.authUsername,
          icon: Icons.person_rounded,
          errorText: usernameError,
        ),
        SizedBox(height: screenHeight * 0.02),
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
        SizedBox(height: screenHeight * 0.02),
        CustomTextField(
          controller: confirmPasswordController,
          hintText: l10n.authConfirmPassword,
          icon: Icons.security_rounded,
          obscureText: obscureConfirmPassword,
          errorText: confirmPasswordError,
          suffix: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
            icon: Icon(
              obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.getSecondary(context).withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: onObscureConfirmPasswordToggle,
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
        CustomButton(
          label: l10n.authRegister,
          onTap: onSubmit,
          activeColor: AppColors.getSecondary(context),
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
