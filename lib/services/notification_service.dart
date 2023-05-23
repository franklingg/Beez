import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.getToken();
  }

  static Future persistNotification(RemoteMessage message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('@beez/event_notification_id', message.data['event']);
  }

  static Future<String?> getNotificationId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('@beez/event_notification_id')) {
      final eventId = prefs.getString('@beez/event_notification_id');
      prefs.remove('@beez/event_notification_id');
      return eventId;
    }
    return null;
  }
}
