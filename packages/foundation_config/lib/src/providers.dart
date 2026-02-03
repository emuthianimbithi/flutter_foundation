import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';
import 'environment.dart';
import 'feature_flags.dart';
import 'foundation_config.dart';
import 'grpc_config.dart';
import 'rest_config.dart';

/// Provider for the app configuration.
final appConfigProvider = Provider<AppConfig>((ref) {
  return FoundationConfig.config;
});

/// Provider for the current environment.
final environmentProvider = Provider<Environment>((ref) {
  return ref.watch(appConfigProvider).environment;
});

/// Provider for whether the app is in debug mode.
final isDebugProvider = Provider<bool>((ref) {
  return ref.watch(environmentProvider).isDebug;
});

/// Provider for the gRPC configuration.
final grpcConfigProvider = Provider<GrpcConfig?>((ref) {
  return ref.watch(appConfigProvider).grpcConfig;
});

/// Provider for the REST configuration.
final restConfigProvider = Provider<RestConfig?>((ref) {
  return ref.watch(appConfigProvider).restConfig;
});

/// Provider for feature flags.
final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  return ref.watch(appConfigProvider).featureFlags;
});

/// Provider for checking if a feature is enabled.
final featureEnabledProvider = Provider.family<bool, String>((ref, key) {
  return ref.watch(featureFlagsProvider).isEnabled(key);
});

/// Provider for getting a feature flag value.
final featureFlagProvider = Provider.family<dynamic, String>((ref, key) {
  return ref.watch(featureFlagsProvider).get(key);
});

/// Provider for the app ID.
final appIdProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).appId;
});

/// Provider for the app version.
final appVersionProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).fullVersion;
});

/// Provider for whether offline mode is enabled.
final offlineModeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appConfigProvider).enableOfflineMode;
});

/// Provider for whether analytics is enabled.
final analyticsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appConfigProvider).enableAnalytics;
});

/// Provider for whether crash reporting is enabled.
final crashReportingEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appConfigProvider).enableCrashReporting;
});

/// Notifier for mutable feature flags.
///
/// This allows updating feature flags at runtime (e.g., from remote config).
class FeatureFlagsNotifier extends StateNotifier<FeatureFlags> {
  FeatureFlagsNotifier(super.initialFlags);

  /// Sets a feature flag.
  void setFlag(String key, dynamic value) {
    state = state.withOverride(key, value);
  }

  /// Sets multiple feature flags.
  void setFlags(Map<String, dynamic> flags) {
    state = state.withOverrides(flags);
  }

  /// Clears all overrides.
  void clearOverrides() {
    state = state.clearOverrides();
  }

  /// Replaces all flags.
  void replaceFlags(FeatureFlags flags) {
    state = flags;
  }
}

/// Provider for mutable feature flags.
final mutableFeatureFlagsProvider =
    StateNotifierProvider<FeatureFlagsNotifier, FeatureFlags>((ref) {
  return FeatureFlagsNotifier(FoundationConfig.config.featureFlags);
});
