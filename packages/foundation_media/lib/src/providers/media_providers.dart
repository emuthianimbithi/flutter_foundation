import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cache/media_cache.dart';

final mediaCacheProvider = Provider<MediaCache>((ref) => MediaCache());
