import 'dart:async';

import 'models/notification_payload.dart';
import 'models/notification_route.dart';
import 'notification_route_resolver.dart';

/// Events emitted by [NotificationRouter].
sealed class NotificationEvent {
  const NotificationEvent();
}

class NotificationReceived extends NotificationEvent {
  final NotificationPayload payload;
  const NotificationReceived(this.payload);
}

class NotificationTapped extends NotificationEvent {
  final NotificationPayload payload;
  final NotificationRoute? route;
  const NotificationTapped(this.payload, this.route);
}

/// Central routing hub. It does not navigate itself; it emits events.
///
/// Your app listens to the event stream and performs navigation using its router.
class NotificationRouter {
  final NotificationRouteResolver resolver;

  final StreamController<NotificationEvent> _controller =
      StreamController<NotificationEvent>.broadcast();

  NotificationRouter({required this.resolver});

  Stream<NotificationEvent> get events => _controller.stream;

  void onForegroundMessage(NotificationPayload payload) {
    _controller.add(NotificationReceived(payload));
  }

  void onTap(NotificationPayload payload) {
    final route = resolver.resolve(payload);
    _controller.add(NotificationTapped(payload, route));
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
