import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_providers.dart';

class EventSchedulerSheet extends ConsumerStatefulWidget {
  const EventSchedulerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const EventSchedulerSheet(),
    );
  }

  @override
  ConsumerState<EventSchedulerSheet> createState() =>
      _EventSchedulerSheetState();
}

class _EventSchedulerSheetState extends ConsumerState<EventSchedulerSheet> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final selected = ref.watch(selectedDateProvider);

    _start ??= DateTime(selected.year, selected.month, selected.day, 9, 0);
    _end ??= DateTime(selected.year, selected.month, selected.day, 10, 0);

    return Padding(
      padding: EdgeInsets.only(
        left: tokens.space16,
        right: tokens.space16,
        top: tokens.space16,
        bottom: tokens.space16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New event'),
          SizedBox(height: tokens.space12),
          FoundationTextField(
            label: 'Title',
            onChanged: (v) => _title.text = v,
          ),
          SizedBox(height: tokens.space12),
          FoundationTextField(
            label: 'Description',
            onChanged: (v) => _desc.text = v,
          ),
          SizedBox(height: tokens.space12),
          Row(
            children: [
              Expanded(
                child: FoundationButton(
                  label: 'Start: ${_hhmm(_start!)}',
                  variant: FoundationButtonVariant.secondary,
                  onPressed: () async {
                    final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_start!));
                    if (t != null)
                      setState(() => _start = DateTime(selected.year,
                          selected.month, selected.day, t.hour, t.minute));
                  },
                ),
              ),
              SizedBox(width: tokens.space12),
              Expanded(
                child: FoundationButton(
                  label: 'End: ${_hhmm(_end!)}',
                  variant: FoundationButtonVariant.secondary,
                  onPressed: () async {
                    final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_end!));
                    if (t != null)
                      setState(() => _end = DateTime(selected.year,
                          selected.month, selected.day, t.hour, t.minute));
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space16),
          FoundationButton(
            label: 'Save',
            onPressed: () {
              final e = CalendarEvent(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                start: _start!,
                end: _end!,
                title: _title.text.isEmpty ? 'Untitled' : _title.text,
                description: _desc.text.isEmpty ? null : _desc.text,
              );
              final current = ref.read(eventsProvider);
              ref.read(eventsProvider.notifier).state = [...current, e];
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
