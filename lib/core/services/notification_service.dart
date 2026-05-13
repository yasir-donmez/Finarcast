import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../database/models/transaction_record.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
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
    if (targetDate.isBefore(DateTime.now())) {
      if (record.periodType == 0) return; // Tek seferlik ise ve geçtiyse kurma
      
      // Basit bir sonraki tarih hesaplama (Aylık vb. için daha kompleks olabilir)
      targetDate = _calculateNextOccurrence(targetDate, record.periodType);
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

    await _notifications.zonedSchedule(
      id: notificationId,
      title: 'Finarcast Hatırlatıcısı',
      body: '${record.title} için ödeme/gelir zamanı geldi!',
      scheduledDate: tz.TZDateTime.from(targetDate, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _getMatchComponents(record.periodType),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  DateTime _calculateNextOccurrence(DateTime current, int periodType) {
    switch (periodType) {
      case 1: return current.add(const Duration(days: 7)); // Haftalık
      case 2: return DateTime(current.year, current.month + 1, current.day, current.hour, current.minute); // Aylık
      case 3: return DateTime(current.year + 1, current.month, current.day, current.hour, current.minute); // Yıllık
      case 4: return current.add(const Duration(days: 14)); // 2 Haftada Bir
      case 8: return current.add(const Duration(days: 1)); // Günlük
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
