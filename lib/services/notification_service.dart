import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.getToken();
  }
}
