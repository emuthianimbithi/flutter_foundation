import 'package:equatable/equatable.dart';

/// Current status of the sync engine.
enum SyncState {
  /// Sync is idle, waiting for changes.
  idle,

  /// Sync is in progress.
  syncing,

  /// Sync completed successfully.
  completed,

  /// Sync failed.
  failed,

  /// Sync is paused (e.g., no connectivity).
  paused,

  /// Sync is disabled.
  disabled,
}

/// Detailed sync status.
class SyncStatus extends Equatable {
  /// The current state.
  final SyncState state;

  /// Number of pending operations.
  final int pendingCount;

  /// Number of operations synced in current/last run.
  final int syncedCount;

  /// Number of failed operations.
  final int failedCount;

  /// Number of conflicts.
  final int conflictCount;

  /// Last sync time.
  final DateTime? lastSyncAt;

  /// Last error message.
  final String? lastError;

  /// Progress (0.0 - 1.0) for current sync.
  final double progress;

  /// Currently syncing entity type.
  final String? currentEntityType;

  /// Whether sync is paused due to no connectivity.
  final bool isOffline;

  const SyncStatus({
    this.state = SyncState.idle,
    this.pendingCount = 0,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.conflictCount = 0,
    this.lastSyncAt,
    this.lastError,
    this.progress = 0.0,
    this.currentEntityType,
    this.isOffline = false,
  });

  /// Initial status.
  factory SyncStatus.initial() => const SyncStatus();

  /// Whether sync is currently active.
  bool get isSyncing => state == SyncState.syncing;

  /// Whether sync is idle.
  bool get isIdle => state == SyncState.idle;

  /// Whether there are pending operations.
  bool get hasPending => pendingCount > 0;

  /// Whether there are conflicts to resolve.
  bool get hasConflicts => conflictCount > 0;

  /// Whether the last sync failed.
  bool get hasFailed => state == SyncState.failed || failedCount > 0;

  /// Whether everything is synced.
  bool get isFullySynced =>
      pendingCount == 0 && conflictCount == 0 && failedCount == 0;

  /// Progress as a percentage string.
  String get progressPercent => '${(progress * 100).toInt()}%';

  /// Creates a copy with modified properties.
  SyncStatus copyWith({
    SyncState? state,
    int? pendingCount,
    int? syncedCount,
    int? failedCount,
    int? conflictCount,
    DateTime? lastSyncAt,
    String? lastError,
    double? progress,
    String? currentEntityType,
    bool? isOffline,
  }) =>
      SyncStatus(
        state: state ?? this.state,
        pendingCount: pendingCount ?? this.pendingCount,
        syncedCount: syncedCount ?? this.syncedCount,
        failedCount: failedCount ?? this.failedCount,
        conflictCount: conflictCount ?? this.conflictCount,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        lastError: lastError ?? this.lastError,
        progress: progress ?? this.progress,
        currentEntityType: currentEntityType ?? this.currentEntityType,
        isOffline: isOffline ?? this.isOffline,
      );

  @override
  List<Object?> get props => [
        state,
        pendingCount,
        syncedCount,
        failedCount,
        conflictCount,
        lastSyncAt,
        lastError,
        progress,
        currentEntityType,
        isOffline,
      ];

  @override
  String toString() =>
      'SyncStatus(${state.name}, pending: $pendingCount, synced: $syncedCount, failed: $failedCount)';
}
