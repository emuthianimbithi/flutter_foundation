/// Storage solutions for Flutter Foundation.
///
/// This library provides:
///
/// - [SecureStorage] - Encrypted storage for sensitive data (tokens, secrets)
/// - [AppDatabase] - SQLite database using Drift
/// - [PreferencesStorage] - Key-value storage for settings
/// - [FileStorage] - File system storage utilities
/// - [ScopedStorage] - Organization-scoped data isolation
library foundation_storage;

// Secure storage
export 'src/secure/secure_storage.dart';
export 'src/secure/secure_storage_keys.dart';

// Database
export 'src/database/app_database.dart';
export 'src/database/tables.dart';
export 'src/database/daos/daos.dart';

// Preferences
export 'src/preferences/preferences_storage.dart';
export 'src/preferences/preference_keys.dart';

// File storage
export 'src/file/file_storage.dart';
export 'src/file/file_cache.dart';

// Scoped storage
export 'src/scoped/scoped_storage.dart';
export 'src/scoped/storage_scope.dart';

// Providers
export 'src/providers.dart';

// Initialization
export 'src/storage_initializer.dart';
export 'src/storage_options.dart';
