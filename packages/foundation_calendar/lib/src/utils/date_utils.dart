extension FoundationDateUtils on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  DateTime addDays(int d) => add(Duration(days: d));

  DateTime startOfWeek({int weekStartsOn = DateTime.monday}) {
    final diff = (weekday - weekStartsOn) % 7;
    return dateOnly.subtract(Duration(days: diff));
  }
}