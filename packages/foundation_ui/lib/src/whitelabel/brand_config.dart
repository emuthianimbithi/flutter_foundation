import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../theme/foundation_color_scheme.dart';
import '../theme/foundation_tokens.dart';

class BrandConfig extends Equatable {
  final String name;
  final Color seedColor;
  final Brightness brightness;
  final FoundationTokens tokens;
  final String? logoAsset;

  const BrandConfig({
    required this.name,
    required this.seedColor,
    this.brightness = Brightness.light,
    this.tokens = const FoundationTokens(),
    this.logoAsset,
  });

  FoundationColorScheme get scheme =>
      FoundationColorScheme(seed: seedColor, brightness: brightness);

  @override
  List<Object?> get props => [name, seedColor, brightness, tokens, logoAsset];
}
