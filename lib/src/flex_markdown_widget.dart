import 'package:flutter/material.dart';
import 'parser.dart';
import 'models.dart';

class FlexMarkdownWidget extends StatefulWidget {
  final String? data;
  final bool isHorizontalLayout;
  final bool showTextField;
  final bool enableTextSelection;

  const FlexMarkdownWidget({
    Key? key,
    this.data,
    this.isHorizontalLayout = true,
    this.showTextField = true,
    this.enableTextSelection = true,
  }) : super(key: key);

  @override
  State<FlexMarkdownWidget> createState() => _FlexMarkdownWidgetState();
}

class _FlexMarkdownWidgetState extends State<FlexMarkdownWidget> {
  late List<MarkdownElement> _elements;
  late TextEditingController _controller;
  late String _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.data ?? '';
    _controller = TextEditingController(text: _currentData);
    _parseMarkdown();
  }

  void _parseMarkdown() {
    try {
      _elements = FlexMarkdownParser.parse(_currentData);
    } catch (e) {
      // Handle parsing errors gracefully
      _elements = [
        ParagraphElement(text: 'Error parsing markdown: ${e.toString()}')
      ];
    }
  }

  @override
  void didUpdateWidget(FlexMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _currentData = widget.data ?? '';
      _controller.text = _currentData;
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
    return widget.showTextField
        ? Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter markdown text...',
              ),
              onChanged: (value) {
                setState(() {
                  _currentData = value;
                  _parseMarkdown();
                });
              },
            ),
          )
        : Container();
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
