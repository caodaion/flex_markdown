import 'package:flutter/material.dart';
import 'parser.dart';
import 'models.dart';

class FlexMarkdownWidget extends StatefulWidget {
  final String data;

  const FlexMarkdownWidget({Key? key, required this.data}) : super(key: key);

  @override
  State<FlexMarkdownWidget> createState() => _FlexMarkdownWidgetState();
}

class _FlexMarkdownWidgetState extends State<FlexMarkdownWidget> {
  late List<MarkdownElement> _elements;

  @override
  void initState() {
    super.initState();
    _parseMarkdown();
  }

  void _parseMarkdown() {
    try {
      _elements = FlexMarkdownParser.parse(widget.data);
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
      setState(() {
        _parseMarkdown();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
  }
}
