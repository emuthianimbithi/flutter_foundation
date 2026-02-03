import 'dart:convert';

/// Normalized notification payload for both FCM data messages and local notifs.
class NotificationPayload {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  const NotificationPayload({
    this.title,
    this.body,
    this.data = const <String, dynamic>{},
  });

  factory NotificationPayload.fromFcmMessage(Map<String, dynamic> message) {
    // `firebase_messaging` provides RemoteMessage, but we keep this type pure.
    final notification = message['notification'] as Map<String, dynamic>?;
    final data = (message['data'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    return NotificationPayload(
      title: notification?['title'] as String?,
      body: notification?['body'] as String?,
      data: data,
    );
  }

  factory NotificationPayload.fromJsonString(String jsonStr) {
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return NotificationPayload(
      title: map['title'] as String?,
      body: map['body'] as String?,
      data:
          (map['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );
  }

  String toJsonString() => json.encode(<String, dynamic>{
        'title': title,
        'body': body,
        'data': data,
      });
}
