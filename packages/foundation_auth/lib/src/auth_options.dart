import 'package:meta/meta.dart';

/// Runtime options controlling auth behaviors.
@immutable
class AuthOptions {
  /// Whether automatic refresh should run when tokens are near expiry.
  final bool autoRefresh;

  /// How soon before expiry we should refresh proactively.
  final Duration refreshLeeway;

  /// Whether logout should clear persisted storage (tokens + prefs) by default.
  final bool logoutClearsStorage;

  /// Require users to pick an organization when multiple exist (else pick first).
  final bool requireOrgSelection;

  /// Whether to gate unlocked session behind biometrics/PIN (UI handled separately).
  final bool enableBiometricsLock;

  const AuthOptions({
    this.autoRefresh = true,
    this.refreshLeeway = const Duration(seconds: 30),
    this.logoutClearsStorage = true,
    this.requireOrgSelection = false,
    this.enableBiometricsLock = false,
  });

  AuthOptions copyWith({
    bool? autoRefresh,
    Duration? refreshLeeway,
    bool? logoutClearsStorage,
    bool? requireOrgSelection,
    bool? enableBiometricsLock,
  }) {
    return AuthOptions(
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshLeeway: refreshLeeway ?? this.refreshLeeway,
      logoutClearsStorage: logoutClearsStorage ?? this.logoutClearsStorage,
      requireOrgSelection: requireOrgSelection ?? this.requireOrgSelection,
      enableBiometricsLock: enableBiometricsLock ?? this.enableBiometricsLock,
    );
  }
}
