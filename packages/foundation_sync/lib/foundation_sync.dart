/// Offline-first sync engine with conflict resolution.
///
/// This library provides:
///
/// - [SyncEngine] - Orchestrates synchronization
/// - [SyncQueue] - Queue for pending operations
/// - [ConflictResolver] - Strategies for resolving conflicts
/// - [ChangeTracker] - Tracks local changes
library foundation_sync;

// Engine
export 'src/engine/sync_engine.dart';
export 'src/engine/sync_config.dart';
export 'src/engine/sync_status.dart';

// Queue
export 'src/queue/sync_queue.dart';
export 'src/queue/sync_operation.dart';

// Conflict resolution
export 'src/conflict/conflict_resolver.dart';
export 'src/conflict/conflict_strategy.dart';
export 'src/conflict/sync_conflict.dart';

// Change tracking
export 'src/change/change_tracker.dart';
export 'src/change/tracked_change.dart';

// Connectivity
export 'src/connectivity/connectivity_monitor.dart';

// Providers
export 'src/providers.dart';
