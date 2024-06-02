import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick =
      BehaviorSubject<String?>();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> initializeNotification() async {
    // App icon for Android notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('greentriangle');

    // Request permissions for iOS notifications
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Combine platform-specific settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse);
  }

  Future<void> showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {
    // Define channel settings for Android notifications
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    // Define settings for iOS notifications
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combine platform-specific details into general notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      id,
      title ?? 'Notification',
      body ?? 'Here is the notification body',
      platformChannelSpecifics,
      payload: payload,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      onNotificationClick.add(response.payload);
    }
  }
}
