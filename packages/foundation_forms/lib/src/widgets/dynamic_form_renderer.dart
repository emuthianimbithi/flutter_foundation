import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_media/foundation_media.dart';
import 'package:foundation_ui/foundation_ui.dart';

import '../models/dynamic_field.dart';

typedef DynamicFormValueChanged = void Function(Map<String, dynamic> values);

/// Renders a dynamic form from a list of field definitions and emits a map of values.
class DynamicFormRenderer extends ConsumerStatefulWidget {
  final List<DynamicFormField> fields;
  final DynamicFormValueChanged? onChanged;
  final DynamicFormValueChanged? onSubmitted;
  final bool showSubmit;

  const DynamicFormRenderer({
    super.key,
    required this.fields,
    this.onChanged,
    this.onSubmitted,
    this.showSubmit = true,
  });

  @override
  ConsumerState<DynamicFormRenderer> createState() =>
      _DynamicFormRendererState();
}

class _DynamicFormRendererState extends ConsumerState<DynamicFormRenderer> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    _values = {
      for (final f in widget.fields) f.id: f.defaultValue,
    };
  }

  void _updateValue(String id, dynamic value) {
    setState(() {
      _values[id] = value;
    });
    widget.onChanged?.call(_values);
  }

  String? _validate(DynamicFormField field, dynamic value) {
    final v = field.validation;

    if (field.required && (value == null || value.toString().isEmpty)) {
      return 'Required';
    }
    if (v != null) {
      if (v.minLength != null &&
          (value?.toString().length ?? 0) < v.minLength!) {
        return v.errorMessage ?? 'Minimum ${v.minLength} characters';
      }
      if (v.maxLength != null &&
          (value?.toString().length ?? 0) > v.maxLength!) {
        return v.errorMessage ?? 'Maximum ${v.maxLength} characters';
      }
      if (value is num) {
        if (v.minValue != null && value < v.minValue!) {
          return v.errorMessage ?? 'Must be ≥ ${v.minValue}';
        }
        if (v.maxValue != null && value > v.maxValue!) {
          return v.errorMessage ?? 'Must be ≤ ${v.maxValue}';
        }
      }
      if (v.pattern != null && v.pattern!.isNotEmpty) {
        final reg = RegExp(v.pattern!);
        if (value != null &&
            value.toString().isNotEmpty &&
            !reg.hasMatch(value.toString())) {
          return v.errorMessage ?? 'Invalid format';
        }
      }
    }
    return null;
  }

  Future<void> _pickDate(String id, {bool includeTime = false}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;
    if (!includeTime) {
      _updateValue(id, date.toIso8601String());
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    _updateValue(id, combined.toIso8601String());
  }

  Future<void> _pickTime(String id) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      _updateValue(id,
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _pickPhoto(String id) async {
    // In this demo renderer we just mark that a photo was picked.
    _updateValue(id, 'photo_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> _captureSignature(String id) async {
    // For simplicity, generate a pseudo image reference.
    _updateValue(id, 'signature_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> _captureLocation(String id) async {
    // In absence of a real location service, emit a deterministic demo location.
    _updateValue(
        id,
        const DynamicLocation(latitude: -1.286389, longitude: 36.817223)
            .toJson());
  }

  Future<void> _scanBarcode(String id) async {
    _updateValue(
        id, 'BAR-${Random().nextInt(999999).toString().padLeft(6, '0')}');
  }

  Widget _buildField(DynamicFormField field) {
    final tokens = FoundationTheme.tokensOf(context);
    final types = FoundationTheme.typeOf(context);
    final value = _values[field.id];

    Widget buildHelper([String? text]) => text == null
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.only(top: tokens.space4),
            child: Text(text, style: types.caption));

    switch (field.type) {
      case DynamicFieldType.text:
      case DynamicFieldType.textarea:
      case DynamicFieldType.number:
      case DynamicFieldType.email:
      case DynamicFieldType.phone:
        final keyboard = switch (field.type) {
          DynamicFieldType.number => TextInputType.number,
          DynamicFieldType.email => TextInputType.emailAddress,
          DynamicFieldType.phone => TextInputType.phone,
          _ => TextInputType.text,
        };
        final maxLines = field.type == DynamicFieldType.textarea ? 4 : 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: value?.toString(),
              keyboardType: keyboard,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: field.label,
                hintText: field.placeholder,
              ),
              onChanged: (v) => _updateValue(field.id, v),
              validator: (v) => _validate(field, v),
            ),
            buildHelper(field.helpText),
          ],
        );

      case DynamicFieldType.date:
        return _PickerRow(
          label: field.label,
          value: value?.toString(),
          onTap: () => _pickDate(field.id),
          helpText: field.helpText,
        );
      case DynamicFieldType.time:
        return _PickerRow(
          label: field.label,
          value: value?.toString(),
          onTap: () => _pickTime(field.id),
          helpText: field.helpText,
        );
      case DynamicFieldType.dateTime:
        return _PickerRow(
          label: field.label,
          value: value?.toString(),
          onTap: () => _pickDate(field.id, includeTime: true),
          helpText: field.helpText,
        );

      case DynamicFieldType.select:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: field.label),
              value: value as String?,
              items: field.options
                  .map((o) => DropdownMenuItem<String>(
                      value: o.value, child: Text(o.label)))
                  .toList(),
              onChanged: (v) => _updateValue(field.id, v),
              validator: (v) => _validate(field, v),
            ),
            buildHelper(field.helpText),
          ],
        );

      case DynamicFieldType.multiSelect:
        final selected = (value as List<String>?) ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: types.h3),
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space8,
              children: field.options.map((o) {
                final isSelected = selected.contains(o.value);
                return FilterChip(
                  label: Text(o.label),
                  selected: isSelected,
                  onSelected: (sel) {
                    final updated = List<String>.from(selected);
                    sel ? updated.add(o.value) : updated.remove(o.value);
                    _updateValue(field.id, updated);
                  },
                );
              }).toList(),
            ),
            buildHelper(field.helpText),
          ],
        );

      case DynamicFieldType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: types.h3),
            ...field.options.map(
              (o) => RadioListTile<String>(
                title: Text(o.label),
                value: o.value,
                groupValue: value as String?,
                onChanged: (v) => _updateValue(field.id, v),
              ),
            ),
            buildHelper(field.helpText),
          ],
        );

      case DynamicFieldType.checkbox:
        return CheckboxListTile(
          title: Text(field.label),
          value: (value as bool?) ?? false,
          onChanged: (v) => _updateValue(field.id, v ?? false),
          subtitle: field.helpText != null ? Text(field.helpText!) : null,
        );
      case DynamicFieldType.toggle:
        return SwitchListTile(
          title: Text(field.label),
          value: (value as bool?) ?? false,
          onChanged: (v) => _updateValue(field.id, v),
          subtitle: field.helpText != null ? Text(field.helpText!) : null,
        );

      case DynamicFieldType.rating:
        final current = (value as int?) ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label, style: types.h3),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(i < current ? Icons.star : Icons.star_border),
                  color: Colors.amber,
                  onPressed: () => _updateValue(field.id, i + 1),
                ),
              ),
            ),
            buildHelper(field.helpText),
          ],
        );

      case DynamicFieldType.photo:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ImagePickerView(onPick: () => _pickPhoto(field.id)),
                if (value != null) ...[
                  SizedBox(width: tokens.space8),
                  Chip(label: Text('Selected')),
                ],
              ],
            ),
            buildHelper(field.helpText),
          ],
        );

      case DynamicFieldType.signature:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoundationButton(
              label: value == null ? 'Capture Signature' : 'Signature captured',
              onPressed: () => _captureSignature(field.id),
              variant: FoundationButtonVariant.secondary,
            ),
            buildHelper(field.helpText),
          ],
        );

      case DynamicFieldType.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoundationButton(
              label: value == null ? 'Add Location' : 'Location added',
              icon: Icons.location_on_outlined,
              onPressed: () => _captureLocation(field.id),
              variant: FoundationButtonVariant.secondary,
            ),
            if (value is Map)
              Padding(
                padding: EdgeInsets.only(top: tokens.space8),
                child: Text('Lat: ${value['lat']}, Lng: ${value['lng']}'),
              ),
            buildHelper(field.helpText),
          ],
        );

      case DynamicFieldType.barcode:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoundationButton(
              label: value == null ? 'Scan Barcode' : 'Rescan',
              icon: Icons.qr_code_scanner,
              onPressed: () => _scanBarcode(field.id),
              variant: FoundationButtonVariant.secondary,
            ),
            if (value != null)
              Padding(
                padding: EdgeInsets.only(top: tokens.space8),
                child: Text('Scanned: $value'),
              ),
            buildHelper(field.helpText),
          ],
        );
    }
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? true;
    if (!valid) return;
    _formKey.currentState?.save();
    widget.onSubmitted?.call(_values);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final ordered = [...widget.fields]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...ordered.map((f) => Padding(
                padding: EdgeInsets.only(bottom: tokens.space16),
                child: _buildField(f),
              )),
          if (widget.showSubmit)
            FoundationButton(
              label: 'Submit',
              onPressed: _submit,
            ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final String? helpText;

  const _PickerRow({
    required this.label,
    this.value,
    required this.onTap,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final types = FoundationTheme.typeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: value != null ? Text(value!) : null,
          trailing: const Icon(Icons.calendar_month),
          onTap: onTap,
        ),
        if (helpText != null)
          Padding(
              padding: EdgeInsets.only(left: tokens.space4),
              child: Text(helpText!, style: types.caption)),
      ],
    );
  }
}
