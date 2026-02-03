import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/src/auth_controller.dart';
import 'package:foundation_auth/src/auth_service.dart';
import 'package:foundation_auth/src/session_manager.dart';
import 'package:foundation_auth/src/token_manager.dart';
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_networking/foundation_networking.dart';
import 'package:foundation_storage/foundation_storage.dart';

/// Expects these to be provided by `foundation_config` and `foundation_storage`.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('Provide AppConfig via foundation_config');
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  throw UnimplementedError('Provide SecureStorage via foundation_storage');
});

final preferencesStorageProvider = Provider<PreferencesStorage>((ref) {
  throw UnimplementedError('Provide PreferencesStorage via foundation_storage');
});

final grpcChannelFactoryProvider = Provider<GrpcChannelFactory>((ref) {
  throw UnimplementedError('Provide GrpcChannelFactory via foundation_networking');
});

final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager(
    secureStorage: ref.watch(secureStorageProvider),
    prefs: ref.watch(preferencesStorageProvider),
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    channelFactory: ref.watch(grpcChannelFactoryProvider),
    tokenManager: ref.watch(tokenManagerProvider),
    appConfig: ref.watch(appConfigProvider),
  );
});

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(
    tokenManager: ref.watch(tokenManagerProvider),
    authService: ref.watch(authServiceProvider),
  );
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    authService: ref.watch(authServiceProvider),
    tokenManager: ref.watch(tokenManagerProvider),
  );
});

final authStateProvider = Provider<AuthState>((ref) => ref.watch(authControllerProvider));
