import 'package:flutter/material.dart';

class FoundationTypography {
  final TextTheme textTheme;

  const FoundationTypography(this.textTheme);

  static FoundationTypography defaultTypography() {
    return FoundationTypography(
      Typography.material2021().black,
    );
  }
}