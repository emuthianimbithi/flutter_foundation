import 'package:flutter/material.dart';

import 'validated_text_field.dart';
import '../validators/validators.dart';

class PhoneField extends ValidatedTextField {
  PhoneField({
    super.key,
    required super.fieldKey,
    super.label = 'Phone',
    super.hint,
  }) : super(
          keyboardType: TextInputType.phone,
          validators: [
            (v) => Validators.phone(v),
          ],
        );
}
