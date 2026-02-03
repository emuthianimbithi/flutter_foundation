import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:foundation_core/foundation_core.dart';

import 'database/app_database.dart';
import 'file/file_storage.dart';
import 'preferences/preferences_storage.dart';
import 'scoped/scoped_storage.dart';
import 'scoped/storage_scope.dart';
import 'secure/secure_storage.dart';
import 'storage_options.dart';

/// Initializes all storage components.
///
/// Call this early in app startup after [FoundationConfig.initialize()].
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await FoundationConfig.initialize(...);
///   await StorageInitializer.initialize();
///
///   // Optionally restore previous session
///   final scope = await StorageInitializer.restoreScope();
///
///   runApp(MyApp());
/// }
/// ```
class StorageInitializer {
  StorageInitializer._();

  static final AppLogger _log = AppLogger('StorageInitializer');

  static SecureStorage? _secureStorage;
  static PreferencesStorage? _preferencesStorage;
  static AppDatabase? _database;
  static FileStorage? _fileStorage;
  static ScopedStorage? _scopedStorage;
  static StorageOptions _options = const StorageOptions();

  static bool _initialized = false;

  /// Whether storage has been initialized.
  static bool get isInitialized => _initialized;

  /// The secure storage instance.
  static SecureStorage get secureStorage {
    _ensureInitialized();
    return _secureStorage!;
  }

  /// The preferences storage instance.
  static PreferencesStorage get preferencesStorage {
    _ensureInitialized();
    return _preferencesStorage!;
  }

  /// The database instance.
  static AppDatabase get database {
    _ensureInitialized();
    return _database!;
  }

  /// The file storage instance.
  static FileStorage get fileStorage {
    _ensureInitialized();
    return _fileStorage!;
  }

  /// The scoped storage instance.
  static ScopedStorage get scopedStorage {
    _ensureInitialized();
    return _scopedStorage!;
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'StorageInitializer not initialized. Call StorageInitializer.initialize() first.',
      );
    }
  }

  /// Initializes all storage components.
  static Future<void> initialize({
    SecureStorage? secureStorage,
    PreferencesStorage? preferencesStorage,
    AppDatabase? database,
    FileStorage? fileStorage,
    StorageOptions options = const StorageOptions(),
    ScopedStorage? scopedStorage,
  }) async {
    if (_initialized) {
      _log.warning('StorageInitializer.initialize() called multiple times');
      return;
    }

    _log.info('Initializing storage...');
    _options = options;

    // Initialize secure storage
    _secureStorage = secureStorage ?? SecureStorage();

    // Generate or load encryption key when requested.
    String? encryptionKey;
    if (options.encryptionEnabled) {
      encryptionKey = await _ensureEncryptionKey(_secureStorage!);
    }

    // Initialize preferences
    _preferencesStorage = preferencesStorage ?? PreferencesStorage();
    await _preferencesStorage!.init();

    // Initialize database
    _database = database ??
        AppDatabase(
          dbName: options.dbName,
          path: options.dbPathOverride,
        );

    // Initialize file storage
    _fileStorage = fileStorage ??
        FileStorage(
          cacheDirName: options.cacheDirName,
          cacheDirOverride: options.cacheDirOverride,
          encryptionKey: encryptionKey,
        );
    await _fileStorage!.init();

    // Initialize scoped storage
    _scopedStorage = scopedStorage ??
        ScopedStorage(
          secureStorage: _secureStorage!,
          preferences: _preferencesStorage!,
          database: _database!,
        );

    // Cleanup expired cache
    await _database!.deleteExpiredCache();

    _initialized = true;
    _log.info('Storage initialized successfully');
  }

  /// Restores the previous session scope, if any.
  ///
  /// Returns the restored scope, or null if no session was found.
  static Future<StorageScope?> restoreScope() async {
    _ensureInitialized();
    if (!_options.orgScopeEnabled) {
      _log.debug('Org scope disabled; skipping restoreScope.');
      return null;
    }
    return _scopedStorage!.restoreScope();
  }

  /// Sets the current scope after authentication.
  static Future<void> setScope(StorageScope scope) async {
    _ensureInitialized();
    if (!_options.orgScopeEnabled) {
      _log.debug('Org scope disabled; setScope no-op.');
      return;
    }
    await _scopedStorage!.setScope(scope);
  }

  /// Clears all storage (for logout).
  static Future<void> clearAll({bool force = false}) async {
    _ensureInitialized();
    if (!force && !_options.clearOnLogout) {
      _log.info('clearOnLogout=false; skipping clearAll.');
      return;
    }
    await _scopedStorage!.clearAll();
  }

  /// Factory reset - clears everything including preferences.
  static Future<void> factoryReset() async {
    _ensureInitialized();
    await _scopedStorage!.factoryReset();
  }

  /// Clears cache to free up space.
  static Future<void> clearCache() async {
    _ensureInitialized();
    await _database!.deleteExpiredCache();
    await _fileStorage!.clearCache();
    _log.info('Cache cleared');
  }

  /// Gets the current cache size (database + file cache).
  static Future<CacheSize> getCacheSize() async {
    _ensureInitialized();
    final dbBytes = await _computeDbSize();
    final fileBytes = await _fileStorage!.getCacheSize();
    return CacheSize(dbSizeBytes: dbBytes, fileCacheBytes: fileBytes);
  }

  /// Formatted cache size string for UI.
  static Future<String> getFormattedCacheSize() async {
    final size = await getCacheSize();
    return size.formatted;
  }

  /// Resets the initializer (for testing).
  static void reset() {
    _secureStorage = null;
    _preferencesStorage = null;
    _database?.close();
    _database = null;
    _fileStorage = null;
    _scopedStorage = null;
    _initialized = false;
  }

  static Future<int> _computeDbSize() async {
    if (kIsWeb) return 0;
    try {
      final path = _database?.path;
      if (path == null) return 0;
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e, s) {
      _log.error('Failed to compute DB size', e, s);
    }
    return 0;
  }

  static Future<String> _ensureEncryptionKey(
      SecureStorage secureStorage) async {
    const keyName = 'storage.encryption_key';
    final existing = await secureStorage.read(keyName);
    final current = existing.valueOrNull;
    if (current != null && current.isNotEmpty) return current;

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final encoded = base64Encode(bytes);
    await secureStorage.write(keyName, encoded);
    return encoded;
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Cache size details for storage layers.
class CacheSize {
  final int dbSizeBytes;
  final int fileCacheBytes;

  const CacheSize({required this.dbSizeBytes, required this.fileCacheBytes});

  int get totalBytes => dbSizeBytes + fileCacheBytes;

  String get formatted => StorageInitializer._formatBytes(totalBytes);
}
