import 'package:flutter/material.dart';
import 'foundation_tokens.dart';
import 'foundation_typography.dart';
import 'foundation_color_scheme.dart';

class FoundationTheme {
  static ThemeData materialTheme({
    required FoundationColorScheme scheme,
    FoundationTokens tokens = const FoundationTokens(),
  }) {
    final colorScheme = scheme.toMaterial();

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: scheme.brightness,
      visualDensity: VisualDensity.standard,
    );

    final typography = FoundationTypography.defaults(base.textTheme);

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[tokens, typography],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: tokens.elevationSm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radiusMd)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(tokens.radiusMd)),
      ),
    );
  }

  static FoundationTokens tokensOf(BuildContext context) =>
      Theme.of(context).extension<FoundationTokens>() ?? const FoundationTokens();

  static FoundationTypography typeOf(BuildContext context) =>
      Theme.of(context).extension<FoundationTypography>() ??
      FoundationTypography.defaults(Theme.of(context).textTheme);
}
