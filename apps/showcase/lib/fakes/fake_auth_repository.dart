import 'dart:async';

enum FakeAuthPhase { idle, loggingIn, needsOrg, needsMfa, authenticated }

class FakeAuthState {
  final FakeAuthPhase phase;
  final String? message;
  final List<String> orgs;
  final List<String> mfaMethods;
  const FakeAuthState({
    required this.phase,
    this.message,
    this.orgs = const [],
    this.mfaMethods = const [],
  });
}

/// Demo-only auth repository that mimics the proto responses without network calls.
class FakeAuthRepository {
  FakeAuthState _state = const FakeAuthState(phase: FakeAuthPhase.idle);
  FakeAuthState get state => _state;

  Future<FakeAuthState> login(String email, String password) async {
    _state = const FakeAuthState(phase: FakeAuthPhase.loggingIn);
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Simulate that some users need org selection, others MFA.
    if (email.endsWith('@org.com')) {
      _state = const FakeAuthState(
        phase: FakeAuthPhase.needsOrg,
        orgs: ['org-a', 'org-b'],
      );
    } else {
      _state = const FakeAuthState(phase: FakeAuthPhase.needsMfa, mfaMethods: ['totp', 'recovery_code']);
    }
    return _state;
  }

  Future<FakeAuthState> selectOrg(String slug) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _state = const FakeAuthState(phase: FakeAuthPhase.needsMfa, mfaMethods: ['totp', 'recovery_code']);
    return _state;
  }

  Future<FakeAuthState> verifyMfa(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (code == '000000') {
      _state = const FakeAuthState(phase: FakeAuthPhase.authenticated);
    } else {
      _state = const FakeAuthState(phase: FakeAuthPhase.needsMfa, message: 'Invalid code');
    }
    return _state;
  }
}
