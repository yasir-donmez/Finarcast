import 'package:flutter/material.dart';

extension StringCasingExtension on String {
  /// Converts the string to uppercase, respecting Turkish casing rules if the locale is Turkish.
  String toSafeLocaleUpperCase(String languageCode) {
    if (languageCode == 'tr') {
      return replaceAll('i', 'İ')
          .replaceAll('ı', 'I')
          .replaceAll('ş', 'Ş')
          .replaceAll('ğ', 'Ğ')
          .replaceAll('ç', 'Ç')
          .replaceAll('ö', 'Ö')
          .replaceAll('ü', 'Ü')
          .toUpperCase();
    }
    return toUpperCase();
  }

  /// Converts the string to uppercase, automatically detecting if the context's locale is Turkish.
  String toSafeUpperCase(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return toSafeLocaleUpperCase(languageCode);
  }
}
