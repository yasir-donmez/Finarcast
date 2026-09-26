import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Hesaplanmış [ThemeData] nesnelerini önbelleğe alarak aynı renk için
/// [ColorScheme.fromSeed] tekrar çağrılmasını engeller.
///
/// Tembel (lazy) önbellekleme: Tema sadece ilk kullanıldığında hesaplanır,
/// sonraki erişimlerde önbellekten anında döner.
class ThemeCache {
  ThemeCache._();

  static final Map<int, ThemeData> _lightCache = {};
  static final Map<int, ThemeData> _darkCache = {};

  /// Verilen vurgu rengi için aydınlık temayı döner.
  /// Önbellekte varsa anında, yoksa hesaplayıp önbelleğe alır.
  static ThemeData getLightTheme(Color accentColor) {
    final key = accentColor.toARGB32();
    return _lightCache.putIfAbsent(
      key,
      () => AppTheme.buildLightTheme(accentColor),
    );
  }

  /// Verilen vurgu rengi için karanlık temayı döner.
  /// Önbellekte varsa anında, yoksa hesaplayıp önbelleğe alır.
  static ThemeData getDarkTheme(Color accentColor) {
    final key = accentColor.toARGB32();
    return _darkCache.putIfAbsent(
      key,
      () => AppTheme.buildDarkTheme(accentColor),
    );
  }
}
