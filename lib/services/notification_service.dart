import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    tz.initializeTimeZones();

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    int? notificationId, required String payload,
  }) async {
    notificationId ??= DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Notificaciones Instantáneas',
      channelDescription: 'Canal para notificaciones inmediatas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      notificationId,
      title,
      body,
      details,
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required int notificationId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Notificaciones Programadas',
      channelDescription: 'Canal para recordatorios de tareas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}