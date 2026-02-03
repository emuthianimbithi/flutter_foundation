import 'package:equatable/equatable.dart';

/// Types of sync operations.
enum SyncOperationType {
  /// Create a new entity.
  create,

  /// Update an existing entity.
  update,

  /// Delete an entity.
  delete,

  /// Custom operation.
  custom,
}

/// Represents a pending sync operation.
class SyncOperation extends Equatable {
  /// Unique ID for this operation.
  final int? id;

  /// The entity type (e.g., 'user', 'task', 'document').
  final String entityType;

  /// The entity ID.
  final String entityId;

  /// The operation type.
  final SyncOperationType operation;

  /// The payload as JSON.
  final Map<String, dynamic> payload;

  /// When this operation was created.
  final DateTime createdAt;

  /// Number of retry attempts.
  final int retryCount;

  /// Last error message, if any.
  final String? lastError;

  /// Priority (lower = higher priority).
  final int priority;

  /// Organization ID for scoping.
  final String? organizationId;

  /// Custom operation name (for custom operations).
  final String? customOperation;

  const SyncOperation({
    this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
    this.priority = 0,
    this.organizationId,
    this.customOperation,
  });

  /// Creates a create operation.
  factory SyncOperation.create({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    String? organizationId,
    int priority = 0,
  }) =>
      SyncOperation(
        entityType: entityType,
        entityId: entityId,
        operation: SyncOperationType.create,
        payload: payload,
        createdAt: DateTime.now(),
        organizationId: organizationId,
        priority: priority,
      );

  /// Creates an update operation.
  factory SyncOperation.update({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    String? organizationId,
    int priority = 0,
  }) =>
      SyncOperation(
        entityType: entityType,
        entityId: entityId,
        operation: SyncOperationType.update,
        payload: payload,
        createdAt: DateTime.now(),
        organizationId: organizationId,
        priority: priority,
      );

  /// Creates a delete operation.
  factory SyncOperation.delete({
    required String entityType,
    required String entityId,
    String? organizationId,
    int priority = 0,
  }) =>
      SyncOperation(
        entityType: entityType,
        entityId: entityId,
        operation: SyncOperationType.delete,
        payload: const {},
        createdAt: DateTime.now(),
        organizationId: organizationId,
        priority: priority,
      );

  /// Creates a custom operation.
  factory SyncOperation.custom({
    required String entityType,
    required String entityId,
    required String customOperation,
    required Map<String, dynamic> payload,
    String? organizationId,
    int priority = 0,
  }) =>
      SyncOperation(
        entityType: entityType,
        entityId: entityId,
        operation: SyncOperationType.custom,
        customOperation: customOperation,
        payload: payload,
        createdAt: DateTime.now(),
        organizationId: organizationId,
        priority: priority,
      );

  /// Whether this operation has failed too many times.
  bool hasExceededRetries(int maxRetries) => retryCount >= maxRetries;

  /// Creates a copy with incremented retry count.
  SyncOperation withRetry(String? error) => copyWith(
        retryCount: retryCount + 1,
        lastError: error,
      );

  /// Creates a copy with modified properties.
  SyncOperation copyWith({
    int? id,
    String? entityType,
    String? entityId,
    SyncOperationType? operation,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
    int? priority,
    String? organizationId,
    String? customOperation,
  }) =>
      SyncOperation(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError ?? this.lastError,
        priority: priority ?? this.priority,
        organizationId: organizationId ?? this.organizationId,
        customOperation: customOperation ?? this.customOperation,
      );

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        operation,
        payload,
        createdAt,
        retryCount,
        lastError,
        priority,
        organizationId,
        customOperation,
      ];

  @override
  String toString() =>
      'SyncOperation(${operation.name} $entityType:$entityId, retries: $retryCount)';
}
