import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_service.dart';
import '../database/models/app_settings.dart';
import '../services/notification_service.dart';
import '../services/sync_coordinator.dart';
import '../services/subscription_service.dart';

extension AppSettingsCopy on AppSettings {
  AppSettings copyWith({
    int? themeModeIndex,
    int? bgColorStyle,
    int? accentColorValue,
    String? languageCode,
    String? currencySymbol,
    int? dataRetentionDays,
    int? permanentDeletionDays,
    bool? isNotificationsEnabled,
    bool? isSyncEnabled,
    String? remoteId,
    int? syncStatus,
  }) {
    return AppSettings()
      ..id = id
      ..themeModeIndex = themeModeIndex ?? this.themeModeIndex
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
      ..remoteId = remoteId ?? this.remoteId
      ..syncStatus = syncStatus ?? this.syncStatus;
  }
}

final rootRepaintBoundaryKey = GlobalKey();

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(DatabaseService.createDefaultSettings()) {
    _listenToSubscriptionChanges();
    _loadSettings();
  }

  void _listenToSubscriptionChanges() {
    _ref.listen<bool>(
      subscriptionServiceProvider.select((s) => s.isPro),
      (previous, next) {
        if (previous != next && !next) {
          _resetPremiumSettings();
        }
      },
    );
  }

  Future<void> _resetPremiumSettings() async {
    bool needsSave = false;
    var settings = state;

    // Premium olmayan kullanıcılar için arkaplan stilini 'Sade' (2) yap
    if (settings.bgColorStyle != 2) {
      settings = settings.copyWith(bgColorStyle: 2);
      needsSave = true;
    }

    // Premium olmayan kullanıcılar için vurgu rengini 'Kutup' (0xFF00BCD4) yap
    if (settings.accentColorValue != 0xFF00BCD4) {
      settings = settings.copyWith(accentColorValue: 0xFF00BCD4);
      needsSave = true;
    }

    // Premium olmayan kullanıcılar için saklama/silme ve eşitleme ayarlarını sıfırla
    if (settings.dataRetentionDays != -1) {
      settings = settings.copyWith(dataRetentionDays: -1);
      needsSave = true;
    }
    if (settings.permanentDeletionDays != -1) {
      settings = settings.copyWith(permanentDeletionDays: -1);
      needsSave = true;
    }
    if (settings.isSyncEnabled) {
      settings = settings.copyWith(isSyncEnabled: false);
      needsSave = true;
    }

    if (needsSave) {
      await _save(settings);
    }
  }

  Future<void> _loadSettings() async {
    var settings = await DatabaseService.getSettings();
    final prefs = await SharedPreferences.getInstance();
    final isPro = prefs.getBool('Finarcast_is_pro_user') ?? false;

    bool needsSave = false;

    // Premium olmayan kullanıcılar için arkaplan stilini 'Sade' (2) yap
    if (!isPro && settings.bgColorStyle != 2) {
      settings = settings.copyWith(bgColorStyle: 2);
      needsSave = true;
    } else if (settings.bgColorStyle == 0) {
      settings = settings.copyWith(bgColorStyle: 1);
      needsSave = true;
    }

    // Premium olmayan kullanıcılar için vurgu rengini 'Kutup' (0xFF00BCD4) yap
    if (!isPro && settings.accentColorValue != 0xFF00BCD4) {
      settings = settings.copyWith(accentColorValue: 0xFF00BCD4);
      needsSave = true;
    }

    // Premium olmayan kullanıcılar için saklama/silme ve eşitleme ayarlarını sıfırla
    if (!isPro) {
      if (settings.dataRetentionDays != -1) {
        settings = settings.copyWith(dataRetentionDays: -1);
        needsSave = true;
      }
      if (settings.permanentDeletionDays != -1) {
        settings = settings.copyWith(permanentDeletionDays: -1);
        needsSave = true;
      }
      if (settings.isSyncEnabled) {
        settings = settings.copyWith(isSyncEnabled: false);
        needsSave = true;
      }
    }

    if (needsSave) {
      await DatabaseService.saveSettings(settings);
    }

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


  Future<void> toggleSync(bool value) async {
    if (state.isSyncEnabled == value) return;
    await _save(state.copyWith(isSyncEnabled: value));
    if (value) {
      await SyncCoordinator.syncNow();
    }
  }

  /// Buluttan cekilen ayarlari yansit
  Future<void> reloadFromDb() async {
    await _loadSettings();
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
  return SettingsNotifier(ref);
});

final dynamicColorProvider = StateProvider<Color>(
  (ref) => const Color(0xFF00BCD4),
);
