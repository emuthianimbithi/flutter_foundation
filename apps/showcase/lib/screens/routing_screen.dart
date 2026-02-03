import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:foundation_ui/foundation_ui.dart';

class RoutingDemoScreen extends StatelessWidget {
  const RoutingDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Routing')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GoRouter deep-link demo'),
            SizedBox(height: tokens.space12),
            FoundationButton(
              label: 'Open detail/42',
              onPressed: () => context.push('/routing/detail/42'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoutingDetailScreen extends StatelessWidget {
  final String id;
  const RoutingDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Routing Detail')),
      body: Center(child: Text('Opened detail id: $id')),
    );
  }
}
