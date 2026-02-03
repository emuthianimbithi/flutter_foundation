import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_storage/foundation_storage.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => StorageInitializer.reset());

  test('db size is reported after writing rows', () async {
    final tempDir = await Directory.systemTemp.createTemp('storage_test_db');
    final dbPath = p.join(tempDir.path, 'test.db');

    final db = AppDatabase.forTesting(NativeDatabase(File(dbPath)));
    await StorageInitializer.initialize(
      database: db,
      fileStorage:
          FileStorage(documentsDirOverride: tempDir, cacheDirOverride: tempDir),
      options: StorageOptions(dbPathOverride: dbPath),
    );

    await db.setCachedValue('key', 'value');

    final size = await StorageInitializer.getCacheSize();
    expect(size.dbSizeBytes, greaterThan(0));
  });

  test('file cache size sums files', () async {
    final tempDir = await Directory.systemTemp.createTemp('storage_test_cache');
    final cacheDir = Directory(p.join(tempDir.path, 'cache'))
      ..createSync(recursive: true);

    final dbPath = p.join(tempDir.path, 'test.db');
    final db = AppDatabase.forTesting(NativeDatabase(File(dbPath)));
    final fileStorage =
        FileStorage(cacheDirOverride: cacheDir, documentsDirOverride: tempDir);
    await StorageInitializer.initialize(
      database: db,
      fileStorage: fileStorage,
      options:
          StorageOptions(cacheDirOverride: cacheDir, dbPathOverride: dbPath),
    );

    final file = File(p.join(cacheDir.path, 'a.bin'))
      ..writeAsBytesSync(Uint8List(10));
    expect(await file.exists(), isTrue);

    final size = await StorageInitializer.getCacheSize();
    expect(size.fileCacheBytes, greaterThanOrEqualTo(10));
  });

  test('missing cache dir returns zero', () async {
    final tempDir =
        await Directory.systemTemp.createTemp('storage_test_missing');
    final cacheDir = Directory(p.join(tempDir.path, 'cache_missing'));
    final dbPath = p.join(tempDir.path, 'test.db');
    final db = AppDatabase.forTesting(NativeDatabase(File(dbPath)));
    final fileStorage =
        FileStorage(cacheDirOverride: cacheDir, documentsDirOverride: tempDir);

    await StorageInitializer.initialize(
      database: db,
      fileStorage: fileStorage,
      options:
          StorageOptions(cacheDirOverride: cacheDir, dbPathOverride: dbPath),
    );

    final size = await StorageInitializer.getCacheSize();
    expect(size.totalBytes, equals(0));
  });
}
