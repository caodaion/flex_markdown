import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

// Update the typedef for the form value changed callback to include field type
typedef FormValueChangedCallback = void Function(String id, dynamic value,
    [String? fieldType]);

/// Callback for custom widget builders
typedef CustomWidgetBuilder = Widget Function(BuildContext context,
    String widgetType, String id, Map<String, dynamic> params,
    {ValueChanged<dynamic>? onValueChanged});

/// Base class for all markdown elements
abstract class MarkdownElement {
  final double baseFontSize;

  const MarkdownElement({this.baseFontSize = 16.0});

  Widget build(BuildContext context);
}

/// Represents a heading element (h1-h6)
class HeadingElement extends MarkdownElement {
  final int level; // 1-6 for h1-h6
  final String text;
  final TextAlign? textAlign;
  final bool isCentered;
  final FormattedTextElement? formattedContent;

  HeadingElement({
    required this.level,
    required this.text,
    this.textAlign,
    this.isCentered = false,
    this.formattedContent,
    double baseFontSize = 16.0,
  }) : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    double fontSize;
    // Calculate font size based on level and base font size
    switch (level) {
      case 1:
        fontSize = baseFontSize * 2.0; // 32 when base is 16
        break;
      case 2:
        fontSize = baseFontSize * 1.75; // 28 when base is 16
        break;
      case 3:
        fontSize = baseFontSize * 1.5; // 24 when base is 16
        break;
      case 4:
        fontSize = baseFontSize * 1.25; // 20 when base is 16
        break;
      case 5:
        fontSize = baseFontSize * 1.125; // 18 when base is 16
        break;
      case 6:
      default:
        fontSize = baseFontSize; // 16 when base is 16
        break;
    }

    Widget content;
    if (formattedContent != null) {
      // Create a styled version of the formatted text using the heading's style
      content = DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        child: formattedContent!.build(context),
      );
    } else {
      // Use regular Text widget for simple text
      content = Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        textAlign: textAlign ?? (isCentered ? TextAlign.center : null),
      );
    }

    return isCentered
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            alignment: Alignment.center,
            child: content,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: content,
          );
  }
}

/// Represents a paragraph of text
class ParagraphElement extends MarkdownElement {
  final String text;
  final TextAlign? textAlign;

  ParagraphElement({
    required this.text,
    this.textAlign,
    double baseFontSize = 16.0,
  }) : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: baseFontSize),
      textAlign: textAlign,
    );
  }
}

/// Represents a line break element
class LineBreakElement extends MarkdownElement {
  const LineBreakElement({double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16.0);
  }
}

/// Represents a centered line element
class CenterElement extends MarkdownElement {
  final MarkdownElement child;

  CenterElement({required this.child, double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: child.build(context),
    );
  }
}

/// Base class for form elements
abstract class FormElement extends MarkdownElement {
  final String id;
  final FormValueChangedCallback? onValueChanged;

  FormElement(
      {required this.id, this.onValueChanged, double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);
}

/// Represents a span of text with optional formatting
class TextSpanElement {
  final String text;
  final bool isBold;
  final bool isItalic;
  final String? linkUrl;
  final bool isCode;
  final bool isUnderline; // Add isUnderline property
  final String? color; // Add color property

  TextSpanElement({
    required this.text,
    required this.isBold,
    required this.isItalic,
    this.linkUrl,
    this.isCode = false,
    this.isUnderline = false, // Add isUnderline with default false
    this.color, // Add color parameter
  });
}

/// Represents a paragraph with formatted text spans
class FormattedTextElement extends MarkdownElement {
  final List<TextSpanElement> spans;

  FormattedTextElement({
    required this.spans,
    double baseFontSize = 16.0,
  }) : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: spans.map((span) {
          Color? textColor;
          if (span.color != null) {
            // Parse color from string
            try {
              // Handle common color names
              switch (span.color!.toLowerCase()) {
                case 'red':
                  textColor = Colors.red;
                  break;
                case 'blue':
                  textColor = Colors.blue;
                  break;
                case 'green':
                  textColor = Colors.green;
                  break;
                case 'yellow':
                  textColor = Colors.yellow;
                  break;
                case 'orange':
                  textColor = Colors.orange;
                  break;
                case 'purple':
                  textColor = Colors.purple;
                  break;
                case 'black':
                  textColor = Colors.black;
                  break;
                case 'white':
                  textColor = Colors.white;
                  break;
                case 'grey':
                case 'gray':
                  textColor = Colors.grey;
                  break;
                default:
                  // Check for hex color format
                  if (span.color!.startsWith('#')) {
                    String hex = span.color!.replaceFirst('#', '');
                    if (hex.length == 6 || hex.length == 8) {
                      textColor =
                          Color(int.parse('0xFF' + hex.substring(0, 6)));
                    }
                  }
              }
            } catch (e) {
              // If color parsing fails, don't apply a color
            }
          }

          return TextSpan(
            text: span.text,
            style: TextStyle(
              fontWeight: span.isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: span.isItalic ? FontStyle.italic : FontStyle.normal,
              decoration:
                  span.linkUrl != null ? TextDecoration.underline : null,
              fontFamily: span.isCode ? 'monospace' : null,
              backgroundColor: span.isCode ? Colors.grey.shade200 : null,
              color: textColor, // Apply the parsed color
              fontSize: baseFontSize, // Use the base font size
            ),
            recognizer: span.linkUrl != null
                ? (TapGestureRecognizer()
                  ..onTap = () {
                    url_launcher.launch(span.linkUrl!);
                  })
                : null,
          );
        }).toList(),
      ),
    );
  }
}

/// Represents a hyperlink element
class LinkElement extends MarkdownElement {
  final String text;
  final String url;

  LinkElement(
      {required this.text, required this.url, double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Color(0xFF2196F3), // Material blue
          decoration: TextDecoration.underline,
          fontSize: baseFontSize,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final Uri uri = Uri.parse(url);
            try {
              // Try to launch using the older API
              await url_launcher.launch(url);
            } catch (e) {
              // If the older API fails, try with the newer API if available
              if (await url_launcher.canLaunch(url)) {
                await url_launcher.launch(url);
              }
            }
          },
      ),
    );
  }
}

/// Represents an unordered list element
class UnorderedListElement extends MarkdownElement {
  final List<ListItemElement> items;

  UnorderedListElement({required this.items, double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => item.build(context)).toList(),
    );
  }
}

/// Represents an ordered list element
class OrderedListElement extends MarkdownElement {
  final List<ListItemElement> items;

  OrderedListElement({required this.items, double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${index + 1}.',
                style: TextStyle(fontSize: baseFontSize),
              ),
            ),
            Expanded(child: items[index].buildContent(context)),
          ],
        );
      }),
    );
  }
}

/// Represents a list item element
class ListItemElement extends MarkdownElement {
  final MarkdownElement content;
  final List<ListItemElement>? nestedItems;
  final bool isUnordered;
  final int depth;

  ListItemElement({
    required this.content,
    this.nestedItems,
    this.isUnordered = true,
    this.depth = 0,
    double baseFontSize = 16.0,
  }) : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            isUnordered ? '•' : '', // Bullet for unordered lists
            style: TextStyle(fontSize: baseFontSize),
          ),
        ),
        Expanded(child: buildContent(context)),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    if (nestedItems == null || nestedItems!.isEmpty) {
      return content.build(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        content.build(context),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: nestedItems!.map((item) => item.build(context)).toList(),
          ),
        ),
      ],
    );
  }
}

/// Represents a blockquote element
class BlockquoteElement extends MarkdownElement {
  final List<MarkdownElement> children;

  BlockquoteElement({required this.children, double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade400,
            width: 4.0,
          ),
        ),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((child) => child.build(context)).toList(),
      ),
    );
  }
}

/// Represents a code block element
class CodeBlockElement extends MarkdownElement {
  final String code;
  final String? language;

  CodeBlockElement(
      {required this.code, this.language, double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.grey.shade100,
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: baseFontSize - 2.0, // Slightly smaller for code
        ),
      ),
    );
  }
}

/// Represents a horizontal rule element
class HorizontalRuleElement extends MarkdownElement {
  const HorizontalRuleElement({double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }
}

/// Represents a table element
class TableElement extends MarkdownElement {
  final List<List<String>> rows;
  final bool hasHeader;

  TableElement(
      {required this.rows, this.hasHeader = true, double baseFontSize = 16.0})
      : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Table(
        border: TableBorder.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: _buildTableRows(context),
      ),
    );
  }

  List<TableRow> _buildTableRows(BuildContext context) {
    List<TableRow> tableRows = [];

    // Process header row
    if (hasHeader && rows.isNotEmpty) {
      tableRows.add(
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          children: rows[0]
              .map((cell) => _buildTableCell(context, cell, true))
              .toList(),
        ),
      );
    }

    // Process data rows
    int startIndex = hasHeader ? 1 : 0;
    for (int i = startIndex; i < rows.length; i++) {
      tableRows.add(
        TableRow(
          children: rows[i]
              .map((cell) => _buildTableCell(context, cell, false))
              .toList(),
        ),
      );
    }

    return tableRows;
  }

  Widget _buildTableCell(BuildContext context, String text, bool isHeader) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: baseFontSize - 2.0, // Slightly smaller for table cells
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}

/// Element that contains a mix of text and form elements
class MixedContentElement extends MarkdownElement {
  final List<MarkdownElement> children;
  final bool isPrintMode;

  MixedContentElement({
    required this.children,
    this.isPrintMode = false,
    double baseFontSize = 16.0,
  }) : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    if (isPrintMode) {
      // In print mode, convert all children to a text span tree
      return Text.rich(
        TextSpan(
          children: _buildTextSpans(context),
          style: TextStyle(fontSize: baseFontSize),
        ),
      );
    } else {
      // In regular mode, use Wrap layout
      return Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children.map((element) => element.build(context)).toList(),
      );
    }
  }

  // Helper method to convert children to TextSpan objects
  List<InlineSpan> _buildTextSpans(BuildContext context) {
    List<InlineSpan> spans = [];

    for (var element in children) {
      if (element is FormattedTextElement) {
        // FormattedTextElement already creates TextSpans, so we can reuse its logic
        final textWidget = element.build(context) as Text;
        if (textWidget.textSpan != null) {
          spans.add(textWidget.textSpan!);
        }
      } else if (element is ParagraphElement) {
        spans.add(TextSpan(
          text: element.text,
          style: TextStyle(fontSize: baseFontSize),
        ));
      } else if (element is FormElement) {
        // Form elements in print mode should be rendered as text
        final formWidget = element.build(context);
        if (formWidget is Text) {
          spans.add(
            TextSpan(
              text: formWidget.data,
              style: TextStyle(
                fontSize: baseFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        } else {
          spans.add(
            WidgetSpan(
              child: formWidget,
              style: TextStyle(
                fontSize: baseFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
      } else {
        // For other elements, we'll use WidgetSpan as fallback
        spans.add(WidgetSpan(
          child: element.build(context),
          alignment: PlaceholderAlignment.middle,
        ));
      }
    }

    return spans;
  }
}

/// Represents indented content with specified indent amount
class IndentElement extends MarkdownElement {
  final double indentWidth;
  final MarkdownElement content;

  IndentElement({
    required this.indentWidth,
    required this.content,
    double baseFontSize = 16.0,
  }) : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: indentWidth),
      width: double.infinity,
      child: content.build(context),
    );
  }
}

/// Element that contains a custom widget
class CustomWidgetElement extends MarkdownElement {
  final String widgetType;
  final String id;
  final Map<String, dynamic> params;
  final CustomWidgetBuilder? widgetBuilder;
  final bool isInline;
  final ValueChanged<dynamic>? onValueChanged;

  CustomWidgetElement({
    required this.widgetType,
    required this.id,
    this.params = const {},
    this.widgetBuilder,
    this.isInline = false,
    this.onValueChanged,
    double baseFontSize = 16.0,
  }) : super(baseFontSize: baseFontSize);

  @override
  Widget build(BuildContext context) {
    if (widgetBuilder != null) {
      return widgetBuilder!(context, widgetType, id, params,
          onValueChanged: onValueChanged);
    }
    // Fallback if no builder is provided
    return Text('Widget: $widgetType (No renderer available)',
        style: TextStyle(color: Colors.red, fontSize: baseFontSize));
  }
}
