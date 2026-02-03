import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../foundation_notifications.dart';

/// Provide an app-specific resolver in your app using `overrideWithValue`.
final notificationRouteResolverProvider = Provider<NotificationRouteResolver>((ref) {
  throw UnimplementedError('Provide NotificationRouteResolver via ProviderScope overrides.');
});

final notificationRouterProvider = Provider<NotificationRouter>((ref) {
  final resolver = ref.watch(notificationRouteResolverProvider);
  final router = NotificationRouter(resolver: resolver);
  ref.onDispose(router.dispose);
  return router;
});

final notificationsPermissionServiceProvider = Provider<NotificationsPermissionService>((ref) {
  return const NotificationsPermissionService();
});

final localNotificationsServiceProvider = Provider<LocalNotificationsService>((ref) {
  return LocalNotificationsService();
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService();
});

final notificationsInitializerProvider = Provider<NotificationsInitializer>((ref) {
  return NotificationsInitializer(
    permissions: ref.watch(notificationsPermissionServiceProvider),
    local: ref.watch(localNotificationsServiceProvider),
    fcm: ref.watch(fcmServiceProvider),
    router: ref.watch(notificationRouterProvider),
  );
});

/// Stream of notification events for the app to consume.
final notificationEventsProvider = StreamProvider<NotificationEvent>((ref) {
  final router = ref.watch(notificationRouterProvider);
  // Convert broadcast stream to single-sub stream for Riverpod.
  final controller = StreamController<NotificationEvent>();
  final sub = router.events.listen(controller.add, onError: controller.addError, onDone: controller.close);
  ref.onDispose(() async {
    await sub.cancel();
    await controller.close();
  });
  return controller.stream;
});
