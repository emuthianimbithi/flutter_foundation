import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../models/date_range.dart';

class DateRangePicker extends StatefulWidget {
  final DateRange? initialRange;
  final ValueChanged<DateRange> onSelected;

  const DateRangePicker({super.key, this.initialRange, required this.onSelected});

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialRange?.start;
    _end = widget.initialRange?.end;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);

    return FoundationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FoundationButton(
            label: _start == null ? 'Pick start date' : 'Start: ${_fmt(_start!)}',
            variant: FoundationButtonVariant.secondary,
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _start ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (d != null) setState(() => _start = d);
            },
          ),
          SizedBox(height: tokens.space12),
          FoundationButton(
            label: _end == null ? 'Pick end date' : 'End: ${_fmt(_end!)}',
            variant: FoundationButtonVariant.secondary,
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _end ?? (_start ?? DateTime.now()),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (d != null) setState(() => _end = d);
            },
          ),
          SizedBox(height: tokens.space16),
          FoundationButton(
            label: 'Apply',
            onPressed: (_start != null && _end != null)
                ? () => widget.onSelected(DateRange(_start!, _end!))
                : null,
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}