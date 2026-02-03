import 'package:flutter/material.dart';
import '../../theme/foundation_theme.dart';
import '../buttons/foundation_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = FoundationTheme.typeOf(context);
    final tokens = FoundationTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            SizedBox(height: tokens.space16),
            Text(title, style: t.h3, textAlign: TextAlign.center),
            SizedBox(height: tokens.space8),
            Text(description, style: t.body, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: tokens.space16),
              FoundationButton(label: actionLabel!, onPressed: onAction, variant: FoundationButtonVariant.secondary),
            ],
          ],
        ),
      ),
    );
  }
}