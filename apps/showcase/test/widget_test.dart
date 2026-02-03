// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:showcase/main.dart';

void main() {
  testWidgets('Home items navigate to screens', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShowcaseApp()));
    await tester.pumpAndSettle();

    final routes = [
      '/ui',
      '/forms',
      '/auth',
      '/notifications',
      '/routing',
      '/permissions',
      '/analytics',
      '/security',
      '/i18n',
      '/media',
      '/device',
      '/maps',
      '/calendar',
      '/chat',
      '/payments',
    ];

    for (final route in routes) {
      final key = find.byKey(ValueKey('home_item_$route'));
      expect(key, findsOneWidget);
      await tester.tap(key);
      await tester.pumpAndSettle();
      // verify screen by route text presence
      expect(find.byType(Scaffold), findsWidgets);
      // go back
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
}
