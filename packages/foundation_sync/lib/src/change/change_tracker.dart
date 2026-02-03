import 'package:foundation_core/foundation_core.dart';

import 'tracked_change.dart';

/// Tracks local changes to entities for sync.
///
/// Example:
/// ```dart
/// final tracker = ChangeTracker();
///
/// // Track a change
/// tracker.track(TrackedChange.update(
///   entityType: 'task',
///   entityId: 'task-123',
///   field: 'title',
///   oldValue: 'Old Title',
///   newValue: 'New Title',
/// ));
///
/// // Get changes for an entity
/// final changes = tracker.getChanges('task', 'task-123');
///
/// // Clear after sync
/// tracker.clearChanges('task', 'task-123');
/// ```
class ChangeTracker {
  final AppLogger _log = AppLogger('ChangeTracker');

  /// Map of entity key to changes
  final Map<String, List<TrackedChange>> _changes = {};

  /// Gets the key for an entity.
  String _key(String entityType, String entityId) => '$entityType:$entityId';

  /// Tracks a change.
  void track(TrackedChange change) {
    final key = _key(change.entityType, change.entityId);
    _changes.putIfAbsent(key, () => []).add(change);
    _log.debug('Tracked change: ${change.changeType.name} ${change.entityType}:${change.entityId}');
  }

  /// Tracks a field update.
  void trackUpdate({
    required String entityType,
    required String entityId,
    required String field,
    dynamic oldValue,
    dynamic newValue,
    String? organizationId,
  }) {
    track(TrackedChange.update(
      entityType: entityType,
      entityId: entityId,
      field: field,
      oldValue: oldValue,
      newValue: newValue,
      organizationId: organizationId,
    ));
  }

  /// Tracks a creation.
  void trackCreate({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    String? organizationId,
  }) {
    track(TrackedChange.create(
      entityType: entityType,
      entityId: entityId,
      data: data,
      organizationId: organizationId,
    ));
  }

  /// Tracks a deletion.
  void trackDelete({
    required String entityType,
    required String entityId,
    String? organizationId,
  }) {
    track(TrackedChange.delete(
      entityType: entityType,
      entityId: entityId,
      organizationId: organizationId,
    ));
  }

  /// Gets all changes for an entity.
  List<TrackedChange> getChanges(String entityType, String entityId) {
    final key = _key(entityType, entityId);
    return List.unmodifiable(_changes[key] ?? []);
  }

  /// Gets all changes.
  List<TrackedChange> getAllChanges() {
    return _changes.values.expand((list) => list).toList();
  }

  /// Gets changes by entity type.
  List<TrackedChange> getChangesByType(String entityType) {
    return getAllChanges().where((c) => c.entityType == entityType).toList();
  }

  /// Gets changes by organization.
  List<TrackedChange> getChangesByOrganization(String organizationId) {
    return getAllChanges().where((c) => c.organizationId == organizationId).toList();
  }

  /// Whether there are changes for an entity.
  bool hasChanges(String entityType, String entityId) {
    final key = _key(entityType, entityId);
    return _changes.containsKey(key) && _changes[key]!.isNotEmpty;
  }

  /// Whether there are any changes.
  bool get hasAnyChanges => _changes.values.any((list) => list.isNotEmpty);

  /// Gets the total number of changes.
  int get changeCount => _changes.values.fold(0, (sum, list) => sum + list.length);

  /// Clears changes for an entity.
  void clearChanges(String entityType, String entityId) {
    final key = _key(entityType, entityId);
    _changes.remove(key);
    _log.debug('Cleared changes for $entityType:$entityId');
  }

  /// Clears changes for an organization.
  void clearChangesForOrganization(String organizationId) {
    _changes.removeWhere((key, changes) {
      return changes.any((c) => c.organizationId == organizationId);
    });
    _log.debug('Cleared changes for organization: $organizationId');
  }

  /// Clears all changes.
  void clearAll() {
    _changes.clear();
    _log.debug('Cleared all tracked changes');
  }

  /// Consolidates changes for an entity.
  ///
  /// Multiple updates to the same field are consolidated into one.
  Map<String, dynamic> getConsolidatedChanges(String entityType, String entityId) {
    final changes = getChanges(entityType, entityId);
    final consolidated = <String, dynamic>{};

    for (final change in changes) {
      if (change.changeType == ChangeType.update && change.field != null) {
        consolidated[change.field!] = change.newValue;
      } else if (change.changeType == ChangeType.create && change.data != null) {
        consolidated.addAll(change.data!);
      }
    }

    return consolidated;
  }

  /// Gets the original values before changes.
  Map<String, dynamic> getOriginalValues(String entityType, String entityId) {
    final changes = getChanges(entityType, entityId);
    final original = <String, dynamic>{};

    for (final change in changes) {
      if (change.changeType == ChangeType.update &&
          change.field != null &&
          !original.containsKey(change.field)) {
        original[change.field!] = change.oldValue;
      }
    }

    return original;
  }

  /// Reverts all changes for an entity and returns the original values.
  Map<String, dynamic> revert(String entityType, String entityId) {
    final original = getOriginalValues(entityType, entityId);
    clearChanges(entityType, entityId);
    _log.debug('Reverted changes for $entityType:$entityId');
    return original;
  }
}
