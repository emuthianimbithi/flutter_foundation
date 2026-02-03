import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';

void main() {
  runApp(const ProviderScope(child: UiCatalogApp()));
}

class UiCatalogApp extends StatelessWidget {
  const UiCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FoundationTheme.materialTheme(
      scheme: const FoundationColorScheme(
          seed: Color(0xFF0066FF), brightness: Brightness.light),
    );
    return MaterialApp(
      title: 'Foundation UI Catalog',
      theme: theme,
      home: const CatalogHomePage(),
    );
  }
}

class CatalogHomePage extends StatefulWidget {
  const CatalogHomePage({super.key});

  @override
  State<CatalogHomePage> createState() => _CatalogHomePageState();
}

class _CatalogHomePageState extends State<CatalogHomePage> {
  String _toastMessage = '';
  final _textController = TextEditingController(text: 'Hello foundation_ui');

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final type = FoundationTheme.typeOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('UI Catalog')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Buttons', style: type.h5),
          const SizedBox(height: 8),
          Wrap(
            spacing: tokens.spacingSm,
            runSpacing: tokens.spacingSm,
            children: [
              FoundationButton(label: 'Primary', onPressed: () {}),
              FoundationButton.secondary(label: 'Secondary', onPressed: () {}),
              FoundationButton.ghost(label: 'Ghost', onPressed: () {}),
              FoundationButton.danger(label: 'Danger', onPressed: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Text('Text Fields', style: type.h5),
          const SizedBox(height: 8),
          FoundationTextField(
            controller: _textController,
            labelText: 'Label',
            helperText: 'Helper text',
          ),
          const SizedBox(height: 24),
          Text('Cards', style: type.h5),
          const SizedBox(height: 8),
          FoundationCard(
            child: Padding(
              padding: EdgeInsets.all(tokens.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card title', style: type.h6),
                  const SizedBox(height: 8),
                  Text('Reusable card component with theme tokens',
                      style: type.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('States', style: type.h5),
          const SizedBox(height: 8),
          Row(
            children: const [
              FoundationLoader(),
              SizedBox(width: 12),
              EmptyState(title: 'Empty', message: 'Nothing here yet'),
            ],
          ),
          const SizedBox(height: 24),
          Text('Toasts', style: type.h5),
          const SizedBox(height: 8),
          FoundationButton(
            label: 'Show toast',
            onPressed: () {
              setState(() => _toastMessage = 'Action completed');
              FoundationToast.show(context, message: _toastMessage);
            },
          ),
        ],
      ),
    );
  }
}
