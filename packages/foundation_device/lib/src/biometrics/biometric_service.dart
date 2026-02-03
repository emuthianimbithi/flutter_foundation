import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheckBiometrics() => _auth.canCheckBiometrics;

  Future<bool> authenticate({required String reason}) async {
    return _auth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
    );
  }
}