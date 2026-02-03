import 'package:flutter/material.dart';
import '../../theme/foundation_theme.dart';

enum FoundationButtonVariant { primary, secondary, subtle, destructive }

class FoundationButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final FoundationButtonVariant variant;
  final IconData? icon;

  const FoundationButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = FoundationButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final cs = Theme.of(context).colorScheme;

    final (bg, fg, border) = switch (variant) {
      FoundationButtonVariant.primary => (cs.primary, cs.onPrimary, Colors.transparent),
      FoundationButtonVariant.secondary => (cs.secondaryContainer, cs.onSecondaryContainer, Colors.transparent),
      FoundationButtonVariant.subtle => (cs.surface, cs.onSurface, cs.outlineVariant),
      FoundationButtonVariant.destructive => (cs.error, cs.onError, Colors.transparent),
    };

    final child = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: fg), SizedBox(width: tokens.space8)],
              Text(label),
            ],
          );

    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radiusMd)),
          padding: EdgeInsets.symmetric(horizontal: tokens.space16),
        ),
        child: child,
      ),
    );
  }
}