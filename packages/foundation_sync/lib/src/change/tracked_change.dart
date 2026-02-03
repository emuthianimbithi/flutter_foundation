import 'package:equatable/equatable.dart';

/// Types of tracked changes.
enum ChangeType {
  /// Entity was created.
  create,

  /// Entity was updated.
  update,

  /// Entity was deleted.
  delete,
}

/// Represents a tracked local change.
class TrackedChange extends Equatable {
  /// The entity type.
  final String entityType;

  /// The entity ID.
  final String entityId;

  /// The type of change.
  final ChangeType changeType;

  /// The field that changed (for updates).
  final String? field;

  /// The old value (for updates).
  final dynamic oldValue;

  /// The new value (for updates).
  final dynamic newValue;

  /// The full data (for creates).
  final Map<String, dynamic>? data;

  /// When the change occurred.
  final DateTime timestamp;

  /// The organization ID.
  final String? organizationId;

  const TrackedChange({
    required this.entityType,
    required this.entityId,
    required this.changeType,
    this.field,
    this.oldValue,
    this.newValue,
    this.data,
    required this.timestamp,
    this.organizationId,
  });

  /// Creates a create change.
  factory TrackedChange.create({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    String? organizationId,
  }) =>
      TrackedChange(
        entityType: entityType,
        entityId: entityId,
        changeType: ChangeType.create,
        data: data,
        timestamp: DateTime.now(),
        organizationId: organizationId,
      );

  /// Creates an update change.
  factory TrackedChange.update({
    required String entityType,
    required String entityId,
    required String field,
    dynamic oldValue,
    dynamic newValue,
    String? organizationId,
  }) =>
      TrackedChange(
        entityType: entityType,
        entityId: entityId,
        changeType: ChangeType.update,
        field: field,
        oldValue: oldValue,
        newValue: newValue,
        timestamp: DateTime.now(),
        organizationId: organizationId,
      );

  /// Creates a delete change.
  factory TrackedChange.delete({
    required String entityType,
    required String entityId,
    String? organizationId,
  }) =>
      TrackedChange(
        entityType: entityType,
        entityId: entityId,
        changeType: ChangeType.delete,
        timestamp: DateTime.now(),
        organizationId: organizationId,
      );

  @override
  List<Object?> get props => [
        entityType,
        entityId,
        changeType,
        field,
        oldValue,
        newValue,
        data,
        timestamp,
        organizationId,
      ];

  @override
  String toString() =>
      'TrackedChange(${changeType.name} $entityType:$entityId${field != null ? '.$field' : ''})';
}
