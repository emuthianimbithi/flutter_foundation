import 'package:intl/intl.dart';

/// Extension methods for [DateTime].
extension DateTimeExtensions on DateTime {
  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Whether this date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Whether this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Whether this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Whether this date is on a weekend.
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Whether this date is on a weekday.
  bool get isWeekday => !isWeekend;

  /// Returns the date only (time set to midnight).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Returns the time only as a Duration from midnight.
  Duration get timeOnly =>
      Duration(hours: hour, minutes: minute, seconds: second);

  /// Returns the start of this day (midnight).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the end of this day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns the start of this week (Monday).
  DateTime get startOfWeek {
    final diff = weekday - DateTime.monday;
    return DateTime(year, month, day - diff);
  }

  /// Returns the end of this week (Sunday 23:59:59.999).
  DateTime get endOfWeek {
    final diff = DateTime.sunday - weekday;
    return DateTime(year, month, day + diff, 23, 59, 59, 999);
  }

  /// Returns the start of this month.
  DateTime get startOfMonth => DateTime(year, month);

  /// Returns the end of this month.
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Returns the start of this year.
  DateTime get startOfYear => DateTime(year);

  /// Returns the end of this year.
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  /// Returns the number of days in this month.
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Returns the day of the year (1-366).
  int get dayOfYear => difference(DateTime(year)).inDays + 1;

  /// Returns the week of the year (1-53).
  int get weekOfYear {
    final firstDayOfYear = DateTime(year);
    final daysSinceFirstDay = difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).floor() + 1;
  }

  /// Returns the quarter (1-4).
  int get quarter => ((month - 1) / 3).floor() + 1;

  /// Adds years to this date.
  DateTime addYears(int years) => DateTime(
        year + years,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  /// Adds months to this date.
  DateTime addMonths(int months) {
    var newYear = year;
    var newMonth = month + months;
    while (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    while (newMonth < 1) {
      newYear--;
      newMonth += 12;
    }
    final maxDay = DateTime(newYear, newMonth + 1, 0).day;
    return DateTime(
      newYear,
      newMonth,
      day > maxDay ? maxDay : day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// Adds days to this date.
  DateTime addDays(int days) => add(Duration(days: days));

  /// Adds hours to this date.
  DateTime addHours(int hours) => add(Duration(hours: hours));

  /// Adds minutes to this date.
  DateTime addMinutes(int minutes) => add(Duration(minutes: minutes));

  /// Returns whether this date is the same day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Returns whether this date is the same month as [other].
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// Returns whether this date is the same year as [other].
  bool isSameYear(DateTime other) => year == other.year;

  /// Returns whether this date is between [start] and [end] (inclusive).
  bool isBetween(DateTime start, DateTime end) =>
      (isAfter(start) || isAtSameMomentAs(start)) &&
      (isBefore(end) || isAtSameMomentAs(end));

  /// Returns the age in years from this date to now.
  int get age {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Returns a human-readable relative time string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.isNegative) {
      return 'in the future';
    }

    if (diff.inSeconds < 60) {
      return 'just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ago';
    }
    if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}mo ago';
    }
    return '${(diff.inDays / 365).floor()}y ago';
  }

  // ─────────────────────────────────────────────────────────────
  // FORMATTING
  // ─────────────────────────────────────────────────────────────

  /// Formats as ISO 8601 date only (yyyy-MM-dd).
  String get toIsoDate => DateFormat('yyyy-MM-dd').format(this);

  /// Formats as ISO 8601 time only (HH:mm:ss).
  String get toIsoTime => DateFormat('HH:mm:ss').format(this);

  /// Formats with a custom pattern.
  String format(String pattern) => DateFormat(pattern).format(this);

  /// Formats as a short date (e.g., "Jan 1, 2024").
  String get toShortDate => DateFormat.yMMMd().format(this);

  /// Formats as a long date (e.g., "January 1, 2024").
  String get toLongDate => DateFormat.yMMMMd().format(this);

  /// Formats as time (e.g., "3:30 PM").
  String get toTime => DateFormat.jm().format(this);

  /// Formats as date and time (e.g., "Jan 1, 2024, 3:30 PM").
  String get toDateTime => DateFormat.yMMMd().add_jm().format(this);
}

/// Extension methods for nullable [DateTime].
extension NullableDateTimeExtensions on DateTime? {
  /// Returns this DateTime or the current time if null.
  DateTime get orNow => this ?? DateTime.now();

  /// Returns whether this is null or in the past.
  bool get isNullOrPast => this == null || this!.isPast;

  /// Returns whether this is not null and in the future.
  bool get isNotNullAndFuture => this != null && this!.isFuture;
}
