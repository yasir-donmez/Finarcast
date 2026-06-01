import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';

class AuthErrorHelper {
  /// Maps Supabase authentication exceptions to localized, user-friendly messages.
  static String getFriendlyErrorMessage(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      
      if (error.code == 'same_password' || 
          message.contains('should be different') || 
          message.contains('different from the old password')) {
        return l10n.authPasswordDifferentError;
      }
      if (error.code == 'user_not_found' || message.contains('user not found')) {
        return l10n.authUserNotFoundError;
      }

      // 1) Rate Limit
      if (error.code == 'rate_limit_exceeded' ||
          message.contains('rate limit') ||
          message.contains('too many requests')) {
        return l10n.authRateLimitExceeded;
      }

      // 2) Disable Signup
      if (error.code == 'signup_disabled' ||
          message.contains('signup is disabled') ||
          message.contains('signups are disabled') ||
          message.contains('signup_disabled')) {
        return l10n.authSignupDisabled;
      }

      // 3) Switch on specific codes first
      switch (error.code) {
        case 'email_not_confirmed':
          return l10n.authEmailNotConfirmed;
        case 'invalid_credentials':
          return l10n.authInvalidCredentials;
        case 'email_exists':
        case 'user_already_exists':
          return l10n.authEmailExists;
        case 'weak_password':
          return l10n.authWeakPassword;
        case 'otp_expired':
          return l10n.authBadCode;
        case 'bad_code':
        case 'invalid_grant':
          return l10n.authBadCode;
      }

      // 4) Fallbacks based on message content
      if (message.contains('login credentials') || message.contains('credentials')) {
        return l10n.authInvalidCredentials;
      }
      if (message.contains('token') || 
          message.contains('otp') || 
          message.contains('code') || 
          message.contains('verify') || 
          message.contains('verification') ||
          message.contains('flow state') ||
          message.contains('expired')) {
        return l10n.authBadCode;
      }

      return error.message;
    }
    return '${l10n.error}: ${error.toString()}';
  }
}
