import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../providers/calendar_providers.dart';
import '../utils/date_utils.dart';

class MonthCalendarView extends ConsumerWidget {
  final int weekStartsOn;

  const MonthCalendarView({super.key, this.weekStartsOn = DateTime.monday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider).dateOnly;
    final events = ref.watch(eventsProvider);
    final tokens = FoundationTheme.tokensOf(context);
    final t = FoundationTheme.typeOf(context);

    final firstOfMonth = DateTime(selected.year, selected.month, 1);
    final start = firstOfMonth.startOfWeek(weekStartsOn: weekStartsOn);
    final days = List.generate(42, (i) => start.addDays(i));

    int countEvents(DateTime day) {
      final d = day.dateOnly;
      return events.where((e) => e.start.dateOnly == d).length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(tokens.space16),
          child: Text(
            '${_monthName(selected.month)} ${selected.year}',
            style: t.h3,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(tokens.space12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, i) {
              final day = days[i];
              final isCurrentMonth = day.month == selected.month;
              final isSelected = day.dateOnly == selected;

              final n = countEvents(day);

              return GestureDetector(
                onTap: () => ref.read(selectedDateProvider.notifier).state = day,
                child: Container(
                  margin: EdgeInsets.all(tokens.space4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: t.caption.copyWith(
                          color: isCurrentMonth
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      if (n > 0) ...[
                        SizedBox(height: tokens.space4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const names = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return names[m - 1];
  }
}