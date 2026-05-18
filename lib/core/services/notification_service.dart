import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../database/models/transaction_record.dart';

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
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_reminders',
        'Test Bildirimleri',
        channelDescription: 'Finarcast bildirim test kanalı',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      if (delaySeconds <= 0) {
        await _notifications.show(
          id: 9999,
          title: '🔔 Finarcast Test Bildirimi',
          body: 'Harika! Uygulama içi (foreground) bildirimleriniz sorunsuz çalışıyor. 🚀',
          notificationDetails: details,
        );
        debugPrint('🔔 [NotificationService] Anlık test bildirimi gönderildi.');
      } else {
        tz.Location location;
        try {
          location = tz.local;
        } catch (e) {
          try {
            location = tz.getLocation('Europe/Istanbul');
          } catch (_) {
            location = tz.UTC;
          }
        }

        final scheduledDate = tz.TZDateTime.now(location).add(Duration(seconds: delaySeconds));
        await _notifications.zonedSchedule(
          id: 9999,
          title: '🔔 Finarcast Gecikmeli Test',
          body: 'Uygulama dışı (background) bildirim testi başarıyla tamamlandı! 🌟',
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        debugPrint('🔔 [NotificationService] $delaySeconds saniye gecikmeli test bildirimi zamanlandı: $scheduledDate');
      }
    } catch (e) {
      debugPrint('❌ [NotificationService] Test bildirimi hatası: $e');
    }
  }

  Future<void> scheduleTransactionNotification(TransactionRecord record) async {
    try {
      if (!record.isNotificationEnabled) {
        await cancelNotification(record.id);
        return;
      }

      // Isar ID'sini bildirim ID'si olarak kullanıyoruz
      final int notificationId = record.id;

      // Hedef tarihi hesapla
      DateTime targetDate = record.date;
      
      // Hatırlatıcı gün farkını uygula
      targetDate = targetDate.subtract(Duration(days: record.notificationReminderDays));
      
      // Saat ve dakikayı ayarla
      targetDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        record.notificationHour,
        record.notificationMinute,
      );

      // Eğer hedef tarih geçmişte ise bir sonraki periyoda aktar (periyodik ise)
      final now = DateTime.now();
      if (targetDate.isBefore(now)) {
        if (record.periodType == 0) {
          // Tek seferlik ise ve geçtiyse, sadece iptal et (veya kurma)
          await cancelNotification(record.id);
          return;
        }
        
        // Gelecek bir tarih bulana kadar ilerlet
        while (targetDate.isBefore(now)) {
          targetDate = _calculateNextOccurrence(targetDate, record.periodType);
        }
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'transaction_reminders',
        'İşlem Hatırlatıcıları',
        channelDescription: 'Periyodik ödemeler ve gelirler için hatırlatıcılar',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Zaman dilimi kontrolü
      tz.Location location;
      try {
        location = tz.local;
      } catch (e) {
        // Eğer yerel saat dilimi ayarlanmamışsa varsayılan olarak İstanbul kullan (veya UTC)
        try {
          location = tz.getLocation('Europe/Istanbul');
        } catch (_) {
          location = tz.UTC;
        }
      }

      final scheduledDate = tz.TZDateTime(
        location,
        targetDate.year,
        targetDate.month,
        targetDate.day,
        targetDate.hour,
        targetDate.minute,
        targetDate.second,
      );

      await _notifications.zonedSchedule(
        id: notificationId,
        title: 'Finarcast Hatırlatıcısı',
        body: '${record.title} için ödeme/gelir zamanı geldi!',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: _getMatchComponents(record.periodType),
      );
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

  DateTime _calculateNextOccurrence(DateTime current, int periodType) {
    switch (periodType) {
      case 8: return current.add(const Duration(days: 1)); // Günlük
      case 9: return current.add(const Duration(days: 2)); // 2 Günde Bir
      case 10: return current.add(const Duration(days: 3)); // 3 Günde Bir
      case 1: return current.add(const Duration(days: 7)); // Haftalık
      case 4: return current.add(const Duration(days: 14)); // 2 Haftada Bir
      case 5: return current.add(const Duration(days: 21)); // 3 Haftada Bir
      case 2: return DateTime(current.year, current.month + 1, current.day, current.hour, current.minute); // Aylık
      case 6: return DateTime(current.year, current.month + 3, current.day, current.hour, current.minute); // 3 Ayda Bir
      case 7: return DateTime(current.year, current.month + 6, current.day, current.hour, current.minute); // 6 Ayda Bir
      case 3: return DateTime(current.year + 1, current.month, current.day, current.hour, current.minute); // Yıllık
      default: return current.add(const Duration(days: 30)); // Varsayılan aylık
    }
  }

  DateTimeComponents? _getMatchComponents(int periodType) {
    switch (periodType) {
      case 8: return DateTimeComponents.time; // Her gün aynı saatte
      case 1: return DateTimeComponents.dayOfWeekAndTime; // Her hafta aynı gün/saat
      case 2: return DateTimeComponents.dayOfMonthAndTime; // Her ay aynı gün/saat
      case 3: return DateTimeComponents.dateAndTime; // Her yıl aynı tarih/saat
      default: return null;
    }
  }
}
