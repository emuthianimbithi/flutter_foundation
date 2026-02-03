class FoundationFormFieldState<T> {
  final T value;
  final String? error;

  const FoundationFormFieldState({required this.value, this.error});

  FoundationFormFieldState<T> copyWith({T? value, String? error}) =>
      FoundationFormFieldState<T>(value: value ?? this.value, error: error);
}