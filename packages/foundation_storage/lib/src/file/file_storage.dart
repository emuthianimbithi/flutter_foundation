import 'dart:io';
import 'dart:typed_data';

import 'package:foundation_core/foundation_core.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File system storage utilities.
///
/// Provides convenient access to app directories and file operations.
///
/// Example:
/// ```dart
/// final fileStorage = FileStorage();
/// await fileStorage.init();
///
/// // Save a file
/// final file = await fileStorage.saveFile('images', 'photo.jpg', bytes);
///
/// // Get file path
/// final path = await fileStorage.getFilePath('images', 'photo.jpg');
/// ```
class FileStorage {
  final AppLogger _log = AppLogger('FileStorage');

  Directory? _appDocumentsDir;
  Directory? _appSupportDir;
  Directory? _tempDir;
  Directory? _cacheDir;

  /// Whether the storage has been initialized.
  bool get isInitialized => _appDocumentsDir != null;

  /// Initializes the file storage.
  Future<void> init() async {
    if (_appDocumentsDir != null) return;

    _appDocumentsDir = await getApplicationDocumentsDirectory();
    _appSupportDir = await getApplicationSupportDirectory();
    _tempDir = await getTemporaryDirectory();
    _cacheDir = await getApplicationCacheDirectory();

    _log.debug('FileStorage initialized');
    _log.debug('Documents: ${_appDocumentsDir!.path}');
    _log.debug('Support: ${_appSupportDir!.path}');
    _log.debug('Temp: ${_tempDir!.path}');
    _log.debug('Cache: ${_cacheDir!.path}');
  }

  void _ensureInitialized() {
    if (_appDocumentsDir == null) {
      throw StateError('FileStorage not initialized. Call init() first.');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // DIRECTORIES
  // ─────────────────────────────────────────────────────────────

  /// The app documents directory (persisted, backed up).
  Directory get documentsDirectory {
    _ensureInitialized();
    return _appDocumentsDir!;
  }

  /// The app support directory (persisted, not visible to user).
  Directory get supportDirectory {
    _ensureInitialized();
    return _appSupportDir!;
  }

  /// The temp directory (may be cleared by system).
  Directory get tempDirectory {
    _ensureInitialized();
    return _tempDir!;
  }

  /// The cache directory (may be cleared by system).
  Directory get cacheDirectory {
    _ensureInitialized();
    return _cacheDir!;
  }

  /// Gets or creates a subdirectory in the documents directory.
  Future<Directory> getDocumentsSubdirectory(String name) async {
    _ensureInitialized();
    final dir = Directory(p.join(_appDocumentsDir!.path, name));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Gets or creates a subdirectory in the cache directory.
  Future<Directory> getCacheSubdirectory(String name) async {
    _ensureInitialized();
    final dir = Directory(p.join(_cacheDir!.path, name));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // ─────────────────────────────────────────────────────────────
  // FILE OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Gets the full path for a file in a subdirectory.
  Future<String> getFilePath(String subdirectory, String filename) async {
    final dir = await getDocumentsSubdirectory(subdirectory);
    return p.join(dir.path, filename);
  }

  /// Gets the full path for a cached file.
  Future<String> getCacheFilePath(String subdirectory, String filename) async {
    final dir = await getCacheSubdirectory(subdirectory);
    return p.join(dir.path, filename);
  }

  /// Saves bytes to a file.
  Future<Result<File>> saveFile(
    String subdirectory,
    String filename,
    Uint8List bytes, {
    bool cache = false,
  }) async {
    try {
      final path = cache
          ? await getCacheFilePath(subdirectory, filename)
          : await getFilePath(subdirectory, filename);

      final file = File(path);
      await file.writeAsBytes(bytes);

      _log.debug('Saved file: $path (${bytes.length} bytes)');
      return Result.success(file);
    } catch (e, s) {
      _log.error('Failed to save file: $subdirectory/$filename', e, s);
      return Result.failure(Failure.storage('Failed to save file', originalException: e));
    }
  }

  /// Saves a string to a file.
  Future<Result<File>> saveTextFile(
    String subdirectory,
    String filename,
    String content, {
    bool cache = false,
  }) async {
    try {
      final path = cache
          ? await getCacheFilePath(subdirectory, filename)
          : await getFilePath(subdirectory, filename);

      final file = File(path);
      await file.writeAsString(content);

      _log.debug('Saved text file: $path');
      return Result.success(file);
    } catch (e, s) {
      _log.error('Failed to save text file: $subdirectory/$filename', e, s);
      return Result.failure(Failure.storage('Failed to save file', originalException: e));
    }
  }

  /// Reads bytes from a file.
  Future<Result<Uint8List>> readFile(String subdirectory, String filename, {bool cache = false}) async {
    try {
      final path = cache
          ? await getCacheFilePath(subdirectory, filename)
          : await getFilePath(subdirectory, filename);

      final file = File(path);
      if (!await file.exists()) {
        return Result.failure(Failure.notFound('File not found: $subdirectory/$filename'));
      }

      final bytes = await file.readAsBytes();
      return Result.success(bytes);
    } catch (e, s) {
      _log.error('Failed to read file: $subdirectory/$filename', e, s);
      return Result.failure(Failure.storage('Failed to read file', originalException: e));
    }
  }

  /// Reads a string from a file.
  Future<Result<String>> readTextFile(String subdirectory, String filename, {bool cache = false}) async {
    try {
      final path = cache
          ? await getCacheFilePath(subdirectory, filename)
          : await getFilePath(subdirectory, filename);

      final file = File(path);
      if (!await file.exists()) {
        return Result.failure(Failure.notFound('File not found: $subdirectory/$filename'));
      }

      final content = await file.readAsString();
      return Result.success(content);
    } catch (e, s) {
      _log.error('Failed to read text file: $subdirectory/$filename', e, s);
      return Result.failure(Failure.storage('Failed to read file', originalException: e));
    }
  }

  /// Deletes a file.
  Future<Result<Unit>> deleteFile(String subdirectory, String filename, {bool cache = false}) async {
    try {
      final path = cache
          ? await getCacheFilePath(subdirectory, filename)
          : await getFilePath(subdirectory, filename);

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _log.debug('Deleted file: $path');
      }
      return Result.success(unit);
    } catch (e, s) {
      _log.error('Failed to delete file: $subdirectory/$filename', e, s);
      return Result.failure(Failure.storage('Failed to delete file', originalException: e));
    }
  }

  /// Checks if a file exists.
  Future<bool> fileExists(String subdirectory, String filename, {bool cache = false}) async {
    final path = cache
        ? await getCacheFilePath(subdirectory, filename)
        : await getFilePath(subdirectory, filename);
    return File(path).exists();
  }

  /// Gets the size of a file in bytes.
  Future<int?> getFileSize(String subdirectory, String filename, {bool cache = false}) async {
    final path = cache
        ? await getCacheFilePath(subdirectory, filename)
        : await getFilePath(subdirectory, filename);
    final file = File(path);
    if (!await file.exists()) return null;
    return file.length();
  }

  /// Lists files in a subdirectory.
  Future<List<FileSystemEntity>> listFiles(String subdirectory, {bool cache = false}) async {
    final dir = cache
        ? await getCacheSubdirectory(subdirectory)
        : await getDocumentsSubdirectory(subdirectory);
    return dir.listSync();
  }

  // ─────────────────────────────────────────────────────────────
  // CLEANUP
  // ─────────────────────────────────────────────────────────────

  /// Clears the cache directory.
  Future<Result<Unit>> clearCache() async {
    try {
      _ensureInitialized();
      if (await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create();
      }
      _log.info('Cleared cache directory');
      return Result.success(unit);
    } catch (e, s) {
      _log.error('Failed to clear cache', e, s);
      return Result.failure(Failure.storage('Failed to clear cache', originalException: e));
    }
  }

  /// Clears a specific subdirectory.
  Future<Result<Unit>> clearSubdirectory(String subdirectory, {bool cache = false}) async {
    try {
      final dir = cache
          ? await getCacheSubdirectory(subdirectory)
          : await getDocumentsSubdirectory(subdirectory);

      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create();
      }
      _log.info('Cleared subdirectory: $subdirectory');
      return Result.success(unit);
    } catch (e, s) {
      _log.error('Failed to clear subdirectory: $subdirectory', e, s);
      return Result.failure(Failure.storage('Failed to clear directory', originalException: e));
    }
  }

  /// Gets total size of a directory in bytes.
  Future<int> getDirectorySize(Directory directory) async {
    var size = 0;
    if (await directory.exists()) {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    }
    return size;
  }

  /// Gets the total cache size in bytes.
  Future<int> getCacheSize() async {
    _ensureInitialized();
    return getDirectorySize(_cacheDir!);
  }
}
