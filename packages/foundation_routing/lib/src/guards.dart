import 'package:foundation_auth/foundation_auth.dart';

/// Pure guard helpers. They are used by [AppRouter] redirect logic.
abstract final class RouteGuards {
  static bool isAuthenticated(AuthState state) => state.isAuthenticated;

  static bool requiresMfa(AuthState state) =>
      state.maybeWhen(requiresMfa: (_, __) => true, orElse: () => false);

  static bool requiresOrgSelection(AuthState state) => state.maybeWhen(
        requiresOrgSelection: (_, __) => true,
        orElse: () => false,
      );

  static bool hasFeature(AuthState state, String code) => state.maybeWhen(
        authenticated: (session) => session.features.contains(code),
        orElse: () => false,
      );
}
