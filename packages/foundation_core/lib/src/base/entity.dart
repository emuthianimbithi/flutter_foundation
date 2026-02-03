import 'package:equatable/equatable.dart';

/// Base class for domain entities.
///
/// Entities are objects that have a distinct identity that runs through time
/// and different representations. They are defined by their identity rather
/// than their attributes.
///
/// Example:
/// ```dart
/// class User extends Entity<String> {
///   final String name;
///   final String email;
///
///   const User({
///     required super.id,
///     required this.name,
///     required this.email,
///     super.createdAt,
///     super.updatedAt,
///   });
///
///   @override
///   List<Object?> get props => [id, name, email, createdAt, updatedAt];
/// }
/// ```
abstract class Entity<T> extends Equatable {
  /// The unique identifier of this entity.
  final T id;

  /// When this entity was created.
  final DateTime? createdAt;

  /// When this entity was last updated.
  final DateTime? updatedAt;

  const Entity({
    required this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// Whether this entity has been persisted (has valid timestamps).
  bool get isPersisted => createdAt != null;

  /// Whether this entity has been modified since creation.
  bool get isModified =>
      updatedAt != null && createdAt != null && updatedAt != createdAt;

  @override
  List<Object?> get props => [id];

  @override
  String toString() => '${runtimeType.toString()}(id: $id)';
}

/// Mixin for entities that support soft deletion.
mixin SoftDeletable {
  /// When this entity was deleted, or null if not deleted.
  DateTime? get deletedAt;

  /// Whether this entity has been soft deleted.
  bool get isDeleted => deletedAt != null;

  /// Whether this entity is active (not deleted).
  bool get isActive => deletedAt == null;
}

/// Mixin for entities that track versions for optimistic locking.
mixin Versioned {
  /// The version number for optimistic locking.
  int get version;
}

/// Mixin for entities that are associated with an organization.
mixin OrganizationScoped {
  /// The organization this entity belongs to.
  String get organizationId;
}

/// Mixin for entities that track who created/updated them.
mixin Auditable {
  /// ID of the user who created this entity.
  String? get createdBy;

  /// ID of the user who last updated this entity.
  String? get updatedBy;
}
