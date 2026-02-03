import 'package:foundation_core/foundation_core.dart';

import 'conflict_strategy.dart';
import 'sync_conflict.dart';

/// Resolves sync conflicts based on configured strategies.
class ConflictResolver {
  final ConflictStrategyConfig _config;
  final AppLogger _log = AppLogger('ConflictResolver');

  ConflictResolver(this._config);

  /// Resolves a conflict using the configured strategy.
  Future<ConflictResolution> resolve(SyncConflict conflict) async {
    final strategy = _config.getStrategyForEntity(conflict.entityType);

    _log.debug(
      'Resolving conflict for ${conflict.entityType}:${conflict.entityId} '
      'using strategy: ${strategy.name}',
    );

    return switch (strategy) {
      ConflictStrategy.localWins => _resolveLocalWins(conflict),
      ConflictStrategy.serverWins => _resolveServerWins(conflict),
      ConflictStrategy.newestWins => _resolveNewestWins(conflict),
      ConflictStrategy.merge => _resolveMerge(conflict),
      ConflictStrategy.manual => _resolveManual(conflict),
    };
  }

  /// Resolves with local data winning.
  ConflictResolution _resolveLocalWins(SyncConflict conflict) {
    _log.debug('Resolving with local wins');
    return ConflictResolution(
      type: ConflictResolutionType.localWins,
      resolvedData: Map.from(conflict.localData),
      resolvedAt: DateTime.now(),
    );
  }

  /// Resolves with server data winning.
  ConflictResolution _resolveServerWins(SyncConflict conflict) {
    _log.debug('Resolving with server wins');
    return ConflictResolution(
      type: ConflictResolutionType.serverWins,
      resolvedData: Map.from(conflict.serverData),
      resolvedAt: DateTime.now(),
    );
  }

  /// Resolves with newest data winning.
  ConflictResolution _resolveNewestWins(SyncConflict conflict) {
    // Check for timestamp fields
    final localUpdatedAt = _getTimestamp(conflict.localData);
    final serverUpdatedAt = _getTimestamp(conflict.serverData);

    if (localUpdatedAt == null || serverUpdatedAt == null) {
      _log.warning('No timestamp found, falling back to server wins');
      return _resolveServerWins(conflict);
    }

    if (localUpdatedAt.isAfter(serverUpdatedAt)) {
      _log.debug('Local is newer, using local data');
      return ConflictResolution(
        type: ConflictResolutionType.newestWins,
        resolvedData: Map.from(conflict.localData),
        resolvedAt: DateTime.now(),
      );
    } else {
      _log.debug('Server is newer, using server data');
      return ConflictResolution(
        type: ConflictResolutionType.newestWins,
        resolvedData: Map.from(conflict.serverData),
        resolvedAt: DateTime.now(),
      );
    }
  }

  /// Resolves by merging non-conflicting fields.
  Future<ConflictResolution> _resolveMerge(SyncConflict conflict) async {
    _log.debug('Attempting merge resolution');

    final merged = <String, dynamic>{...conflict.serverData};
    final unresolvedConflicts = <String, FieldConflict>{};

    for (final entry in conflict.conflictingFields.entries) {
      final field = entry.key;
      final fieldConflict = entry.value;

      // Check if field has a specific strategy
      final fieldStrategy = _config.getStrategyForField(conflict.entityType, field);

      if (_config.isLocalOnlyField(field)) {
        merged[field] = fieldConflict.localValue;
      } else if (_config.isServerOnlyField(field)) {
        merged[field] = fieldConflict.serverValue;
      } else if (fieldStrategy == ConflictStrategy.localWins) {
        merged[field] = fieldConflict.localValue;
      } else if (fieldStrategy == ConflictStrategy.serverWins) {
        merged[field] = fieldConflict.serverValue;
      } else if (fieldStrategy == ConflictStrategy.newestWins) {
        // For field-level newest wins, use overall timestamp
        final localUpdatedAt = _getTimestamp(conflict.localData);
        final serverUpdatedAt = _getTimestamp(conflict.serverData);
        if (localUpdatedAt != null &&
            serverUpdatedAt != null &&
            localUpdatedAt.isAfter(serverUpdatedAt)) {
          merged[field] = fieldConflict.localValue;
        } else {
          merged[field] = fieldConflict.serverValue;
        }
      } else {
        // Can't auto-resolve this field
        unresolvedConflicts[field] = fieldConflict;
      }
    }

    // If there are unresolved conflicts, need manual resolution
    if (unresolvedConflicts.isNotEmpty) {
      if (_config.manualResolver != null) {
        _log.debug('${unresolvedConflicts.length} fields need manual resolution');
        return _resolveManual(conflict);
      } else {
        // Fall back to server wins for unresolved
        _log.warning('No manual resolver, using server for unresolved fields');
        for (final field in unresolvedConflicts.keys) {
          merged[field] = conflict.serverData[field];
        }
      }
    }

    return ConflictResolution(
      type: ConflictResolutionType.merged,
      resolvedData: merged,
      resolvedAt: DateTime.now(),
    );
  }

  /// Resolves manually using the configured resolver.
  Future<ConflictResolution> _resolveManual(SyncConflict conflict) async {
    if (_config.manualResolver == null) {
      _log.warning('No manual resolver configured, falling back to server wins');
      return _resolveServerWins(conflict);
    }

    _log.debug('Delegating to manual resolver');
    return _config.manualResolver!(conflict);
  }

  /// Extracts timestamp from data.
  DateTime? _getTimestamp(Map<String, dynamic> data) {
    // Check common timestamp field names
    final timestampFields = ['updated_at', 'updatedAt', 'modified_at', 'modifiedAt', 'timestamp'];

    for (final field in timestampFields) {
      final value = data[field];
      if (value == null) continue;

      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }

  /// Checks if a conflict can be auto-resolved.
  bool canAutoResolve(SyncConflict conflict) {
    final strategy = _config.getStrategyForEntity(conflict.entityType);

    // These strategies can always auto-resolve
    if (strategy == ConflictStrategy.localWins ||
        strategy == ConflictStrategy.serverWins) {
      return true;
    }

    // Newest wins can auto-resolve if timestamps exist
    if (strategy == ConflictStrategy.newestWins) {
      return _getTimestamp(conflict.localData) != null &&
          _getTimestamp(conflict.serverData) != null;
    }

    // Merge can auto-resolve if simple or auto-resolve is enabled
    if (strategy == ConflictStrategy.merge) {
      if (_config.autoResolveSimple && conflict.isSimple) {
        return true;
      }
      // Check if all conflicting fields have specific strategies
      for (final field in conflict.conflictingFields.keys) {
        final fieldStrategy = _config.getStrategyForField(conflict.entityType, field);
        if (fieldStrategy == ConflictStrategy.manual) {
          return false;
        }
        if (!_config.isLocalOnlyField(field) && !_config.isServerOnlyField(field)) {
          if (fieldStrategy == ConflictStrategy.merge) {
            return false;
          }
        }
      }
      return true;
    }

    // Manual strategy cannot auto-resolve
    return false;
  }
}
