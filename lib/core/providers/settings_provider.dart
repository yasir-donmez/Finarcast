import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../database/database_service.dart';
import '../database/models/app_settings.dart';
import '../services/notification_service.dart';

extension AppSettingsCopy on AppSettings {
  AppSettings copyWith({
    int? themeModeIndex,
    int? bgPatternDensity,
    int? bgColorStyle,
    int? accentColorValue,
    String? languageCode,
    String? currencySymbol,
    int? dataRetentionDays,
    int? permanentDeletionDays,
    bool? isNotificationsEnabled,
    bool? isSyncEnabled,
    bool? isLocationEnabled,
    String? countryName,
    String? remoteId,
    int? syncStatus,
  }) {
    return AppSettings()
      ..id = this.id
      ..themeModeIndex = themeModeIndex ?? this.themeModeIndex
      ..bgPatternDensity = bgPatternDensity ?? this.bgPatternDensity
      ..bgColorStyle = bgColorStyle ?? this.bgColorStyle
      ..accentColorValue = accentColorValue ?? this.accentColorValue
      ..languageCode = languageCode ?? this.languageCode
      ..currencySymbol = currencySymbol ?? this.currencySymbol
      ..dataRetentionDays = dataRetentionDays ?? this.dataRetentionDays
      ..permanentDeletionDays =
          permanentDeletionDays ?? this.permanentDeletionDays
      ..isNotificationsEnabled =
          isNotificationsEnabled ?? this.isNotificationsEnabled
      ..isSyncEnabled = isSyncEnabled ?? this.isSyncEnabled
      ..isLocationEnabled = isLocationEnabled ?? this.isLocationEnabled
      ..countryName = countryName ?? this.countryName
      ..remoteId = remoteId ?? this.remoteId
      ..syncStatus = syncStatus ?? this.syncStatus;
  }
}

final rootRepaintBoundaryKey = GlobalKey();

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseService.getSettings();
    state = settings;
    _updateIntl(state.languageCode);
  }

  Future<void> setThemeMode(int index) async {
    if (state.themeModeIndex == index) return;
    await _save(state.copyWith(themeModeIndex: index));
  }

  Future<void> setAccentColor(int colorValue) async {
    if (state.accentColorValue == colorValue) return;
    await _save(state.copyWith(accentColorValue: colorValue));
  }

  Future<void> setBgPatternDensity(int density) async {
    if (state.bgPatternDensity == density) return;
    await _save(state.copyWith(bgPatternDensity: density));
  }

  Future<void> setBgColorStyle(int style) async {
    if (state.bgColorStyle == style) return;
    await _save(state.copyWith(bgColorStyle: style));
  }

  Future<void> setLanguage(String code) async {
    if (state.languageCode == code) return;
    await _save(state.copyWith(languageCode: code));
    _updateIntl(code);
  }

  Future<void> setCurrency(String symbol) async {
    if (state.currencySymbol == symbol) return;
    await _save(state.copyWith(currencySymbol: symbol));
  }

  void _updateIntl(String langCode) {
    String localeStr;
    switch (langCode) {
      case 'tr':
        localeStr = 'tr_TR';
        break;
      case 'en':
        localeStr = 'en_US';
        break;
      case 'de':
        localeStr = 'de_DE';
        break;
      case 'es':
        localeStr = 'es_ES';
        break;
      case 'fr':
        localeStr = 'fr_FR';
        break;
      case 'pt':
        localeStr = 'pt_BR';
        break;
      case 'it':
        localeStr = 'it_IT';
        break;
      case 'ja':
        localeStr = 'ja_JP';
        break;
      case 'zh':
        localeStr = 'zh_CN';
        break;
      case 'ko':
        localeStr = 'ko_KR';
        break;
      default:
        localeStr = 'en_US';
    }
    initializeDateFormatting(localeStr, null);
    Intl.defaultLocale = localeStr;
  }

  Future<void> setDataRetention(int days) async {
    if (state.dataRetentionDays == days) return;
    await _save(state.copyWith(dataRetentionDays: days));
  }

  Future<void> setPermanentDeletion(int days) async {
    if (state.permanentDeletionDays == days) return;
    await _save(state.copyWith(permanentDeletionDays: days));
  }

  Future<void> toggleNotifications(bool value) async {
    if (state.isNotificationsEnabled == value) return;

    final updated = state.copyWith(isNotificationsEnabled: value);
    await _save(updated);

    // Master Switch Mantığı
    if (!value) {
      await NotificationService().cancelAll();
    } else {
      await NotificationService().requestPermissions();
      final transactions = await DatabaseService.getAllTransactions();
      for (final tx in transactions) {
        if (tx.isNotificationEnabled) {
          await NotificationService().scheduleTransactionNotification(tx);
        }
      }
    }
  }

  Future<void> toggleLocation(bool value) async {
    if (state.isLocationEnabled == value) return;
    await _save(state.copyWith(isLocationEnabled: value));
  }

  Future<void> toggleSync(bool value) async {
    if (state.isSyncEnabled == value) return;
    await _save(state.copyWith(isSyncEnabled: value));
  }

  Future<void> setCountry(String? name) async {
    if (state.countryName == name) return;
    await _save(state.copyWith(countryName: name));
  }

  Future<void> _save(AppSettings settings) async {
    await DatabaseService.saveSettings(settings);
    // Directly assign the new state to notify listeners properly
    state = settings;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});

final dynamicColorProvider = StateProvider<Color>(
  (ref) => const Color(0xFF00E5FF),
);
