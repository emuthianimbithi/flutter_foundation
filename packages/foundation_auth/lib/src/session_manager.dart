import 'package:foundation_auth/src/auth_state.dart';
import 'package:foundation_auth/src/auth_service.dart';
import 'package:foundation_auth/src/token_manager.dart';

/// Restores a session on app start and refreshes if needed.
class SessionManager {
  final TokenManager _tokenManager;
  final AuthService _authService;

  SessionManager({
    required TokenManager tokenManager,
    required AuthService authService,
  })  : _tokenManager = tokenManager,
        _authService = authService;

  /// Attempts to restore an authenticated session.
  ///
  /// - If access token is still valid -> authenticated state (features may be empty)
  /// - Else if refresh token is valid -> refresh() and return authenticated
  /// - Else -> unauthenticated
  Future<AuthState> restore() async {
    if (await _tokenManager.hasValidAccessToken) {
      final userId = await _tokenManager.getUserId() ?? '';
      final orgSlug = await _tokenManager.getOrgSlug();
      final role = await _tokenManager.getRole() ?? '';
      final accessToken = await _tokenManager.getAccessToken() ?? '';
      final refreshToken = await _tokenManager.getRefreshToken() ?? '';
      return AuthState.authenticated(
        userId: userId,
        orgSlug: orgSlug,
        features: const [],
        role: role,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    if (await _tokenManager.hasRefreshToken) {
      return _authService.refresh();
    }

    return const AuthState.unauthenticated();
  }
}
