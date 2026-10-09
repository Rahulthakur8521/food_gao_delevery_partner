```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServerKey {
  final _fm = FirebaseMessaging.instance;

  Future<String?> getToken() async {
    return await _fm.getToken();
  }

  Future<String> getServerKey() async {
    return '';
  }

  Future<void> sendOrderNotificationToPartner({
    required String serverKey,
    required String deviceToken,
    required String name,
    required String orderId,
    required String partnerId,
  }) async {
    if (serverKey.isEmpty) {
      print('Notification unavailable: secure backend required.');
      return;
    }
  }
}
```
