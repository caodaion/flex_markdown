import 'dart:developer';

import 'package:flutter/material.dart';
import 'parser.dart';
import 'models.dart';
import 'models/form_field_configurations.dart';
import 'models/controller_button_configurations.dart'; // Add this import

enum MarkdownControllerPosition {
  above,
  below,
}

class FlexMarkdownWidget extends StatefulWidget {
  final String? data;
  final bool isHorizontalLayout;
  final bool showTextField;
  final bool enableTextSelection;
  final bool showController;
  final MarkdownControllerPosition controllerPosition;
  final bool isPrintMode;
  final double baseFontSize;
  final Map<String, FormFieldConfiguration>? formFieldConfigurations;
  final Map<String, CustomWidgetBuilder>? customWidgetBuilders;
  final double minHeight;
  final MarkdownControllerConfiguration
      controllerConfiguration; // Add this parameter

  const FlexMarkdownWidget({
    Key? key,
    this.data,
    this.isHorizontalLayout = true,
    this.showTextField = true,
    this.enableTextSelection = true,
    this.showController = true,
    this.controllerPosition = MarkdownControllerPosition.above,
    this.isPrintMode = false,
    this.baseFontSize = 16.0,
    this.formFieldConfigurations,
    this.customWidgetBuilders,
    this.minHeight = 360.0,
    this.controllerConfiguration =
        const MarkdownControllerConfiguration(), // Default configuration
  }) : super(key: key);

  @override
  State<FlexMarkdownWidget> createState() => _FlexMarkdownWidgetState();
}

class _FlexMarkdownWidgetState extends State<FlexMarkdownWidget> {
  late List<MarkdownElement> _elements;
  late TextEditingController _controller;
  late String _currentData;
  Map<String, dynamic> _formValues = {};

  // Add a map to store custom widget instances
  Map<String, CustomWidgetElement> _customWidgetInstances = {};

  late bool _isPrintMode;
  late double _baseFontSize;
  late Map<String, FormFieldConfiguration>? _formFieldConfigurations;
  late Map<String, CustomWidgetBuilder>? _customWidgetBuilders;

  @override
  void initState() {
    super.initState();
    _currentData = widget.data ?? '';
    _controller = TextEditingController(text: _currentData);
    _isPrintMode = widget.isPrintMode;
    _baseFontSize = widget.baseFontSize;
    _formFieldConfigurations =
        widget.formFieldConfigurations; // Initialize from widget property
    _customWidgetBuilders = widget.customWidgetBuilders;
    _initializeFormValues(); // Add this to initialize form values from configurations
    _parseMarkdown();
  }

  // Add a method to initialize form values from configurations
  void _initializeFormValues() {
    if (_formFieldConfigurations == null) return;

    _formFieldConfigurations!.forEach((id, config) {
      if (config is TextFieldConfiguration && config.defaultValue != null) {
        _formValues[id] = config.defaultValue;
      } else if (config is CheckboxConfiguration) {
        _formValues[id] = config.defaultValue;
      } else if (config is RadioConfiguration && config.defaultSelected) {
        _formValues[config.groupName] = id;
      } else if (config is SelectConfiguration && config.defaultValue != null) {
        _formValues[id] = config.defaultValue;
      }
    });
  }

  void _parseMarkdown() {
    try {
      _elements = FlexMarkdownParser.parse(
        _currentData,
        formValues: _formValues,
        handleFormValueChanged: _handleFormValueChanged,
        isPrintMode: _isPrintMode,
        baseFontSize: _baseFontSize,
        formFieldConfigurations:
            _formFieldConfigurations, // Pass configurations to parser
        customWidgetBuilders: _customWidgetBuilders,
        handleWidgetValueChanged: _handleWidgetValueChanged,
        customWidgetInstances: _customWidgetInstances, // Pass the instances map
      );
    } catch (e) {
      // Handle parsing errors gracefully
      _elements = [
        ParagraphElement(
          text: 'Error parsing markdown: ${e.toString()}',
          baseFontSize: _baseFontSize, // Pass base font size to element
        )
      ];
    }
  }

  // Updated method to handle form value changes with field type parameter
  void _handleFormValueChanged(String id, dynamic value, [String? fieldType]) {
    setState(() {
      _formValues[id] = value;
      // Only re-parse if we're in print mode OR if the element is not a text field
      bool isTextField = fieldType == 'textfield';
      if (_isPrintMode || !isTextField) {
        _parseMarkdown();
      }
    });
  }

  // Add method to handle widget value changes
  void _handleWidgetValueChanged(dynamic value) {
    setState(() {
      // Widgets can update their state - we need to re-render
      _parseMarkdown();
    });
  }

  @override
  void didUpdateWidget(FlexMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.isPrintMode != widget.isPrintMode ||
        oldWidget.baseFontSize != widget.baseFontSize ||
        oldWidget.formFieldConfigurations != widget.formFieldConfigurations) {
      // Add this check
      // Check for font size changes
      _currentData = widget.data ?? '';
      _controller.text = _currentData;
      _isPrintMode = widget.isPrintMode;
      _baseFontSize = widget.baseFontSize; // Update font size state
      _formFieldConfigurations =
          widget.formFieldConfigurations; // Update configurations
      // If configurations changed, we need to re-initialize form values
      if (oldWidget.formFieldConfigurations != widget.formFieldConfigurations) {
        _initializeFormValues();
      }
      setState(() {
        _parseMarkdown();
      });
    }
  }

  @override
  void dispose() {
    // Clear any stateful widgets we might have created
    _customWidgetInstances.clear();
    _controller.dispose();
    super.dispose();
  }

  // Apply formatting to selected text
  void _applyFormatting(String prefix, String suffix) {
    final TextEditingValue value = _controller.value;
    final int start = value.selection.start;
    final int end = value.selection.end;

    if (start < 0 || end < 0) return;

    final String selectedText = value.text.substring(start, end);
    final String newText = '$prefix$selectedText$suffix';

    final TextEditingValue newValue = TextEditingValue(
      text: value.text.replaceRange(start, end, newText),
      selection: TextSelection.collapsed(offset: start + newText.length),
    );

    _controller.value = newValue;
    setState(() {
      _currentData = _controller.text;
      _parseMarkdown();
    });
  }

  // Format buttons handlers
  void _applyBold() => _applyFormatting('**', '**');
  void _applyItalic() => _applyFormatting('_', '_');
  void _applyHeading(int level) => _applyFormatting('${'#' * level} ', '');
  void _applyLink() {
    final TextEditingValue value = _controller.value;
    final int start = value.selection.start;
    final int end = value.selection.end;

    if (start < 0 || end < 0) return;

    final String selectedText = value.text.substring(start, end);
    final String newText = '[$selectedText](url)';

    final TextEditingValue newValue = TextEditingValue(
      text: value.text.replaceRange(start, end, newText),
      selection: TextSelection(
          baseOffset: start + selectedText.length + 2,
          extentOffset: start + newText.length - 1),
    );

    _controller.value = newValue;
    setState(() {
      _currentData = _controller.text;
      _parseMarkdown();
    });
  }

  void _applyCode() => _applyFormatting('`', '`');
  void _applyCodeBlock() => _applyFormatting('```\n', '\n```');
  void _applyBulletList() => _applyFormatting('- ', '');
  void _applyNumberedList() => _applyFormatting('1. ', '');

  // New formatting methods
  void _applyBlockquote() => _applyFormatting('> ', '');
  void _applyHorizontalRule() {
    final TextEditingValue value = _controller.value;
    final int start = value.selection.start;
    final int end = value.selection.end;

    final String newText = '\n---\n';

    final TextEditingValue newValue = TextEditingValue(
      text: value.text.replaceRange(start, end, newText),
      selection: TextSelection.collapsed(offset: start + newText.length),
    );

    _controller.value = newValue;
    setState(() {
      _currentData = _controller.text;
      _parseMarkdown();
    });
  }

  void _applyCenter() {
    final TextEditingValue value = _controller.value;
    final int start = value.selection.start;
    final int end = value.selection.end;

    if (start < 0 || end < 0) return;

    final String selectedText = value.text.substring(start, end);
    final String newText = '->$selectedText<-';

    final TextEditingValue newValue = TextEditingValue(
      text: value.text.replaceRange(start, end, newText),
      selection: TextSelection.collapsed(offset: start + newText.length),
    );

    _controller.value = newValue;
    setState(() {
      _currentData = _controller.text;
      _parseMarkdown();
    });
  }

  void _applyTable() {
    final TextEditingValue value = _controller.value;
    final int start = value.selection.start;
    final int end = value.selection.end;

    final String tableTemplate = '''
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |
''';

    final TextEditingValue newValue = TextEditingValue(
      text: value.text.replaceRange(start, end, tableTemplate),
      selection: TextSelection.collapsed(offset: start + tableTemplate.length),
    );

    _controller.value = newValue;
    setState(() {
      _currentData = _controller.text;
      _parseMarkdown();
    });
  }

  void _applyTextField() {
    _insertInlineElement('{{textfield|id|Label|Placeholder|Default Value|10}}');
  }

  void _applyCheckbox() {
    _insertInlineElement('{{checkbox|id|Checkbox label|false|10}}');
  }

  void _applyRadio() {
    _insertInlineElement('{{radio|id|Radio label|groupName|false|10}}');
  }

  void _applySelect() {
    _insertInlineElement(
        '{{select|id|Label|Option1,Option2,Option3|Option1|10}}');
  }

  void _insertInlineElement(String element) {
    final TextEditingValue value = _controller.value;
    final int start = value.selection.start;
    final int end = value.selection.end;

    final TextEditingValue newValue = TextEditingValue(
      text: value.text.replaceRange(start, end, element),
      selection: TextSelection.collapsed(offset: start + element.length),
    );

    _controller.value = newValue;
    setState(() {
      _currentData = _controller.text;
      _parseMarkdown();
    });
  }

  // Add a method to toggle print mode
  void _togglePrintMode() {
    setState(() {
      _isPrintMode = !_isPrintMode;
      _parseMarkdown(); // Re-parse with the new mode
    });
  }

  Widget _buildMarkdownController() {
    if (!widget.showController || !widget.showTextField) return Container();

    final config = widget.controllerConfiguration;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Wrap(
        children: [
          // Text formatting buttons
          if (config.bold.visible)
            IconButton(
              icon: config.bold.icon != null
                  ? Icon(config.bold.icon)
                  : Icon(Icons.format_bold),
              tooltip: config.bold.tooltip,
              onPressed: _applyBold,
            ),
          if (config.italic.visible)
            IconButton(
              icon: config.italic.icon != null
                  ? Icon(config.italic.icon)
                  : Icon(Icons.format_italic),
              tooltip: config.italic.tooltip,
              onPressed: _applyItalic,
            ),
          if (config.code.visible)
            IconButton(
              icon: config.code.icon != null
                  ? Icon(config.code.icon)
                  : Icon(Icons.code),
              tooltip: config.code.tooltip,
              onPressed: _applyCode,
            ),
          if (config.indent.visible)
            IconButton(
              icon: config.indent.icon != null
                  ? Icon(config.indent.icon)
                  : Icon(Icons.format_indent_increase),
              tooltip: config.indent.tooltip,
              onPressed: _applyIndent,
            ),
          SizedBox(width: config.smallSpacerWidth),

          // Heading dropdown
          if (config.headingDropdown.visible)
            PopupMenuButton<int>(
              tooltip: config.headingDropdown.tooltip,
              icon: config.headingDropdown.icon != null
                  ? Icon(config.headingDropdown.icon)
                  : Icon(Icons.title),
              onSelected: _applyHeading,
              itemBuilder: (context) => config.headingItems.map((item) {
                return PopupMenuItem<int>(
                  value: item.value as int,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: item.fontSize,
                      fontWeight: item.fontWeight,
                    ),
                  ),
                );
              }).toList(),
            ),
          SizedBox(width: config.smallSpacerWidth),

          // Block formatting buttons
          if (config.blockquote.visible)
            IconButton(
              icon: config.blockquote.icon != null
                  ? Icon(config.blockquote.icon)
                  : Icon(Icons.format_quote),
              tooltip: config.blockquote.tooltip,
              onPressed: _applyBlockquote,
            ),
          if (config.codeBlock.visible)
            IconButton(
              icon: config.codeBlock.icon != null
                  ? Icon(config.codeBlock.icon)
                  : Icon(Icons.code_rounded),
              tooltip: config.codeBlock.tooltip,
              onPressed: _applyCodeBlock,
            ),
          if (config.bulletList.visible)
            IconButton(
              icon: config.bulletList.icon != null
                  ? Icon(config.bulletList.icon)
                  : Icon(Icons.format_list_bulleted),
              tooltip: config.bulletList.tooltip,
              onPressed: _applyBulletList,
            ),
          if (config.numberedList.visible)
            IconButton(
              icon: config.numberedList.icon != null
                  ? Icon(config.numberedList.icon)
                  : Icon(Icons.format_list_numbered),
              tooltip: config.numberedList.tooltip,
              onPressed: _applyNumberedList,
            ),
          SizedBox(width: config.smallSpacerWidth),

          // Special elements
          if (config.link.visible)
            IconButton(
              icon: config.link.icon != null
                  ? Icon(config.link.icon)
                  : Icon(Icons.link),
              tooltip: config.link.tooltip,
              onPressed: _applyLink,
            ),
          if (config.table.visible)
            IconButton(
              icon: config.table.icon != null
                  ? Icon(config.table.icon)
                  : Icon(Icons.table_chart),
              tooltip: config.table.tooltip,
              onPressed: _applyTable,
            ),
          if (config.center.visible)
            IconButton(
              icon: config.center.icon != null
                  ? Icon(config.center.icon)
                  : Icon(Icons.format_align_center),
              tooltip: config.center.tooltip,
              onPressed: _applyCenter,
            ),
          if (config.horizontalRule.visible)
            IconButton(
              icon: config.horizontalRule.icon != null
                  ? Icon(config.horizontalRule.icon)
                  : Icon(Icons.horizontal_rule),
              tooltip: config.horizontalRule.tooltip,
              onPressed: _applyHorizontalRule,
            ),

          // Form element dropdown menu
          SizedBox(width: config.smallSpacerWidth),
          if (config.formFields.visible)
            PopupMenuButton<String>(
              tooltip: config.formFields.tooltip,
              icon: config.formFields.icon != null
                  ? Icon(config.formFields.icon)
                  : Icon(Icons.input),
              onSelected: _applyFormField,
              itemBuilder: (context) => config.formFieldItems.map((item) {
                return PopupMenuItem<String>(
                  value: item.value as String,
                  child: Row(
                    children: [
                      if (item.icon != null) Icon(item.icon, size: 20),
                      SizedBox(width: 8),
                      Text(item.label),
                    ],
                  ),
                );
              }).toList(),
            ),

          // Add widget button
          if (config.formFields.visible)
            IconButton(
              icon: Icon(Icons.widgets),
              tooltip: 'Insert Custom Widget',
              onPressed: _applyCustomWidget,
            ),

          // Add print mode toggle
          if (config.showPrintModeToggle) ...[
            SizedBox(width: config.largeSpacerWidth),
            IntrinsicWidth(
              child: Row(
                children: [
                  Text(config.printModeLabel),
                  const SizedBox(width: 4),
                  Switch(
                    value: _isPrintMode,
                    onChanged: (value) {
                      _togglePrintMode();
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Add method to apply indentation
  void _applyIndent() {
    final TextEditingValue value = _controller.value;
    final int start = value.selection.start;
    final int end = value.selection.end;

    if (start < 0 || end < 0) return;

    final String selectedText = value.text.substring(start, end);
    final String newText = '[[indent|20|$selectedText]]';

    final TextEditingValue newValue = TextEditingValue(
      text: value.text.replaceRange(start, end, newText),
      selection: TextSelection.collapsed(offset: start + newText.length),
    );

    _controller.value = newValue;
    setState(() {
      _currentData = _controller.text;
      _parseMarkdown();
    });
  }

  // Add a method to handle form field selection
  void _applyFormField(String fieldType) {
    switch (fieldType) {
      case 'textfield':
        _applyTextField();
        break;
      case 'checkbox':
        _applyCheckbox();
        break;
      case 'radio':
        _applyRadio();
        break;
      case 'select':
        _applySelect();
        break;
    }
  }

  void _applyCustomWidget() {
    _insertInlineElement(
        '{{widget:button|my_button|text:Click Me;color:blue}}');
  }

  Widget _buildMarkdownPreview() {
    Widget content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _elements.map((element) {
          try {
            return element.build(context);
          } catch (e) {
            // Handle element building errors gracefully
            return Text('Error rendering element: ${e.toString()}');
          }
        }).toList(),
      ),
    );

    // Wrap with SelectionArea if text selection is enabled
    if (widget.enableTextSelection) {
      content = SelectionArea(child: content);
    }

    return Expanded(child: content);
  }

  Widget _buildTextField() {
    if (!widget.showTextField) return Container();

    return SizedBox(
      width: widget.isHorizontalLayout ? null : double.infinity,
      child: Column(
        children: [
          if (widget.controllerPosition == MarkdownControllerPosition.above)
            _buildMarkdownController(),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: widget.controllerConfiguration.editorPlaceholder,
                alignLabelWithHint: true,
              ),
              onChanged: (value) {
                setState(() {
                  _currentData = value;
                  _parseMarkdown();
                });
              },
            ),
          ),
          if (widget.controllerPosition == MarkdownControllerPosition.below)
            _buildMarkdownController(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHorizontalLayout) {
      if (widget.showTextField) {
        // Only use fixed height when showing text field
        return Column(
          children: [
            Container(
              height: widget.minHeight,
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildTextField()),
                  SizedBox(width: 16),
                  _buildMarkdownPreview(),
                ],
              ),
            ),
          ],
        );
      } else {
        // When text field is hidden, let the preview take all available space
        return IntrinsicWidth(child: Container(child: _buildMarkdownPreview()));
      }
    } else {
      if (widget.showTextField) {
        // Only use fixed height when showing text field
        return Column(
          children: [
            Container(
              height: widget.minHeight,
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: Column(
                children: [
                  Expanded(child: _buildTextField()),
                  SizedBox(height: 16),
                  Expanded(child: _buildMarkdownPreview()),
                ],
              ),
            ),
          ],
        );
      } else {
        // When text field is hidden, let the preview take all available space
        return IntrinsicWidth(child: Container(child: _buildMarkdownPreview()));
      }
    }
  }
}
