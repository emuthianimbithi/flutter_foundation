import 'package:foundation_forms/foundation_forms.dart';
import 'package:marulla_protos/marulla/reja/v1/forms.pb.dart' as pb;

/// Demo-only in-memory forms repository that starts from real proto templates
/// but serves DynamicFormField models for the renderer.
class FakeFormsRepository {
  late final List<pb.FormTemplate> _templates;
  final Map<String, List<Map<String, dynamic>>> _submissions = {};

  FakeFormsRepository() {
    _templates = [_buildDemoTemplate()];
  }

  List<pb.FormTemplate> listTemplates() => _templates;

  pb.FormTemplate getTemplate(String id) =>
      _templates.firstWhere((t) => t.id == id, orElse: () => _templates.first);

  void saveSubmission(String templateId, Map<String, dynamic> data) {
    _submissions.putIfAbsent(templateId, () => []).add(data);
  }

  List<Map<String, dynamic>> submissionsFor(String templateId) =>
      _submissions[templateId] ?? const [];

  List<DynamicFormField> toDynamicFields(pb.FormTemplate template) {
    return template.fields
        .map(
          (f) => DynamicFormField(
            id: f.id,
            label: f.label,
            type: _mapType(f.type),
            required: f.required,
            placeholder: f.placeholder.isNotEmpty ? f.placeholder : null,
            helpText: f.helpText.isNotEmpty ? f.helpText : null,
            defaultValue: f.defaultValue.isNotEmpty ? f.defaultValue : null,
            order: f.order,
            options: f.options.map((o) => DynamicFieldOption(value: o.value, label: o.label)).toList(),
            validation: f.hasValidation()
                ? DynamicFieldValidation(
                    minLength: f.validation.minLength != 0 ? f.validation.minLength : null,
                    maxLength: f.validation.maxLength != 0 ? f.validation.maxLength : null,
                    minValue: f.validation.minValue != 0 ? f.validation.minValue : null,
                    maxValue: f.validation.maxValue != 0 ? f.validation.maxValue : null,
                    pattern: f.validation.pattern.isNotEmpty ? f.validation.pattern : null,
                    errorMessage: f.validation.errorMessage.isNotEmpty ? f.validation.errorMessage : null,
                  )
                : null,
          ),
        )
        .toList();
  }

  pb.FormTemplate _buildDemoTemplate() {
    final template = pb.FormTemplate()
      ..id = 'demo_form'
      ..name = 'Site Inspection'
      ..description = 'Covers common field types'
      ..status = pb.FormStatus.FORM_STATUS_PUBLISHED
      ..version = 1;

    template.fields.addAll([
      pb.FormField()
        ..id = 'title'
        ..label = 'Title'
        ..type = pb.FormFieldType.FORM_FIELD_TYPE_TEXT
        ..required = true
        ..order = 1,
      pb.FormField()
        ..id = 'details'
        ..label = 'Details'
        ..type = pb.FormFieldType.FORM_FIELD_TYPE_TEXTAREA
        ..order = 2,
      pb.FormField()
        ..id = 'severity'
        ..label = 'Severity'
        ..type = pb.FormFieldType.FORM_FIELD_TYPE_RADIO
        ..required = true
        ..order = 3
        ..options.addAll([
          pb.FormFieldOption()
            ..value = 'low'
            ..label = 'Low',
          pb.FormFieldOption()
            ..value = 'medium'
            ..label = 'Medium',
          pb.FormFieldOption()
            ..value = 'high'
            ..label = 'High',
        ]),
      pb.FormField()
        ..id = 'photos'
        ..label = 'Photos'
        ..type = pb.FormFieldType.FORM_FIELD_TYPE_PHOTO
        ..order = 4,
      pb.FormField()
        ..id = 'signature'
        ..label = 'Signature'
        ..type = pb.FormFieldType.FORM_FIELD_TYPE_SIGNATURE
        ..order = 5,
      pb.FormField()
        ..id = 'location'
        ..label = 'Location'
        ..type = pb.FormFieldType.FORM_FIELD_TYPE_LOCATION
        ..order = 6,
    ]);

    return template;
  }
}

DynamicFieldType _mapType(pb.FormFieldType t) {
  switch (t) {
    case pb.FormFieldType.FORM_FIELD_TYPE_TEXTAREA:
      return DynamicFieldType.textarea;
    case pb.FormFieldType.FORM_FIELD_TYPE_NUMBER:
      return DynamicFieldType.number;
    case pb.FormFieldType.FORM_FIELD_TYPE_EMAIL:
      return DynamicFieldType.email;
    case pb.FormFieldType.FORM_FIELD_TYPE_PHONE:
      return DynamicFieldType.phone;
    case pb.FormFieldType.FORM_FIELD_TYPE_DATE:
      return DynamicFieldType.date;
    case pb.FormFieldType.FORM_FIELD_TYPE_TIME:
      return DynamicFieldType.time;
    case pb.FormFieldType.FORM_FIELD_TYPE_DATETIME:
      return DynamicFieldType.dateTime;
    case pb.FormFieldType.FORM_FIELD_TYPE_SELECT:
      return DynamicFieldType.select;
    case pb.FormFieldType.FORM_FIELD_TYPE_MULTI_SELECT:
      return DynamicFieldType.multiSelect;
    case pb.FormFieldType.FORM_FIELD_TYPE_RADIO:
      return DynamicFieldType.radio;
    case pb.FormFieldType.FORM_FIELD_TYPE_CHECKBOX:
      return DynamicFieldType.checkbox;
    case pb.FormFieldType.FORM_FIELD_TYPE_TOGGLE:
      return DynamicFieldType.toggle;
    case pb.FormFieldType.FORM_FIELD_TYPE_RATING:
      return DynamicFieldType.rating;
    case pb.FormFieldType.FORM_FIELD_TYPE_PHOTO:
      return DynamicFieldType.photo;
    case pb.FormFieldType.FORM_FIELD_TYPE_SIGNATURE:
      return DynamicFieldType.signature;
    case pb.FormFieldType.FORM_FIELD_TYPE_LOCATION:
      return DynamicFieldType.location;
    case pb.FormFieldType.FORM_FIELD_TYPE_BARCODE:
      return DynamicFieldType.barcode;
    case pb.FormFieldType.FORM_FIELD_TYPE_TEXT:
    default:
      return DynamicFieldType.text;
  }
}
