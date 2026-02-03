import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:foundation_storage/foundation_storage.dart';

import 'sync_operation.dart';

/// Queue for managing pending sync operations.
///
/// Operations are persisted to the database and processed in order.
///
/// Example:
/// ```dart
/// final queue = SyncQueue(database);
///
/// // Add an operation
/// await queue.enqueue(SyncOperation.create(
///   entityType: 'task',
///   entityId: 'task-123',
///   payload: {'title': 'New Task'},
/// ));
///
/// // Get pending operations
/// final pending = await queue.getPending();
///
/// // Remove after successful sync
/// await queue.remove(operation.id);
/// ```
class SyncQueue {
  final AppDatabase _database;
  final AppLogger _log = AppLogger('SyncQueue');

  SyncQueue(this._database);

  /// Adds an operation to the queue.
  Future<int> enqueue(SyncOperation operation) async {
    _log.debug(
        'Enqueuing: ${operation.operation.name} ${operation.entityType}:${operation.entityId}');

    final id = await _database.addToSyncQueue(
      SyncQueueCompanion(
        entityType: Value(operation.entityType),
        entityId: Value(operation.entityId),
        operation: Value(operation.operation.name),
        payload: Value(jsonEncode(operation.payload)),
        createdAt: Value(operation.createdAt),
        retryCount: Value(operation.retryCount),
        lastError: Value(operation.lastError),
        priority: Value(operation.priority),
        organizationId: Value(operation.organizationId),
      ),
    );

    _log.debug('Enqueued operation with id: $id');
    return id;
  }

  /// Gets all pending operations, ordered by priority and creation time.
  Future<List<SyncOperation>> getPending({int? limit}) async {
    final rows = await _database.getPendingOperations(limit: limit);
    return rows.map(_rowToOperation).toList();
  }

  /// Gets operations for a specific entity.
  Future<List<SyncOperation>> getForEntity(
      String entityType, String entityId) async {
    final rows = await _database.getOperationsForEntity(entityType, entityId);
    return rows.map(_rowToOperation).toList();
  }

  /// Gets the count of pending operations.
  Future<int> getPendingCount() async {
    final pending = await getPending();
    return pending.length;
  }

  /// Removes an operation from the queue.
  Future<void> remove(int id) async {
    await _database.removeFromSyncQueue(id);
    _log.debug('Removed operation: $id');
  }

  /// Updates an operation's retry count and error.
  Future<void> updateRetry(int id, int retryCount, String? error) async {
    await _database.updateSyncQueueRetry(id, retryCount, error);
    _log.debug('Updated retry for operation $id: attempt $retryCount');
  }

  /// Clears all operations for an organization.
  Future<void> clearForOrganization(String organizationId) async {
    await _database.clearSyncQueueForOrg(organizationId);
    _log.info('Cleared queue for organization: $organizationId');
  }

  /// Clears all operations.
  Future<void> clearAll() async {
    await _database.delete(_database.syncQueue).go();
    _log.info('Cleared entire sync queue');
  }

  /// Checks if there are any pending operations.
  Future<bool> hasPending() async {
    final count = await getPendingCount();
    return count > 0;
  }

  /// Checks if there are operations for a specific entity.
  Future<bool> hasOperationsFor(String entityType, String entityId) async {
    final ops = await getForEntity(entityType, entityId);
    return ops.isNotEmpty;
  }

  /// Consolidates operations for the same entity.
  ///
  /// For example, if there's a create followed by multiple updates,
  /// this can consolidate them into a single create with the latest data.
  Future<void> consolidate(String entityType, String entityId) async {
    final operations = await getForEntity(entityType, entityId);
    if (operations.length <= 1) return;

    _log.debug(
        'Consolidating ${operations.length} operations for $entityType:$entityId');

    // Sort by creation time
    operations.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final first = operations.first;
    final last = operations.last;

    // If last is delete, just keep the delete
    if (last.operation == SyncOperationType.delete) {
      for (final op in operations.where((o) => o.id != last.id)) {
        await remove(op.id!);
      }
      return;
    }

    // If first is create, consolidate all updates into the create
    if (first.operation == SyncOperationType.create) {
      final mergedPayload = <String, dynamic>{...first.payload};
      for (final op in operations.skip(1)) {
        if (op.operation == SyncOperationType.update) {
          mergedPayload.addAll(op.payload);
        }
      }

      // Remove all and re-add consolidated
      for (final op in operations) {
        await remove(op.id!);
      }

      await enqueue(SyncOperation.create(
        entityType: entityType,
        entityId: entityId,
        payload: mergedPayload,
        organizationId: first.organizationId,
        priority: first.priority,
      ));
      return;
    }

    // Otherwise, merge all updates
    final mergedPayload = <String, dynamic>{};
    for (final op in operations) {
      if (op.operation == SyncOperationType.update) {
        mergedPayload.addAll(op.payload);
      }
    }

    // Remove all and re-add consolidated
    for (final op in operations) {
      await remove(op.id!);
    }

    await enqueue(SyncOperation.update(
      entityType: entityType,
      entityId: entityId,
      payload: mergedPayload,
      organizationId: first.organizationId,
      priority: first.priority,
    ));
  }

  SyncOperation _rowToOperation(SyncQueueData row) {
    return SyncOperation(
      id: row.id,
      entityType: row.entityType,
      entityId: row.entityId,
      operation: SyncOperationType.values.firstWhere(
        (e) => e.name == row.operation,
        orElse: () => SyncOperationType.custom,
      ),
      payload: jsonDecode(row.payload) as Map<String, dynamic>,
      createdAt: row.createdAt,
      retryCount: row.retryCount,
      lastError: row.lastError,
      priority: row.priority,
      organizationId: row.organizationId,
    );
  }
}
