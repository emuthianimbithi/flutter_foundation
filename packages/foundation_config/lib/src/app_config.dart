import 'package:equatable/equatable.dart';

import 'environment.dart';
import 'feature_flags.dart';
import 'grpc_config.dart';
import 'rest_config.dart';

/// Application configuration.
///
/// This holds all configuration for the application, including:
/// - Environment
/// - App identification
/// - Network configuration (gRPC, REST)
/// - Feature flags
///
/// Example:
/// ```dart
/// final config = AppConfig(
///   environment: Environment.production,
///   appId: 'com.example.app',
///   appName: 'My App',
///   grpcConfig: GrpcConfig(host: 'api.example.com'),
/// );
/// ```
class AppConfig extends Equatable {
  // ─────────────────────────────────────────────────────────────
  // CORE
  // ─────────────────────────────────────────────────────────────

  /// The current environment.
  final Environment environment;

  /// The application ID (e.g., package name).
  final String appId;

  /// The application name.
  final String appName;

  /// The application version.
  final String appVersion;

  /// The build number.
  final String buildNumber;

  // ─────────────────────────────────────────────────────────────
  // NETWORK
  // ─────────────────────────────────────────────────────────────

  /// gRPC configuration.
  final GrpcConfig? grpcConfig;

  /// REST API configuration.
  final RestConfig? restConfig;

  // ─────────────────────────────────────────────────────────────
  // FEATURES
  // ─────────────────────────────────────────────────────────────

  /// Feature flags.
  final FeatureFlags featureFlags;

  // ─────────────────────────────────────────────────────────────
  // OPTIONS
  // ─────────────────────────────────────────────────────────────

  /// Whether to enable offline mode.
  final bool enableOfflineMode;

  /// Whether to enable analytics.
  final bool enableAnalytics;

  /// Whether to enable crash reporting.
  final bool enableCrashReporting;

  /// Whether to enable logging.
  final bool enableLogging;

  /// The minimum log level.
  final String logLevel;

  /// Custom metadata.
  final Map<String, dynamic> metadata;

  const AppConfig({
    required this.environment,
    required this.appId,
    this.appName = '',
    this.appVersion = '0.0.0',
    this.buildNumber = '0',
    this.grpcConfig,
    this.restConfig,
    this.featureFlags = const FeatureFlags(),
    this.enableOfflineMode = true,
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    this.enableLogging = true,
    this.logLevel = 'debug',
    this.metadata = const {},
  });

  /// Whether this is a debug build.
  bool get isDebug => environment.isDebug;

  /// Whether this is a release build.
  bool get isRelease => environment.isProduction;

  /// The full version string (version+build).
  String get fullVersion => '$appVersion+$buildNumber';

  /// Creates a copy with modified properties.
  AppConfig copyWith({
    Environment? environment,
    String? appId,
    String? appName,
    String? appVersion,
    String? buildNumber,
    GrpcConfig? grpcConfig,
    RestConfig? restConfig,
    FeatureFlags? featureFlags,
    bool? enableOfflineMode,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    bool? enableLogging,
    String? logLevel,
    Map<String, dynamic>? metadata,
  }) =>
      AppConfig(
        environment: environment ?? this.environment,
        appId: appId ?? this.appId,
        appName: appName ?? this.appName,
        appVersion: appVersion ?? this.appVersion,
        buildNumber: buildNumber ?? this.buildNumber,
        grpcConfig: grpcConfig ?? this.grpcConfig,
        restConfig: restConfig ?? this.restConfig,
        featureFlags: featureFlags ?? this.featureFlags,
        enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
        enableAnalytics: enableAnalytics ?? this.enableAnalytics,
        enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
        enableLogging: enableLogging ?? this.enableLogging,
        logLevel: logLevel ?? this.logLevel,
        metadata: metadata ?? this.metadata,
      );

  @override
  List<Object?> get props => [
        environment,
        appId,
        appName,
        appVersion,
        buildNumber,
        grpcConfig,
        restConfig,
        featureFlags,
        enableOfflineMode,
        enableAnalytics,
        enableCrashReporting,
        enableLogging,
        logLevel,
        metadata,
      ];

  @override
  String toString() => 'AppConfig($appId, $environment)';
}
