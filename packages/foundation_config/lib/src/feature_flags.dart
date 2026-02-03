import 'package:equatable/equatable.dart';

/// Feature flags configuration.
///
/// Feature flags can be used to enable/disable features at runtime.
/// They can be initialized from various sources:
/// - Default values
/// - Remote config (Firebase, custom backend)
/// - Local overrides (for testing)
///
/// Example:
/// ```dart
/// final flags = FeatureFlags({
///   'dark_mode': true,
///   'new_checkout': false,
///   'max_items': 100,
/// });
///
/// if (flags.isEnabled('dark_mode')) {
///   // Enable dark mode
/// }
/// ```
class FeatureFlags extends Equatable {
  final Map<String, dynamic> _flags;
  final Map<String, dynamic> _overrides;

  /// Creates feature flags with the given initial values.
  const FeatureFlags([
    Map<String, dynamic> flags = const {},
    Map<String, dynamic> overrides = const {},
  ])  : _flags = flags,
        _overrides = overrides;

  /// Creates empty feature flags.
  factory FeatureFlags.empty() => const FeatureFlags();

  /// Gets a flag value.
  T? get<T>(String key) {
    if (_overrides.containsKey(key)) {
      return _overrides[key] as T?;
    }
    return _flags[key] as T?;
  }

  /// Gets a flag value with a default.
  T getOr<T>(String key, T defaultValue) => get<T>(key) ?? defaultValue;

  /// Whether a boolean flag is enabled.
  bool isEnabled(String key) => getOr<bool>(key, false);

  /// Whether a boolean flag is disabled.
  bool isDisabled(String key) => !isEnabled(key);

  /// Gets a string flag value.
  String? getString(String key) => get<String>(key);

  /// Gets an int flag value.
  int? getInt(String key) => get<int>(key);

  /// Gets a double flag value.
  double? getDouble(String key) => get<double>(key);

  /// Gets a list flag value.
  List<T>? getList<T>(String key) => get<List<dynamic>>(key)?.cast<T>();

  /// Gets a map flag value.
  Map<String, dynamic>? getMap(String key) => get<Map<String, dynamic>>(key);

  /// Whether a flag exists.
  bool hasFlag(String key) =>
      _overrides.containsKey(key) || _flags.containsKey(key);

  /// All flag keys.
  Set<String> get keys => {..._flags.keys, ..._overrides.keys};

  /// Creates a copy with additional flags.
  FeatureFlags withFlags(Map<String, dynamic> flags) =>
      FeatureFlags({..._flags, ...flags}, _overrides);

  /// Creates a copy with local overrides.
  FeatureFlags withOverrides(Map<String, dynamic> overrides) =>
      FeatureFlags(_flags, {..._overrides, ...overrides});

  /// Creates a copy with a single override.
  FeatureFlags withOverride(String key, dynamic value) =>
      FeatureFlags(_flags, {..._overrides, key: value});

  /// Creates a copy without overrides.
  FeatureFlags clearOverrides() => FeatureFlags(_flags);

  /// Exports all flags as a map.
  Map<String, dynamic> toMap() => {..._flags, ..._overrides};

  @override
  List<Object?> get props => [_flags, _overrides];

  @override
  String toString() =>
      'FeatureFlags(${_flags.length} flags, ${_overrides.length} overrides)';
}

/// Predefined feature flag keys.
abstract class FeatureFlagKeys {
  // ─────────────────────────────────────────────────────────────
  // CORE FEATURES
  // ─────────────────────────────────────────────────────────────

  /// Enable offline mode.
  static const offlineMode = 'offline_mode';

  /// Enable analytics.
  static const analytics = 'analytics';

  /// Enable crash reporting.
  static const crashReporting = 'crash_reporting';

  /// Enable debug mode.
  static const debugMode = 'debug_mode';

  /// Enable logging.
  static const logging = 'logging';

  // ─────────────────────────────────────────────────────────────
  // AUTH FEATURES
  // ─────────────────────────────────────────────────────────────

  /// Enable biometric authentication.
  static const biometricAuth = 'biometric_auth';

  /// Enable social login.
  static const socialLogin = 'social_login';

  /// Enable MFA.
  static const mfa = 'mfa';

  // ─────────────────────────────────────────────────────────────
  // UI FEATURES
  // ─────────────────────────────────────────────────────────────

  /// Enable dark mode.
  static const darkMode = 'dark_mode';

  /// Enable haptic feedback.
  static const hapticFeedback = 'haptic_feedback';

  /// Enable animations.
  static const animations = 'animations';

  // ─────────────────────────────────────────────────────────────
  // EXPERIMENTAL FEATURES
  // ─────────────────────────────────────────────────────────────

  /// Enable experimental features.
  static const experimental = 'experimental';
}
