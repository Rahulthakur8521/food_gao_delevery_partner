import 'dart:convert';
import 'dart:io';

class PushNotification {
  // final baseUrl = "https://us-central1-urlifemebership.cloudfunctions.net/app/";

  static const fcmServerKey = "key=AAAA3eLhBAM:APA91bE7UZqtlN32Xu13A58GaOZVc3CU984i5bCYoagstTWVn8xxHH3eVjFjr6eCGCC4k0qvAcoqP9K83uR3_wtpKIxA7O1S0Y35hGCuHsO21TNfxfeD-oZnAqbbv9g6d-F6Sc-0wjQi";
  final httpClient = HttpClient();


  // call this fun for sending notification to one app to another app or app to app
  sendNotification(String title, String body, String id, List<String> to,
      String type) async {
    var notificationData = {
      "registration_ids": [to[0]],
      "notification": {
        "body": body,
        "title": title,
        "flutter_channel_id": "channel_id_fcm_vi",
        "sound": true
      },
      "data": {"_id": id, "_type": type}
    };

    final client = HttpClient();
    final request =
    await client.postUrl(Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.headers.set("Content-Type", "application/json; charset=UTF-8");
    request.headers.set("Authorization", fcmServerKey);
    request.add(utf8.encode(json.encode(notificationData)));
    final response = await request.close();
    print(response.statusCode);
  }

}