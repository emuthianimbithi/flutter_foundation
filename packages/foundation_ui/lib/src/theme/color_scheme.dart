import 'package:flutter/material.dart';

class FoundationColorScheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;

  const FoundationColorScheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
  });

  ColorScheme toMaterial() {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      background: background,
      onBackground: Colors.black,
      surface: surface,
      onSurface: Colors.black,
    );
  }
}