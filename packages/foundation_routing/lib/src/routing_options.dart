import 'package:flutter/foundation.dart';

/// Routing modes supported by the foundation router.
enum RoutingMode { authDriven, simple }

@immutable
class RoutingOptions {
  final RoutingMode mode;
  final String initialRoute;
  final bool enableDeepLinks;
  final bool deepLinkQueueUntilAuthReady;

  const RoutingOptions({
    this.mode = RoutingMode.authDriven,
    this.initialRoute = '/',
    this.enableDeepLinks = true,
    this.deepLinkQueueUntilAuthReady = true,
  });

  RoutingOptions copyWith({
    RoutingMode? mode,
    String? initialRoute,
    bool? enableDeepLinks,
    bool? deepLinkQueueUntilAuthReady,
  }) {
    return RoutingOptions(
      mode: mode ?? this.mode,
      initialRoute: initialRoute ?? this.initialRoute,
      enableDeepLinks: enableDeepLinks ?? this.enableDeepLinks,
      deepLinkQueueUntilAuthReady:
          deepLinkQueueUntilAuthReady ?? this.deepLinkQueueUntilAuthReady,
    );
  }
}
