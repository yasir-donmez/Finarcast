import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../database/database_service.dart';
import '../database/models/app_settings.dart';
import '../services/notification_service.dart';

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

    final newSettings = AppSettings()
      ..id = state.id
      ..themeModeIndex = index
      ..accentColorValue = state.accentColorValue
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isNotificationsEnabled = state.isNotificationsEnabled
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(newSettings);
  }

  Future<void> setAccentColor(int colorValue) async {
    if (state.accentColorValue == colorValue) return;

    final newSettings = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..accentColorValue = colorValue
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isNotificationsEnabled = state.isNotificationsEnabled
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(newSettings);
  }

  Future<void> setLanguage(String code) async {
    if (state.languageCode == code) return;

    final newSettings = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..accentColorValue = state.accentColorValue
      ..languageCode = code
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isNotificationsEnabled = state.isNotificationsEnabled
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(newSettings);
    _updateIntl(code);
  }

  Future<void> setCurrency(String symbol) async {
    if (state.currencySymbol == symbol) return;

    final newSettings = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..accentColorValue = state.accentColorValue
      ..languageCode = state.languageCode
      ..currencySymbol = symbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isNotificationsEnabled = state.isNotificationsEnabled
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(newSettings);
  }

  void _updateIntl(String langCode) {
    String localeStr;
    switch (langCode) {
      case 'tr': localeStr = 'tr_TR'; break;
      case 'en': localeStr = 'en_US'; break;
      case 'de': localeStr = 'de_DE'; break;
      case 'es': localeStr = 'es_ES'; break;
      case 'fr': localeStr = 'fr_FR'; break;
      case 'pt': localeStr = 'pt_BR'; break;
      case 'it': localeStr = 'it_IT'; break;
      case 'ja': localeStr = 'ja_JP'; break;
      case 'zh': localeStr = 'zh_CN'; break;
      case 'ko': localeStr = 'ko_KR'; break;
      default: localeStr = 'en_US';
    }
    initializeDateFormatting(localeStr, null);
    Intl.defaultLocale = localeStr;
  }

  Future<void> setDataRetention(int days) async {
    if (state.dataRetentionDays == days) return;

    final updated = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..accentColorValue = state.accentColorValue
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = days
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isNotificationsEnabled = state.isNotificationsEnabled
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(updated);
  }

  Future<void> setPermanentDeletion(int days) async {
    if (state.permanentDeletionDays == days) return;

    final updated = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..accentColorValue = state.accentColorValue
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = days
      ..isNotificationsEnabled = state.isNotificationsEnabled
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(updated);
  }

  Future<void> toggleNotifications(bool value) async {
    if (state.isNotificationsEnabled == value) return;
    
    final updated = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..accentColorValue = state.accentColorValue
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isNotificationsEnabled = value
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(updated);

    // Master Switch Mantığı
    if (!value) {
      await NotificationService().cancelAll();
    } else {
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

    final updated = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..accentColorValue = state.accentColorValue
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isNotificationsEnabled = state.isNotificationsEnabled
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = value
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(updated);
  }

  Future<void> toggleSync(bool value) async {
    if (state.isSyncEnabled == value) return;

    final updated = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..accentColorValue = state.accentColorValue
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isNotificationsEnabled = state.isNotificationsEnabled
      ..isSyncEnabled = value
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(updated);
  }

  Future<void> setCountry(String? name) async {
    if (state.countryName == name) return;

    final updated = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..accentColorValue = state.accentColorValue
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isNotificationsEnabled = state.isNotificationsEnabled
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = name
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(updated);
  }

  Future<void> _save(AppSettings settings) async {
    await DatabaseService.saveSettings(settings);
    // Directly assign the new state to notify listeners properly
    state = settings;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final dynamicColorProvider = StateProvider<Color>((ref) => const Color(0xFF00E5FF));
