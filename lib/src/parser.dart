import 'package:flutter/widgets.dart';
import 'models.dart';
import 'widgets/form_elements.dart';

class FlexMarkdownParser {
  /// Parse markdown string into a list of MarkdownElement objects
  static List<MarkdownElement> parse(String markdown) {
    List<MarkdownElement> elements = [];
    List<String> lines = markdown.split('\n');

    // For tracking list state
    List<ListItemElement> currentListItems = [];
    bool inList = false;
    bool isOrderedList = false;
    int listIndentLevel = 0;

    // For tracking blockquote state
    List<MarkdownElement> blockquoteContent = [];
    bool inBlockquote = false;

    // For tracking code block state
    bool inCodeBlock = false;
    String codeBlockContent = '';
    String? codeBlockLanguage;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Process code blocks first (they take precedence)
      if (line.trim().startsWith('```')) {
        if (!inCodeBlock) {
          // Start of code block
          inCodeBlock = true;
          codeBlockContent = '';

          // Extract language if specified
          String languagePart = line.trim().substring(3).trim();
          codeBlockLanguage = languagePart.isNotEmpty ? languagePart : null;
        } else {
          // End of code block
          elements.add(CodeBlockElement(
            code: codeBlockContent.trim(),
            language: codeBlockLanguage,
          ));
          inCodeBlock = false;
          codeBlockLanguage = null;
        }
        continue;
      }

      // If we're in a code block, just add lines to the content
      if (inCodeBlock) {
        codeBlockContent += line + '\n';
        continue;
      }

      // Process blockquotes
      if (line.trim().startsWith('>')) {
        if (!inBlockquote) {
          inBlockquote = true;
          blockquoteContent = [];
        }

        // Remove the '>' prefix and process the content
        String blockquoteLine =
            line.replaceFirst(RegExp(r'^\s*>\s?'), '').trim();
        if (blockquoteLine.isNotEmpty) {
          blockquoteContent.add(processInlineFormatting(blockquoteLine));
        } else {
          // Empty line within blockquote
          blockquoteContent.add(LineBreakElement());
        }
        continue;
      } else if (inBlockquote) {
        // End of blockquote
        elements.add(BlockquoteElement(children: blockquoteContent));
        inBlockquote = false;
      }

      // Process lists
      if (line.trim().startsWith('* ') || line.trim().startsWith('- ')) {
        // Unordered list item
        int indentLevel = _getIndentLevel(line);
        String itemContent = line.trim().substring(2).trim();

        if (!inList || isOrderedList) {
          // Start new unordered list
          if (inList) {
            // End previous ordered list
            if (isOrderedList) {
              elements
                  .add(OrderedListElement(items: List.from(currentListItems)));
            }
          }
          currentListItems = [];
          inList = true;
          isOrderedList = false;
          listIndentLevel = indentLevel;
        }

        _addListItem(
            currentListItems, itemContent, indentLevel - listIndentLevel,
            isOrderedItem: false);
        continue;
      } else if (RegExp(r'^\s*\d+\.\s').hasMatch(line)) {
        // Ordered list item
        int indentLevel = _getIndentLevel(line);
        String itemContent = line.replaceFirst(RegExp(r'^\s*\d+\.\s'), '');

        if (!inList || !isOrderedList) {
          // Start new ordered list
          if (inList) {
            // End previous unordered list
            if (!isOrderedList) {
              elements.add(
                  UnorderedListElement(items: List.from(currentListItems)));
            }
          }
          currentListItems = [];
          inList = true;
          isOrderedList = true;
          listIndentLevel = indentLevel;
        }

        _addListItem(
            currentListItems, itemContent, indentLevel - listIndentLevel,
            isOrderedItem: true);
        continue;
      } else if (inList && line.trim().isEmpty) {
        // Empty line ends the list
        if (isOrderedList) {
          elements.add(OrderedListElement(items: List.from(currentListItems)));
        } else {
          elements
              .add(UnorderedListElement(items: List.from(currentListItems)));
        }
        currentListItems = [];
        inList = false;
        continue;
      } else if (inList) {
        // Non-list line ends the list
        if (isOrderedList) {
          elements.add(OrderedListElement(items: List.from(currentListItems)));
        } else {
          elements
              .add(UnorderedListElement(items: List.from(currentListItems)));
        }
        currentListItems = [];
        inList = false;
      }

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

      // Process centered heading (e.g., -># Heading 1<-)
      if (line.startsWith('->') &&
          line.endsWith('<-') &&
          line.substring(2, line.length - 2).trim().startsWith('#')) {
        String headingLine = line.substring(2, line.length - 2).trim();
        int level = 0;
        while (level < 6 && headingLine.startsWith('#', level)) {
          level++;
        }
        String text = headingLine.substring(level).trim();
        elements
            .add(HeadingElement(level: level, text: text, isCentered: true));
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
        String innerText = line.substring(2, line.length - 2).trim();
        // Process inline formatting for the centered text
        MarkdownElement innerElement = processInlineFormatting(innerText);
        elements.add(CenterElement(child: innerElement));
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

    // Handle any unclosed elements at the end
    if (inList) {
      if (isOrderedList) {
        elements.add(OrderedListElement(items: List.from(currentListItems)));
      } else {
        elements.add(UnorderedListElement(items: List.from(currentListItems)));
      }
    }

    if (inBlockquote) {
      elements.add(BlockquoteElement(children: blockquoteContent));
    }

    if (inCodeBlock) {
      elements.add(CodeBlockElement(
        code: codeBlockContent.trim(),
        language: codeBlockLanguage,
      ));
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
        text.contains('`') ||
        (text.contains('[') && text.contains(']') && text.contains('(')))) {
      return ParagraphElement(text: text);
    }

    // Process bold, italic, code, and link formatting
    List<TextSpanElement> spans = [];
    int currentPos = 0;

    while (currentPos < text.length) {
      // Find the next formatting marker
      int boldItalicTripleAsteriskPos = text.indexOf('***', currentPos);
      int boldItalicTripleUnderscorePos = text.indexOf('___', currentPos);
      int boldDoubleAsteriskPos = text.indexOf('**', currentPos);
      int boldDoubleUnderscorePos = text.indexOf('__', currentPos);
      int italicAsteriskPos = text.indexOf('*', currentPos);
      int italicUnderscorePos = text.indexOf('_', currentPos);
      int linkOpenBracketPos = text.indexOf('[', currentPos);
      int codeTickPos = text.indexOf('`', currentPos);

      // Find the earliest marker
      int nextPos = _findEarliestPosition([
        boldItalicTripleAsteriskPos,
        boldItalicTripleUnderscorePos,
        boldDoubleAsteriskPos,
        boldDoubleUnderscorePos,
        italicAsteriskPos,
        italicUnderscorePos,
        linkOpenBracketPos,
        codeTickPos,
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

            // Check if the link text contains formatting
            if (linkText.contains('**') ||
                linkText.contains('*') ||
                linkText.contains('__') ||
                linkText.contains('_')) {
              // Process formatting inside the link text
              bool isBold = false;
              bool isItalic = false;

              // Handle bold-italic combined formatting first
              if (linkText.startsWith('***') && linkText.endsWith('***')) {
                linkText = linkText.substring(3, linkText.length - 3);
                isBold = true;
                isItalic = true;
              } else if (linkText.startsWith('___') &&
                  linkText.endsWith('___')) {
                linkText = linkText.substring(3, linkText.length - 3);
                isBold = true;
                isItalic = true;
              }
              // Handle bold formatting
              else if (linkText.startsWith('**') && linkText.endsWith('**')) {
                linkText = linkText.substring(2, linkText.length - 2);
                isBold = true;
              } else if (linkText.startsWith('__') && linkText.endsWith('__')) {
                linkText = linkText.substring(2, linkText.length - 2);
                isBold = true;
              }
              // Handle italic formatting
              else if (linkText.startsWith('*') && linkText.endsWith('*')) {
                linkText = linkText.substring(1, linkText.length - 1);
                isItalic = true;
              } else if (linkText.startsWith('_') && linkText.endsWith('_')) {
                linkText = linkText.substring(1, linkText.length - 1);
                isItalic = true;
              }

              spans.add(TextSpanElement(
                  text: linkText,
                  isBold: isBold,
                  isItalic: isItalic,
                  linkUrl: linkUrl));
            } else {
              // No formatting in link text
              spans.add(TextSpanElement(
                  text: linkText,
                  isBold: false,
                  isItalic: false,
                  linkUrl: linkUrl));
            }

            currentPos = closeParenPos + 1;
            continue;
          }
        }
        // Not a valid link format, treat as regular text
        spans.add(TextSpanElement(
            text: text[nextPos], isBold: false, isItalic: false));
        currentPos = nextPos + 1;
      }
      // Handle combined bold and italic formatting
      else if (nextPos == boldItalicTripleAsteriskPos ||
          nextPos == boldItalicTripleUnderscorePos) {
        // Bold and italic text (*** or ___)
        String marker = nextPos == boldItalicTripleAsteriskPos ? '***' : '___';
        int endMarkerPos = text.indexOf(marker, nextPos + 3);

        if (endMarkerPos != -1) {
          String boldItalicText = text.substring(nextPos + 3, endMarkerPos);
          spans.add(TextSpanElement(
              text: boldItalicText, isBold: true, isItalic: true));
          currentPos = endMarkerPos + 3;
        } else {
          // No end marker, treat as regular text
          spans.add(
              TextSpanElement(text: marker, isBold: false, isItalic: false));
          currentPos = nextPos + 3;
        }
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

      // Handle inline code formatting with backticks `code`
      if (nextPos == codeTickPos) {
        int closeCodePos = text.indexOf('`', nextPos + 1);
        if (closeCodePos != -1) {
          // Add text before code as plain text
          if (nextPos > currentPos) {
            spans.add(TextSpanElement(
              text: text.substring(currentPos, nextPos),
              isBold: false,
              isItalic: false,
            ));
          }

          // Add the code text
          spans.add(TextSpanElement(
            text: text.substring(nextPos + 1, closeCodePos),
            isBold: false,
            isItalic: false,
            isCode: true,
          ));

          currentPos = closeCodePos + 1;
          continue;
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

  // Helper method to get indent level of a line
  static int _getIndentLevel(String line) {
    int spaces = 0;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == ' ') {
        spaces++;
      } else {
        break;
      }
    }
    return spaces ~/ 2; // Every 2 spaces is one indent level
  }

  // Helper method to add list items with proper nesting
  static void _addListItem(
      List<ListItemElement> items, String content, int depth,
      {required bool isOrderedItem}) {
    MarkdownElement contentElement = processInlineFormatting(content);

    if (depth == 0) {
      // Add to the main list
      items.add(ListItemElement(
        content: contentElement,
        isUnordered: !isOrderedItem,
        depth: depth,
      ));
    } else {
      // Add to the nested list of the last item
      _addNestedListItem(items.last, contentElement, depth - 1,
          isOrderedItem: isOrderedItem);
    }
  }

  // Helper method to add nested list items
  static void _addNestedListItem(
      ListItemElement parent, MarkdownElement content, int remainingDepth,
      {required bool isOrderedItem}) {
    if (parent.nestedItems == null) {
      parent = ListItemElement(
        content: parent.content,
        nestedItems: [],
        isUnordered: parent.isUnordered,
        depth: parent.depth,
      );
    }

    if (remainingDepth == 0) {
      parent.nestedItems!.add(ListItemElement(
        content: content,
        isUnordered: !isOrderedItem,
        depth: parent.depth + 1,
      ));
    } else if (parent.nestedItems!.isNotEmpty) {
      _addNestedListItem(parent.nestedItems!.last, content, remainingDepth - 1,
          isOrderedItem: isOrderedItem);
    }
  }
}
