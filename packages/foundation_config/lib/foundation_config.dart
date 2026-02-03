/// Environment and application configuration for Flutter Foundation packages.
///
/// This library provides:
///
/// - [Environment] - Environment enumeration (dev, staging, prod)
/// - [AppConfig] - Application configuration holder
/// - [FoundationConfig] - Main configuration initializer
/// - Riverpod providers for accessing configuration
library foundation_config;

export 'src/environment.dart';
export 'src/app_config.dart';
export 'src/foundation_config.dart';
export 'src/grpc_config.dart';
export 'src/rest_config.dart';
export 'src/feature_flags.dart';
export 'src/providers.dart';
