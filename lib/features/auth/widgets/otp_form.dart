import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';

class OtpForm extends StatelessWidget {
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final String? otpError;
  final bool isLoading;
  final int resendCountdown;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final String registeredEmail;

  const OtpForm({
    super.key,
    required this.otpController,
    required this.otpFocusNode,
    required this.otpError,
    required this.isLoading,
    required this.resendCountdown,
    required this.onVerify,
    required this.onResend,
    required this.registeredEmail,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      key: const ValueKey('otp_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authVerificationCode,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authVerificationDesc(registeredEmail),
          style: TextStyle(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
            fontSize: (screenHeight * 0.016).clamp(11.0, 14.0),
            height: 1.35,
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hidden TextField that captures input
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
              
              // 6 Stylized Cards UI
              GestureDetector(
                onTap: () {
                  otpFocusNode.requestFocus();
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
                      final primaryColor = AppColors.getPrimary(context);

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
            padding: const EdgeInsets.only(top: 12, left: 16),
            child: Center(
              child: Text(
                otpError!,
                style: TextStyle(
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        SizedBox(height: screenHeight * 0.03),
        Column(
          children: [
            CustomButton(
              label: l10n.authVerifyCode,
              onTap: onVerify,
              activeColor: AppColors.getPrimary(context),
              isLoading: isLoading,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: (resendCountdown > 0 || isLoading) ? null : onResend,
                  child: Text(
                    resendCountdown > 0
                        ? l10n.authResendCodeCountdown(resendCountdown)
                        : l10n.authResendCode,
                    style: TextStyle(
                      color: (resendCountdown > 0 || isLoading)
                          ? AppColors.getTextSecondary(context).withValues(alpha: 0.4)
                          : AppColors.getPrimary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
