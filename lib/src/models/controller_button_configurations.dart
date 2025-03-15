import 'package:flutter/material.dart';

/// Base class for controller button configuration
class ControllerButtonConfiguration {
  final String tooltip;
  final IconData? icon;
  final bool visible;

  const ControllerButtonConfiguration({
    required this.tooltip,
    this.icon,
    this.visible = true,
  });
}

/// Configuration for dropdown items in controller buttons
class DropdownItemConfiguration {
  final String label;
  final dynamic value;
  final IconData? icon;
  final double? fontSize;
  final FontWeight? fontWeight;

  const DropdownItemConfiguration({
    required this.label,
    this.value,
    this.icon,
    this.fontSize,
    this.fontWeight,
  });
}

/// Configuration for the markdown controller
class MarkdownControllerConfiguration {
  // Text formatting buttons
  final ControllerButtonConfiguration bold;
  final ControllerButtonConfiguration italic;
  final ControllerButtonConfiguration code;
  final ControllerButtonConfiguration indent;

  // Block formatting buttons
  final ControllerButtonConfiguration blockquote;
  final ControllerButtonConfiguration codeBlock;
  final ControllerButtonConfiguration bulletList;
  final ControllerButtonConfiguration numberedList;

  // Special elements
  final ControllerButtonConfiguration link;
  final ControllerButtonConfiguration table;
  final ControllerButtonConfiguration center;
  final ControllerButtonConfiguration horizontalRule;

  // Form fields dropdown button
  final ControllerButtonConfiguration formFields;
  final List<DropdownItemConfiguration> formFieldItems;

  // Heading button configuration
  final ControllerButtonConfiguration headingDropdown;
  final List<DropdownItemConfiguration> headingItems;

  // Print mode toggle configuration
  final bool showPrintModeToggle;
  final String printModeLabel;

  // Spacer configurations
  final double smallSpacerWidth;
  final double largeSpacerWidth;

  // Editor configuration
  final String editorPlaceholder;

  const MarkdownControllerConfiguration({
    this.bold = const ControllerButtonConfiguration(
      tooltip: 'Bold',
      icon: Icons.format_bold,
    ),
    this.italic = const ControllerButtonConfiguration(
      tooltip: 'Italic',
      icon: Icons.format_italic,
    ),
    this.code = const ControllerButtonConfiguration(
      tooltip: 'Code',
      icon: Icons.code,
    ),
    this.indent = const ControllerButtonConfiguration(
      tooltip: 'Indent',
      icon: Icons.format_indent_increase,
    ),
    this.blockquote = const ControllerButtonConfiguration(
      tooltip: 'Blockquote',
      icon: Icons.format_quote,
    ),
    this.codeBlock = const ControllerButtonConfiguration(
      tooltip: 'Code Block',
      icon: Icons.code_outlined,
    ),
    this.bulletList = const ControllerButtonConfiguration(
      tooltip: 'Bullet List',
      icon: Icons.format_list_bulleted,
    ),
    this.numberedList = const ControllerButtonConfiguration(
      tooltip: 'Numbered List',
      icon: Icons.format_list_numbered,
    ),
    this.link = const ControllerButtonConfiguration(
      tooltip: 'Link',
      icon: Icons.link,
    ),
    this.table = const ControllerButtonConfiguration(
      tooltip: 'Table',
      icon: Icons.table_chart,
    ),
    this.center = const ControllerButtonConfiguration(
      tooltip: 'Center Text',
      icon: Icons.format_align_center,
    ),
    this.horizontalRule = const ControllerButtonConfiguration(
      tooltip: 'Horizontal Rule',
      icon: Icons.horizontal_rule,
    ),
    this.formFields = const ControllerButtonConfiguration(
      tooltip: 'Form Fields',
      icon: Icons.input,
    ),
    this.formFieldItems = const [
      DropdownItemConfiguration(
        label: 'Text Field',
        value: 'textfield',
        icon: Icons.text_fields,
      ),
      DropdownItemConfiguration(
        label: 'Checkbox',
        value: 'checkbox',
        icon: Icons.check_box,
      ),
      DropdownItemConfiguration(
        label: 'Radio Button',
        value: 'radio',
        icon: Icons.radio_button_checked,
      ),
      DropdownItemConfiguration(
        label: 'Dropdown',
        value: 'select',
        icon: Icons.arrow_drop_down_circle,
      ),
    ],
    this.headingDropdown = const ControllerButtonConfiguration(
      tooltip: 'Headings',
      icon: Icons.title,
    ),
    this.headingItems = const [
      DropdownItemConfiguration(
        label: 'Heading 1',
        value: 1,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      DropdownItemConfiguration(
        label: 'Heading 2',
        value: 2,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      DropdownItemConfiguration(
        label: 'Heading 3',
        value: 3,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      DropdownItemConfiguration(
        label: 'Heading 4',
        value: 4,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      DropdownItemConfiguration(
        label: 'Heading 5',
        value: 5,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
      DropdownItemConfiguration(
        label: 'Heading 6',
        value: 6,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ],
    this.showPrintModeToggle = true,
    this.printModeLabel = 'Print Mode:',
    this.smallSpacerWidth = 8.0,
    this.largeSpacerWidth = 16.0,
    this.editorPlaceholder = 'Enter markdown text...',
  });
}
