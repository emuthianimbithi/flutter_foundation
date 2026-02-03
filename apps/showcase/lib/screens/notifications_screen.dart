import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_notifications/foundation_notifications.dart';
import 'package:foundation_ui/foundation_ui.dart';

final _fakeResolverProvider = Provider<NotificationRouteResolver>((ref) {
  return _DemoNotificationResolver();
});

class _DemoNotificationResolver implements NotificationRouteResolver {
  @override
  NotificationRoute? resolve(NotificationPayload payload) {
    final route = (payload.data['route'] as String?) ?? '/notifications';
    final params = <String, String>{};
    final rawParams = payload.data['params'];
    if (rawParams is Map) {
      rawParams.forEach((key, value) {
        params[key.toString()] = value?.toString() ?? '';
      });
    }
    return NotificationRoute(route, params: params);
  }
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late final NotificationRouter _router;
  StreamSubscription<NotificationEvent>? _sub;
  String _last = 'None yet';

  @override
  void initState() {
    super.initState();
    _router = NotificationRouter(resolver: ref.read(_fakeResolverProvider));
    _sub = _router.events.listen((event) {
      if (event is NotificationTapped) {
        setState(() => _last = 'Tapped: ${event.payload.title}');
      } else if (event is NotificationReceived) {
        setState(() => _last = 'Received: ${event.payload.title}');
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simulate a notification event and observe routing.'),
            SizedBox(height: tokens.space12),
            FoundationButton(
              label: 'Simulate notification',
              onPressed: () {
                final payload = NotificationPayload(
                  title: 'Demo alert',
                  body: 'This is a fake notification',
                  data: {
                    'route': '/notifications',
                    'params': {'source': 'demo'},
                  },
                );
                _router.onTap(payload);
              },
            ),
            SizedBox(height: tokens.space16),
            Text('Last event: $_last'),
          ],
        ),
      ),
    );
  }
}
