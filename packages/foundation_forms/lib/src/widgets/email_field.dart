import 'package:flutter/material.dart';

import 'validated_text_field.dart';
import '../validators/validators.dart';

class EmailField extends ValidatedTextField {
  EmailField({
    super.key,
    required super.fieldKey,
    super.label = 'Email',
    super.hint,
  }) : super(
          keyboardType: TextInputType.emailAddress,
          validators: [
            (v) => Validators.required(v),
            (v) => Validators.email(v),
          ],
        );
}
