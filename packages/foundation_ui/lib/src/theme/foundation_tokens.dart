import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

@immutable
class FoundationTokens extends ThemeExtension<FoundationTokens> {
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  final double space2;
  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space24;
  final double space32;

  final double elevationSm;
  final double elevationMd;

  const FoundationTokens({
    this.radiusSm = 8,
    this.radiusMd = 12,
    this.radiusLg = 20,
    this.space2 = 2,
    this.space4 = 4,
    this.space8 = 8,
    this.space12 = 12,
    this.space16 = 16,
    this.space24 = 24,
    this.space32 = 32,
    this.elevationSm = 1,
    this.elevationMd = 3,
  });

  @override
  FoundationTokens copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? space2,
    double? space4,
    double? space8,
    double? space12,
    double? space16,
    double? space24,
    double? space32,
    double? elevationSm,
    double? elevationMd,
  }) {
    return FoundationTokens(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      space2: space2 ?? this.space2,
      space4: space4 ?? this.space4,
      space8: space8 ?? this.space8,
      space12: space12 ?? this.space12,
      space16: space16 ?? this.space16,
      space24: space24 ?? this.space24,
      space32: space32 ?? this.space32,
      elevationSm: elevationSm ?? this.elevationSm,
      elevationMd: elevationMd ?? this.elevationMd,
    );
  }

  @override
  FoundationTokens lerp(ThemeExtension<FoundationTokens>? other, double t) {
    if (other is! FoundationTokens) return this;
    return FoundationTokens(
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      space2: lerpDouble(space2, other.space2, t)!,
      space4: lerpDouble(space4, other.space4, t)!,
      space8: lerpDouble(space8, other.space8, t)!,
      space12: lerpDouble(space12, other.space12, t)!,
      space16: lerpDouble(space16, other.space16, t)!,
      space24: lerpDouble(space24, other.space24, t)!,
      space32: lerpDouble(space32, other.space32, t)!,
      elevationSm: lerpDouble(elevationSm, other.elevationSm, t)!,
      elevationMd: lerpDouble(elevationMd, other.elevationMd, t)!,
    );
  }
}
