import 'package:flutter/material.dart';
import '../models.dart';

/// Text field input element
class TextFieldElement extends FormElement {
  final String label;
  final String hint;

  TextFieldElement({required super.id, this.label = '', this.hint = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: IntrinsicWidth(
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dropdown select element
class SelectElement extends FormElement {
  final String label;
  final List<String> options;

  SelectElement({
    required super.id,
    required this.label,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: IntrinsicWidth(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: (value) {},
        ),
      ),
    );
  }
}

/// Checkbox element
class CheckboxElement extends FormElement {
  final String label;
  final bool initialValue;

  CheckboxElement({
    required super.id,
    required this.label,
    this.initialValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      value: initialValue,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onChanged: (bool? value) {
        // In a real app, you would update state using a callback or provider
        // For demo purposes, we're just accepting the change without updating state
      },
    );
  }
}

/// Radio button element
class RadioElement extends FormElement {
  final String label;
  final String groupName;
  final bool selected;

  RadioElement({
    required super.id,
    required this.label,
    required this.groupName,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(label),
      value: id,
      groupValue: selected ? id : null,
      dense: true,
      contentPadding: EdgeInsets.zero,
      onChanged: (String? value) {
        // In a real app, you would update state using a callback or provider
        // For demo purposes, we're just accepting the change without updating state
      },
    );
  }
}
