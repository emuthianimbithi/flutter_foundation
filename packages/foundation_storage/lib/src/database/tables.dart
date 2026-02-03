import 'package:drift/drift.dart';

// ─────────────────────────────────────────────────────────────
// SYNC METADATA
// ─────────────────────────────────────────────────────────────

/// Tracks sync metadata for entities.
class SyncMetadata extends Table {
  /// The entity type (e.g., 'user', 'organization').
  TextColumn get entityType => text()();

  /// The entity ID.
  TextColumn get entityId => text()();

  /// The local version.
  IntColumn get localVersion => integer().withDefault(const Constant(1))();

  /// The server version.
  IntColumn get serverVersion => integer().nullable()();

  /// When this entity was last synced.
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// When this entity was locally modified.
  DateTimeColumn get localModifiedAt => dateTime().nullable()();

  /// Sync status: 'synced', 'pending', 'conflict', 'error'.
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  /// Error message if sync failed.
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {entityType, entityId};
}

// ─────────────────────────────────────────────────────────────
// SYNC QUEUE
// ─────────────────────────────────────────────────────────────

/// Queue of pending sync operations.
class SyncQueue extends Table {
  /// Auto-incrementing ID.
  IntColumn get id => integer().autoIncrement()();

  /// The entity type.
  TextColumn get entityType => text()();

  /// The entity ID.
  TextColumn get entityId => text()();

  /// Operation type: 'create', 'update', 'delete'.
  TextColumn get operation => text()();

  /// The payload as JSON.
  TextColumn get payload => text()();

  /// When this operation was queued.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Number of retry attempts.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Last error message.
  TextColumn get lastError => text().nullable()();

  /// Priority (lower = higher priority).
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// Organization ID for scoping.
  TextColumn get organizationId => text().nullable()();
}

// ─────────────────────────────────────────────────────────────
// KEY-VALUE CACHE
// ─────────────────────────────────────────────────────────────

/// Generic key-value cache table.
class KeyValueCache extends Table {
  /// The cache key.
  TextColumn get key => text()();

  /// The cached value as JSON.
  TextColumn get value => text()();

  /// When this cache entry was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When this cache entry expires.
  DateTimeColumn get expiresAt => dateTime().nullable()();

  /// Organization ID for scoping.
  TextColumn get organizationId => text().nullable()();

  /// Cache tags for bulk invalidation.
  TextColumn get tags => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

// ─────────────────────────────────────────────────────────────
// CACHED USER
// ─────────────────────────────────────────────────────────────

/// Cached user data.
class CachedUsers extends Table {
  /// User ID.
  TextColumn get id => text()();

  /// Email address.
  TextColumn get email => text()();

  /// First name.
  TextColumn get firstName => text()();

  /// Last name.
  TextColumn get lastName => text()();

  /// Phone number.
  TextColumn get phone => text().nullable()();

  /// Avatar URL.
  TextColumn get avatarUrl => text().nullable()();

  /// Whether email is verified.
  BoolColumn get emailVerified =>
      boolean().withDefault(const Constant(false))();

  /// User status.
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// When the user was created.
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// When the user was last updated.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// When this cache entry was fetched.
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────
// CACHED ORGANIZATION
// ─────────────────────────────────────────────────────────────

/// Cached organization data.
class CachedOrganizations extends Table {
  /// Organization ID.
  TextColumn get id => text()();

  /// Organization slug.
  TextColumn get slug => text()();

  /// Organization name.
  TextColumn get name => text()();

  /// Logo URL.
  TextColumn get logoUrl => text().nullable()();

  /// Organization settings as JSON.
  TextColumn get settings => text().nullable()();

  /// When the organization was created.
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// When the organization was last updated.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// When this cache entry was fetched.
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────
// USER ORGANIZATION MEMBERSHIP
// ─────────────────────────────────────────────────────────────

/// Cached user-organization membership.
class CachedMemberships extends Table {
  /// User ID.
  TextColumn get userId => text()();

  /// Organization ID.
  TextColumn get organizationId => text()();

  /// Role name.
  TextColumn get role => text()();

  /// Features as JSON array.
  TextColumn get features => text().nullable()();

  /// When this membership was last updated.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// When this cache entry was fetched.
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userId, organizationId};
}

// ─────────────────────────────────────────────────────────────
// PENDING FILES
// ─────────────────────────────────────────────────────────────

/// Files pending upload.
class PendingFiles extends Table {
  /// Auto-incrementing ID.
  IntColumn get id => integer().autoIncrement()();

  /// Local file path.
  TextColumn get localPath => text()();

  /// Remote path/key.
  TextColumn get remotePath => text().nullable()();

  /// File mime type.
  TextColumn get mimeType => text().nullable()();

  /// File size in bytes.
  IntColumn get fileSize => integer().nullable()();

  /// Upload status: 'pending', 'uploading', 'completed', 'failed'.
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Upload progress (0-100).
  IntColumn get progress => integer().withDefault(const Constant(0))();

  /// Associated entity type.
  TextColumn get entityType => text().nullable()();

  /// Associated entity ID.
  TextColumn get entityId => text().nullable()();

  /// Organization ID.
  TextColumn get organizationId => text().nullable()();

  /// When this file was queued.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Last error message.
  TextColumn get lastError => text().nullable()();
}
