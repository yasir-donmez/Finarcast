import 'package:flutter/material.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

class BottomActions extends StatelessWidget {
  final bool isLogin;
  final bool showCancel;
  final bool isOtpVerification;
  final bool isLoading;
  final VoidCallback onToggleAuthMode;
  final VoidCallback onContinueAsGuest;
  final VoidCallback onCancel;

  const BottomActions({
    super.key,
    required this.isLogin,
    required this.showCancel,
    required this.isOtpVerification,
    required this.isLoading,
    required this.onToggleAuthMode,
    required this.onContinueAsGuest,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = AppColors.getPrimary(context);

    // Sequential fade curves to match 1000ms easeInOutSine transition
    const switchInCurve = Interval(0.5, 1.0, curve: Curves.easeInOutSine);
    const switchOutCurve = Interval(0.5, 1.0, curve: Curves.easeInOutSine);

    // Child 1: Login / Register switcher & Continue as Guest
    final Widget firstChild = Column(
      key: const ValueKey('bottom_login_register'),
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          switchInCurve: switchInCurve,
          switchOutCurve: switchOutCurve,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Row(
            key: ValueKey<bool>(isLogin),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? l10n.authNoAccount : l10n.authAlreadyHaveAccount,
                style: TextStyle(color: AppColors.getTextSecondary(context)),
              ),
              TextButton(
                onPressed: isLoading ? null : onToggleAuthMode,
                child: Text(
                  isLogin ? l10n.authRegisterAction : l10n.authLoginAction,
                  style: TextStyle(
                    color: isLoading ? primaryColor.withValues(alpha: 0.3) : primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : onContinueAsGuest,
          child: Text(
            l10n.authContinueAsGuest,
            style: TextStyle(
              color: isLoading
                  ? AppColors.getTextSecondary(context).withValues(alpha: 0.2)
                  : AppColors.getTextSecondary(context).withValues(alpha: 0.5),
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );

    // Child 2: Cancel / Back button
    final Widget secondChild = Center(
      key: const ValueKey('bottom_cancel'),
      child: TextButton(
        onPressed: isLoading ? null : onCancel,
        child: Text(
          isOtpVerification ? l10n.authGoBack : l10n.authBackToLogin,
          style: TextStyle(
            color: isLoading
                ? AppColors.getTextSecondary(context).withValues(alpha: 0.3)
                : AppColors.getTextSecondary(context).withValues(alpha: 0.6),
            fontSize: 12,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 1000),
      firstCurve: const Interval(0.0, 0.5, curve: Curves.easeInOutSine),
      secondCurve: const Interval(0.5, 1.0, curve: Curves.easeInOutSine),
      sizeCurve: Curves.easeInOutSine,
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState: showCancel ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    );
  }
}
