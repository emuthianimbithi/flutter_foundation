import 'dart:io';

/// Options for configuring storage initialization.
class StorageOptions {
  /// File name for the Drift database.
  final String dbName;

  /// Optional full path override for the database file (used in tests).
  final String? dbPathOverride;

  /// Whether to encrypt cached files using AES with a key stored in secure storage.
  final bool encryptionEnabled;

  /// Subdirectory name inside the platform cache directory for file cache.
  final String cacheDirName;

  /// Optional override directory for cache (used in tests).
  final Directory? cacheDirOverride;

  /// Optional soft cap for cache bytes (not enforced automatically, but emitted in metrics).
  final int? maxCacheBytes;

  /// Whether storage should be cleared automatically on logout.
  final bool clearOnLogout;

  /// Whether to enable org-scoped storage (scoped storage APIs stay enabled regardless).
  final bool orgScopeEnabled;

  const StorageOptions({
    this.dbName = 'foundation.db',
    this.dbPathOverride,
    this.encryptionEnabled = false,
    this.cacheDirName = 'foundation_cache',
    this.cacheDirOverride,
    this.maxCacheBytes,
    this.clearOnLogout = true,
    this.orgScopeEnabled = true,
  });
}
