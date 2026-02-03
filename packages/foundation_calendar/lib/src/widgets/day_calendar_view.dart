import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../providers/calendar_providers.dart';
import '../utils/date_utils.dart';

class DayCalendarView extends ConsumerWidget {
  const DayCalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider).dateOnly;
    final events = ref.watch(eventsProvider)
        .where((e) => e.start.dateOnly == selected)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final tokens = FoundationTheme.tokensOf(context);
    final t = FoundationTheme.typeOf(context);

    return Padding(
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Events', style: t.h3),
          SizedBox(height: tokens.space12),
          if (events.isEmpty)
            const EmptyState(
              icon: Icons.event_note_outlined,
              title: 'No events',
              description: 'Add an event to see it here.',
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: events.length,
                separatorBuilder: (_, __) => SizedBox(height: tokens.space12),
                itemBuilder: (context, i) {
                  final e = events[i];
                  return FoundationCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title, style: t.bodyStrong),
                        SizedBox(height: tokens.space4),
                        Text(
                          '${_hhmm(e.start)} - ${_hhmm(e.end)}',
                          style: t.caption,
                        ),
                        if (e.description != null) ...[
                          SizedBox(height: tokens.space8),
                          Text(e.description!, style: t.body),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _hhmm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
