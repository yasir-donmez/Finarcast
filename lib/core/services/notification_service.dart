import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:intl/intl.dart';
import '../database/models/recurring_template.dart';
import '../database/database_service.dart';
import '../domain/recurrence_engine.dart';
import '../utils/currency_utils.dart';
import '../../l10n/app_localizations.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final String tzName = _getStandardTimezoneName();
      tz.setLocalLocation(tz.getLocation(tzName));
      debugPrint('🔔 [NotificationService] Yerel zaman dilimi ayarlandı: $tzName');
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Yerel zaman dilimi ayarlanamadı, varsayılana geçiliyor: $e');
      try {
        tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        // Bildirime tıklandığında yapılacak işlem (opsiyonel)
      },
    );
  }

  String _getStandardTimezoneName() {
    try {
      final String nativeName = DateTime.now().timeZoneName;
      if (nativeName.contains('/')) {
        return nativeName;
      }
    } catch (_) {}

    final double offsetHours = DateTime.now().timeZoneOffset.inMinutes / 60.0;
    
    if (offsetHours == 0.0) return 'Europe/London';
    if (offsetHours == 1.0) return 'Europe/Paris';
    if (offsetHours == 2.0) return 'Europe/Athens';
    if (offsetHours == 3.0) return 'Europe/Istanbul';
    if (offsetHours == 3.5) return 'Asia/Tehran';
    if (offsetHours == 4.0) return 'Asia/Dubai';
    if (offsetHours == 4.5) return 'Asia/Kabul';
    if (offsetHours == 5.0) return 'Asia/Karachi';
    if (offsetHours == 5.5) return 'Asia/Kolkata';
    if (offsetHours == 5.75) return 'Asia/Kathmandu';
    if (offsetHours == 6.0) return 'Asia/Dhaka';
    if (offsetHours == 6.5) return 'Asia/Yangon';
    if (offsetHours == 7.0) return 'Asia/Bangkok';
    if (offsetHours == 8.0) return 'Asia/Singapore';
    if (offsetHours == 8.75) return 'Australia/Eucla';
    if (offsetHours == 9.0) return 'Asia/Tokyo';
    if (offsetHours == 9.5) return 'Australia/Darwin';
    if (offsetHours == 10.0) return 'Australia/Sydney';
    if (offsetHours == 10.5) return 'Australia/Lord_Howe';
    if (offsetHours == 11.0) return 'Pacific/Guadalcanal';
    if (offsetHours == 11.5) return 'Pacific/Norfolk';
    if (offsetHours == 12.0) return 'Pacific/Auckland';
    if (offsetHours == 12.75) return 'Pacific/Chatham';
    if (offsetHours == 13.0) return 'Pacific/Apia';
    if (offsetHours == 14.0) return 'Pacific/Kiritimati';
    
    if (offsetHours == -1.0) return 'Atlantic/Cape_Verde';
    if (offsetHours == -2.0) return 'America/Noronha';
    if (offsetHours == -3.0) return 'America/Sao_Paulo';
    if (offsetHours == -3.5) return 'America/St_Johns';
    if (offsetHours == -4.0) return 'America/Caracas';
    if (offsetHours == -5.0) return 'America/New_York';
    if (offsetHours == -6.0) return 'America/Chicago';
    if (offsetHours == -7.0) return 'America/Denver';
    if (offsetHours == -8.0) return 'America/Los_Angeles';
    if (offsetHours == -9.0) return 'America/Anchorage';
    if (offsetHours == -9.5) return 'Pacific/Marquesas';
    if (offsetHours == -10.0) return 'Pacific/Honolulu';
    if (offsetHours == -11.0) return 'Pacific/Pago_Pago';
    
    return 'UTC';
  }

  Future<bool> requestPermissions() async {
    try {
      final iosImplementation = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        try {
          await androidImplementation.requestExactAlarmsPermission();
        } catch (e) {
          debugPrint('⚠️ [NotificationService] Hassas alarm izni alınamadı/desteklenmiyor: $e');
        }
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('❌ [NotificationService] İzin isteme hatası: $e');
    }
    return true;
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        return await androidImplementation.areNotificationsEnabled() ?? false;
      }
    } catch (_) {}
    return true;
  }

  Future<void> showTestNotification({int delaySeconds = 0}) async {
    try {
      final settings = await DatabaseService.getSettings();
      final l10n = await AppLocalizations.delegate.load(Locale(settings.languageCode));

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_reminders',
        l10n.notificationTestChannelName,
        channelDescription: l10n.notificationTestChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        color: const Color(0xFF00BCD4),
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      if (delaySeconds <= 0) {
        await _notifications.show(
          id: 9999,
          title: l10n.notificationTestTitle,
          body: l10n.notificationTestBody,
          notificationDetails: details,
        );
        debugPrint('🔔 [NotificationService] Anlık test bildirimi gönderildi.');
      } else {
        final scheduledDate = tz.TZDateTime.from(
          DateTime.now().add(Duration(seconds: delaySeconds)).toUtc(),
          tz.UTC,
        );
        try {
          await _notifications.zonedSchedule(
            id: 9999,
            title: l10n.notificationTestDelayedTitle,
            body: l10n.notificationTestDelayedBody,
            scheduledDate: scheduledDate,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        } catch (e) {
          debugPrint('⚠️ [NotificationService] exactAllowWhileIdle başarısız oldu, inexact deneniyor: $e');
          await _notifications.zonedSchedule(
            id: 9999,
            title: l10n.notificationTestDelayedTitle,
            body: l10n.notificationTestDelayedBody,
            scheduledDate: scheduledDate,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        }
        debugPrint('🔔 [NotificationService] $delaySeconds saniye gecikmeli test bildirimi zamanlandı: $scheduledDate');
      }
    } catch (e) {
      debugPrint('❌ [NotificationService] Test bildirimi hatası: $e');
    }
  }

  Future<void> scheduleTemplateNotification(RecurringTemplate template) async {
    try {
      if (!template.isNotificationEnabled) {
        await cancelNotification(template.id);
        return;
      }

      // Isar ID'sini bildirim ID'si olarak kullanıyoruz
      final int notificationId = template.id;

      final now = DateTime.now();
      DateTime? localTarget;

      if (template.periodType == 0) {
        // Tek seferlik
        final DateTime targetDate = template.startDate.subtract(Duration(days: template.notificationReminderDays));
        final DateTime candidate = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          template.notificationHour,
          template.notificationMinute,
        );
        if (candidate.isAfter(now)) {
          localTarget = candidate;
        }
      } else {
        // Tekrarlı şablon için RecurrenceEngine kullanan arama
        DateTime searchAfter = now.subtract(Duration(days: template.notificationReminderDays + 2));
        DateTime? nextOcc = RecurrenceEngine.nextOccurrence(template.recurrenceRule, after: searchAfter);

        while (nextOcc != null) {
          final DateTime targetDate = nextOcc.subtract(Duration(days: template.notificationReminderDays));
          final DateTime candidate = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            template.notificationHour,
            template.notificationMinute,
          );
          if (candidate.isAfter(now)) {
            localTarget = candidate;
            break;
          }
          searchAfter = nextOcc;
          nextOcc = RecurrenceEngine.nextOccurrence(template.recurrenceRule, after: searchAfter);
        }
      }

      if (localTarget == null) {
        await cancelNotification(template.id);
        return;
      }

      final settings = await DatabaseService.getSettings();
      final l10n = await AppLocalizations.delegate.load(Locale(settings.languageCode));

      final String amountText = template.minAmount != null && template.maxAmount != null
          ? "${CurrencyUtils.formatAmount(template.minAmount!, currencySymbol: template.currency ?? "₺")} - ${CurrencyUtils.formatAmount(template.maxAmount!, currencySymbol: template.currency ?? "₺")}"
          : CurrencyUtils.formatAmount(template.effectiveAmount, currencySymbol: template.currency ?? "₺");

      final String dateText;
      final today = DateTime(now.year, now.month, now.day);
      final paymentDateOnly = DateTime(template.startDate.year, template.startDate.month, template.startDate.day);
      final difference = paymentDateOnly.difference(today).inDays;
      if (difference == 0) {
        dateText = l10n.today;
      } else if (difference == 1) {
        dateText = l10n.tomorrow;
      } else if (difference == -1) {
        dateText = l10n.yesterday;
      } else {
        dateText = DateFormat('d MMMM', settings.languageCode).format(template.startDate);
      }

      final String notificationTitle = template.isIncome
          ? l10n.notificationIncomeTitle(template.title)
          : l10n.notificationExpenseTitle(template.title);

      final buffer = StringBuffer();
      buffer.write(l10n.notificationBodyAmount(amountText));
      buffer.write('  •  ');
      buffer.write(l10n.notificationBodyDate(dateText));
      if (template.note != null && template.note!.trim().isNotEmpty) {
        buffer.write('\n');
        buffer.write(l10n.notificationBodyNote(template.note!.trim()));
      }
      final String notificationBody = buffer.toString();

      final BigTextStyleInformation bigTextStyleInfo = BigTextStyleInformation(
        notificationBody,
        contentTitle: notificationTitle,
        htmlFormatContentTitle: false,
        htmlFormatBigText: false,
      );

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'transaction_reminders',
        l10n.notificationChannelName,
        channelDescription: l10n.notificationChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        color: const Color(0xFF00BCD4),
        styleInformation: bigTextStyleInfo,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Yerel saati cihazın kendi sistemi üzerinden UTC'ye çevirip UTC diliminde zamanlıyoruz.
      // Bu sayede yerel saat dilimi ve DST (yaz/kış saati) uyuşmazlıkları tamamen aşılır.
      final scheduledDate = tz.TZDateTime.from(localTarget.toUtc(), tz.UTC);

      try {
        await _notifications.zonedSchedule(
          id: notificationId,
          title: notificationTitle,
          body: notificationBody,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: _getMatchComponents(template.periodType),
        );
      } catch (e) {
        debugPrint('⚠️ [NotificationService] exactAllowWhileIdle başarısız oldu (Transaction), inexact deneniyor: $e');
        await _notifications.zonedSchedule(
          id: notificationId,
          title: notificationTitle,
          body: notificationBody,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: _getMatchComponents(template.periodType),
        );
      }
      debugPrint('🔔 [NotificationService] Bildirim başarıyla zamanlandı: ID $notificationId, Tarih: $scheduledDate');
    } catch (e, stack) {
      debugPrint('❌ [NotificationService] Bildirim zamanlama hatası: $e');
      debugPrint(stack.toString());
      // Hata olsa bile işlemin kaydedilmesini engellememek için hatayı yutuyoruz (ancak logluyoruz)
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id: id);
    } catch (e) {
      debugPrint('❌ [NotificationService] Bildirim iptal hatası: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
      debugPrint('🔔 [NotificationService] Tüm bildirimler iptal edildi.');
    } catch (e) {
      debugPrint('❌ [NotificationService] Tüm bildirimleri iptal etme hatası: $e');
    }
  }


  DateTimeComponents? _getMatchComponents(int periodType) {
    switch (periodType) {
      case 101: return DateTimeComponents.time; // Her gün aynı saatte
      case 201: return DateTimeComponents.dayOfWeekAndTime; // Her hafta aynı gün/saat
      case 301: return DateTimeComponents.dayOfMonthAndTime; // Her ay aynı gün/saat
      case 401: return DateTimeComponents.dateAndTime; // Her yıl aynı tarih/saat
      default: return null;
    }
  }
}
