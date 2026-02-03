import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MediaCache {
  Future<Directory> getCacheDir() async {
    final dir = await getTemporaryDirectory();
    final cache = Directory('${dir.path}/foundation_media_cache');
    if (!await cache.exists()) {
      await cache.create(recursive: true);
    }
    return cache;
  }

  Future<void> clear() async {
    final cache = await getCacheDir();
    if (await cache.exists()) {
      await cache.delete(recursive: true);
    }
  }
}
