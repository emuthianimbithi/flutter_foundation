import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:foundation_core/foundation_core.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File system storage utilities.
///
/// Provides convenient access to app directories and file operations.
/// Supports optional AES encryption (CBC) for cached files when an
/// encryption key is supplied.
class FileStorage {
  final AppLogger _log = AppLogger('FileStorage');
  final String? _cacheDirName;
  final String? _encryptionKey;
  final Directory? _cacheDirOverride;
  final Directory? _documentsDirOverride;
  encrypt.Encrypter? _encrypter;

  Directory? _appDocumentsDir;
  Directory? _appSupportDir;
  Directory? _tempDir;
  Directory? _cacheDir;

  FileStorage({
    String? cacheDirName,
    String? encryptionKey,
    Directory? cacheDirOverride,
    Directory? documentsDirOverride,
  })  : _cacheDirName = cacheDirName,
        _encryptionKey = encryptionKey,
        _cacheDirOverride = cacheDirOverride,
        _documentsDirOverride = documentsDirOverride;

  /// Whether the storage has been initialized.
  bool get isInitialized => _appDocumentsDir != null;

  /// Initializes the file storage.
  Future<void> init() async {
    if (_appDocumentsDir != null) return;

    _appDocumentsDir =
        _documentsDirOverride ?? await getApplicationDocumentsDirectory();
    _appSupportDir = await getApplicationSupportDirectory();
    _tempDir = await getTemporaryDirectory();
    _cacheDir = _cacheDirOverride ?? await getApplicationCacheDirectory();

    if (_cacheDirName != null && _cacheDirName!.isNotEmpty) {
      _cacheDir = Directory(p.join(_cacheDir!.path, _cacheDirName!));
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    }

    if (_encryptionKey != null && _encryptionKey!.isNotEmpty) {
      _prepareEncrypter(_encryptionKey!);
    }

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

  Directory get documentsDirectory {
    _ensureInitialized();
    return _appDocumentsDir!;
  }

  Directory get supportDirectory {
    _ensureInitialized();
    return _appSupportDir!;
  }

  Directory get tempDirectory {
    _ensureInitialized();
    return _tempDir!;
  }

  Directory get cacheDirectory {
    _ensureInitialized();
    return _cacheDir!;
  }

  Future<Directory> getDocumentsSubdirectory(String name) async {
    _ensureInitialized();
    final dir = Directory(p.join(_appDocumentsDir!.path, name));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

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

  Future<String> getFilePath(String subdirectory, String filename) async {
    final dir = await getDocumentsSubdirectory(subdirectory);
    return p.join(dir.path, filename);
  }

  Future<String> getCacheFilePath(String subdirectory, String filename) async {
    final dir = await getCacheSubdirectory(subdirectory);
    return p.join(dir.path, filename);
  }

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
      await file.writeAsBytes(_encryptIfNeeded(bytes));
      _log.debug('Saved file: $path (${bytes.length} bytes)');
      return Result.success(file);
    } catch (e, s) {
      _log.error('Failed to save file: $subdirectory/$filename', e, s);
      return Result.failure(
          Failure.storage('Failed to save file', originalException: e));
    }
  }

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
      final data = _encryptIfNeeded(Uint8List.fromList(utf8.encode(content)));
      await file.writeAsBytes(data);
      _log.debug('Saved text file: $path');
      return Result.success(file);
    } catch (e, s) {
      _log.error('Failed to save text file: $subdirectory/$filename', e, s);
      return Result.failure(
          Failure.storage('Failed to save file', originalException: e));
    }
  }

  Future<Result<Uint8List>> readFile(String subdirectory, String filename,
      {bool cache = false}) async {
    try {
      final path = cache
          ? await getCacheFilePath(subdirectory, filename)
          : await getFilePath(subdirectory, filename);
      final file = File(path);
      if (!await file.exists()) {
        return Result.failure(
            Failure.notFound('File not found: $subdirectory/$filename'));
      }
      final bytes = await file.readAsBytes();
      return Result.success(_decryptIfNeeded(bytes));
    } catch (e, s) {
      _log.error('Failed to read file: $subdirectory/$filename', e, s);
      return Result.failure(
          Failure.storage('Failed to read file', originalException: e));
    }
  }

  Future<Result<String>> readTextFile(String subdirectory, String filename,
      {bool cache = false}) async {
    try {
      final path = cache
          ? await getCacheFilePath(subdirectory, filename)
          : await getFilePath(subdirectory, filename);
      final file = File(path);
      if (!await file.exists()) {
        return Result.failure(
            Failure.notFound('File not found: $subdirectory/$filename'));
      }
      final bytes = await file.readAsBytes();
      final decoded = utf8.decode(_decryptIfNeeded(bytes));
      return Result.success(decoded);
    } catch (e, s) {
      _log.error('Failed to read text file: $subdirectory/$filename', e, s);
      return Result.failure(
          Failure.storage('Failed to read file', originalException: e));
    }
  }

  Future<Result<Unit>> deleteFile(String subdirectory, String filename,
      {bool cache = false}) async {
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
      return Result.failure(
          Failure.storage('Failed to delete file', originalException: e));
    }
  }

  Future<bool> fileExists(String subdirectory, String filename,
      {bool cache = false}) async {
    final path = cache
        ? await getCacheFilePath(subdirectory, filename)
        : await getFilePath(subdirectory, filename);
    return File(path).exists();
  }

  Future<int?> getFileSize(String subdirectory, String filename,
      {bool cache = false}) async {
    final path = cache
        ? await getCacheFilePath(subdirectory, filename)
        : await getFilePath(subdirectory, filename);
    final file = File(path);
    if (!await file.exists()) return null;
    return file.length();
  }

  Future<List<FileSystemEntity>> listFiles(String subdirectory,
      {bool cache = false}) async {
    final dir = cache
        ? await getCacheSubdirectory(subdirectory)
        : await getDocumentsSubdirectory(subdirectory);
    return dir.listSync();
  }

  // ─────────────────────────────────────────────────────────────
  // CLEANUP
  // ─────────────────────────────────────────────────────────────

  Future<Result<Unit>> clearCache() async {
    try {
      _ensureInitialized();
      if (await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create(recursive: true);
      }
      _log.info('Cleared cache directory');
      return Result.success(unit);
    } catch (e, s) {
      _log.error('Failed to clear cache', e, s);
      return Result.failure(
          Failure.storage('Failed to clear cache', originalException: e));
    }
  }

  Future<Result<Unit>> clearSubdirectory(String subdirectory,
      {bool cache = false}) async {
    try {
      final dir = cache
          ? await getCacheSubdirectory(subdirectory)
          : await getDocumentsSubdirectory(subdirectory);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
      _log.info('Cleared subdirectory: $subdirectory');
      return Result.success(unit);
    } catch (e, s) {
      _log.error('Failed to clear subdirectory: $subdirectory', e, s);
      return Result.failure(
          Failure.storage('Failed to clear directory', originalException: e));
    }
  }

  Future<int> getDirectorySize(Directory directory) async {
    var size = 0;
    if (await directory.exists()) {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final base = p.basename(entity.path);
          if (_excludedNames.contains(base)) continue;
          size += await entity.length();
        }
      }
    }
    return size;
  }

  Future<int> getCacheSize() async {
    _ensureInitialized();
    return getDirectorySize(_cacheDir!);
  }

  // ─────────────────────────────────────────────────────────────
  // ENCRYPTION HELPERS
  // ─────────────────────────────────────────────────────────────

  static const List<String> _excludedNames = ['.DS_Store'];

  void _prepareEncrypter(String keyString) {
    try {
      final normalized = _normalizeKey(keyString);
      final key = encrypt.Key(normalized);
      _encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    } catch (e, s) {
      _log.error(
          'Failed to prepare encrypter; falling back to plaintext.', e, s);
      _encrypter = null;
    }
  }

  Uint8List _normalizeKey(String keyString) {
    try {
      final decoded = base64.decode(keyString);
      return _padKey(decoded);
    } catch (_) {
      return _padKey(utf8.encode(keyString));
    }
  }

  Uint8List _padKey(List<int> bytes) {
    final out = List<int>.filled(32, 0);
    final copyLen = bytes.length >= 32 ? 32 : bytes.length;
    out.setRange(0, copyLen, bytes);
    return Uint8List.fromList(out);
  }

  Uint8List _encryptIfNeeded(Uint8List bytes) {
    if (_encrypter == null) return bytes;
    try {
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypted = _encrypter!.encryptBytes(bytes, iv: iv);
      return Uint8List.fromList(iv.bytes + encrypted.bytes);
    } catch (e, s) {
      _log.error('Encryption failed, writing plaintext', e, s);
      return bytes;
    }
  }

  Uint8List _decryptIfNeeded(Uint8List bytes) {
    if (_encrypter == null) return bytes;
    if (bytes.length <= 16) return bytes;
    try {
      final iv = encrypt.IV(bytes.sublist(0, 16));
      final cipher = encrypt.Encrypted(bytes.sublist(16));
      final decrypted = _encrypter!.decryptBytes(cipher, iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (e, s) {
      _log.error('Decryption failed, returning raw bytes', e, s);
      return bytes;
    }
  }
}
