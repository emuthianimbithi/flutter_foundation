import 'form_field_state.dart';

class FoundationFormState {
  final Map<String, FoundationFormFieldState<dynamic>> fields;

  const FoundationFormState({this.fields = const {}});

  FoundationFormFieldState<T> field<T>(String key, {required T initial}) {
    final v = fields[key];
    if (v is FoundationFormFieldState<T>) return v;
    return FoundationFormFieldState<T>(value: initial);
  }

  FoundationFormState setField<T>(
      String key, FoundationFormFieldState<T> state) {
    return FoundationFormState(fields: {...fields, key: state});
  }

  bool get isValid => fields.values.every((f) => f.error == null);
}
