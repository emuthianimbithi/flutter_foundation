import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_notifications/foundation_notifications.dart';

class _TestResolver implements NotificationRouteResolver {
  @override
  NotificationRoute? resolve(NotificationPayload payload) {
    final id = payload.data['id']?.toString();
    if (id == null) return null;
    return NotificationRoute('/items/$id');
  }
}

void main() {
  test('NotificationRouter emits tapped event with resolved route', () async {
    final router = NotificationRouter(resolver: _TestResolver());
    final payload = NotificationPayload(title: 't', body: 'b', data: {'id': 7});

    final events = <NotificationEvent>[];
    final sub = router.events.listen(events.add);

    router.onTap(payload);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(events.length, 1);
    expect(events.first, isA<NotificationTapped>());
    final tapped = events.first as NotificationTapped;
    expect(tapped.route?.location, '/items/7');

    await sub.cancel();
    await router.dispose();
  });
}
