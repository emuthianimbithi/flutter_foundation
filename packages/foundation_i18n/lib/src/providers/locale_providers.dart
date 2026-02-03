import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale?>((ref) => null);

final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return const [
    Locale('en'),
  ];
});
