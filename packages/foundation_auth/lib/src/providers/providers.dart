import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/src/auth_controller.dart';
import 'package:foundation_auth/src/auth_service.dart';
import 'package:foundation_auth/src/auth_state.dart';
import 'package:foundation_auth/src/session_manager.dart';
import 'package:foundation_auth/src/token_manager.dart';
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_networking/foundation_networking.dart';
import 'package:foundation_storage/foundation_storage.dart';
import 'package:foundation_auth/src/auth_options.dart';

/// Expects these to be provided by `foundation_config` and `foundation_storage`.
final appConfigProvider = Provider<AppConfig>((ref) {
  return FoundationConfig.config;
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return StorageInitializer.secureStorage;
});

final preferencesStorageProvider = Provider<PreferencesStorage>((ref) {
  return StorageInitializer.preferencesStorage;
});

final grpcChannelFactoryProvider = Provider<GrpcChannelFactory>((ref) {
  final appConfig = ref.watch(appConfigProvider);
  final config = appConfig.grpcConfig;
  if (config == null) {
    throw StateError(
        'GrpcConfig is missing. Set AppConfig.grpcConfig or override grpcChannelFactoryProvider.');
  }
  return GrpcChannelFactoryBuilder()
      .withConfig(config)
      .withLogging(
        logMetadata: false,
        logRequest: appConfig.enableLogging,
        logResponse: appConfig.enableLogging,
      )
      .build();
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
    options: ref.watch(authOptionsProvider),
  );
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    authService: ref.watch(authServiceProvider),
    tokenManager: ref.watch(tokenManagerProvider),
    options: ref.watch(authOptionsProvider),
  );
});

final authStateProvider =
    Provider<AuthState>((ref) => ref.watch(authControllerProvider));

/// Auth runtime options. Override in your app to customize behaviors.
final authOptionsProvider = Provider<AuthOptions>((ref) => const AuthOptions());
