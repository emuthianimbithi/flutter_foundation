import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../providers/calendar_providers.dart';
import '../utils/date_utils.dart';

class WeekCalendarView extends ConsumerWidget {
  final int weekStartsOn;
  const WeekCalendarView({super.key, this.weekStartsOn = DateTime.monday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider).dateOnly;
    final start = selected.startOfWeek(weekStartsOn: weekStartsOn);
    final days = List.generate(7, (i) => start.addDays(i));
    final tokens = FoundationTheme.tokensOf(context);
    final t = FoundationTheme.typeOf(context);

    return ListView.separated(
      padding: EdgeInsets.all(tokens.space16),
      itemCount: days.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.space12),
      itemBuilder: (context, i) {
        final day = days[i];
        final isSelected = day.dateOnly == selected;
        return GestureDetector(
          onTap: () => ref.read(selectedDateProvider.notifier).state = day,
          child: FoundationCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_weekdayName(day.weekday)} • ${day.day}/${day.month}',
                    style: isSelected ? t.bodyStrong : t.body,
                  ),
                ),
                if (isSelected) const Icon(Icons.check),
              ],
            ),
          ),
        );
      },
    );
  }

  String _weekdayName(int w) {
    const names = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return names[w - 1];
  }
}