import 'package:intl/intl.dart';

class DateFormatters {
  static String yMd(DateTime date, {String? locale}) =>
      DateFormat.yMd(locale).format(date);
  static String yMMMMd(DateTime date, {String? locale}) =>
      DateFormat.yMMMMd(locale).format(date);
  static String jm(DateTime date, {String? locale}) =>
      DateFormat.jm(locale).format(date);
  static String yMMMMEEEEd(DateTime date, {String? locale}) =>
      DateFormat.yMMMMEEEEd(locale).format(date);
}
