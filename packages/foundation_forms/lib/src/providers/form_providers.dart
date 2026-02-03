import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/form_state.dart';
import '../models/form_field_state.dart';

class FoundationFormController extends StateNotifier<FoundationFormState> {
  FoundationFormController() : super(const FoundationFormState());

  void setText(String key, String value, {String? error}) {
    state = state.setField<String>(
        key, FoundationFormFieldState<String>(value: value, error: error));
  }
}

final foundationFormControllerProvider = StateNotifierProvider.autoDispose<
    FoundationFormController, FoundationFormState>((ref) {
  return FoundationFormController();
});
