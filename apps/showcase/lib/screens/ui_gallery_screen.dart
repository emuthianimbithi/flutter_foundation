import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

class UiGalleryScreen extends StatelessWidget {
  const UiGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('UI Gallery')),
      body: ListView(
        padding: EdgeInsets.all(tokens.space16),
        children: [
          Text('Buttons', style: FoundationTheme.typeOf(context).h3),
          SizedBox(height: tokens.space12),
          Wrap(
            spacing: tokens.space12,
            runSpacing: tokens.space12,
            children: const [
              _Btn('Primary', FoundationButtonVariant.primary),
              _Btn('Secondary', FoundationButtonVariant.secondary),
              _Btn('Subtle', FoundationButtonVariant.subtle),
            ],
          ),
          SizedBox(height: tokens.space24),
          Text('Cards', style: FoundationTheme.typeOf(context).h3),
          SizedBox(height: tokens.space12),
          const FoundationCard(
            child: Text('A basic FoundationCard'),
          ),
          SizedBox(height: tokens.space12),
          const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Empty state',
            description: 'Use this for empty lists, errors, and onboarding moments.',
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final FoundationButtonVariant variant;
  const _Btn(this.label, this.variant);

  @override
  Widget build(BuildContext context) {
    return FoundationButton(
      label: label,
      variant: variant,
      onPressed: () {},
    );
  }
}
