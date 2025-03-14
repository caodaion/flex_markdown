import 'dart:developer';

import 'package:flutter/material.dart';
import 'parser.dart';
import 'models.dart';

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
  final bool isPrintMode; // Added new parameter

  const FlexMarkdownWidget({
    Key? key,
    this.data,
    this.isHorizontalLayout = true,
    this.showTextField = true,
    this.enableTextSelection = true,
    this.showController = true,
    this.controllerPosition = MarkdownControllerPosition.above,
    this.isPrintMode = false, // Default to false
  }) : super(key: key);

  @override
  State<FlexMarkdownWidget> createState() => _FlexMarkdownWidgetState();
}

class _FlexMarkdownWidgetState extends State<FlexMarkdownWidget> {
  late List<MarkdownElement> _elements;
  late TextEditingController _controller;
  late String _currentData;
  // Add a map to track form field values
  Map<String, dynamic> _formValues = {};
  late bool _isPrintMode; // Add state variable for print mode

  @override
  void initState() {
    super.initState();
    _currentData = widget.data ?? '';
    _controller = TextEditingController(text: _currentData);
    _isPrintMode = widget.isPrintMode; // Initialize from widget property
    _parseMarkdown();
  }

  void _parseMarkdown() {
    try {
      // Pass the form values, update callback, and print mode flag to the parser
      _elements = FlexMarkdownParser.parse(
        _currentData,
        formValues: _formValues,
        onValueChanged: _handleFormValueChanged,
        isPrintMode: _isPrintMode, // Use the state variable
      );
    } catch (e) {
      // Handle parsing errors gracefully
      _elements = [
        ParagraphElement(text: 'Error parsing markdown: ${e.toString()}')
      ];
    }
  }

  // Add a method to handle form value changes
  void _handleFormValueChanged(String id, dynamic value) {
    setState(() {
      log(id);
      log(value.toString());
      _formValues[id] = value;
      // Only update the parser in normal mode
      if (_isPrintMode) {
        // Re-parse markdown to update the UI
        _parseMarkdown();
      }
    });
  }

  @override
  void didUpdateWidget(FlexMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.isPrintMode != widget.isPrintMode) {
      _currentData = widget.data ?? '';
      _controller.text = _currentData;
      _isPrintMode =
          widget.isPrintMode; // Update state when widget property changes
      setState(() {
        _parseMarkdown();
      });
    }
  }

  @override
  void dispose() {
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

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Text formatting buttons
            IconButton(
              icon: const Icon(Icons.format_bold),
              tooltip: 'Bold',
              onPressed: _applyBold,
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              tooltip: 'Italic',
              onPressed: _applyItalic,
            ),
            IconButton(
              icon: const Icon(Icons.code),
              tooltip: 'Code',
              onPressed: _applyCode,
            ),
            const SizedBox(width: 8),

            // Heading dropdown
            PopupMenuButton<int>(
              tooltip: 'Headings',
              icon: const Icon(Icons.title),
              onSelected: _applyHeading,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Text('Heading 1',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text('Heading 2',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Text('Heading 3',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                PopupMenuItem(
                  value: 4,
                  child: Text('Heading 4',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                PopupMenuItem(
                  value: 5,
                  child: Text('Heading 5',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                PopupMenuItem(
                  value: 6,
                  child: Text('Heading 6',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Block formatting buttons
            IconButton(
              icon: const Icon(Icons.format_quote),
              tooltip: 'Blockquote',
              onPressed: _applyBlockquote,
            ),
            IconButton(
              icon: const Icon(Icons.code_outlined),
              tooltip: 'Code Block',
              onPressed: _applyCodeBlock,
            ),
            IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              tooltip: 'Bullet List',
              onPressed: _applyBulletList,
            ),
            IconButton(
              icon: const Icon(Icons.format_list_numbered),
              tooltip: 'Numbered List',
              onPressed: _applyNumberedList,
            ),
            const SizedBox(width: 8),

            // Special elements
            IconButton(
              icon: const Icon(Icons.link),
              tooltip: 'Link',
              onPressed: _applyLink,
            ),
            IconButton(
              icon: const Icon(Icons.table_chart),
              tooltip: 'Table',
              onPressed: _applyTable,
            ),
            IconButton(
              icon: const Icon(Icons.format_align_center),
              tooltip: 'Center Text',
              onPressed: _applyCenter,
            ),
            IconButton(
              icon: const Icon(Icons.horizontal_rule),
              tooltip: 'Horizontal Rule',
              onPressed: _applyHorizontalRule,
            ),

            // Form element dropdown menu
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: 'Form Fields',
              icon: const Icon(Icons.input),
              onSelected: _applyFormField,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'textfield',
                  child: Row(
                    children: [
                      Icon(Icons.text_fields, size: 20),
                      SizedBox(width: 8),
                      Text('Text Field'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'checkbox',
                  child: Row(
                    children: [
                      Icon(Icons.check_box, size: 20),
                      SizedBox(width: 8),
                      Text('Checkbox'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'radio',
                  child: Row(
                    children: [
                      Icon(Icons.radio_button_checked, size: 20),
                      SizedBox(width: 8),
                      Text('Radio Button'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'select',
                  child: Row(
                    children: [
                      Icon(Icons.arrow_drop_down_circle, size: 20),
                      SizedBox(width: 8),
                      Text('Dropdown'),
                    ],
                  ),
                ),
              ],
            ),

            // Add print mode toggle
            const SizedBox(width: 16),
            Row(
              children: [
                Text('Print Mode:'),
                const SizedBox(width: 4),
                Switch(
                  value: _isPrintMode,
                  onChanged: (value) {
                    _togglePrintMode();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

    return Expanded(
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
                hintText: 'Enter markdown text...',
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
      return Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showTextField) ...[
              _buildTextField(),
              SizedBox(width: 16),
            ],
            _buildMarkdownPreview(),
          ],
        ),
      );
    } else {
      return Container(
        child: Column(
          children: [
            if (widget.showTextField) ...[
              _buildTextField(),
              SizedBox(height: 16),
            ],
            _buildMarkdownPreview(),
          ],
        ),
      );
    }
  }
}
