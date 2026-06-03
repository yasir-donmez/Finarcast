import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../l10n/app_localizations.dart';

class ForgotPasswordForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController otpController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? emailError;
  final String? otpError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onObscurePasswordToggle;
  final VoidCallback onObscureConfirmPasswordToggle;
  final bool isLoading;
  final int resendCountdown;
  final int forgotPasswordStep;
  final VoidCallback onSendCode;
  final VoidCallback onVerifyCode;
  final VoidCallback onSubmitNewPassword;
  final VoidCallback onChangeEmail;
  final VoidCallback onResendCode;
  final FocusNode otpFocusNode;

  const ForgotPasswordForm({
    super.key,
    required this.emailController,
    required this.otpController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.emailError,
    required this.otpError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onObscurePasswordToggle,
    required this.onObscureConfirmPasswordToggle,
    required this.isLoading,
    required this.resendCountdown,
    required this.forgotPasswordStep,
    required this.onSendCode,
    required this.onVerifyCode,
    required this.onSubmitNewPassword,
    required this.onChangeEmail,
    required this.onResendCode,
    required this.otpFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = AppColors.getPrimary(context);

    Widget child;

    if (forgotPasswordStep == 1) {
      child = Column(
        key: const ValueKey('forgot_password_step_1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.authPasswordReset,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.authForgotPasswordDesc,
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
          SizedBox(height: screenHeight * 0.035),
          CustomButton(
            label: l10n.authSendCode,
            onTap: onSendCode,
            isLoading: isLoading,
          ),
        ],
      );
    } else if (forgotPasswordStep == 2) {
      child = Column(
        key: const ValueKey('forgot_password_step_2'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.authVerificationCodeTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.authForgotPasswordOtpDesc(emailController.text),
            style: TextStyle(
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
              fontSize: (screenHeight * 0.016).clamp(11.0, 14.0),
              height: 1.35,
            ),
          ),
          SizedBox(height: screenHeight * 0.035),
          
          // Stylized 6-Box OTP
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.0,
                  child: SizedBox(
                    width: 280,
                    height: 60,
                    child: TextField(
                      controller: otpController,
                      focusNode: otpFocusNode,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      maxLength: 6,
                      showCursor: false,
                      enableInteractiveSelection: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (otpFocusNode.hasFocus) {
                      otpFocusNode.unfocus();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        otpFocusNode.requestFocus();
                      });
                    } else {
                      otpFocusNode.requestFocus();
                    }
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final text = otpController.text;
                        String char = "";
                        if (text.length > index) {
                          char = text[index];
                        }
                        
                        final isFocused = otpFocusNode.hasFocus && text.length == index;
                        final isFilled = text.length > index;
  
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: CustomCard(
                            padding: EdgeInsets.zero,
                            backgroundColor: isFocused 
                                ? primaryColor.withValues(alpha: 0.1)
                                : null,
                            borderColor: isFocused 
                                ? primaryColor 
                                : isFilled 
                                    ? primaryColor.withValues(alpha: 0.4) 
                                    : null,
                            child: SizedBox(
                              width: 38,
                              height: 48,
                              child: Center(
                                child: Text(
                                  char,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.getTextPrimary(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (otpError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  otpError!,
                  style: TextStyle(
                    color: Colors.redAccent.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
          SizedBox(height: screenHeight * 0.035),
          CustomButton(
            label: l10n.authVerifyCode,
            onTap: onVerifyCode,
            isLoading: isLoading,
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onChangeEmail,
                child: Text(
                  l10n.authChangeEmail,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              TextButton(
                onPressed: (resendCountdown > 0 || isLoading) ? null : onResendCode,
                child: Text(
                  resendCountdown > 0 
                      ? l10n.authResendCodeCountdown(resendCountdown) 
                      : l10n.authResendCode,
                  style: TextStyle(
                    color: (resendCountdown > 0 || isLoading)
                        ? AppColors.getTextSecondary(context).withValues(alpha: 0.4)
                        : primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      child = Column(
        key: const ValueKey('forgot_password_step_3'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.authNewPasswordTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.authNewPasswordDesc,
            style: TextStyle(
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
              fontSize: (screenHeight * 0.016).clamp(11.0, 14.0),
              height: 1.35,
            ),
          ),
          SizedBox(height: screenHeight * 0.035),
          CustomTextField(
            controller: passwordController,
            hintText: l10n.authNewPassword,
            icon: Icons.lock_rounded,
            obscureText: obscurePassword,
            errorText: passwordError,
            suffix: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: primaryColor.withValues(alpha: 0.5),
                size: 20,
              ),
              onPressed: onObscurePasswordToggle,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          CustomTextField(
            controller: confirmPasswordController,
            hintText: l10n.authConfirmNewPassword,
            icon: Icons.security_rounded,
            obscureText: obscureConfirmPassword,
            errorText: confirmPasswordError,
            suffix: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: primaryColor.withValues(alpha: 0.5),
                size: 20,
              ),
              onPressed: onObscureConfirmPasswordToggle,
            ),
          ),
          SizedBox(height: screenHeight * 0.035),
          CustomButton(
            label: l10n.authUpdatePassword,
            onTap: onSubmitNewPassword,
            isLoading: isLoading,
          ),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}
