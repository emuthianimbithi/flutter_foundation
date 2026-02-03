import 'forms.pbenum.dart';
import '../../../google/protobuf/timestamp.pb.dart';

class FormFieldOption {
  String value;
  String label;
  FormFieldOption({this.value = '', this.label = ''});
}

class FormFieldValidation {
  int minLength;
  int maxLength;
  double minValue;
  double maxValue;
  String pattern;
  String errorMessage;
  FormFieldValidation({
    this.minLength = 0,
    this.maxLength = 0,
    this.minValue = 0,
    this.maxValue = 0,
    this.pattern = '',
    this.errorMessage = '',
  });
}

class FormField {
  String id = '';
  String label = '';
  FormFieldType type = FormFieldType.FORM_FIELD_TYPE_TEXT;
  bool required = false;
  String placeholder = '';
  String helpText = '';
  String defaultValue = '';
  int order = 0;
  List<FormFieldOption> options = [];
  FormFieldValidation? validation;
  String section = '';
}

class FormTemplate {
  String id = '';
  String orgId = '';
  String name = '';
  String description = '';
  FormStatus status = FormStatus.FORM_STATUS_DRAFT;
  int version = 0;
  List<FormField> fields = [];
  String category = '';
  List<String> tags = [];
  String createdByUserId = '';
  Timestamp? publishedAt;
  int submissionCount = 0;
}

class FormSubmission {
  String id = '';
  String orgId = '';
  String templateId = '';
  String templateName = '';
  int templateVersion = 0;
  String submittedByUserId = '';
  String submittedByUserName = '';
  Map<String, dynamic> data = {};
  Timestamp? submittedAt;
  int completionDurationSeconds = 0;
}
