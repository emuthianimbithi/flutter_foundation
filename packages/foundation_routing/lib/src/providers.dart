import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/foundation_auth.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'deep_link_handler.dart';
import 'navigation_service.dart';

/// Provide a [DeepLinkHandler] so apps can override it.
final deepLinkHandlerProvider = Provider<DeepLinkHandler>((ref) {
  return DeepLinkHandler();
});

/// Provide the [GoRouter] instance.
final goRouterProvider = Provider<GoRouter>((ref) {
  final config = ref.watch(appRouterConfigProvider);
  return AppRouter(ref: ref, config: config).router;
});

/// Provide a [NavigationService] instance.
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref.watch(goRouterProvider));
});

/// Default router configuration.
///
/// Apps can override this provider in their top-level [ProviderScope] to supply
/// real page builders.
final appRouterConfigProvider = Provider<AppRouterConfig>((ref) {
  return const AppRouterConfig();
});

/// Convenient access to auth state for routing.
final authStateForRoutingProvider = Provider<AuthState>((ref) {
  return ref.watch(authControllerProvider);
});
