import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    const items = [
      _Item('UI Gallery', '/ui', Icons.dashboard_customize),
      _Item('Forms', '/forms', Icons.list_alt),
      _Item('Auth', '/auth', Icons.lock_open),
      _Item('Notifications', '/notifications', Icons.notifications_outlined),
      _Item('Routing Demo', '/routing', Icons.alt_route),
      _Item('Permissions', '/permissions', Icons.verified_user_outlined),
      _Item('Analytics', '/analytics', Icons.analytics_outlined),
      _Item('Security', '/security', Icons.security),
      _Item('i18n', '/i18n', Icons.language),
      _Item('Media', '/media', Icons.perm_media),
      _Item('Device', '/device', Icons.memory),
      _Item('Maps', '/maps', Icons.map),
      _Item('Calendar', '/calendar', Icons.calendar_month),
      _Item('Chat', '/chat', Icons.chat_bubble_outline),
      _Item('Payments', '/payments', Icons.payments_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Foundation Showcase')),
      body: ListView.separated(
        padding: EdgeInsets.all(tokens.space16),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: tokens.space12),
        itemBuilder: (context, i) {
          final it = items[i];
          return InkWell(
            onTap: () => context.push(it.route),
            child: FoundationCard(
              key: ValueKey('home_item_${it.route}'),
              child: Row(
                children: [
                  Icon(it.icon),
                  SizedBox(width: tokens.space12),
                  Expanded(child: Text(it.title)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Item {
  final String title;
  final String route;
  final IconData icon;
  const _Item(this.title, this.route, this.icon);
}
