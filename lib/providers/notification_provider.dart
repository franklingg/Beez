import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/presentation/event/event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider extends ChangeNotifier {
  late final InitializationSettings settings;
  late final FlutterLocalNotificationsPlugin plugin;

  NotificationProvider() {
    plugin = FlutterLocalNotificationsPlugin();
    plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    settings = const InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'));
  }

  void start(BuildContext context) {
    plugin.initialize(settings,
        onDidReceiveNotificationResponse: (response) async {
      GoRouter.of(context)
          .pushNamed(EventScreen.name, queryParams: {'id': response.payload});
    });
  }

  Future<void> scheduleNotification(EventModel event) async {
    await plugin.zonedSchedule(
        DateTime.now().hashCode,
        'Evento Próximo!',
        "Beez aqui para te lembrar que ${event.name} acontecerá em 12h, tudo pronto? Bora lá!",
        tz.TZDateTime.from(event.date.toDate(), tz.local)
            .subtract(const Duration(hours: 12)),
        NotificationDetails(
            android: AndroidNotificationDetails(
                dotenv.env['NOTIFICATION_CHANNEL_ID']!, '@BEEZ/EVENTS',
                playSound: false,
                category: AndroidNotificationCategory.event,
                channelShowBadge: true,
                color: AppColors.darkYellow,
                visibility: NotificationVisibility.public,
                fullScreenIntent: true,
                styleInformation: const BigTextStyleInformation(''),
                channelDescription:
                    'Canal de notificações para eventos do Beez')),
        payload: event.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> subscribeNotifications(
      String? userId, List<EventModel> events) async {
    if (userId != null) {
      await plugin.cancelAll();
      for (final event in events) {
        if (event.interested.contains(userId)) {
          await scheduleNotification(event);
        }
      }
    }
  }

  // TODO: DELETE
  Future<void> debug(EventModel event) async {
    await plugin.zonedSchedule(
        DateTime.now().hashCode,
        'Evento Próximo!',
        "Beez aqui para te lembrar que ${event.name} acontecerá em 12h, tudo pronto? Bora lá!",
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
        NotificationDetails(
            android: AndroidNotificationDetails(
                dotenv.env['NOTIFICATION_CHANNEL_ID']!, '@BEEZ/EVENTS_TEST',
                playSound: false,
                category: AndroidNotificationCategory.event,
                channelShowBadge: true,
                color: AppColors.darkYellow,
                visibility: NotificationVisibility.public,
                fullScreenIntent: true,
                styleInformation: const BigTextStyleInformation(''),
                channelDescription:
                    'Canal de notificações para eventos do Beez')),
        payload: event.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
