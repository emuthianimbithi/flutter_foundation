import 'package:foundation_auth/foundation_auth.dart';
import 'package:foundation_routing/src/routing_options.dart';
import 'package:go_router/go_router.dart';

/// Deep-link handling utilities.
///
/// This is intentionally lightweight. go_router already supports deep links.
/// You can extend this to map incoming URIs into app routes or trigger flows.
class DeepLinkHandler {
  DeepLinkHandler();

  String? _queuedLocation;

  /// Map an incoming URI to a location string understood by [GoRouter].
  ///
  /// Return null to let go_router handle it normally.
  String? mapIncomingUri(Uri uri) {
    // Example: app://verify-email?token=... -> /login?verify=...
    // Implement your product-specific mapping here.
    return null;
  }

  /// Optional hook after a deep link has been routed.
  void onRouted(GoRouterState state) {
    // No-op by default.
  }

  /// Queue a location until auth is ready.
  void queue(String location) {
    _queuedLocation ??= location;
  }

  /// Consume queued deep link when authenticated.
  String? consumeQueued() {
    final queued = _queuedLocation;
    _queuedLocation = null;
    return queued;
  }

  /// Returns a queued deep link if auth has become authenticated and queueing is enabled.
  String? takeIfReady(AuthState authState, RoutingOptions options) {
    if (authState.isAuthenticated && options.deepLinkQueueUntilAuthReady) {
      return consumeQueued();
    }
    return null;
  }
}
