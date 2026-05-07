import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../database/database_service.dart';
import '../database/models/app_settings.dart';

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
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isAiNotificationsEnabled = state.isAiNotificationsEnabled
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
      ..languageCode = code
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isAiNotificationsEnabled = state.isAiNotificationsEnabled
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
      ..languageCode = state.languageCode
      ..currencySymbol = symbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isAiNotificationsEnabled = state.isAiNotificationsEnabled
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
      default: localeStr = 'en_US';
    }
    initializeDateFormatting(localeStr, null);
  }

  Future<void> setDataRetention(int days) async {
    if (state.dataRetentionDays == days) return;

    final updated = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = days
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isAiNotificationsEnabled = state.isAiNotificationsEnabled
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
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = days
      ..isAiNotificationsEnabled = state.isAiNotificationsEnabled
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(updated);
  }

  Future<void> toggleAiNotifications(bool value) async {
    if (state.isAiNotificationsEnabled == value) return;

    final updated = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isAiNotificationsEnabled = value
      ..isSyncEnabled = state.isSyncEnabled
      ..isLocationEnabled = state.isLocationEnabled
      ..countryName = state.countryName
      ..remoteId = state.remoteId
      ..syncStatus = state.syncStatus;
    await _save(updated);
  }

  Future<void> toggleLocation(bool value) async {
    if (state.isLocationEnabled == value) return;

    final updated = AppSettings()
      ..id = state.id
      ..themeModeIndex = state.themeModeIndex
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isAiNotificationsEnabled = state.isAiNotificationsEnabled
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
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isAiNotificationsEnabled = state.isAiNotificationsEnabled
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
      ..languageCode = state.languageCode
      ..currencySymbol = state.currencySymbol
      ..dataRetentionDays = state.dataRetentionDays
      ..permanentDeletionDays = state.permanentDeletionDays
      ..isAiNotificationsEnabled = state.isAiNotificationsEnabled
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
