import 'package:flutter/widgets.dart';
import 'models.dart';
import 'widgets/form_elements.dart';

class FlexMarkdownParser {
  /// Parse markdown string into a list of MarkdownElement objects
  static List<MarkdownElement> parse(String markdown) {
    List<MarkdownElement> elements = [];
    List<String> lines = markdown.split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Skip empty lines
      if (line.trim().isEmpty) {
        elements.add(LineBreakElement());
        continue;
      }

      // Process link-only line (e.g., [Link Text](https://example.com))
      final RegExp linkRegex = RegExp(r'^\[(.+?)\]\((.+?)\)$');
      if (linkRegex.hasMatch(line.trim())) {
        final match = linkRegex.firstMatch(line.trim())!;
        final text = match.group(1)!;
        final url = match.group(2)!;
        elements.add(LinkElement(text: text, url: url));
        continue;
      }

      // Process heading (e.g., # Heading 1)
      if (line.startsWith('#')) {
        int level = 0;
        while (level < 6 && line.startsWith('#', level)) {
          level++;
        }
        String text = line.substring(level).trim();
        elements.add(HeadingElement(level: level, text: text));
        continue;
      }

      // Process centered text (e.g., ->Centered Text<-)
      if (line.startsWith('->') && line.endsWith('<-')) {
        String text = line.substring(2, line.length - 2).trim();
        elements.add(CenterElement(text: text));
        continue;
      }

      // Process form elements
      if (line.contains('{{') && line.contains('}}')) {
        String beforeInput = line.substring(0, line.indexOf('{{'));
        String formContent = _extractBetween(line, '{{', '}}');
        String afterInput = line.substring(line.indexOf('}}') + 2);

        if (beforeInput.isNotEmpty) {
          elements.add(ParagraphElement(text: beforeInput));
        }

        elements.add(_parseFormElement(formContent));

        if (afterInput.isNotEmpty) {
          elements.add(ParagraphElement(text: afterInput));
        }

        continue;
      }

      // Regular paragraph with potential inline formatting
      elements.add(processInlineFormatting(line));
    }

    return elements;
  }

  /// Process inline formatting like bold and italic text
  static MarkdownElement processInlineFormatting(String text) {
    // Check if text contains formatting indicators
    if (!(text.contains('**') ||
        text.contains('__') ||
        text.contains('*') ||
        text.contains('_') ||
        (text.contains('[') && text.contains(']') && text.contains('(')))) {
      return ParagraphElement(text: text);
    }

    // Process bold, italic, and link formatting
    List<TextSpanElement> spans = [];
    int currentPos = 0;

    while (currentPos < text.length) {
      // Find the next formatting marker
      int boldDoubleAsteriskPos = text.indexOf('**', currentPos);
      int boldDoubleUnderscorePos = text.indexOf('__', currentPos);
      int italicAsteriskPos = text.indexOf('*', currentPos);
      int italicUnderscorePos = text.indexOf('_', currentPos);
      int linkOpenBracketPos = text.indexOf('[', currentPos);

      // Find the earliest marker
      int nextPos = _findEarliestPosition([
        boldDoubleAsteriskPos,
        boldDoubleUnderscorePos,
        italicAsteriskPos,
        italicUnderscorePos,
        linkOpenBracketPos,
      ]);

      if (nextPos == -1) {
        // No more formatting markers, add the rest as plain text
        if (currentPos < text.length) {
          spans.add(TextSpanElement(
              text: text.substring(currentPos),
              isBold: false,
              isItalic: false));
        }
        break;
      }

      // Add the text before the marker as plain text
      if (nextPos > currentPos) {
        spans.add(TextSpanElement(
            text: text.substring(currentPos, nextPos),
            isBold: false,
            isItalic: false));
      }

      // Handle the link formatting [text](url)
      if (nextPos == linkOpenBracketPos) {
        int closeBracketPos = text.indexOf(']', nextPos);
        if (closeBracketPos != -1 &&
            closeBracketPos + 1 < text.length &&
            text[closeBracketPos + 1] == '(') {
          int closeParenPos = text.indexOf(')', closeBracketPos);
          if (closeParenPos != -1) {
            String linkText = text.substring(nextPos + 1, closeBracketPos);
            String linkUrl = text.substring(closeBracketPos + 2, closeParenPos);
            spans.add(TextSpanElement(
                text: linkText,
                isBold: false,
                isItalic: false,
                linkUrl: linkUrl));
            currentPos = closeParenPos + 1;
            continue;
          }
        }
        // Not a valid link format, treat as regular text
        spans.add(TextSpanElement(
            text: text[nextPos], isBold: false, isItalic: false));
        currentPos = nextPos + 1;
      }
      // Handle the formatting for bold and italic
      else if (nextPos == boldDoubleAsteriskPos ||
          nextPos == boldDoubleUnderscorePos) {
        // Bold text (** or __)
        String marker = nextPos == boldDoubleAsteriskPos ? '**' : '__';
        int endMarkerPos = text.indexOf(marker, nextPos + 2);

        if (endMarkerPos != -1) {
          String boldText = text.substring(nextPos + 2, endMarkerPos);
          spans.add(
              TextSpanElement(text: boldText, isBold: true, isItalic: false));
          currentPos = endMarkerPos + 2;
        } else {
          // No end marker, treat as regular text
          spans.add(
              TextSpanElement(text: marker, isBold: false, isItalic: false));
          currentPos = nextPos + 2;
        }
      } else {
        // Italic text (* or _)
        String marker = nextPos == italicAsteriskPos ? '*' : '_';
        int endMarkerPos = text.indexOf(marker, nextPos + 1);

        if (endMarkerPos != -1) {
          String italicText = text.substring(nextPos + 1, endMarkerPos);
          spans.add(
              TextSpanElement(text: italicText, isBold: false, isItalic: true));
          currentPos = endMarkerPos + 1;
        } else {
          // No end marker, treat as regular text
          spans.add(
              TextSpanElement(text: marker, isBold: false, isItalic: false));
          currentPos = nextPos + 1;
        }
      }
    }

    return FormattedTextElement(spans: spans);
  }

  /// Find the earliest valid position, ignoring -1 values
  static int _findEarliestPosition(List<int> positions) {
    int earliest = -1;
    for (int pos in positions) {
      if (pos != -1 && (earliest == -1 || pos < earliest)) {
        earliest = pos;
      }
    }
    return earliest;
  }

  /// Extract text between two delimiters
  static String _extractBetween(String text, String start, String end) {
    final startIndex = text.indexOf(start) + start.length;
    final endIndex = text.indexOf(end, startIndex);
    if (startIndex >= 0 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex);
    }
    return '';
  }

  /// Parse form element syntax
  static MarkdownElement _parseFormElement(String formContent) {
    List<String> parts = formContent.split('|');
    String type = parts[0].trim().toLowerCase();
    String id = parts.length > 1 ? parts[1].trim() : 'default_id';

    switch (type) {
      case 'textfield':
        String label = parts.length > 2 ? parts[2].trim() : '';
        String hint = parts.length > 3 ? parts[3].trim() : '';
        return TextFieldElement(id: id, label: label, hint: hint);

      case 'select':
        String label = parts.length > 2 ? parts[2].trim() : '';
        List<String> options = parts.length > 3
            ? parts[3].split(',').map((e) => e.trim()).toList()
            : [];
        return SelectElement(id: id, label: label, options: options);

      case 'checkbox':
        String label = parts.length > 2 ? parts[2].trim() : '';
        bool initialValue =
            parts.length > 3 ? parts[3].trim() == 'true' : false;
        return CheckboxElement(
          id: id,
          label: label,
          initialValue: initialValue,
        );

      case 'radio':
        String label = parts.length > 2 ? parts[2].trim() : '';
        String groupName = parts.length > 3 ? parts[3].trim() : 'defaultGroup';
        bool selected = parts.length > 4 ? parts[4].trim() == 'true' : false;
        return RadioElement(
          id: id,
          label: label,
          groupName: groupName,
          selected: selected,
        );

      default:
        return ParagraphElement(text: 'Unsupported form element: $type');
    }
  }
}
