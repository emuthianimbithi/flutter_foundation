import 'package:foundation_auth/src/auth_state.dart';
import 'package:foundation_auth/src/auth_service.dart';
import 'package:foundation_auth/src/auth_options.dart';
import 'package:foundation_auth/src/token_manager.dart';

/// Restores a session on app start and refreshes if needed.
class SessionManager {
  final TokenManager _tokenManager;
  final AuthService _authService;
  final AuthOptions _options;
  final DateTime Function() _now;

  SessionManager({
    required TokenManager tokenManager,
    required AuthService authService,
    AuthOptions options = const AuthOptions(),
    DateTime Function()? now,
  })  : _tokenManager = tokenManager,
        _authService = authService,
        _options = options,
        _now = now ?? DateTime.now;

  /// Attempts to restore an authenticated session.
  ///
  /// - If access token is still valid -> authenticated state (features may be empty)
  /// - Else if refresh token is valid -> refresh() and return authenticated
  /// - Else -> unauthenticated
  Future<AuthState> restore() async {
    final snapshot = await _tokenManager.loadSnapshot();
    final now = _now();

    final accessValid = snapshot.accessToken != null &&
        snapshot.accessExpiry != null &&
        snapshot.accessExpiry!.isAfter(now.add(_options.refreshLeeway));

    if (accessValid) {
      return AuthState.authenticated(
        userId: snapshot.userId ?? '',
        orgSlug: snapshot.orgSlug,
        features: const [],
        role: snapshot.role ?? '',
        accessToken: snapshot.accessToken!,
        refreshToken: snapshot.refreshToken ?? '',
      );
    }

    final refreshValid = snapshot.refreshToken != null &&
        snapshot.refreshExpiry != null &&
        snapshot.refreshExpiry!.isAfter(now.add(_options.refreshLeeway));

    if (_options.autoRefresh && refreshValid) {
      return _authService.refresh();
    }

    return const AuthState.unauthenticated();
  }
}
