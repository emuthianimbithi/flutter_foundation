import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// The main application database.
///
/// Uses Drift (formerly Moor) for type-safe SQLite access.
///
/// Example:
/// ```dart
/// final db = AppDatabase();
///
/// // Insert a cached user
/// await db.cachedUsersDao.upsertUser(user);
///
/// // Query sync queue
/// final pending = await db.syncQueueDao.getPendingOperations();
/// ```
@DriftDatabase(
  tables: [
    SyncMetadata,
    SyncQueue,
    KeyValueCache,
    CachedUsers,
    CachedOrganizations,
    CachedMemberships,
    PendingFiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  static final AppLogger _log = AppLogger('AppDatabase');

  /// Creates the database with the default connection.
  AppDatabase() : super(_openConnection());

  /// Creates the database with a custom connection (for testing).
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        _log.info('Creating database schema v$schemaVersion');
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        _log.info('Upgrading database from v$from to v$to');
        // Add migrations here as schema evolves
        // Example:
        // if (from < 2) {
        //   await m.addColumn(syncQueue, syncQueue.priority);
        // }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
        _log.debug('Database opened (v${details.versionNow})');
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SYNC METADATA OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Gets sync metadata for an entity.
  Future<SyncMetadataData?> getSyncMetadata(String entityType, String entityId) {
    return (select(syncMetadata)
          ..where((t) => t.entityType.equals(entityType) & t.entityId.equals(entityId)))
        .getSingleOrNull();
  }

  /// Upserts sync metadata.
  Future<void> upsertSyncMetadata(SyncMetadataCompanion data) {
    return into(syncMetadata).insertOnConflictUpdate(data);
  }

  /// Gets all entities with pending sync.
  Future<List<SyncMetadataData>> getPendingSyncEntities() {
    return (select(syncMetadata)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Gets all entities with conflicts.
  Future<List<SyncMetadataData>> getConflictedEntities() {
    return (select(syncMetadata)..where((t) => t.syncStatus.equals('conflict'))).get();
  }

  // ─────────────────────────────────────────────────────────────
  // SYNC QUEUE OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Adds an operation to the sync queue.
  Future<int> addToSyncQueue(SyncQueueCompanion data) {
    return into(syncQueue).insert(data);
  }

  /// Gets pending operations ordered by priority and creation time.
  Future<List<SyncQueueData>> getPendingOperations({int? limit}) {
    final query = select(syncQueue)
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority),
        (t) => OrderingTerm(expression: t.createdAt),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  /// Gets operations for a specific entity.
  Future<List<SyncQueueData>> getOperationsForEntity(String entityType, String entityId) {
    return (select(syncQueue)
          ..where((t) => t.entityType.equals(entityType) & t.entityId.equals(entityId)))
        .get();
  }

  /// Removes an operation from the queue.
  Future<int> removeFromSyncQueue(int id) {
    return (delete(syncQueue)..where((t) => t.id.equals(id))).go();
  }

  /// Updates retry count and error for an operation.
  Future<void> updateSyncQueueRetry(int id, int retryCount, String? error) {
    return (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: Value(retryCount),
        lastError: Value(error),
      ),
    );
  }

  /// Clears the sync queue for an organization.
  Future<int> clearSyncQueueForOrg(String organizationId) {
    return (delete(syncQueue)..where((t) => t.organizationId.equals(organizationId))).go();
  }

  // ─────────────────────────────────────────────────────────────
  // KEY-VALUE CACHE OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Gets a cached value.
  Future<String?> getCachedValue(String key) async {
    final result = await (select(keyValueCache)
          ..where((t) => t.key.equals(key))
          ..where((t) => t.expiresAt.isNull() | t.expiresAt.isBiggerThanValue(DateTime.now())))
        .getSingleOrNull();
    return result?.value;
  }

  /// Sets a cached value.
  Future<void> setCachedValue(
    String key,
    String value, {
    Duration? ttl,
    String? organizationId,
    List<String>? tags,
  }) {
    return into(keyValueCache).insertOnConflictUpdate(
      KeyValueCacheCompanion(
        key: Value(key),
        value: Value(value),
        createdAt: Value(DateTime.now()),
        expiresAt: Value(ttl != null ? DateTime.now().add(ttl) : null),
        organizationId: Value(organizationId),
        tags: Value(tags?.join(','))),
    );
  }

  /// Deletes a cached value.
  Future<int> deleteCachedValue(String key) {
    return (delete(keyValueCache)..where((t) => t.key.equals(key))).go();
  }

  /// Deletes expired cache entries.
  Future<int> deleteExpiredCache() {
    return (delete(keyValueCache)..where((t) => t.expiresAt.isSmallerThanValue(DateTime.now()))).go();
  }

  /// Deletes cache entries by tag.
  Future<int> deleteCacheByTag(String tag) {
    return (delete(keyValueCache)..where((t) => t.tags.like('%$tag%'))).go();
  }

  /// Clears cache for an organization.
  Future<int> clearCacheForOrg(String organizationId) {
    return (delete(keyValueCache)..where((t) => t.organizationId.equals(organizationId))).go();
  }

  // ─────────────────────────────────────────────────────────────
  // CACHED USER OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Gets a cached user.
  Future<CachedUsersData?> getCachedUser(String id) {
    return (select(cachedUsers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Upserts a cached user.
  Future<void> upsertCachedUser(CachedUsersCompanion data) {
    return into(cachedUsers).insertOnConflictUpdate(data);
  }

  /// Deletes a cached user.
  Future<int> deleteCachedUser(String id) {
    return (delete(cachedUsers)..where((t) => t.id.equals(id))).go();
  }

  // ─────────────────────────────────────────────────────────────
  // CACHED ORGANIZATION OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Gets a cached organization by ID.
  Future<CachedOrganizationsData?> getCachedOrganization(String id) {
    return (select(cachedOrganizations)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Gets a cached organization by slug.
  Future<CachedOrganizationsData?> getCachedOrganizationBySlug(String slug) {
    return (select(cachedOrganizations)..where((t) => t.slug.equals(slug))).getSingleOrNull();
  }

  /// Upserts a cached organization.
  Future<void> upsertCachedOrganization(CachedOrganizationsCompanion data) {
    return into(cachedOrganizations).insertOnConflictUpdate(data);
  }

  // ─────────────────────────────────────────────────────────────
  // CLEANUP
  // ─────────────────────────────────────────────────────────────

  /// Clears all data for an organization (on org switch or logout).
  Future<void> clearOrganizationData(String organizationId) async {
    _log.info('Clearing data for organization: $organizationId');
    await clearSyncQueueForOrg(organizationId);
    await clearCacheForOrg(organizationId);
    // Add more org-scoped cleanup as needed
  }

  /// Clears all cached data (on logout).
  Future<void> clearAllData() async {
    _log.info('Clearing all database data');
    await delete(syncQueue).go();
    await delete(syncMetadata).go();
    await delete(keyValueCache).go();
    await delete(cachedUsers).go();
    await delete(cachedOrganizations).go();
    await delete(cachedMemberships).go();
    await delete(pendingFiles).go();
  }
}

/// Opens the database connection.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'foundation.db'));
    return NativeDatabase.createInBackground(file);
  });
}
