import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

// Add a typedef for the form value changed callback
typedef FormValueChangedCallback = void Function(String id, dynamic value);

/// Base class for all markdown elements
abstract class MarkdownElement {
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
  });

  @override
  Widget build(BuildContext context) {
    double fontSize;
    switch (level) {
      case 1:
        fontSize = 32.0;
        break;
      case 2:
        fontSize = 28.0;
        break;
      case 3:
        fontSize = 24.0;
        break;
      case 4:
        fontSize = 20.0;
        break;
      case 5:
        fontSize = 18.0;
        break;
      case 6:
      default:
        fontSize = 16.0;
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

  ParagraphElement({required this.text, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16.0),
      textAlign: textAlign,
    );
  }
}

/// Represents a line break element
class LineBreakElement extends MarkdownElement {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16.0);
  }
}

/// Represents a centered line element
class CenterElement extends MarkdownElement {
  final MarkdownElement child;

  CenterElement({required this.child});

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

  FormElement({required this.id, this.onValueChanged});
}

/// Represents a span of text with optional formatting
class TextSpanElement {
  final String text;
  final bool isBold;
  final bool isItalic;
  final String? linkUrl;
  final bool isCode;
  final String? color; // Add color property

  TextSpanElement({
    required this.text,
    required this.isBold,
    required this.isItalic,
    this.linkUrl,
    this.isCode = false,
    this.color, // Add color parameter
  });
}

/// Represents a paragraph with formatted text spans
class FormattedTextElement extends MarkdownElement {
  final List<TextSpanElement> spans;

  FormattedTextElement({required this.spans});

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

  LinkElement({required this.text, required this.url});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF2196F3), // Material blue
          decoration: TextDecoration.underline,
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

  UnorderedListElement({required this.items});

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

  OrderedListElement({required this.items});

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
                style: const TextStyle(fontSize: 16.0),
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
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            isUnordered ? '•' : '', // Bullet for unordered lists
            style: const TextStyle(fontSize: 16.0),
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

  BlockquoteElement({required this.children});

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

  CodeBlockElement({required this.code, this.language});

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
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14.0,
        ),
      ),
    );
  }
}

/// Represents a horizontal rule element
class HorizontalRuleElement extends MarkdownElement {
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

  TableElement({required this.rows, this.hasHeader = true});

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
          fontSize: 14.0,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}

/// Element that contains a mix of text and form elements
class MixedContentElement extends MarkdownElement {
  final List<MarkdownElement> children;

  MixedContentElement({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children.map((element) => element.build(context)).toList(),
    );
  }
}

/// Represents indented content with specified indent amount
class IndentElement extends MarkdownElement {
  final double indentWidth;
  final MarkdownElement content;

  IndentElement({
    required this.indentWidth,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: indentWidth),
      width: double.infinity,
      child: content.build(context),
    );
  }
}
