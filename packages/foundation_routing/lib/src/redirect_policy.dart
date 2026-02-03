import 'package:foundation_auth/foundation_auth.dart';
import 'package:foundation_routing/foundation_routing.dart';
import 'package:foundation_routing/src/routing_options.dart';
import 'package:go_router/go_router.dart';

class RedirectRequest {
  final String matchedLocation;
  final Uri uri;

  const RedirectRequest({required this.matchedLocation, required this.uri});
}

abstract class RedirectPolicy {
  String? redirect(
      {required AuthState authState, required RedirectRequest request});
}

class AuthRedirectPolicy implements RedirectPolicy {
  final RoutingOptions options;
  final DeepLinkHandler deepLinkHandler;

  const AuthRedirectPolicy(
      {required this.options, required this.deepLinkHandler});

  @override
  String? redirect(
      {required AuthState authState, required RedirectRequest request}) {
    final loc = request.matchedLocation;
    final isAtSplash = loc == AppRoutes.splash;
    final isAtLogin = loc == AppRoutes.login;
    final isAtOrg = loc == AppRoutes.orgSelect;
    final isAtMfa = loc == AppRoutes.mfa;

    // allow deep-link queueing if not authenticated yet
    if (!authState.isAuthenticated && options.deepLinkQueueUntilAuthReady) {
      final incoming = request.uri.toString();
      if (!_isSystemRoute(loc)) {
        deepLinkHandler.queue(incoming);
      }
    }

    switch (authState.phase) {
      case AuthPhase.unauthenticated:
        if (isAtLogin) return null;
        if (isAtSplash) return AppRoutes.login;
        if (_isSystemRoute(loc)) return null;
        return AppRoutes.login;
      case AuthPhase.requiresOrgSelection:
        if (isAtOrg) return null;
        return AppRoutes.orgSelect;
      case AuthPhase.requiresMfa:
        if (isAtMfa) return null;
        return AppRoutes.mfa;
      case AuthPhase.authenticated:
        if (isAtLogin || isAtOrg || isAtMfa || isAtSplash) {
          final queued = deepLinkHandler.consumeQueued();
          if (queued != null && queued != loc) return queued;
          return AppRoutes.home;
        }
        return null;
      case AuthPhase.authenticating:
        // stay on current route while loading
        return isAtSplash ? null : AppRoutes.splash;
    }
  }

  bool _isSystemRoute(String location) =>
      location == AppRoutes.splash || location == AppRoutes.login;
}

class NoAuthRedirectPolicy implements RedirectPolicy {
  const NoAuthRedirectPolicy();

  @override
  String? redirect(
          {required AuthState authState, required RedirectRequest request}) =>
      null;
}
