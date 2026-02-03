import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_auth/foundation_auth.dart';

void main() {
  test('AuthState unauthenticated defaults', () {
    const s = AuthState.unauthenticated();
    expect(s.isAuthenticated, false);
    expect(s.phase, AuthPhase.unauthenticated);
  });
}
