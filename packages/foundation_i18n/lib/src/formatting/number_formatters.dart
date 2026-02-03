import 'package:intl/intl.dart';

class NumberFormatters {
  static String compact(num value, {String? locale}) =>
      NumberFormat.compact(locale: locale).format(value);
  static String decimal(num value, {String? locale}) =>
      NumberFormat.decimalPattern(locale).format(value);
  static String currency(num value, {String? locale, String? symbol}) =>
      NumberFormat.currency(locale: locale, symbol: symbol).format(value);
  static String percent(num value, {String? locale, int? decimals}) {
    final f = NumberFormat.percentPattern(locale);
    if (decimals != null) f.maximumFractionDigits = decimals;
    return f.format(value);
  }
}
