import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/foundation_auth.dart';
import 'package:go_router/go_router.dart';

import 'deep_link_handler.dart';
import 'providers.dart';
import 'routes.dart';
import 'routing_options.dart';
import 'redirect_policy.dart';
import 'default_pages.dart';

/// Router configuration allowing host apps to plug in pages.
class AppRouterConfig {
  final RoutingOptions options;
  final WidgetBuilder splashBuilder;
  final WidgetBuilder loginBuilder;
  final WidgetBuilder orgSelectBuilder;
  final WidgetBuilder mfaBuilder;
  final WidgetBuilder homeBuilder;
  final WidgetBuilder forbiddenBuilder;

  const AppRouterConfig({
    this.options = const RoutingOptions(),
    WidgetBuilder? splashBuilder,
    WidgetBuilder? loginBuilder,
    WidgetBuilder? orgSelectBuilder,
    WidgetBuilder? mfaBuilder,
    WidgetBuilder? homeBuilder,
    WidgetBuilder? forbiddenBuilder,
  })  : splashBuilder = splashBuilder ?? _defaultSplash,
        loginBuilder = loginBuilder ?? _defaultLogin,
        orgSelectBuilder = orgSelectBuilder ?? _defaultOrg,
        mfaBuilder = mfaBuilder ?? _defaultMfa,
        homeBuilder = homeBuilder ?? _defaultHome,
        forbiddenBuilder = forbiddenBuilder ?? _defaultForbidden;

  static Widget _defaultSplash(BuildContext _) =>
      const SplashPage(appName: 'Loading...');
  static Widget _defaultLogin(BuildContext _) => const DefaultLoginPage();
  static Widget _defaultOrg(BuildContext _) => const DefaultOrgSelectionPage();
  static Widget _defaultMfa(BuildContext _) => const DefaultMfaPage();
  static Widget _defaultHome(BuildContext _) => const _HomePlaceholder();
  static Widget _defaultForbidden(BuildContext _) => const ForbiddenPage();
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
  final RoutingOptions options;
  late final GoRouter router;
  late final RedirectPolicy _redirectPolicy;

  AppRouter({required this.ref, required this.config})
      : options = config.options {
    final deepLinkHandler = ref.read(deepLinkHandlerProvider);
    _redirectPolicy = options.mode == RoutingMode.simple
        ? const NoAuthRedirectPolicy()
        : AuthRedirectPolicy(
            options: options, deepLinkHandler: deepLinkHandler);

    router = GoRouter(
      initialLocation: options.initialRoute,
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
        if (options.enableDeepLinks) {
          final mapped = deepLinkHandler.mapIncomingUri(state.uri);
          if (mapped != null && mapped != state.matchedLocation) {
            return mapped;
          }
        }

        final authState = ref.read(authControllerProvider);

        final queued = deepLinkHandler.takeIfReady(authState, options);
        if (queued != null && queued != state.matchedLocation) {
          return queued;
        }

        return _redirectPolicy.redirect(
          authState: authState,
          request: RedirectRequest(
            matchedLocation: state.matchedLocation,
            uri: state.uri,
          ),
        );
      },
      navigatorKey: GlobalKey<NavigatorState>(),
      observers: <NavigatorObserver>[
        _DeepLinkObserver(deepLinkHandler),
      ],
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Provide a homeBuilder to AppRouterConfig.')),
      );
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
