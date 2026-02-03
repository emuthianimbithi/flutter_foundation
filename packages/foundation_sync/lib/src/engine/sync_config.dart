import '../conflict/conflict_strategy.dart';

/// Configuration for the sync engine.
class SyncConfig {
  /// Maximum number of retries for failed operations.
  final int maxRetries;

  /// Delay between retries (increases exponentially).
  final Duration retryDelay;

  /// Maximum retry delay.
  final Duration maxRetryDelay;

  /// Batch size for processing operations.
  final int batchSize;

  /// Interval for automatic sync.
  final Duration? autoSyncInterval;

  /// Whether to sync only on WiFi.
  final bool syncOnWifiOnly;

  /// Whether to sync in the background.
  final bool enableBackgroundSync;

  /// Conflict resolution configuration.
  final ConflictStrategyConfig conflictConfig;

  /// Entity types to sync (null = all).
  final Set<String>? entityTypes;

  /// Timeout for sync operations.
  final Duration operationTimeout;

  const SyncConfig({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(minutes: 5),
    this.batchSize = 10,
    this.autoSyncInterval,
    this.syncOnWifiOnly = false,
    this.enableBackgroundSync = false,
    this.conflictConfig = const ConflictStrategyConfig(),
    this.entityTypes,
    this.operationTimeout = const Duration(seconds: 30),
  });

  /// Default configuration.
  factory SyncConfig.defaults() => const SyncConfig();

  /// Configuration for aggressive syncing.
  factory SyncConfig.aggressive() => const SyncConfig(
        maxRetries: 5,
        retryDelay: Duration(milliseconds: 500),
        batchSize: 20,
        autoSyncInterval: Duration(seconds: 30),
      );

  /// Configuration for battery-saving mode.
  factory SyncConfig.batterySaver() => const SyncConfig(
        maxRetries: 2,
        retryDelay: Duration(seconds: 5),
        batchSize: 5,
        autoSyncInterval: Duration(minutes: 15),
        syncOnWifiOnly: true,
      );

  /// Calculates the delay for a retry attempt.
  Duration getRetryDelay(int attempt) {
    // Exponential backoff: delay * 2^attempt
    final delay = retryDelay * (1 << attempt);
    return delay > maxRetryDelay ? maxRetryDelay : delay;
  }

  /// Creates a copy with modified settings.
  SyncConfig copyWith({
    int? maxRetries,
    Duration? retryDelay,
    Duration? maxRetryDelay,
    int? batchSize,
    Duration? autoSyncInterval,
    bool? syncOnWifiOnly,
    bool? enableBackgroundSync,
    ConflictStrategyConfig? conflictConfig,
    Set<String>? entityTypes,
    Duration? operationTimeout,
  }) =>
      SyncConfig(
        maxRetries: maxRetries ?? this.maxRetries,
        retryDelay: retryDelay ?? this.retryDelay,
        maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
        batchSize: batchSize ?? this.batchSize,
        autoSyncInterval: autoSyncInterval ?? this.autoSyncInterval,
        syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
        enableBackgroundSync: enableBackgroundSync ?? this.enableBackgroundSync,
        conflictConfig: conflictConfig ?? this.conflictConfig,
        entityTypes: entityTypes ?? this.entityTypes,
        operationTimeout: operationTimeout ?? this.operationTimeout,
      );
}
