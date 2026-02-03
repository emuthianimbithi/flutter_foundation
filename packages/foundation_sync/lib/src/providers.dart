import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_storage/foundation_storage.dart';

import 'change/change_tracker.dart';
import 'conflict/conflict_resolver.dart';
import 'conflict/conflict_strategy.dart';
import 'connectivity/connectivity_monitor.dart';
import 'engine/sync_config.dart';
import 'engine/sync_engine.dart';
import 'engine/sync_status.dart';
import 'queue/sync_queue.dart';

/// Provider for the connectivity monitor.
final connectivityMonitorProvider = Provider<ConnectivityMonitor>((ref) {
  final monitor = ConnectivityMonitor();
  ref.onDispose(() => monitor.dispose());
  return monitor;
});

/// Provider for connectivity status.
final isConnectedProvider = StreamProvider<bool>((ref) {
  final monitor = ref.watch(connectivityMonitorProvider);
  return monitor.onConnectivityChanged;
});

/// Provider for the sync queue.
final syncQueueProvider = Provider<SyncQueue>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return SyncQueue(database);
});

/// Provider for the change tracker.
final changeTrackerProvider = Provider<ChangeTracker>((ref) {
  return ChangeTracker();
});

/// Provider for sync configuration.
final syncConfigProvider = Provider<SyncConfig>((ref) {
  return SyncConfig.defaults();
});

/// Provider for conflict strategy configuration.
final conflictStrategyConfigProvider = Provider<ConflictStrategyConfig>((ref) {
  return const ConflictStrategyConfig(
    defaultStrategy: ConflictStrategy.serverWins,
    autoResolveSimple: true,
  );
});

/// Provider for the conflict resolver.
final conflictResolverProvider = Provider<ConflictResolver>((ref) {
  final config = ref.watch(conflictStrategyConfigProvider);
  return ConflictResolver(config);
});

/// Provider for the sync engine.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final queue = ref.watch(syncQueueProvider);
  final changeTracker = ref.watch(changeTrackerProvider);
  final conflictResolver = ref.watch(conflictResolverProvider);
  final connectivityMonitor = ref.watch(connectivityMonitorProvider);
  final config = ref.watch(syncConfigProvider);

  final engine = SyncEngine(
    queue: queue,
    changeTracker: changeTracker,
    conflictResolver: conflictResolver,
    connectivityMonitor: connectivityMonitor,
    config: config,
  );

  ref.onDispose(() => engine.dispose());
  return engine;
});

/// Provider for sync status.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.statusStream;
});

/// Provider for current sync status (non-stream).
final currentSyncStatusProvider = Provider<SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.status;
});

/// Provider for pending sync count.
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final queue = ref.watch(syncQueueProvider);
  return queue.getPendingCount();
});

/// Provider for checking if there are pending syncs.
final hasPendingSyncsProvider = FutureProvider<bool>((ref) async {
  final queue = ref.watch(syncQueueProvider);
  return queue.hasPending();
});

/// Provider for whether sync is in progress.
final isSyncingProvider = Provider<bool>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.isSyncing;
});

/// Provider for unresolved conflicts.
final unresolvedConflictsProvider = Provider((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.unresolvedConflicts;
});

/// Provider for whether there are unresolved conflicts.
final hasConflictsProvider = Provider<bool>((ref) {
  final conflicts = ref.watch(unresolvedConflictsProvider);
  return conflicts.isNotEmpty;
});
