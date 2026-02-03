import 'models/notification_payload.dart';
import 'models/notification_route.dart';

/// Converts a notification payload into an app route.
///
/// Keep this app-specific. The foundation package provides the wiring.
/// Return null if the notification should not navigate anywhere.
abstract class NotificationRouteResolver {
  NotificationRoute? resolve(NotificationPayload payload);
}
