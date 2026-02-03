import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:foundation_ui/foundation_ui.dart';
import 'package:foundation_payments/foundation_payments.dart';
import 'fakes/fake_payment_service.dart';
import 'screens/home_screen.dart';
import 'screens/ui_gallery_screen.dart';
import 'screens/forms_screen.dart';
import 'screens/maps_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/payments_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/routing_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/security_screen.dart';
import 'screens/i18n_screen.dart';
import 'screens/media_screen.dart';
import 'screens/device_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/ui', builder: (_, __) => const UiGalleryScreen()),
      GoRoute(path: '/forms', builder: (_, __) => const FormsScreen()),
      GoRoute(path: '/maps', builder: (_, __) => const MapsScreen()),
      GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
      GoRoute(path: '/payments', builder: (_, __) => const PaymentsScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/routing', builder: (_, __) => const RoutingDemoScreen()),
      GoRoute(
        path: '/routing/detail/:id',
        builder: (_, state) => RoutingDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(path: '/permissions', builder: (_, __) => const PermissionsScreen()),
      GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
      GoRoute(path: '/security', builder: (_, __) => const SecurityScreen()),
      GoRoute(path: '/i18n', builder: (_, __) => const I18nScreen()),
      GoRoute(path: '/media', builder: (_, __) => const MediaScreen()),
      GoRoute(path: '/device', builder: (_, __) => const DeviceScreen()),
    ],
  );
});

void main() {
  runApp(
    ProviderScope(
      overrides: [
        paymentServiceProvider.overrideWithValue(FakePaymentService()),
      ],
      child: const ShowcaseApp(),
    ),
  );
}

class ShowcaseApp extends ConsumerWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final theme = ref.watch(themeDataProvider);
    return MaterialApp.router(
      title: 'Foundation Showcase',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
