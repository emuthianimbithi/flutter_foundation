import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/foundation_auth.dart' as auth;
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:foundation_networking/foundation_networking.dart';
import 'package:foundation_payments/foundation_payments.dart';
import 'package:foundation_routing/foundation_routing.dart';
import 'package:foundation_storage/foundation_storage.dart';
import 'package:go_router/go_router.dart';

import 'bootstrap_options.dart';
part 'bootstrap_router.dart';

/// Wires core Foundation subsystems in a deterministic order.
class FoundationBootstrap {
  FoundationBootstrap._();

  static final AppLogger _log = AppLogger('FoundationBootstrap');

  static bool _initialized = false;
  static late AppConfig _config;
  static late FoundationBootstrapOptions _options;

  static GrpcChannelFactory? _grpcChannelFactory;
  static auth.TokenManager? _tokenManager;
  static auth.AuthService? _authService;
  static auth.SessionManager? _sessionManager;
  static auth.AuthController? _authController;

  /// Initializes all subsystems.
  ///
  /// Order:
  /// 1) Config
  /// 2) Storage
  /// 3) Networking (gRPC factory)
  /// 4) Auth (token/session hydration)
  ///
  /// Call this once at startup *before* building [ProviderScope].
  static Future<void> initialize({
    required AppConfig config,
    required String environment,
    FoundationBootstrapOptions options = const FoundationBootstrapOptions(),
  }) async {
    if (_initialized) {
      _log.warning(
          'FoundationBootstrap.initialize() called multiple times; ignoring');
      return;
    }

    _config = config;
    _options = options;

    if (config.environment.name.toLowerCase() != environment.toLowerCase()) {
      _log.warning(
        'AppConfig.environment (${config.environment.name}) does not match provided environment "$environment".',
      );
    }

    // 1) Config
    await FoundationConfig.initializeWithConfig(config);

    // 2) Storage
    await StorageInitializer.initialize(
      secureStorage: options.storage.secureStorage,
      preferencesStorage: options.storage.preferencesStorage,
      database: options.storage.database,
      fileStorage: options.storage.fileStorage,
      options: options.storage.options ?? const StorageOptions(),
    );

    // 3) Networking (gRPC)
    _grpcChannelFactory = options.networking.grpcChannelFactory;
    if (_grpcChannelFactory == null && config.grpcConfig != null) {
      final builder =
          GrpcChannelFactoryBuilder().withConfig(config.grpcConfig!);
      options.networking.configureGrpc?.call(builder);
      _grpcChannelFactory = builder.build();
    }

    // 4) Auth (hydrate session)
    final authOptions = options.auth.authOptions ?? const auth.AuthOptions();
    _tokenManager = auth.TokenManager(
      secureStorage: StorageInitializer.secureStorage,
      prefs: StorageInitializer.preferencesStorage,
    );

    if (_grpcChannelFactory != null) {
      _authService = auth.AuthService(
        channelFactory: _grpcChannelFactory!,
        tokenManager: _tokenManager!,
        appConfig: config,
      );
      _sessionManager = auth.SessionManager(
        tokenManager: _tokenManager!,
        authService: _authService!,
        options: authOptions,
      );
      _authController = auth.AuthController(
        authService: _authService!,
        tokenManager: _tokenManager!,
        options: authOptions,
      );

      if (options.auth.autoRestoreSession) {
        try {
          await _authController!.restoreSession(_sessionManager!);
          options.auth.onRestored?.call(_authController!.state);
        } catch (e, s) {
          _log.error('Session restore failed', e, s);
        }
      }
    } else {
      _log.warning(
          'Skipping auth wiring because no gRPC config/factory was provided.');
    }

    _initialized = true;
    _log.info('FoundationBootstrap initialized');
  }

  /// Provider overrides so Riverpod can reuse the initialized singletons.
  static List<Override> overrides() {
    _ensureInitialized();

    final overrides = <Override>[
      // foundation_config -> foundation_auth bridge
      auth.appConfigProvider.overrideWithValue(_config),

      // storage singletons
      secureStorageProvider.overrideWithValue(StorageInitializer.secureStorage),
      preferencesStorageProvider
          .overrideWithValue(StorageInitializer.preferencesStorage),
      appDatabaseProvider.overrideWithValue(StorageInitializer.database),
      fileStorageProvider.overrideWithValue(StorageInitializer.fileStorage),
      scopedStorageProvider.overrideWithValue(StorageInitializer.scopedStorage),

      // auth wiring
      auth.secureStorageProvider
          .overrideWithValue(StorageInitializer.secureStorage),
      auth.preferencesStorageProvider
          .overrideWithValue(StorageInitializer.preferencesStorage),
      if (_tokenManager != null)
        auth.tokenManagerProvider.overrideWithValue(_tokenManager!),
      if (_sessionManager != null)
        auth.sessionManagerProvider.overrideWithValue(_sessionManager!),
      if (_authService != null)
        auth.authServiceProvider.overrideWithValue(_authService!),
      if (_authController != null)
        auth.authControllerProvider.overrideWith((ref) {
          ref.onDispose(() => _authController?.dispose());
          return _authController!;
        }),
      // Use the configured auth options (overridable in app code)
      auth.authOptionsProvider.overrideWithValue(
        _options.auth.authOptions ?? const auth.AuthOptions(),
      ),

      // payments wiring (optional)
      if (_options.payments.paymentService != null)
        paymentServiceProvider
            .overrideWithValue(_options.payments.paymentService!),
    ];

    if (_grpcChannelFactory != null) {
      overrides.add(auth.grpcChannelFactoryProvider
          .overrideWithValue(_grpcChannelFactory!));
    }

    return overrides;
  }

  /// Access to the constructed gRPC factory (if created).
  static GrpcChannelFactory? get grpcChannelFactory => _grpcChannelFactory;

  /// Access to the initialized auth controller (if created).
  static auth.AuthController? get authController => _authController;

  /// Access to the active [AppConfig].
  static AppConfig get config {
    _ensureInitialized();
    return _config;
  }

  /// Convenience to build the default router wired to auth + routing defaults.
  static GoRouter router({
    required WidgetRef ref,
    required WidgetBuilder homeBuilder,
    WidgetBuilder? loginBuilder,
    WidgetBuilder? splashBuilder,
    WidgetBuilder? orgSelectionBuilder,
    WidgetBuilder? mfaBuilder,
    WidgetBuilder? forbiddenBuilder,
    BootstrapRoutingOptions? routingOptions,
  }) {
    _ensureInitialized();
    return FoundationBootstrapRouter.build(
      ref: ref,
      homeBuilder: homeBuilder,
      loginBuilder: loginBuilder,
      splashBuilder: splashBuilder,
      orgSelectionBuilder: orgSelectionBuilder,
      mfaBuilder: mfaBuilder,
      forbiddenBuilder: forbiddenBuilder,
      routingOptions: routingOptions ?? _options.routing,
    );
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'FoundationBootstrap.initialize() must be called before requesting overrides or router.',
      );
    }
  }
}
