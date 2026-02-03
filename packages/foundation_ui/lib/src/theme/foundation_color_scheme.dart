import 'package:flutter/material.dart';

class FoundationColorScheme {
  final Color seed;
  final Brightness brightness;

  const FoundationColorScheme({required this.seed, required this.brightness});

  ColorScheme toMaterial() => ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
}