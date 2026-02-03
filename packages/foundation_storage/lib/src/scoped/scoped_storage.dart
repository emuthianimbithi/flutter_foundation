import 'package:foundation_core/foundation_core.dart';

import '../database/app_database.dart';
import '../preferences/preferences_storage.dart';
import '../secure/secure_storage.dart';
import 'storage_scope.dart';

/// Storage that isolates data by organization/user scope.
///
/// This is crucial for multi-tenant apps where users can switch
/// between organizations and each organization's data must be isolated.
///
/// Example:
/// ```dart
/// final scopedStorage = ScopedStorage(
///   secureStorage: secureStorage,
///   preferences: preferences,
///   database: database,
/// );
///
/// // Set current scope
/// await scopedStorage.setScope(StorageScope(
///   userId: 'user-123',
///   organizationId: 'org-456',
/// ));
///
/// // When user switches orgs
/// await scopedStorage.switchOrganization('new-org-789');
/// // This clears org-specific cached data
///
/// // On logout
/// await scopedStorage.clearAll();
/// ```
class ScopedStorage {
  final SecureStorage _secureStorage;
  final PreferencesStorage _preferences;
  final AppDatabase _database;
  final AppLogger _log = AppLogger('ScopedStorage');

  StorageScope? _currentScope;

  ScopedStorage({
    required SecureStorage secureStorage,
    required PreferencesStorage preferences,
    required AppDatabase database,
  })  : _secureStorage = secureStorage,
        _preferences = preferences,
        _database = database;

  /// The current storage scope.
  StorageScope? get currentScope => _currentScope;

  /// The current user ID.
  String? get currentUserId => _currentScope?.userId;

  /// The current organization ID.
  String? get currentOrganizationId => _currentScope?.organizationId;

  /// Whether there is a current scope set.
  bool get hasScope => _currentScope != null;

  /// Whether there is an organization in the current scope.
  bool get hasOrganization => _currentScope?.organizationId != null;

  // ─────────────────────────────────────────────────────────────
  // SCOPE MANAGEMENT
  // ─────────────────────────────────────────────────────────────

  /// Sets the current storage scope.
  ///
  /// This should be called after successful authentication.
  Future<void> setScope(StorageScope scope) async {
    _log.info(
        'Setting storage scope: user=${scope.userId}, org=${scope.organizationId}');

    final previousScope = _currentScope;
    _currentScope = scope;

    // Store in secure storage for persistence
    await _secureStorage.setUserId(scope.userId);
    if (scope.organizationId != null) {
      await _secureStorage.setOrganizationId(scope.organizationId!);
    }
    if (scope.organizationSlug != null) {
      await _preferences.setLastOrganizationSlug(scope.organizationSlug!);
    }

    // If organization changed, clear org-specific data
    if (previousScope != null &&
        previousScope.organizationId != null &&
        previousScope.organizationId != scope.organizationId) {
      await _clearOrganizationData(previousScope.organizationId!);
    }
  }

  /// Restores the scope from persisted storage.
  ///
  /// Call this on app startup to restore the previous session.
  Future<StorageScope?> restoreScope() async {
    final userId = await _secureStorage.getUserId();
    if (userId == null) {
      _log.debug('No stored scope found');
      return null;
    }

    final organizationId = await _secureStorage.getOrganizationId();
    final organizationSlug = _preferences.getLastOrganizationSlug();

    _currentScope = StorageScope(
      userId: userId,
      organizationId: organizationId,
      organizationSlug: organizationSlug,
    );

    _log.info('Restored storage scope: user=$userId, org=$organizationId');
    return _currentScope;
  }

  /// Switches to a different organization.
  ///
  /// This clears the previous organization's cached data.
  Future<void> switchOrganization({
    required String organizationId,
    String? organizationSlug,
  }) async {
    if (_currentScope == null) {
      throw StateError('No scope set. Call setScope() first.');
    }

    final previousOrgId = _currentScope!.organizationId;

    _log.info('Switching organization: $previousOrgId -> $organizationId');

    // Update scope
    _currentScope = _currentScope!.copyWith(
      organizationId: organizationId,
      organizationSlug: organizationSlug,
    );

    // Persist
    await _secureStorage.setOrganizationId(organizationId);
    if (organizationSlug != null) {
      await _preferences.setLastOrganizationSlug(organizationSlug);
    }

    // Clear previous org's data
    if (previousOrgId != null && previousOrgId != organizationId) {
      await _clearOrganizationData(previousOrgId);
    }
  }

  /// Clears the current scope (on logout).
  Future<void> clearScope() async {
    _log.info('Clearing storage scope');

    _currentScope = null;

    // Clear auth data
    await _secureStorage.clearAuthData();
  }

  // ─────────────────────────────────────────────────────────────
  // DATA CLEARING
  // ─────────────────────────────────────────────────────────────

  /// Clears organization-specific data.
  Future<void> _clearOrganizationData(String organizationId) async {
    _log.info('Clearing data for organization: $organizationId');

    // Clear org-scoped database data
    await _database.clearOrganizationData(organizationId);

    // Clear org-scoped cache
    await _database.clearCacheForOrg(organizationId);
  }

  /// Clears all user and organization data (full logout).
  Future<void> clearAll() async {
    _log.info('Clearing all storage data');

    // Clear scope
    _currentScope = null;

    // Clear secure storage
    await _secureStorage.clearAuthData();
    await _secureStorage.deleteAll();

    // Clear database
    await _database.clearAllData();

    // Note: We don't clear preferences as they contain app settings,
    // not user data. Override if needed.
  }

  /// Clears all data and preferences (factory reset).
  Future<void> factoryReset() async {
    _log.info('Factory reset - clearing ALL data');

    await clearAll();
    await _preferences.clear();
  }

  // ─────────────────────────────────────────────────────────────
  // SCOPED KEY GENERATION
  // ─────────────────────────────────────────────────────────────

  /// Generates a user-scoped key.
  String userScopedKey(String key) {
    if (_currentScope?.userId == null) {
      throw StateError('No user scope set');
    }
    return 'user:${_currentScope!.userId}:$key';
  }

  /// Generates an organization-scoped key.
  String orgScopedKey(String key) {
    if (_currentScope?.organizationId == null) {
      throw StateError('No organization scope set');
    }
    return 'org:${_currentScope!.organizationId}:$key';
  }

  /// Generates a user+organization scoped key.
  String fullyScopedKey(String key) {
    if (_currentScope?.userId == null ||
        _currentScope?.organizationId == null) {
      throw StateError('Full scope not set');
    }
    return 'user:${_currentScope!.userId}:org:${_currentScope!.organizationId}:$key';
  }
}
