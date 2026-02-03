/// A navigation intent extracted from a notification.
class NotificationRoute {
  final String location; // e.g. '/orders/123'
  final Map<String, String> params;

  const NotificationRoute(this.location, {this.params = const {}});
}
