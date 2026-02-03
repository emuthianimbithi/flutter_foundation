import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_config.dart';
import 'environment.dart';
import 'feature_flags.dart';
import 'grpc_config.dart';
import 'rest_config.dart';

/// Main configuration initializer for Flutter Foundation.
///
/// Call [FoundationConfig.initialize] early in your app's startup
/// to configure all foundation packages.
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await FoundationConfig.initialize(
///     environment: Environment.production,
///     appId: 'your-app-id',
///     grpcHost: 'api.yourcompany.com',
///   );
///
///   runApp(MyApp());
/// }
/// ```
class FoundationConfig {
  FoundationConfig._();

  static AppConfig? _config;
  static PackageInfo? _packageInfo;
  static BaseDeviceInfo? _deviceInfo;
  static bool _initialized = false;

  /// Whether the configuration has been initialized.
  static bool get isInitialized => _initialized;

  /// The current app configuration.
  ///
  /// Throws if [initialize] has not been called.
  static AppConfig get config {
    if (_config == null) {
      throw StateError(
        'FoundationConfig has not been initialized. '
        'Call FoundationConfig.initialize() first.',
      );
    }
    return _config!;
  }

  /// The package info, if available.
  static PackageInfo? get packageInfo => _packageInfo;

  /// The device info, if available.
  static BaseDeviceInfo? get deviceInfo => _deviceInfo;

  /// The current environment.
  static Environment get environment => config.environment;

  /// Whether the app is in debug mode.
  static bool get isDebug => config.isDebug;

  /// Whether the app is in release mode.
  static bool get isRelease => config.isRelease;

  /// Initializes the foundation configuration.
  ///
  /// This should be called early in your app's startup, after
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  ///
  /// Parameters:
  /// - [environment] - The current environment
  /// - [appId] - Your application's ID (used for auth)
  /// - [grpcHost] - The gRPC server host
  /// - [grpcPort] - The gRPC server port (default: 443)
  /// - [grpcUseTls] - Whether to use TLS for gRPC (default: true)
  /// - [restBaseUrl] - Optional REST API base URL
  /// - [featureFlags] - Initial feature flags
  /// - [enableOfflineMode] - Enable offline support (default: true)
  /// - [enableAnalytics] - Enable analytics (default: true in production)
  /// - [enableCrashReporting] - Enable crash reporting (default: true in production)
  /// - [enableLogging] - Enable logging (default: true in debug)
  static Future<void> initialize({
    required Environment environment,
    required String appId,
    String? appName,
    String? grpcHost,
    int grpcPort = 443,
    bool grpcUseTls = true,
    String? restBaseUrl,
    FeatureFlags featureFlags = const FeatureFlags(),
    bool enableOfflineMode = true,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    bool? enableLogging,
    String? logLevel,
    Duration connectionTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Map<String, dynamic> metadata = const {},
  }) async {
    if (_initialized) {
      log.warning('FoundationConfig.initialize() called multiple times');
      return;
    }

    // Load package info
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      log.warning('Failed to load package info: $e');
    }

    // Load device info
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.android) {
        _deviceInfo = await deviceInfoPlugin.androidInfo;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        _deviceInfo = await deviceInfoPlugin.iosInfo;
      }
    } catch (e) {
      log.warning('Failed to load device info: $e');
    }

    // Build gRPC config
    GrpcConfig? grpcConfig;
    if (grpcHost != null) {
      grpcConfig = GrpcConfig(
        host: grpcHost,
        port: grpcPort,
        useTls: grpcUseTls,
        connectionTimeout: connectionTimeout,
      );
    }

    // Build REST config
    RestConfig? restConfig;
    if (restBaseUrl != null) {
      restConfig = RestConfig(
        baseUrl: restBaseUrl,
        connectionTimeout: connectionTimeout,
        receiveTimeout: receiveTimeout,
        enableLogging: enableLogging ?? environment.isDebug,
      );
    }

    // Determine defaults based on environment
    final effectiveEnableAnalytics =
        enableAnalytics ?? environment.isProduction;
    final effectiveEnableCrashReporting =
        enableCrashReporting ?? environment.isProduction;
    final effectiveEnableLogging = enableLogging ?? environment.isDebug;
    final effectiveLogLevel =
        logLevel ?? (environment.isDebug ? 'debug' : 'warning');

    // Create config
    _config = AppConfig(
      environment: environment,
      appId: appId,
      appName: appName ?? _packageInfo?.appName ?? '',
      appVersion: _packageInfo?.version ?? '0.0.0',
      buildNumber: _packageInfo?.buildNumber ?? '0',
      grpcConfig: grpcConfig,
      restConfig: restConfig,
      featureFlags: featureFlags,
      enableOfflineMode: enableOfflineMode,
      enableAnalytics: effectiveEnableAnalytics,
      enableCrashReporting: effectiveEnableCrashReporting,
      enableLogging: effectiveEnableLogging,
      logLevel: effectiveLogLevel,
      metadata: metadata,
    );

    // Initialize logger
    AppLogger.init(
      enabled: effectiveEnableLogging,
      minLevel: _parseLogLevel(effectiveLogLevel),
    );

    _initialized = true;

    log.info('FoundationConfig initialized');
    log.debug('Environment: $environment');
    log.debug('App: ${_config!.appName} v${_config!.fullVersion}');
    if (grpcConfig != null) {
      log.debug('gRPC: ${grpcConfig.url}');
    }
    if (restConfig != null) {
      log.debug('REST: ${restConfig.baseUrl}');
    }
  }

  /// Initializes with a pre-built [AppConfig].
  static Future<void> initializeWithConfig(AppConfig config) async {
    if (_initialized) {
      log.warning('FoundationConfig.initialize() called multiple times');
      return;
    }

    _config = config;

    // Load package info
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      log.warning('Failed to load package info: $e');
    }

    // Initialize logger
    AppLogger.init(
      enabled: config.enableLogging,
      minLevel: _parseLogLevel(config.logLevel),
    );

    _initialized = true;
    log.info('FoundationConfig initialized with custom config');
  }

  /// Updates the configuration.
  ///
  /// This can be used to update feature flags or other settings
  /// after initialization.
  static void update(AppConfig Function(AppConfig current) updater) {
    if (!_initialized) {
      throw StateError('FoundationConfig has not been initialized');
    }
    _config = updater(_config!);
    log.debug('FoundationConfig updated');
  }

  /// Updates feature flags.
  static void updateFeatureFlags(FeatureFlags flags) {
    update((c) => c.copyWith(featureFlags: flags));
  }

  /// Resets the configuration (mainly for testing).
  @visibleForTesting
  static void reset() {
    _config = null;
    _packageInfo = null;
    _deviceInfo = null;
    _initialized = false;
  }

  static LogLevel _parseLogLevel(String level) {
    return switch (level.toLowerCase()) {
      'trace' || 'verbose' => LogLevel.trace,
      'debug' => LogLevel.debug,
      'info' => LogLevel.info,
      'warning' || 'warn' => LogLevel.warning,
      'error' => LogLevel.error,
      'fatal' => LogLevel.fatal,
      _ => LogLevel.debug,
    };
  }
}
