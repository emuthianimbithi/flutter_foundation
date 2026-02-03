import 'package:flutter/services.dart';

class InputFormatters {
  static TextInputFormatter digitsOnly() =>
      FilteringTextInputFormatter.digitsOnly;

  static TextInputFormatter maxLength(int max) =>
      LengthLimitingTextInputFormatter(max);

  static TextInputFormatter singleLine() =>
      FilteringTextInputFormatter.deny(RegExp(r'[\n\r]'));
}
