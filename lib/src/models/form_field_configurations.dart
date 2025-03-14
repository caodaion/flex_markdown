import 'package:flutter/material.dart';

/// Base class for all form field configurations
abstract class FormFieldConfiguration {
  final String id;
  final String label;
  final String? placeholder;
  final double? width;
  final int? placeholderDots;
  final List<String>? options;
  final String? groupName;
  final bool? selected;
  final bool? isInline;

  const FormFieldConfiguration({
    required this.id,
    required this.label,
    this.placeholder,
    this.width,
    this.placeholderDots,
    this.options,
    this.groupName,
    this.selected,
    this.isInline,
  });
}

/// Configuration for text field form elements
class TextFieldConfiguration extends FormFieldConfiguration {
  final String? placeholder;
  final String? defaultValue;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  const TextFieldConfiguration({
    required String id,
    required String label,
    this.placeholder,
    this.defaultValue,
    double? width,
    int? placeholderDots,
    this.maxLines = 1,
    this.keyboardType,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
  }) : super(
            id: id,
            label: label,
            width: width,
            placeholderDots: placeholderDots);
}

/// Configuration for checkbox form elements
class CheckboxConfiguration extends FormFieldConfiguration {
  final bool defaultValue;

  const CheckboxConfiguration({
    required String id,
    required String label,
    this.defaultValue = false,
    double? width,
    int? placeholderDots,
  }) : super(
            id: id,
            label: label,
            width: width,
            placeholderDots: placeholderDots);
}

/// Configuration for radio button form elements
class RadioConfiguration extends FormFieldConfiguration {
  final String groupName;
  final bool defaultSelected;

  const RadioConfiguration({
    required String id,
    required String label,
    required this.groupName,
    this.defaultSelected = false,
    double? width,
    int? placeholderDots,
  }) : super(
            id: id,
            label: label,
            width: width,
            placeholderDots: placeholderDots);
}

/// Configuration for select/dropdown form elements
class SelectConfiguration extends FormFieldConfiguration {
  final List<String> options;
  final String? defaultValue;

  const SelectConfiguration({
    required String id,
    required String label,
    required this.options,
    this.defaultValue,
    double? width,
    int? placeholderDots,
  }) : super(
            id: id,
            label: label,
            width: width,
            placeholderDots: placeholderDots);
}
