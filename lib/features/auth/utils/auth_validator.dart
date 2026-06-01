import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class AuthValidator {
  /// Validates registration username input.
  static String? validateUsername(BuildContext context, String username) {
    final l10n = AppLocalizations.of(context)!;
    if (username.isEmpty) {
      return l10n.authUsernameRequired;
    } else if (username.length < 3) {
      return l10n.authUsernameTooShort;
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return l10n.authUsernameInvalid;
    }
    return null;
  }

  /// Validates email address format.
  static String? validateEmail(BuildContext context, String email) {
    final l10n = AppLocalizations.of(context)!;
    if (email.isEmpty) {
      return l10n.authEmailRequired;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return l10n.authEmailInvalid;
    }
    return null;
  }

  /// Validates standard password strength (min length).
  static String? validatePassword(BuildContext context, String password) {
    final l10n = AppLocalizations.of(context)!;
    if (password.isEmpty) {
      return l10n.authPasswordRequired;
    } else if (password.length < 6) {
      return l10n.authPasswordTooShort;
    }
    return null;
  }

  /// Validates password confirmation matches the password.
  static String? validateConfirmPassword(
      BuildContext context, String password, String confirmPassword) {
    final l10n = AppLocalizations.of(context)!;
    if (confirmPassword.isEmpty) {
      return l10n.authConfirmPasswordRequired;
    } else if (password != confirmPassword) {
      return l10n.authPasswordsDoNotMatch;
    }
    return null;
  }
}
