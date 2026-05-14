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

  Future<bool> requestPermissions() async {
    final iosImplementation = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    // Android 13+ için izin kontrolü gerekebilir, ancak şimdilik basitleştiriyoruz
    return true;
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
        iOS: DarwinNotificationDetails(),
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

      await _notifications.zonedSchedule(
        id: notificationId,
        title: 'Finarcast Hatırlatıcısı',
        body: '${record.title} için ödeme/gelir zamanı geldi!',
        scheduledDate: tz.TZDateTime.from(targetDate, location),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: _getMatchComponents(record.periodType),
      );
      debugPrint('🔔 [NotificationService] Bildirim başarıyla zamanlandı: ID $notificationId, Tarih: $targetDate');
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
