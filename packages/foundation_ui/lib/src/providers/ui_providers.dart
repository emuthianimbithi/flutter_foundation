import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../whitelabel/brand_config.dart';
import '../theme/foundation_theme.dart';

final brandConfigProvider = StateProvider<BrandConfig>((ref) {
  // Default brand; override in app.
  return const BrandConfig(name: 'Foundation', seedColor: Color(0xFF6750A4));
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final brand = ref.watch(brandConfigProvider);
  return FoundationTheme.materialTheme(scheme: brand.scheme, tokens: brand.tokens);
});