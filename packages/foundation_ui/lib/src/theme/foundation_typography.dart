import 'package:flutter/material.dart';

@immutable
class FoundationTypography extends ThemeExtension<FoundationTypography> {
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle caption;

  const FoundationTypography({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.body,
    required this.bodyStrong,
    required this.caption,
  });

  factory FoundationTypography.defaults(TextTheme base) {
    return FoundationTypography(
      h1: (base.headlineLarge ?? const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)).copyWith(height: 1.15),
      h2: (base.headlineMedium ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)).copyWith(height: 1.2),
      h3: (base.titleLarge ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)).copyWith(height: 1.25),
      body: (base.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(height: 1.35),
      bodyStrong: (base.bodyMedium ?? const TextStyle(fontSize: 14)).copyWith(fontWeight: FontWeight.w600, height: 1.35),
      caption: (base.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(height: 1.25),
    );
  }

  @override
  FoundationTypography copyWith({
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? caption,
  }) {
    return FoundationTypography(
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      caption: caption ?? this.caption,
    );
  }

  @override
  FoundationTypography lerp(ThemeExtension<FoundationTypography>? other, double t) {
    if (other is! FoundationTypography) return this;
    return FoundationTypography(
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyStrong: TextStyle.lerp(bodyStrong, other.bodyStrong, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}