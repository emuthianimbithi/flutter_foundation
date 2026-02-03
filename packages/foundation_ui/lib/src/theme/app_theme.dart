import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'typography.dart';

class FoundationAppTheme {
  final FoundationColorScheme colors;
  final FoundationTypography typography;

  const FoundationAppTheme({
    required this.colors,
    required this.typography,
  });

  ThemeData toThemeData() {
    return ThemeData(
      colorScheme: colors.toMaterial(),
      textTheme: typography.textTheme,
      useMaterial3: true,
    );
  }
}