import 'package:equatable/equatable.dart';

import '../queue/sync_operation.dart';

/// Represents a sync conflict between local and server data.
class SyncConflict extends Equatable {
  /// The entity type.
  final String entityType;

  /// The entity ID.
  final String entityId;

  /// The local version.
  final int localVersion;

  /// The server version.
  final int serverVersion;

  /// The local data.
  final Map<String, dynamic> localData;

  /// The server data.
  final Map<String, dynamic> serverData;

  /// The operation that caused the conflict.
  final SyncOperation operation;

  /// When the conflict was detected.
  final DateTime detectedAt;

  /// Whether this conflict has been resolved.
  final bool resolved;

  /// How this conflict was resolved.
  final ConflictResolution? resolution;

  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localVersion,
    required this.serverVersion,
    required this.localData,
    required this.serverData,
    required this.operation,
    required this.detectedAt,
    this.resolved = false,
    this.resolution,
  });

  /// The fields that have conflicts.
  Map<String, FieldConflict> get conflictingFields {
    final conflicts = <String, FieldConflict>{};

    // Get all unique keys
    final allKeys = {...localData.keys, ...serverData.keys};

    for (final key in allKeys) {
      final localValue = localData[key];
      final serverValue = serverData[key];

      if (localValue != serverValue) {
        conflicts[key] = FieldConflict(
          field: key,
          localValue: localValue,
          serverValue: serverValue,
        );
      }
    }

    return conflicts;
  }

  /// Whether this is a simple conflict (can be auto-resolved).
  bool get isSimple => conflictingFields.length == 1;

  /// Whether this is a complex conflict (multiple fields).
  bool get isComplex => conflictingFields.length > 1;

  /// Creates a resolved conflict.
  SyncConflict withResolution(ConflictResolution resolution) => SyncConflict(
        entityType: entityType,
        entityId: entityId,
        localVersion: localVersion,
        serverVersion: serverVersion,
        localData: localData,
        serverData: serverData,
        operation: operation,
        detectedAt: detectedAt,
        resolved: true,
        resolution: resolution,
      );

  @override
  List<Object?> get props => [
        entityType,
        entityId,
        localVersion,
        serverVersion,
        localData,
        serverData,
        operation,
        detectedAt,
        resolved,
        resolution,
      ];

  @override
  String toString() =>
      'SyncConflict($entityType:$entityId, local: v$localVersion, server: v$serverVersion)';
}

/// Represents a conflict in a single field.
class FieldConflict extends Equatable {
  /// The field name.
  final String field;

  /// The local value.
  final dynamic localValue;

  /// The server value.
  final dynamic serverValue;

  const FieldConflict({
    required this.field,
    required this.localValue,
    required this.serverValue,
  });

  @override
  List<Object?> get props => [field, localValue, serverValue];

  @override
  String toString() => 'FieldConflict($field: local=$localValue, server=$serverValue)';
}

/// How a conflict was resolved.
class ConflictResolution extends Equatable {
  /// The resolution strategy used.
  final ConflictResolutionType type;

  /// The resolved data.
  final Map<String, dynamic> resolvedData;

  /// When the resolution was made.
  final DateTime resolvedAt;

  /// Who resolved it (for manual resolution).
  final String? resolvedBy;

  const ConflictResolution({
    required this.type,
    required this.resolvedData,
    required this.resolvedAt,
    this.resolvedBy,
  });

  @override
  List<Object?> get props => [type, resolvedData, resolvedAt, resolvedBy];
}

/// Types of conflict resolution.
enum ConflictResolutionType {
  /// Local data wins.
  localWins,

  /// Server data wins.
  serverWins,

  /// Data was merged.
  merged,

  /// User manually resolved.
  manual,

  /// Newest timestamp wins.
  newestWins,

  /// Custom resolution.
  custom,
}
