import 'package:flutter/material.dart';
import '../models.dart';

// Default minimum width for form fields
const double kDefaultFormFieldMinWidth = 120.0;

/// Text field input element
class TextFieldElement extends FormElement {
  final String label;
  final String hint;
  final bool isInline;
  final String? initialValue;
  final bool isPrintMode; // Add isPrintMode flag
  final int? placeholderDots; // Number of dots to show in print mode when empty
  late final TextEditingController _controller;

  TextFieldElement(
      {required super.id,
      this.label = '',
      this.hint = '',
      this.isInline = false,
      this.initialValue,
      super.onValueChanged,
      this.isPrintMode = false,
      this.placeholderDots}) {
    _controller = TextEditingController(text: initialValue);
  }

  @override
  Widget build(BuildContext context) {
    // In print mode, show the value as text or dots as placeholder
    if (isPrintMode) {
      final text = _controller.text;
      if (text.isEmpty && placeholderDots != null) {
        // Show dots as placeholder based on the placeholderDots parameter
        return Text('.' * placeholderDots!,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
      }
      return Text(text,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
    }

    if (isInline) {
      return IntrinsicWidth(
        child: Container(
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          constraints:
              const BoxConstraints(minWidth: kDefaultFormFieldMinWidth),
          child: TextField(
            controller: _controller,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (onValueChanged != null) {
                onValueChanged!(id, value);
              }
            },
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: IntrinsicWidth(
        child: Container(
          constraints:
              const BoxConstraints(minWidth: kDefaultFormFieldMinWidth),
          child: TextField(
            controller: _controller,
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
            onChanged: (value) {
              if (onValueChanged != null) {
                onValueChanged!(id, value);
              }
            },
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
  final bool isInline;
  final String? initialValue;
  final bool isPrintMode; // Add isPrintMode flag
  final int? placeholderDots; // Number of dots to show in print mode when empty

  SelectElement(
      {required super.id,
      required this.label,
      required this.options,
      this.isInline = false,
      this.initialValue,
      super.onValueChanged,
      this.isPrintMode = false,
      this.placeholderDots}); // Add placeholderDots parameter

  @override
  Widget build(BuildContext context) {
    // In print mode, show the selected value as text or dots as placeholder
    if (isPrintMode) {
      final value = initialValue;
      if ((value == null || value.isEmpty) && placeholderDots != null) {
        // Show dots as placeholder
        return Text('.' * placeholderDots!,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
      }
      return Text(value ?? '',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
    }

    if (isInline) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 36,
        constraints: const BoxConstraints(minWidth: kDefaultFormFieldMinWidth),
        child: DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButton<String>(
              isDense: true,
              value: initialValue,
              hint: Text(label),
              items: options
                  .map((option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null && onValueChanged != null) {
                  onValueChanged!(id, value);
                }
              },
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      constraints: const BoxConstraints(minWidth: kDefaultFormFieldMinWidth),
      child: IntrinsicWidth(
        child: DropdownButtonFormField<String>(
          value: initialValue,
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
          onChanged: (value) {
            if (value != null && onValueChanged != null) {
              onValueChanged!(id, value);
            }
          },
        ),
      ),
    );
  }
}

/// Checkbox element
class CheckboxElement extends FormElement {
  final String label;
  final bool initialValue;
  final bool isInline;
  final bool isPrintMode; // Add isPrintMode flag
  final int?
      placeholderDots; // Number of dots to show in print mode when not checked

  CheckboxElement(
      {required super.id,
      required this.label,
      this.initialValue = false,
      this.isInline = false,
      super.onValueChanged,
      this.isPrintMode = false,
      this.placeholderDots}); // Add placeholderDots parameter

  @override
  Widget build(BuildContext context) {
    // In print mode, show the label if checked or dots if not checked and placeholderDots specified
    if (isPrintMode) {
      if (initialValue) {
        return Text(label,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
      } else if (placeholderDots != null) {
        return Text('.' * placeholderDots!,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
      } else {
        return SizedBox.shrink(); // Hide if not checked and no dots specified
      }
    }

    if (isInline) {
      return IntrinsicWidth(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: initialValue,
                  onChanged: (value) {
                    if (value != null && onValueChanged != null) {
                      onValueChanged!(id, value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return CheckboxListTile(
      title: Text(label),
      value: initialValue,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onChanged: (bool? value) {
        if (value != null && onValueChanged != null) {
          onValueChanged!(id, value);
        }
      },
    );
  }
}

/// Radio button element
class RadioElement extends FormElement {
  final String label;
  final String groupName;
  final bool selected;
  final bool isInline;
  final bool isPrintMode; // Add isPrintMode flag
  final int?
      placeholderDots; // Number of dots to show in print mode when not selected

  RadioElement(
      {required super.id,
      required this.label,
      required this.groupName,
      this.selected = false,
      this.isInline = false,
      super.onValueChanged,
      this.isPrintMode = false,
      this.placeholderDots}); // Add placeholderDots parameter

  @override
  Widget build(BuildContext context) {
    // In print mode, show the label if selected or dots if not selected and placeholderDots specified
    if (isPrintMode) {
      if (selected) {
        return Text(label,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
      } else if (placeholderDots != null) {
        return Text('.' * placeholderDots!,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
      } else {
        return SizedBox.shrink(); // Hide if not selected and no dots specified
      }
    }

    if (isInline) {
      return IntrinsicWidth(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Radio<String>(
                  value: id,
                  groupValue: selected ? id : null,
                  onChanged: (value) {
                    if (value != null && onValueChanged != null) {
                      onValueChanged!(groupName, id);
                    }
                  },
                ),
              ),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return RadioListTile<String>(
      title: Text(label),
      value: id,
      groupValue: selected ? id : null,
      dense: true,
      contentPadding: EdgeInsets.zero,
      onChanged: (value) {
        if (value != null && onValueChanged != null) {
          onValueChanged!(groupName, id);
        }
      },
    );
  }
}
