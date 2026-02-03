import 'dart:async';

import 'package:foundation_core/foundation_core.dart';

import '../change/change_tracker.dart';
import '../conflict/conflict_resolver.dart';
import '../conflict/sync_conflict.dart';
import '../connectivity/connectivity_monitor.dart';
import '../queue/sync_operation.dart';
import '../queue/sync_queue.dart';
import 'sync_config.dart';
import 'sync_status.dart';

/// Callback for executing a sync operation on the server.
typedef SyncExecutor = Future<SyncExecutionResult> Function(
    SyncOperation operation);

/// Result of executing a sync operation.
class SyncExecutionResult {
  final bool success;
  final Map<String, dynamic>? serverData;
  final int? serverVersion;
  final String? errorMessage;
  final bool isConflict;

  const SyncExecutionResult({
    required this.success,
    this.serverData,
    this.serverVersion,
    this.errorMessage,
    this.isConflict = false,
  });

  factory SyncExecutionResult.success({
    Map<String, dynamic>? serverData,
    int? serverVersion,
  }) =>
      SyncExecutionResult(
        success: true,
        serverData: serverData,
        serverVersion: serverVersion,
      );

  factory SyncExecutionResult.failure(String error) =>
      SyncExecutionResult(success: false, errorMessage: error);

  factory SyncExecutionResult.conflict({
    required Map<String, dynamic> serverData,
    required int serverVersion,
  }) =>
      SyncExecutionResult(
        success: false,
        isConflict: true,
        serverData: serverData,
        serverVersion: serverVersion,
      );
}

/// Orchestrates offline-first data synchronization.
///
/// Example:
/// ```dart
/// final engine = SyncEngine(
///   queue: syncQueue,
///   changeTracker: changeTracker,
///   conflictResolver: conflictResolver,
///   connectivityMonitor: connectivityMonitor,
///   config: SyncConfig.defaults(),
/// );
///
/// // Register executor for entity types
/// engine.registerExecutor('task', (operation) async {
///   return switch (operation.operation) {
///     SyncOperationType.create => await taskApi.create(operation.payload),
///     SyncOperationType.update => await taskApi.update(operation.entityId, operation.payload),
///     SyncOperationType.delete => await taskApi.delete(operation.entityId),
///     _ => SyncExecutionResult.failure('Unknown operation'),
///   };
/// });
///
/// // Start sync
/// await engine.sync();
///
/// // Listen to status changes
/// engine.statusStream.listen((status) {
///   print('Sync status: ${status.state}');
/// });
/// ```
class SyncEngine {
  final SyncQueue _queue;
  final ChangeTracker _changeTracker;
  final ConflictResolver _conflictResolver;
  final ConnectivityMonitor _connectivityMonitor;
  final SyncConfig _config;
  final AppLogger _log = AppLogger('SyncEngine');

  final Map<String, SyncExecutor> _executors = {};
  final List<SyncConflict> _unresolvedConflicts = [];

  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = SyncStatus.initial();

  Timer? _autoSyncTimer;
  bool _isSyncing = false;

  SyncEngine({
    required SyncQueue queue,
    required ChangeTracker changeTracker,
    required ConflictResolver conflictResolver,
    required ConnectivityMonitor connectivityMonitor,
    SyncConfig config = const SyncConfig(),
  })  : _queue = queue,
        _changeTracker = changeTracker,
        _conflictResolver = conflictResolver,
        _connectivityMonitor = connectivityMonitor,
        _config = config {
    // Listen to connectivity changes
    _connectivityMonitor.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  /// The current sync status.
  SyncStatus get status => _status;

  /// Stream of sync status changes.
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Unresolved conflicts that need manual resolution.
  List<SyncConflict> get unresolvedConflicts =>
      List.unmodifiable(_unresolvedConflicts);

  /// Whether sync is currently in progress.
  bool get isSyncing => _isSyncing;

  /// Registers an executor for an entity type.
  void registerExecutor(String entityType, SyncExecutor executor) {
    _executors[entityType] = executor;
    _log.debug('Registered executor for: $entityType');
  }

  /// Starts automatic syncing.
  void startAutoSync() {
    if (_config.autoSyncInterval == null) return;

    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(_config.autoSyncInterval!, (_) {
      sync();
    });
    _log.info('Auto-sync started with interval: ${_config.autoSyncInterval}');
  }

  /// Stops automatic syncing.
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    _log.info('Auto-sync stopped');
  }

  /// Performs a sync operation.
  Future<SyncStatus> sync() async {
    if (_isSyncing) {
      _log.debug('Sync already in progress');
      return _status;
    }

    if (!_connectivityMonitor.isConnected) {
      _log.debug('No connectivity, skipping sync');
      _updateStatus(_status.copyWith(state: SyncState.paused, isOffline: true));
      return _status;
    }

    if (_config.syncOnWifiOnly && !_connectivityMonitor.isWifi) {
      _log.debug('WiFi only mode, skipping sync');
      _updateStatus(_status.copyWith(state: SyncState.paused));
      return _status;
    }

    _isSyncing = true;
    _updateStatus(_status.copyWith(
      state: SyncState.syncing,
      progress: 0.0,
      isOffline: false,
    ));

    try {
      final pending = await _queue.getPending(limit: _config.batchSize);
      final total = pending.length;
      var synced = 0;
      var failed = 0;

      _log.info('Starting sync with $total pending operations');

      for (final operation in pending) {
        if (!_connectivityMonitor.isConnected) {
          _log.warning('Lost connectivity during sync');
          _updateStatus(
              _status.copyWith(state: SyncState.paused, isOffline: true));
          break;
        }

        final result = await _processOperation(operation);

        if (result) {
          synced++;
        } else {
          failed++;
        }

        _updateStatus(_status.copyWith(
          progress: (synced + failed) / total,
          syncedCount: synced,
          failedCount: failed,
          currentEntityType: operation.entityType,
        ));
      }

      // Update pending count
      final remainingCount = await _queue.getPendingCount();

      _updateStatus(_status.copyWith(
        state: failed > 0 ? SyncState.failed : SyncState.completed,
        pendingCount: remainingCount,
        syncedCount: synced,
        failedCount: failed,
        conflictCount: _unresolvedConflicts.length,
        lastSyncAt: DateTime.now(),
        progress: 1.0,
        currentEntityType: null,
      ));

      _log.info(
          'Sync completed: $synced synced, $failed failed, $remainingCount remaining');
    } catch (e, s) {
      _log.error('Sync error', e, s);
      _updateStatus(_status.copyWith(
        state: SyncState.failed,
        lastError: e.toString(),
      ));
    } finally {
      _isSyncing = false;
    }

    return _status;
  }

  /// Processes a single sync operation.
  Future<bool> _processOperation(SyncOperation operation) async {
    final executor = _executors[operation.entityType];
    if (executor == null) {
      _log.warning('No executor for entity type: ${operation.entityType}');
      return false;
    }

    try {
      final result =
          await executor(operation).timeout(_config.operationTimeout);

      if (result.success) {
        await _queue.remove(operation.id!);
        _changeTracker.clearChanges(operation.entityType, operation.entityId);
        _log.debug(
            'Operation succeeded: ${operation.entityType}:${operation.entityId}');
        return true;
      }

      if (result.isConflict) {
        await _handleConflict(operation, result);
        return false;
      }

      // Handle failure with retry
      if (operation.hasExceededRetries(_config.maxRetries)) {
        _log.warning(
            'Operation exceeded max retries: ${operation.entityType}:${operation.entityId}');
        return false;
      }

      await _queue.updateRetry(
        operation.id!,
        operation.retryCount + 1,
        result.errorMessage,
      );

      _log.debug(
          'Operation failed, will retry: ${operation.entityType}:${operation.entityId}');
      return false;
    } on TimeoutException {
      _log.warning(
          'Operation timed out: ${operation.entityType}:${operation.entityId}');
      await _queue.updateRetry(
          operation.id!, operation.retryCount + 1, 'Timeout');
      return false;
    } catch (e, s) {
      _log.error(
          'Operation error: ${operation.entityType}:${operation.entityId}',
          e,
          s);
      await _queue.updateRetry(
          operation.id!, operation.retryCount + 1, e.toString());
      return false;
    }
  }

  /// Handles a conflict.
  Future<void> _handleConflict(
      SyncOperation operation, SyncExecutionResult result) async {
    _log.warning(
        'Conflict detected: ${operation.entityType}:${operation.entityId}');

    final conflict = SyncConflict(
      entityType: operation.entityType,
      entityId: operation.entityId,
      localVersion: 0, // TODO: Get from sync metadata
      serverVersion: result.serverVersion ?? 0,
      localData: operation.payload,
      serverData: result.serverData ?? {},
      operation: operation,
      detectedAt: DateTime.now(),
    );

    if (_conflictResolver.canAutoResolve(conflict)) {
      final resolution = await _conflictResolver.resolve(conflict);
      _log.info('Auto-resolved conflict: ${resolution.type}');

      // Re-queue with resolved data
      await _queue.remove(operation.id!);
      await _queue.enqueue(SyncOperation.update(
        entityType: operation.entityType,
        entityId: operation.entityId,
        payload: resolution.resolvedData,
        organizationId: operation.organizationId,
      ));
    } else {
      _log.info('Conflict requires manual resolution');
      _unresolvedConflicts.add(conflict);
    }
  }

  /// Resolves a conflict manually.
  Future<void> resolveConflict(
      SyncConflict conflict, Map<String, dynamic> resolvedData) async {
    _log.info(
        'Manually resolving conflict: ${conflict.entityType}:${conflict.entityId}');

    _unresolvedConflicts.remove(conflict);

    // Queue the resolved data
    await _queue.enqueue(SyncOperation.update(
      entityType: conflict.entityType,
      entityId: conflict.entityId,
      payload: resolvedData,
      organizationId: conflict.operation.organizationId,
    ));

    _updateStatus(_status.copyWith(conflictCount: _unresolvedConflicts.length));
  }

  void _onConnectivityChanged(bool isConnected) {
    _log.debug('Connectivity changed: $isConnected');

    if (isConnected && _status.isOffline) {
      _updateStatus(_status.copyWith(isOffline: false));
      // Trigger sync when connectivity is restored
      sync();
    } else if (!isConnected) {
      _updateStatus(_status.copyWith(isOffline: true, state: SyncState.paused));
    }
  }

  void _updateStatus(SyncStatus status) {
    _status = status;
    _statusController.add(status);
  }

  /// Disposes the sync engine.
  void dispose() {
    stopAutoSync();
    _statusController.close();
  }
}
