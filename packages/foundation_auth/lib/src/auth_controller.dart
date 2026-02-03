import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/src/auth_service.dart';
import 'package:foundation_auth/src/auth_state.dart';
import 'package:foundation_auth/src/token_manager.dart';
import 'package:foundation_core/foundation_core.dart';

/// Controls the auth state machine and exposes actions to the UI/router.
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final TokenManager _tokenManager;

  AuthController({
    required AuthService authService,
    required TokenManager tokenManager,
  })  : _authService = authService,
        _tokenManager = tokenManager,
        super(const AuthState.unauthenticated());

  Future<void> restoreSession(SessionManager sessionManager) async {
    state = const AuthState.authenticating();
    try {
      state = await sessionManager.restore();
    } catch (e) {
      state = const AuthState.unauthenticated(message: 'Failed to restore session');
    }
  }

  Future<Result<void>> login({
    required String email,
    required String password,
    String? orgSlug,
  }) async {
    state = const AuthState.authenticating();
    try {
      state = await _authService.login(email: email, password: password, orgSlug: orgSlug);
      return Result.success(null);
    } catch (e) {
      state = const AuthState.unauthenticated(message: 'Login failed');
      return Result.failure(Failure.unexpected(e.toString()));
    }
  }

  Future<Result<void>> selectOrganization({
    required String orgSelectionToken,
    required String orgSlug,
  }) async {
    state = const AuthState.authenticating();
    try {
      state = await _authService.selectOrganization(
        orgSelectionToken: orgSelectionToken,
        orgSlug: orgSlug,
      );
      return Result.success(null);
    } catch (e) {
      state = const AuthState.unauthenticated(message: 'Organization selection failed');
      return Result.failure(Failure.unexpected(e.toString()));
    }
  }

  /// Verify MFA to complete login.
  Future<Result<void>> verifyMfa({
    required String mfaToken,
    required String method,
    required String code,
  }) async {
    // Preserve prior MFA context if we're currently in it.
    final prior = state;
    state = const AuthState.authenticating();
    try {
      state = await _authService.verifyMfa(mfaToken: mfaToken, method: method, code: code);
      return Result.success(null);
    } catch (e) {
      if (prior.phase == AuthPhase.requiresMfa) {
        state = AuthState.requiresMfa(
          mfaToken: prior.mfaToken ?? mfaToken,
          methods: prior.mfaMethods.isNotEmpty ? prior.mfaMethods : <String>[method],
        );
      } else {
        state = const AuthState.unauthenticated(message: 'MFA verification failed');
      }
      return Result.failure(Failure.unexpected(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // MFA feature management (authenticated user)
  // ---------------------------------------------------------------------------

  Future<Result<TotpSetupData>> setupTotp() async {
    try {
      final data = await _authService.setupTotp();
      return Result.success(data);
    } catch (e) {
      return Result.failure(Failure.unexpected(e.toString()));
    }
  }

  Future<Result<List<String>>> verifyTotpSetup({required String code}) async {
    try {
      final codes = await _authService.verifyTotpSetup(code: code);
      return Result.success(codes);
    } catch (e) {
      return Result.failure(Failure.unexpected(e.toString()));
    }
  }

  Future<Result<void>> disableTotp({required String password, required String code}) async {
    try {
      await _authService.disableTotp(password: password, code: code);
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.unexpected(e.toString()));
    }
  }

  Future<Result<List<String>>> generateRecoveryCodes({required String password}) async {
    try {
      final codes = await _authService.generateRecoveryCodes(password: password);
      return Result.success(codes);
    } catch (e) {
      return Result.failure(Failure.unexpected(e.toString()));
    }
  }

  Future<Result<MfaStatusData>> getMfaStatus() async {
    try {
      final status = await _authService.getMfaStatus();
      return Result.success(status);
    } catch (e) {
      return Result.failure(Failure.unexpected(e.toString()));
    }
  }


  Future<Result<void>> switchOrganization({required String orgSlug}) async {
    state = const AuthState.authenticating();
    try {
      state = await _authService.switchOrganization(orgSlug: orgSlug);
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.unexpected(e.toString()));
    }
  }

  Future<void> logout() async {
    final refresh = await _tokenManager.getRefreshToken();
    try {
      await _authService.logout(refreshToken: refresh);
    } finally {
      state = const AuthState.unauthenticated();
    }
  }
}
