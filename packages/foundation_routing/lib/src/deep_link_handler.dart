import 'package:go_router/go_router.dart';

/// Deep-link handling utilities.
///
/// This is intentionally lightweight. go_router already supports deep links.
/// You can extend this to map incoming URIs into app routes or trigger flows.
class DeepLinkHandler {
  const DeepLinkHandler();

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
}
