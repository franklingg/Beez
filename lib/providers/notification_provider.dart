import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationProvider extends ChangeNotifier {
  late final FlutterLocalNotificationsPlugin plugin;

  NotificationProvider() {
    plugin = FlutterLocalNotificationsPlugin();
    plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    plugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) async {
      print(response.payload);
    });
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await plugin.show(0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }
}
