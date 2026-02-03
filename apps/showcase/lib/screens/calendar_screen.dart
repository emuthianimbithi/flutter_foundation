import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import 'package:foundation_calendar/foundation_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FoundationTheme.tokensOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => EventSchedulerSheet.show(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(tokens.space8),
        child: const MonthCalendarView(),
      ),
    );
  }
}
