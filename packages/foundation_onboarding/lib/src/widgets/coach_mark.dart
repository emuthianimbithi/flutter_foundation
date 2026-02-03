import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

class CoachMark extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDismiss;

  const CoachMark({
    super.key,
    required this.title,
    required this.description,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final t = FoundationTheme.typeOf(context);
    final tokens = FoundationTheme.tokensOf(context);

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: FoundationCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.h3),
                SizedBox(height: tokens.space8),
                Text(description, style: t.body),
                SizedBox(height: tokens.space16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FoundationButton(
                    label: 'Got it',
                    onPressed: onDismiss,
                    variant: FoundationButtonVariant.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
