/// Application environment.
enum Environment {
  /// Development environment.
  development,

  /// Staging environment.
  staging,

  /// Production environment.
  production;

  /// Whether this is the development environment.
  bool get isDevelopment => this == Environment.development;

  /// Whether this is the staging environment.
  bool get isStaging => this == Environment.staging;

  /// Whether this is the production environment.
  bool get isProduction => this == Environment.production;

  /// Whether this is a debug environment (dev or staging).
  bool get isDebug => this != Environment.production;

  /// Creates an environment from a string.
  static Environment fromString(String value) {
    return switch (value.toLowerCase()) {
      'development' || 'dev' => Environment.development,
      'staging' || 'stg' => Environment.staging,
      'production' || 'prod' => Environment.production,
      _ => throw ArgumentError('Unknown environment: $value'),
    };
  }

  /// Creates an environment from a string, returning null if invalid.
  static Environment? tryFromString(String? value) {
    if (value == null) return null;
    try {
      return fromString(value);
    } catch (_) {
      return null;
    }
  }

  /// Returns the short name (dev, stg, prod).
  String get shortName => switch (this) {
        Environment.development => 'dev',
        Environment.staging => 'stg',
        Environment.production => 'prod',
      };

  @override
  String toString() => name;
}
