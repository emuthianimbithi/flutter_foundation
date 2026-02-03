import 'dart:typed_data';

import 'package:foundation_core/foundation_core.dart';

import 'file_storage.dart';

/// A caching layer for files with TTL support.
///
/// Example:
/// ```dart
/// final cache = FileCache(fileStorage);
///
/// // Cache an image
/// await cache.put('images', 'user_123.jpg', imageBytes, ttl: Duration(days: 7));
///
/// // Get from cache
/// final bytes = await cache.get('images', 'user_123.jpg');
///
/// // Get or fetch
/// final bytes = await cache.getOrFetch(
///   'images',
///   'user_123.jpg',
///   () => downloadImage(url),
///   ttl: Duration(days: 7),
/// );
/// ```
class FileCache {
  final FileStorage _storage;
  final AppLogger _log = AppLogger('FileCache');

  /// Metadata file extension.
  static const _metaExtension = '.meta';

  FileCache(this._storage);

  // ─────────────────────────────────────────────────────────────
  // BASIC OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Puts bytes into the cache.
  Future<Result<Unit>> put(
    String subdirectory,
    String filename,
    Uint8List bytes, {
    Duration? ttl,
    Map<String, String>? metadata,
  }) async {
    // Save the file
    final result =
        await _storage.saveFile(subdirectory, filename, bytes, cache: true);
    if (result.isFailure) return Result.failure(result.failure);

    // Save metadata if TTL is specified
    if (ttl != null || metadata != null) {
      final meta = {
        if (ttl != null)
          'expires_at': DateTime.now().add(ttl).toIso8601String(),
        if (metadata != null) ...metadata,
      };
      await _storage.saveTextFile(
        subdirectory,
        '$filename$_metaExtension',
        meta.entries.map((e) => '${e.key}=${e.value}').join('\n'),
        cache: true,
      );
    }

    return Result.success(unit);
  }

  /// Gets bytes from the cache.
  Future<Uint8List?> get(String subdirectory, String filename) async {
    // Check if expired
    if (await isExpired(subdirectory, filename)) {
      await remove(subdirectory, filename);
      return null;
    }

    final result = await _storage.readFile(subdirectory, filename, cache: true);
    return result.valueOrNull;
  }

  /// Gets bytes from cache, or fetches and caches if not present.
  Future<Result<Uint8List>> getOrFetch(
    String subdirectory,
    String filename,
    Future<Uint8List> Function() fetch, {
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    // Try to get from cache first
    if (!forceRefresh) {
      final cached = await get(subdirectory, filename);
      if (cached != null) {
        _log.debug('Cache hit: $subdirectory/$filename');
        return Result.success(cached);
      }
    }

    // Fetch and cache
    _log.debug('Cache miss: $subdirectory/$filename');
    try {
      final bytes = await fetch();
      await put(subdirectory, filename, bytes, ttl: ttl);
      return Result.success(bytes);
    } catch (e, s) {
      _log.error('Failed to fetch: $subdirectory/$filename', e, s);
      return Result.failure(
          Failure.cache('Failed to fetch and cache', originalException: e));
    }
  }

  /// Checks if a cache entry exists.
  Future<bool> exists(String subdirectory, String filename) async {
    if (await isExpired(subdirectory, filename)) {
      return false;
    }
    return _storage.fileExists(subdirectory, filename, cache: true);
  }

  /// Checks if a cache entry is expired.
  Future<bool> isExpired(String subdirectory, String filename) async {
    final metaResult = await _storage.readTextFile(
      subdirectory,
      '$filename$_metaExtension',
      cache: true,
    );

    if (metaResult.isFailure) return false; // No metadata = not expired

    final meta = _parseMetadata(metaResult.value);
    final expiresAtStr = meta['expires_at'];
    if (expiresAtStr == null) return false;

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return false;

    return DateTime.now().isAfter(expiresAt);
  }

  /// Removes a cache entry.
  Future<Result<Unit>> remove(String subdirectory, String filename) async {
    await _storage.deleteFile(subdirectory, filename, cache: true);
    await _storage.deleteFile(subdirectory, '$filename$_metaExtension',
        cache: true);
    return Result.success(unit);
  }

  /// Clears all cache entries in a subdirectory.
  Future<Result<Unit>> clearSubdirectory(String subdirectory) {
    return _storage.clearSubdirectory(subdirectory, cache: true);
  }

  /// Clears all cache.
  Future<Result<Unit>> clearAll() {
    return _storage.clearCache();
  }

  /// Removes expired entries from a subdirectory.
  Future<int> removeExpired(String subdirectory) async {
    var removedCount = 0;
    final files = await _storage.listFiles(subdirectory, cache: true);

    for (final file in files) {
      final filename = file.path.split('/').last;
      if (filename.endsWith(_metaExtension)) continue;

      if (await isExpired(subdirectory, filename)) {
        await remove(subdirectory, filename);
        removedCount++;
      }
    }

    if (removedCount > 0) {
      _log.debug('Removed $removedCount expired entries from $subdirectory');
    }
    return removedCount;
  }

  // ─────────────────────────────────────────────────────────────
  // METADATA
  // ─────────────────────────────────────────────────────────────

  /// Gets metadata for a cache entry.
  Future<Map<String, String>?> getMetadata(
      String subdirectory, String filename) async {
    final result = await _storage.readTextFile(
      subdirectory,
      '$filename$_metaExtension',
      cache: true,
    );
    if (result.isFailure) return null;
    return _parseMetadata(result.value);
  }

  Map<String, String> _parseMetadata(String content) {
    final meta = <String, String>{};
    for (final line in content.split('\n')) {
      final idx = line.indexOf('=');
      if (idx > 0) {
        meta[line.substring(0, idx)] = line.substring(idx + 1);
      }
    }
    return meta;
  }

  // ─────────────────────────────────────────────────────────────
  // STATS
  // ─────────────────────────────────────────────────────────────

  /// Gets the total cache size in bytes.
  Future<int> getTotalSize() {
    return _storage.getCacheSize();
  }

  /// Gets a human-readable cache size string.
  Future<String> getFormattedSize() async {
    final bytes = await getTotalSize();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
