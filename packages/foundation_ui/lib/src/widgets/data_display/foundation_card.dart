import 'package:flutter/material.dart';
import '../../theme/foundation_theme.dart';

class FoundationCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const FoundationCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return Card(
      child: Padding(
        padding: padding ?? EdgeInsets.all(tokens.space16),
        child: child,
      ),
    );
  }
}
