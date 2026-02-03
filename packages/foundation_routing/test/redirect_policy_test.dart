import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_auth/foundation_auth.dart';
import 'package:foundation_routing/foundation_routing.dart';

void main() {
  group('AuthRedirectPolicy', () {
    final handler = DeepLinkHandler();
    final options = RoutingOptions();
    final policy =
        AuthRedirectPolicy(options: options, deepLinkHandler: handler);

    RedirectRequest req(String location) =>
        RedirectRequest(matchedLocation: location, uri: Uri.parse(location));

    test('unauthenticated redirects to login', () {
      final result = policy.redirect(
          authState: const AuthState.unauthenticated(), request: req('/home'));
      expect(result, AppRoutes.login);
    });

    test('authenticated stays on home', () {
      final authState = const AuthState.authenticated(
        userId: 'u1',
        orgSlug: 'org',
        features: [],
        role: 'user',
        accessToken: 'a',
        refreshToken: 'r',
      );
      final result =
          policy.redirect(authState: authState, request: req(AppRoutes.home));
      expect(result, isNull);
    });

    test('deep link queued then resumed after auth', () {
      final unauth = const AuthState.unauthenticated();
      final authd = const AuthState.authenticated(
        userId: 'u1',
        orgSlug: 'org',
        features: [],
        role: 'user',
        accessToken: 'a',
        refreshToken: 'r',
      );

      final first = policy.redirect(
        authState: unauth,
        request: RedirectRequest(
            matchedLocation: '/profile/123', uri: Uri.parse('/profile/123')),
      );
      expect(first, AppRoutes.login);

      final resume = policy.redirect(
        authState: authd,
        request: RedirectRequest(
            matchedLocation: AppRoutes.home, uri: Uri.parse(AppRoutes.home)),
      );
      expect(resume, '/profile/123');
    });
  });

  group('NoAuthRedirectPolicy', () {
    final policy = NoAuthRedirectPolicy();
    test('never redirects', () {
      final result = policy.redirect(
        authState: const AuthState.unauthenticated(),
        request: RedirectRequest(
            matchedLocation: '/anything', uri: Uri.parse('/anything')),
      );
      expect(result, isNull);
    });
  });
}
