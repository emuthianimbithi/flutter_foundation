import 'sync_conflict.dart';

/// Strategy for resolving sync conflicts.
enum ConflictStrategy {
  /// Local changes always win.
  localWins,

  /// Server changes always win.
  serverWins,

  /// Most recent change wins (requires timestamps).
  newestWins,

  /// Merge non-conflicting fields, prompt for conflicts.
  merge,

  /// Always prompt user for manual resolution.
  manual,
}

/// Configuration for a conflict strategy.
class ConflictStrategyConfig {
  /// The default strategy to use.
  final ConflictStrategy defaultStrategy;

  /// Per-entity type strategies.
  final Map<String, ConflictStrategy> entityStrategies;

  /// Per-field strategies (entity_type.field_name).
  final Map<String, ConflictStrategy> fieldStrategies;

  /// Fields that should always use local value.
  final Set<String> localOnlyFields;

  /// Fields that should always use server value.
  final Set<String> serverOnlyFields;

  /// Whether to auto-resolve simple conflicts.
  final bool autoResolveSimple;

  /// Callback for manual resolution.
  final Future<ConflictResolution> Function(SyncConflict)? manualResolver;

  const ConflictStrategyConfig({
    this.defaultStrategy = ConflictStrategy.serverWins,
    this.entityStrategies = const {},
    this.fieldStrategies = const {},
    this.localOnlyFields = const {},
    this.serverOnlyFields = const {},
    this.autoResolveSimple = true,
    this.manualResolver,
  });

  /// Gets the strategy for an entity type.
  ConflictStrategy getStrategyForEntity(String entityType) {
    return entityStrategies[entityType] ?? defaultStrategy;
  }

  /// Gets the strategy for a specific field.
  ConflictStrategy getStrategyForField(String entityType, String field) {
    final key = '$entityType.$field';
    if (fieldStrategies.containsKey(key)) {
      return fieldStrategies[key]!;
    }
    if (fieldStrategies.containsKey(field)) {
      return fieldStrategies[field]!;
    }
    return getStrategyForEntity(entityType);
  }

  /// Whether a field should use local value.
  bool isLocalOnlyField(String field) => localOnlyFields.contains(field);

  /// Whether a field should use server value.
  bool isServerOnlyField(String field) => serverOnlyFields.contains(field);

  /// Creates a copy with modified settings.
  ConflictStrategyConfig copyWith({
    ConflictStrategy? defaultStrategy,
    Map<String, ConflictStrategy>? entityStrategies,
    Map<String, ConflictStrategy>? fieldStrategies,
    Set<String>? localOnlyFields,
    Set<String>? serverOnlyFields,
    bool? autoResolveSimple,
    Future<ConflictResolution> Function(SyncConflict)? manualResolver,
  }) =>
      ConflictStrategyConfig(
        defaultStrategy: defaultStrategy ?? this.defaultStrategy,
        entityStrategies: entityStrategies ?? this.entityStrategies,
        fieldStrategies: fieldStrategies ?? this.fieldStrategies,
        localOnlyFields: localOnlyFields ?? this.localOnlyFields,
        serverOnlyFields: serverOnlyFields ?? this.serverOnlyFields,
        autoResolveSimple: autoResolveSimple ?? this.autoResolveSimple,
        manualResolver: manualResolver ?? this.manualResolver,
      );
}
