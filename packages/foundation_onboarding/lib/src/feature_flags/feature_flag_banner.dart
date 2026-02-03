import 'package:flutter/material.dart';

class FeatureFlagBanner extends StatelessWidget {
  final String label;
  final Widget child;

  const FeatureFlagBanner(
      {super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Banner(
      message: label,
      location: BannerLocation.topEnd,
      child: child,
    );
  }
}
