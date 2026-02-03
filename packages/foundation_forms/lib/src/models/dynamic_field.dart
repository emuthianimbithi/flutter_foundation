/// Field types aligned with marulla.reja.v1.FormFieldType.
enum DynamicFieldType {
  text,
  textarea,
  number,
  email,
  phone,
  date,
  time,
  dateTime,
  select,
  multiSelect,
  radio,
  checkbox,
  toggle,
  rating,
  photo,
  signature,
  location,
  barcode,
}

class DynamicFieldValidation {
  final int? minLength;
  final int? maxLength;
  final num? minValue;
  final num? maxValue;
  final String? pattern;
  final String? errorMessage;

  const DynamicFieldValidation({
    this.minLength,
    this.maxLength,
    this.minValue,
    this.maxValue,
    this.pattern,
    this.errorMessage,
  });
}

class DynamicFieldOption {
  final String value;
  final String label;
  const DynamicFieldOption({required this.value, required this.label});
}

class DynamicFormField {
  final String id;
  final String label;
  final DynamicFieldType type;
  final bool required;
  final String? placeholder;
  final String? helpText;
  final dynamic defaultValue;
  final int? order;
  final List<DynamicFieldOption> options;
  final DynamicFieldValidation? validation;
  final String? section;

  const DynamicFormField({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.placeholder,
    this.helpText,
    this.defaultValue,
    this.order,
    this.options = const [],
    this.validation,
    this.section,
  });

  DynamicFormField copyWith({
    String? id,
    String? label,
    DynamicFieldType? type,
    bool? required,
    String? placeholder,
    String? helpText,
    dynamic defaultValue,
    int? order,
    List<DynamicFieldOption>? options,
    DynamicFieldValidation? validation,
    String? section,
  }) {
    return DynamicFormField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      placeholder: placeholder ?? this.placeholder,
      helpText: helpText ?? this.helpText,
      defaultValue: defaultValue ?? this.defaultValue,
      order: order ?? this.order,
      options: options ?? this.options,
      validation: validation ?? this.validation,
      section: section ?? this.section,
    );
  }
}

/// Simple location value used by the renderer.
class DynamicLocation {
  final double latitude;
  final double longitude;
  const DynamicLocation({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
      };
}
