import 'package:foundation_core/foundation_core.dart';

import 'database/app_database.dart';
import 'file/file_storage.dart';
import 'preferences/preferences_storage.dart';
import 'scoped/scoped_storage.dart';
import 'scoped/storage_scope.dart';
import 'secure/secure_storage.dart';

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
  }) async {
    if (_initialized) {
      _log.warning('StorageInitializer.initialize() called multiple times');
      return;
    }

    _log.info('Initializing storage...');

    // Initialize secure storage
    _secureStorage = secureStorage ?? SecureStorage();

    // Initialize preferences
    _preferencesStorage = preferencesStorage ?? PreferencesStorage();
    await _preferencesStorage!.init();

    // Initialize database
    _database = database ?? AppDatabase();

    // Initialize file storage
    _fileStorage = fileStorage ?? FileStorage();
    await _fileStorage!.init();

    // Initialize scoped storage
    _scopedStorage = ScopedStorage(
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
    return _scopedStorage!.restoreScope();
  }

  /// Sets the current scope after authentication.
  static Future<void> setScope(StorageScope scope) async {
    _ensureInitialized();
    await _scopedStorage!.setScope(scope);
  }

  /// Clears all storage (for logout).
  static Future<void> clearAll() async {
    _ensureInitialized();
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

  /// Gets the current cache size as a formatted string.
  static Future<String> getCacheSize() async {
    _ensureInitialized();
    final dbSize = 0; // TODO: Calculate DB size
    final fileSize = await _fileStorage!.getCacheSize();
    final totalBytes = dbSize + fileSize;

    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
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
}
