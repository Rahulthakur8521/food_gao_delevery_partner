
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

  static void initLocalNotification() {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    flutterLocalNotificationPlugin.initialize(settings);
  }

  static void showLocalNotification(RemoteMessage message) {
    try {
      const androidDetails = AndroidNotificationDetails(
        "channel_id_FoodGao_partner", "channelNameFoodGao_partner",
        importance: Importance.high,
        priority: Priority.high,
        showWhen: false,
      );
      const details = NotificationDetails(android: androidDetails);

      flutterLocalNotificationPlugin.show(
        0,
        message.notification?.title,
        message.notification?.body,
        details,
      );
    } catch (error) {
      print(error);
    }
  }
}