import 'package:intl/intl.dart';

class NumberFormatter {
  static String decimal(num value, {String? locale}) {
    return NumberFormat.decimalPattern(locale).format(value);
  }

  static String currency(num value, {String? locale, String? symbol}) {
    return NumberFormat.currency(locale: locale, symbol: symbol).format(value);
  }

  static String percent(num value, {String? locale}) {
    return NumberFormat.percentPattern(locale).format(value);
  }
}