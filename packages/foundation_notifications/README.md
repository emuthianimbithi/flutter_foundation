# foundation_notifications

A small, opinionated-but-extensible notifications layer for Flutter mobile apps:

- FCM registration + token refresh
- Foreground local notifications via `flutter_local_notifications`
- Notification routing (tap → route) via a pluggable resolver
- Riverpod providers for app-level composition

This package intentionally does **not** decide your routes. You plug in a resolver.

## Install

Add as a path or git dependency.

```yaml
dependencies:
  foundation_notifications:
    path: packages/foundation_notifications
  foundation_routing:
    path: packages/foundation_routing
  # If your notification payloads reference backend protos, add:
  marulla_protos:
    git:
      url: https://github.com/emuthianimbithi/protos.git
      ref: 0.0.1
      path: gen/dart/marulla_protos
```

## Usage (high level)

1. Provide `NotificationRouteResolver` and `NotificationRouter` in your app.
2. Call `NotificationsInitializer.initialize()` on app start.
3. Listen to `notificationEventsProvider` and perform navigation with your routing layer.

See `lib/src/notifications_initializer.dart` and `lib/src/providers.dart`.
