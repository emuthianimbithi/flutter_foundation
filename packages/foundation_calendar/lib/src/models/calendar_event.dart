class CalendarEvent {
  final String id;
  final DateTime start;
  final DateTime end;
  final String title;
  final String? description;

  const CalendarEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
    this.description,
  });
}