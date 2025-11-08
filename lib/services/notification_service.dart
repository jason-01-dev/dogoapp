import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
// timezone imports must be before declarations
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint('Notifications are not supported on web platform');
      return;
    }

    // Initialize timezone database for zonedSchedule
    initNotificationTimezone();

    // Platform-specific initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: null,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (payload) {
      debugPrint('Notification clicked: $payload');
    });

    // Create Android notification channel (no-op on iOS)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'dogo_channel', // id
      'DoGo reminders', // title
      description: 'Rappels pour les tâches DoGo',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request runtime permissions where required
    await _requestPermissionsIfNeeded();
  }

  Future<void> _requestPermissionsIfNeeded() async {
    try {
      if (Platform.isIOS) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      } else if (Platform.isAndroid) {
        // On Android 13+ (SDK 33) we must request POST_NOTIFICATIONS at runtime.
        // Using permission_handler simplifies the request flow.
        final status = await Permission.notification.status;
        if (status.isDenied || status.isRestricted) {
          await Permission.notification.request();
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return; // No-op on web

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'dogo_channel',
      'DoGo reminders',
      channelDescription: 'Rappels pour les tâches DoGo',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const platform =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      // Convert DateTime to TZ-aware time using local timezone handling fallback
      tz.TZDateTime.from(scheduledDate, tz.local),
      platform,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // best-effort
      payload: body,
    );
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

Future<void> initNotificationTimezone() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
}
