import 'package:intl/intl.dart';

class DateFormatter {
  static String short(DateTime date, {String? locale}) {
    return DateFormat.yMd(locale).format(date);
  }

  static String long(DateTime date, {String? locale}) {
    return DateFormat.yMMMMEEEEd(locale).format(date);
  }

  static String time(DateTime date, {String? locale}) {
    return DateFormat.Hm(locale).format(date);
  }
}