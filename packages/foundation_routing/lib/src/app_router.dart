import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/foundation_auth.dart';
import 'package:go_router/go_router.dart';

import 'deep_link_handler.dart';
import 'providers.dart';
import 'routes.dart';

/// Router configuration allowing host apps to plug in pages.
class AppRouterConfig {
  final WidgetBuilder splashBuilder;
  final WidgetBuilder loginBuilder;
  final WidgetBuilder orgSelectBuilder;
  final WidgetBuilder mfaBuilder;
  final WidgetBuilder homeBuilder;
  final WidgetBuilder forbiddenBuilder;

  const AppRouterConfig({
    this.splashBuilder = _defaultSplash,
    this.loginBuilder = _defaultLogin,
    this.orgSelectBuilder = _defaultOrg,
    this.mfaBuilder = _defaultMfa,
    this.homeBuilder = _defaultHome,
    this.forbiddenBuilder = _defaultForbidden,
  });

  static Widget _defaultSplash(BuildContext _) =>
      const PlaceholderPage('Splash (override in AppRouterConfig)');
  static Widget _defaultLogin(BuildContext _) =>
      const PlaceholderPage('Login (override in AppRouterConfig)');
  static Widget _defaultOrg(BuildContext _) =>
      const PlaceholderPage('Org Select (override in AppRouterConfig)');
  static Widget _defaultMfa(BuildContext _) =>
      const PlaceholderPage('MFA (override in AppRouterConfig)');
  static Widget _defaultHome(BuildContext _) =>
      const PlaceholderPage('Home (override in AppRouterConfig)');
  static Widget _defaultForbidden(BuildContext _) =>
      const PlaceholderPage('Forbidden (override in AppRouterConfig)');
}

/// GoRouter setup with redirects driven by [AuthState].
///
/// Redirect rules:
/// - unauthenticated -> /login
/// - requires_org_selection -> /org
/// - requires_mfa -> /mfa
/// - authenticated -> /home (unless already at an allowed route)
class AppRouter {
  final Ref ref;
  final AppRouterConfig config;
  late final GoRouter router;

  AppRouter({required this.ref, required this.config}) {
    final deepLinkHandler = ref.read(deepLinkHandlerProvider);

    router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: <RouteBase>[
        GoRoute(
          name: AppRouteNames.splash,
          path: AppRoutes.splash,
          builder: (context, state) => config.splashBuilder(context),
        ),
        GoRoute(
          name: AppRouteNames.login,
          path: AppRoutes.login,
          builder: (context, state) => config.loginBuilder(context),
        ),
        GoRoute(
          name: AppRouteNames.orgSelect,
          path: AppRoutes.orgSelect,
          builder: (context, state) => config.orgSelectBuilder(context),
        ),
        GoRoute(
          name: AppRouteNames.mfa,
          path: AppRoutes.mfa,
          builder: (context, state) => config.mfaBuilder(context),
        ),
        GoRoute(
          name: AppRouteNames.home,
          path: AppRoutes.home,
          builder: (context, state) => config.homeBuilder(context),
        ),
        GoRoute(
          name: AppRouteNames.forbidden,
          path: AppRoutes.forbidden,
          builder: (context, state) => config.forbiddenBuilder(context),
        ),
      ],
      refreshListenable: _GoRouterRefreshStream(
        // Rebuild redirect logic whenever auth state changes
        ref.watch(authControllerProvider.notifier).stream,
      ),
      redirect: (context, state) {
        // Allow deep link mapping hook
        final mapped = deepLinkHandler.mapIncomingUri(state.uri);
        if (mapped != null && mapped != state.matchedLocation) {
          return mapped;
        }

        final authState = ref.read(authControllerProvider);

        final loc = state.matchedLocation;

        final isAtSplash = loc == AppRoutes.splash;
        final isAtLogin = loc == AppRoutes.login;
        final isAtOrg = loc == AppRoutes.orgSelect;
        final isAtMfa = loc == AppRoutes.mfa;

        // State-specific redirects
        return authState.when(
          unauthenticated: () {
            // Let splash render once, then bounce to login
            if (isAtLogin) return null;
            if (isAtSplash) return AppRoutes.login;
            // allow forbidden route
            if (loc == AppRoutes.forbidden) return null;
            return AppRoutes.login;
          },
          requiresOrgSelection: (orgs, token) {
            if (isAtOrg) return null;
            return AppRoutes.orgSelect;
          },
          requiresMfa: (token, methods) {
            if (isAtMfa) return null;
            return AppRoutes.mfa;
          },
          authenticated: (session) {
            // If user is authenticated but somehow at login/org/mfa/splash, go home.
            if (isAtLogin || isAtOrg || isAtMfa || isAtSplash) {
              return AppRoutes.home;
            }
            return null;
          },
        );
      },
      navigatorKey: GlobalKey<NavigatorState>(),
      observers: <NavigatorObserver>[
        _DeepLinkObserver(deepLinkHandler),
      ],
    );
  }
}

/// Allows GoRouter to refresh when a stream emits.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Hooks for post-route deep link handling.
class _DeepLinkObserver extends NavigatorObserver {
  final DeepLinkHandler handler;
  _DeepLinkObserver(this.handler);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final settings = route.settings;
    if (settings is GoRouterState) {
      handler.onRouted(settings);
    }
    super.didPush(route, previousRoute);
  }
}
