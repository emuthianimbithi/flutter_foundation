import 'package:equatable/equatable.dart';

/// Represents the current storage scope (user + organization).
///
/// This is used to isolate data between users and organizations
/// in multi-tenant applications.
class StorageScope extends Equatable {
  /// The current user's ID.
  final String userId;

  /// The current organization's ID (null for consumer apps).
  final String? organizationId;

  /// The current organization's slug.
  final String? organizationSlug;

  /// Additional scope metadata.
  final Map<String, String>? metadata;

  const StorageScope({
    required this.userId,
    this.organizationId,
    this.organizationSlug,
    this.metadata,
  });

  /// Creates a user-only scope (no organization).
  factory StorageScope.userOnly(String userId) => StorageScope(userId: userId);

  /// Whether this scope includes an organization.
  bool get hasOrganization => organizationId != null;

  /// Creates a copy with modified properties.
  StorageScope copyWith({
    String? userId,
    String? organizationId,
    String? organizationSlug,
    Map<String, String>? metadata,
  }) =>
      StorageScope(
        userId: userId ?? this.userId,
        organizationId: organizationId ?? this.organizationId,
        organizationSlug: organizationSlug ?? this.organizationSlug,
        metadata: metadata ?? this.metadata,
      );

  /// Creates a copy without organization (for switching to consumer mode).
  StorageScope withoutOrganization() => StorageScope(
        userId: userId,
        metadata: metadata,
      );

  @override
  List<Object?> get props =>
      [userId, organizationId, organizationSlug, metadata];

  @override
  String toString() =>
      'StorageScope(user: $userId, org: ${organizationId ?? 'none'})';
}
