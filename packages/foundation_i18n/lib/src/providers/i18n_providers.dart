import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../locale/locale_service.dart';

final localeServiceProvider = Provider<LocaleService>((ref) => LocaleService());

final localeProvider = StateProvider<Locale?>((ref) {
  return ref.watch(localeServiceProvider).locale;
});