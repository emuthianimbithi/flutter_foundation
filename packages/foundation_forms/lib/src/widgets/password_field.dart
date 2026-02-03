import 'package:flutter/services.dart';
import 'validated_text_field.dart';
import '../validators/validators.dart';

class PasswordField extends ValidatedTextField {
  PasswordField({
    super.key,
    required super.fieldKey,
    super.label = 'Password',
    super.hint,
    int minLength = 8,
  }) : super(
          obscureText: true,
          validators: [
            (v) => Validators.required(v),
            (v) => Validators.minLength(v, minLength),
          ],
        );
}