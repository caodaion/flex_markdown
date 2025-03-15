import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'models.dart';
import 'widgets/form_elements.dart';
import 'models/form_field_configurations.dart'; // Add this import

class FlexMarkdownParser {
  /// Parse markdown string into a list of MarkdownElement objects
  static List<MarkdownElement> parse(String markdown,
      {Map<String, dynamic>? formValues,
      FormValueChangedCallback? handleFormValueChanged,
      bool isPrintMode = false,
      double baseFontSize = 16.0,
      Map<String, FormFieldConfiguration>? formFieldConfigurations,
      Map<String, CustomWidgetBuilder>? customWidgetBuilders,
      ValueChanged<dynamic>? handleWidgetValueChanged}) {
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

    // For tracking table state
    bool inTable = false;
    List<List<String>> tableRows = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Process indent syntax [[indent|20|content]]
      final RegExp indentRegex = RegExp(r'^\[\[indent\|(\d+)\|(.*)\]\]$');
      if (indentRegex.hasMatch(line.trim())) {
        final match = indentRegex.firstMatch(line.trim())!;
        final indentAmount = double.parse(match.group(1)!);
        final content = match.group(2)!;

        // Check if the indented content contains form elements
        if (content.contains('{{') && content.contains('}}')) {
          // Process as mixed content to handle form elements within indented blocks
          MarkdownElement mixedContent = _processMixedContent(content,
              handleFormValueChanged: handleFormValueChanged,
              formValues: formValues,
              isPrintMode: isPrintMode,
              baseFontSize: baseFontSize,
              formFieldConfigurations: formFieldConfigurations,
              customWidgetBuilders: customWidgetBuilders,
              handleWidgetValueChanged:
                  handleWidgetValueChanged); // Pass formFieldConfigurations
          elements.add(IndentElement(
            indentWidth: indentAmount,
            content: mixedContent,
          ));
        } else {
          // Process the content inside the indent as regular formatted text (no form elements)
          MarkdownElement innerElement = processInlineFormatting(content,
              baseFontSize: baseFontSize); // Pass base font size
          elements.add(IndentElement(
            indentWidth: indentAmount,
            content: innerElement,
          ));
        }
        continue;
      }

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

      // Process horizontal rule
      if (RegExp(r'^\s*(---|\*\*\*|___)\s*$').hasMatch(line)) {
        // End any ongoing elements
        if (inTable) {
          elements.add(TableElement(rows: List.from(tableRows)));
          tableRows = [];
          inTable = false;
        }

        elements.add(HorizontalRuleElement());
        continue;
      }

      // Process tables
      if (line.trim().startsWith('|') && line.trim().endsWith('|')) {
        // Start or continue table
        if (!inTable) {
          inTable = true;
          tableRows = [];
        }

        // Extract cells from the line
        List<String> cells = line
            .trim()
            .substring(1, line.trim().length - 1)
            .split('|')
            .map((cell) => cell.trim())
            .toList();

        // Skip separator row (e.g., |---|---|---|)
        if (cells.every((cell) => RegExp(r'^:?-+:?$').hasMatch(cell))) {
          continue;
        }

        tableRows.add(cells);
        continue;
      } else if (inTable) {
        // End of table
        elements.add(TableElement(rows: List.from(tableRows)));
        tableRows = [];
        inTable = false;
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
          blockquoteContent.add(processInlineFormatting(blockquoteLine,
              baseFontSize: baseFontSize)); // Pass base font size
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

        // Process inline formatting in the heading text
        MarkdownElement innerElement = processInlineFormatting(text,
            baseFontSize: baseFontSize); // Pass base font size

        // If the innerElement is a FormattedTextElement, use its spans to create a formatted heading
        if (innerElement is FormattedTextElement) {
          elements.add(HeadingElement(
            level: level,
            text: text,
            isCentered: true,
            formattedContent: innerElement,
            baseFontSize: baseFontSize, // Pass base font size
          ));
        } else {
          // Fallback to original behavior for simple text
          elements.add(HeadingElement(
            level: level,
            text: text,
            isCentered: true,
            baseFontSize: baseFontSize, // Pass base font size
          ));
        }
        continue;
      }

      // Process heading (e.g., # Heading 1)
      if (line.startsWith('#')) {
        int level = 0;
        while (level < 6 && line.startsWith('#', level)) {
          level++;
        }
        String text = line.substring(level).trim();

        // Process inline formatting in the heading text
        MarkdownElement innerElement = processInlineFormatting(text,
            baseFontSize: baseFontSize); // Pass base font size

        // If the innerElement is a FormattedTextElement, use its spans to create a formatted heading
        if (innerElement is FormattedTextElement) {
          elements.add(HeadingElement(
            level: level,
            text: text,
            formattedContent: innerElement,
            baseFontSize: baseFontSize, // Pass base font size
          ));
        } else {
          // Fallback to original behavior for simple text
          elements.add(HeadingElement(
              level: level,
              text: text,
              baseFontSize: baseFontSize)); // Pass base font size
        }
        continue;
      }

      // Process centered text (e.g., ->Centered Text<-)
      if (line.startsWith('->') && line.endsWith('<-')) {
        String innerText = line.substring(2, line.length - 2).trim();
        // Check if the centered text contains form elements
        if (innerText.contains('{{') && innerText.contains('}}')) {
          // Process as mixed content
          MarkdownElement mixedContent = _processMixedContent(innerText,
              handleFormValueChanged: handleFormValueChanged,
              formValues: formValues,
              isPrintMode: isPrintMode,
              baseFontSize: baseFontSize,
              formFieldConfigurations: formFieldConfigurations,
              customWidgetBuilders: customWidgetBuilders,
              handleWidgetValueChanged:
                  handleWidgetValueChanged); // Pass formFieldConfigurations
          elements.add(CenterElement(child: mixedContent));
        } else {
          // Process inline formatting for the centered text (no form elements)
          MarkdownElement innerElement = processInlineFormatting(innerText,
              baseFontSize: baseFontSize); // Pass base font size
          elements.add(CenterElement(child: innerElement));
        }
        continue;
      }

      // Process form elements
      if (line.contains('{{') && line.contains('}}')) {
        // Check if the form element is the entire line or part of a paragraph
        if (line.trim().startsWith('{{') && line.trim().endsWith('}}')) {
          // Standalone form element (existing behavior)
          String formContent = _extractBetween(line, '{{', '}}');
          elements.add(_parseFormElement(formContent,
              handleFormValueChanged: handleFormValueChanged,
              formValues: formValues,
              isPrintMode: isPrintMode,
              formFieldConfigurations: formFieldConfigurations,
              customWidgetBuilders: customWidgetBuilders,
              handleWidgetValueChanged:
                  handleWidgetValueChanged)); // Pass isPrintMode
        } else {
          // Inline form element - process as mixed content
          elements.add(_processMixedContent(line,
              handleFormValueChanged: handleFormValueChanged,
              formValues: formValues,
              isPrintMode: isPrintMode,
              baseFontSize: baseFontSize,
              formFieldConfigurations: formFieldConfigurations,
              customWidgetBuilders: customWidgetBuilders,
              handleWidgetValueChanged:
                  handleWidgetValueChanged)); // Pass formFieldConfigurations
        }
        continue;
      }

      // Regular paragraph with potential inline formatting
      elements.add(processInlineFormatting(line,
          baseFontSize: baseFontSize)); // Pass base font size
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

    // Handle unclosed table at the end
    if (inTable && tableRows.isNotEmpty) {
      elements.add(TableElement(rows: List.from(tableRows)));
    }

    return elements;
  }

  /// Process inline formatting like bold and italic text
  static MarkdownElement processInlineFormatting(String text,
      {double baseFontSize = 16.0}) {
    // Check if text contains formatting indicators
    if (!(text.contains('**') ||
        text.contains('__') ||
        text.contains('*') ||
        text.contains('_') ||
        text.contains('`') ||
        text.contains('++') || // Add check for underline syntax
        text.contains('{color:') || // Add check for color syntax
        (text.contains('[') && text.contains(']') && text.contains('(')))) {
      return ParagraphElement(text: text);
    }

    // Process color formatting first, separately from other formatting
    if (text.contains('{color:')) {
      return _processColorFormatting(text,
          baseFontSize: baseFontSize); // Pass base font size
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
      int underlinePos =
          text.indexOf('++', currentPos); // Add underline marker position

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
        underlinePos, // Add to earliest position check
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

      // Handle underline formatting with ++text++
      if (nextPos == underlinePos) {
        int endUnderlinePos = text.indexOf('++', nextPos + 2);
        if (endUnderlinePos != -1) {
          // Add text before underline as plain text
          if (nextPos > currentPos) {
            spans.add(TextSpanElement(
              text: text.substring(currentPos, nextPos),
              isBold: false,
              isItalic: false,
              isUnderline: false,
            ));
          }

          // Add the underlined text
          spans.add(TextSpanElement(
            text: text.substring(nextPos + 2, endUnderlinePos),
            isBold: false,
            isItalic: false,
            isUnderline: true,
          ));

          currentPos = endUnderlinePos + 2;
          continue;
        }
      }
    }

    return FormattedTextElement(
        spans: spans, baseFontSize: baseFontSize); // Pass base font size
  }

  /// Process text with color formatting
  static MarkdownElement _processColorFormatting(String text,
      {double baseFontSize = 16.0}) {
    List<TextSpanElement> spans = [];
    int currentPos = 0;

    while (currentPos < text.length) {
      int colorStartPos = text.indexOf('{color:', currentPos);

      if (colorStartPos == -1) {
        // No more color formatting, add the rest as plain text with potential formatting
        if (currentPos < text.length) {
          // Process the remaining text for other formatting types
          String remainingText = text.substring(currentPos);

          // Check if there's any formatting in the remaining text
          if (remainingText.contains('**') ||
              remainingText.contains('*') ||
              remainingText.contains('__') ||
              remainingText.contains('_') ||
              remainingText.contains('`') ||
              (remainingText.contains('[') &&
                  remainingText.contains(']') &&
                  remainingText.contains('('))) {
            // Process and add the formatted spans from the remaining text
            FormattedTextElement formatted = processInlineFormatting(
                    remainingText,
                    baseFontSize: baseFontSize)
                as FormattedTextElement; // Pass base font size
            spans.addAll(formatted.spans);
          } else {
            // Simple text, no formatting
            spans.add(TextSpanElement(
              text: remainingText,
              isBold: false,
              isItalic: false,
            ));
          }
        }
        break;
      }

      // Add text before the color marker with potential formatting
      if (colorStartPos > currentPos) {
        String beforeText = text.substring(currentPos, colorStartPos);

        // Check if there's any formatting in the text before color marker
        if (beforeText.contains('**') ||
            beforeText.contains('*') ||
            beforeText.contains('__') ||
            beforeText.contains('_') ||
            beforeText.contains('`') ||
            (beforeText.contains('[') &&
                beforeText.contains(']') &&
                beforeText.contains('('))) {
          // Process and add the formatted spans
          FormattedTextElement formatted =
              processInlineFormatting(beforeText, baseFontSize: baseFontSize)
                  as FormattedTextElement; // Pass base font size
          spans.addAll(formatted.spans);
        } else {
          // Simple text, no formatting
          spans.add(TextSpanElement(
            text: beforeText,
            isBold: false,
            isItalic: false,
          ));
        }
      }

      int colorSeparatorPos = text.indexOf('|', colorStartPos);
      int colorEndPos = text.indexOf('}', colorStartPos);

      if (colorSeparatorPos != -1 &&
          colorEndPos != -1 &&
          colorSeparatorPos < colorEndPos) {
        String colorValue =
            text.substring(colorStartPos + 7, colorSeparatorPos);
        String coloredText = text.substring(colorSeparatorPos + 1, colorEndPos);

        // Check if the colored text contains formatting
        if (coloredText.contains('**') ||
            coloredText.contains('*') ||
            coloredText.contains('__') ||
            coloredText.contains('_') ||
            coloredText.contains('`') ||
            (coloredText.contains('[') &&
                coloredText.contains(']') &&
                coloredText.contains('('))) {
          // Process the formatting inside the colored text
          FormattedTextElement formatted =
              processInlineFormatting(coloredText, baseFontSize: baseFontSize)
                  as FormattedTextElement; // Pass base font size

          // Apply the color to all spans within the coloredText
          for (var span in formatted.spans) {
            spans.add(TextSpanElement(
              text: span.text,
              isBold: span.isBold,
              isItalic: span.isItalic,
              isCode: span.isCode,
              linkUrl: span.linkUrl,
              color: colorValue, // Apply the color to each span
            ));
          }
        } else {
          // No formatting in the colored text
          spans.add(TextSpanElement(
            text: coloredText,
            isBold: false,
            isItalic: false,
            color: colorValue,
          ));
        }

        currentPos = colorEndPos + 1;
      } else {
        // Invalid color format, treat as regular text
        spans.add(TextSpanElement(
          text: text.substring(colorStartPos, colorStartPos + 7),
          isBold: false,
          isItalic: false,
        ));
        currentPos = colorStartPos + 7;
      }
    }

    return FormattedTextElement(
        spans: spans, baseFontSize: baseFontSize); // Pass base font size
  }

  /// Process text with potentially inline form elements
  static MarkdownElement _processMixedContent(String text,
      {Map<String, dynamic>? formValues,
      FormValueChangedCallback? handleFormValueChanged,
      bool isPrintMode = false,
      double baseFontSize = 16.0,
      Map<String, FormFieldConfiguration>? formFieldConfigurations,
      Map<String, CustomWidgetBuilder>? customWidgetBuilders,
      ValueChanged<dynamic>? handleWidgetValueChanged}) {
    // Add this parameter

    // Added isPrintMode parameter
    // If there are no form elements, process as regular text with formatting
    if (!text.contains('{{') || !text.contains('}}')) {
      return processInlineFormatting(text,
          baseFontSize: baseFontSize); // Pass base font size
    }

    List<MarkdownElement> elements = [];
    int currentPos = 0;

    while (currentPos < text.length) {
      int formStartPos = text.indexOf('{{', currentPos);

      if (formStartPos == -1) {
        // No more form elements, process the rest as formatted text
        String remainingText = text.substring(currentPos);
        if (remainingText.isNotEmpty) {
          elements.add(processInlineFormatting(remainingText,
              baseFontSize: baseFontSize)); // Pass base font size
        }
        break;
      }

      // Process text before form element
      if (formStartPos > currentPos) {
        String beforeText = text.substring(currentPos, formStartPos);
        elements.add(processInlineFormatting(beforeText,
            baseFontSize: baseFontSize)); // Pass base font size
      }

      // Find the end of the form element
      int formEndPos = text.indexOf('}}', formStartPos);
      if (formEndPos == -1) {
        // No closing bracket, treat as regular text
        String remainingText = text.substring(currentPos);
        elements.add(processInlineFormatting(remainingText,
            baseFontSize: baseFontSize)); // Pass base font size
        break;
      }

      // Extract and parse the form element
      String formContent = text.substring(formStartPos + 2, formEndPos);
      elements.add(_parseFormElement(formContent,
          isInline: true,
          formValues: formValues,
          handleFormValueChanged: handleFormValueChanged,
          isPrintMode: isPrintMode,
          formFieldConfigurations: formFieldConfigurations,
          customWidgetBuilders: customWidgetBuilders,
          handleWidgetValueChanged:
              handleWidgetValueChanged)); // Pass formFieldConfigurations

      // Move position after this form element
      currentPos = formEndPos + 2;
    }

    return MixedContentElement(
        children: elements,
        isPrintMode: isPrintMode, // Pass isPrintMode here
        baseFontSize: baseFontSize); // Pass base font size
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
  static MarkdownElement _parseFormElement(String formContent,
      {bool isInline = false,
      Map<String, dynamic>? formValues,
      FormValueChangedCallback? handleFormValueChanged,
      bool isPrintMode = false,
      Map<String, FormFieldConfiguration>? formFieldConfigurations,
      Map<String, CustomWidgetBuilder>? customWidgetBuilders,
      ValueChanged<dynamic>? handleWidgetValueChanged}) {
    // Add this parameter

    // Added isPrintMode parameter
    // Check if it's a custom widget (starts with "widget:")
    if (formContent.startsWith('widget:')) {
      // Strip the 'widget:' prefix
      String content = formContent.substring(7);
      return _parseCustomWidget(content,
          isInline: isInline,
          customWidgetBuilders: customWidgetBuilders,
          handleWidgetValueChanged: handleWidgetValueChanged);
    }

    List<String> parts = formContent.split('|');
    String type = parts[0].trim().toLowerCase();
    String id = parts.length > 1 ? parts[1].trim() : 'default_id';
    var triggerFormConfig = formFieldConfigurations != null &&
            formFieldConfigurations.containsKey(id)
        ? formFieldConfigurations[id]
        : null;

    var triggerFormFieldLabel = triggerFormConfig?.label;
    var triggerFormFieldPlaceholder = triggerFormConfig?.placeholder;
    var triggerFormFieldPlaceholderDots = triggerFormConfig?.placeholderDots;
    var triggerFormFieldOptions = triggerFormConfig?.options;
    var triggerFormFieldOnValueChanged = triggerFormConfig?.onValueChanged;
    var triggerFormFieldGroupName = triggerFormConfig?.groupName;
    var triggerFormFieldSelected = triggerFormConfig?.selected;
    var triggerFormFieldDefaultSelected = triggerFormConfig?.defaultSelected;
    switch (type) {
      case 'textfield':
        String label = triggerFormFieldLabel != null
            ? triggerFormFieldLabel
            : parts.length > 2
                ? parts[2].trim()
                : '';
        String hint = triggerFormFieldPlaceholder != null
            ? triggerFormFieldPlaceholder
            : parts.length > 3
                ? parts[3].trim()
                : '';
        // Use formValues if available, otherwise use the default value (parts[4]) if provided
        String? defaultValue = parts.length > 4 ? parts[4].trim() : null;
        String? initialValue = formValues != null && formValues.containsKey(id)
            ? formValues[id]?.toString()
            : defaultValue;
        // Add a placeholderDots parameter
        int? placeholderDots = triggerFormFieldPlaceholderDots != null
            ? triggerFormFieldPlaceholderDots
            : parts.length > 5 && parts[5].trim().isNotEmpty
                ? int.tryParse(parts[5].trim())
                : null;

        return TextFieldElement(
            id: id,
            label: label,
            hint: hint,
            initialValue: initialValue,
            isInline: isInline,
            handleFormValueChanged: handleFormValueChanged,
            onValueChanged: triggerFormFieldOnValueChanged != null
                ? triggerFormFieldOnValueChanged
                : null,
            isPrintMode: isPrintMode,
            placeholderDots: placeholderDots); // Add placeholderDots parameter

      case 'select':
        String label = triggerFormFieldLabel != null
            ? triggerFormFieldLabel
            : parts.length > 2
                ? parts[2].trim()
                : '';
        List<String> options = triggerFormFieldOptions != null
            ? triggerFormFieldOptions
            : parts.length > 3
                ? parts[3].split(',').map((e) => e.trim()).toList()
                : [];
        // Use formValues if available, otherwise use the default value (parts[4]) if valid
        String? defaultValue =
            parts.length > 4 && options.contains(parts[4].trim())
                ? parts[4].trim()
                : null;
        String? initialValue = formValues != null && formValues.containsKey(id)
            ? formValues[id]?.toString()
            : defaultValue;
        // Add a placeholderDots parameter
        int? placeholderDots = triggerFormFieldPlaceholderDots != null
            ? triggerFormFieldPlaceholderDots
            : parts.length > 5 && parts[5].trim().isNotEmpty
                ? int.tryParse(parts[5].trim())
                : null;

        return SelectElement(
            id: id,
            label: label,
            options: options,
            initialValue: initialValue,
            isInline: isInline,
            handleFormValueChanged: handleFormValueChanged,
            onValueChanged: triggerFormFieldOnValueChanged != null
                ? triggerFormFieldOnValueChanged
                : null,
            isPrintMode: isPrintMode,
            placeholderDots: placeholderDots); // Add placeholderDots parameter

      case 'checkbox':
        String label = triggerFormFieldLabel != null
            ? triggerFormFieldLabel
            : parts.length > 2
                ? parts[2].trim()
                : '';
        // Use formValues if available, otherwise use the default value (parts[3]) if provided
        bool defaultValue =
            parts.length > 3 ? parts[3].trim() == 'true' : false;
        bool initialValue = formValues != null && formValues.containsKey(id)
            ? formValues[id] == true
            : defaultValue;
        // Add a placeholderDots parameter
        int? placeholderDots = triggerFormFieldPlaceholderDots != null
            ? triggerFormFieldPlaceholderDots
            : parts.length > 4 && parts[4].trim().isNotEmpty
                ? int.tryParse(parts[4].trim())
                : null;

        return CheckboxElement(
          id: id,
          label: label,
          initialValue: initialValue,
          isInline: isInline,
          handleFormValueChanged: handleFormValueChanged,
          onValueChanged: triggerFormFieldOnValueChanged != null
              ? triggerFormFieldOnValueChanged
              : null,
          isPrintMode: isPrintMode,
          placeholderDots: placeholderDots, // Add placeholderDots parameter
        );

      case 'radio':
        String label = triggerFormFieldLabel != null
            ? triggerFormFieldLabel
            : parts.length > 2
                ? parts[2].trim()
                : '';
        String groupName = triggerFormFieldGroupName != null
            ? triggerFormFieldGroupName
            : parts.length > 3
                ? parts[3].trim()
                : 'defaultGroup';
        // Use formValues if available, otherwise use the default value (parts[4]) if provided
        bool defaultSelected = triggerFormFieldDefaultSelected != null
            ? triggerFormFieldDefaultSelected
            : parts.length > 4
                ? parts[4].trim() == 'true'
                : false;
        bool selected = triggerFormFieldSelected != null
            ? triggerFormFieldSelected
            : formValues != null && formValues.containsKey(groupName)
                ? formValues[groupName] == id
                : defaultSelected;

        // Add a placeholderDots parameter
        int? placeholderDots = parts.length > 5 && parts[5].trim().isNotEmpty
            ? int.tryParse(parts[5].trim())
            : null;

        return RadioElement(
          id: id,
          label: label,
          groupName: groupName,
          selected: selected,
          isInline: isInline,
          handleFormValueChanged: handleFormValueChanged,
          onValueChanged: triggerFormFieldOnValueChanged != null
              ? triggerFormFieldOnValueChanged
              : null,
          isPrintMode: isPrintMode,
          placeholderDots: placeholderDots, // Add placeholderDots parameter
        );

      default:
        return ParagraphElement(text: 'Unsupported form element: $type');
    }
  }

  /// Parse custom widget element syntax
  static MarkdownElement _parseCustomWidget(String content,
      {bool isInline = false,
      Map<String, CustomWidgetBuilder>? customWidgetBuilders,
      ValueChanged<dynamic>? handleWidgetValueChanged}) {
    // Extract widget type, id, and parameters
    List<String> parts = content.split('|');
    if (parts.isEmpty) {
      return ParagraphElement(text: 'Invalid widget syntax');
    }

    String widgetType = parts[0].trim();
    String id = parts.length > 1 ? parts[1].trim() : '';

    // Parse parameters
    Map<String, dynamic> params = {};
    if (parts.length > 2) {
      String paramStr = parts.sublist(2).join('|');
      // Try to split by semicolons for multiple parameters
      List<String> paramPairs = paramStr.split(';');
      for (var pair in paramPairs) {
        List<String> keyValue = pair.split(':');
        if (keyValue.length == 2) {
          // Try to parse as int or double or bool, fallback to string
          String value = keyValue[1].trim();
          dynamic parsedValue = value;

          if (value.toLowerCase() == 'true') {
            parsedValue = true;
          } else if (value.toLowerCase() == 'false') {
            parsedValue = false;
          } else {
            try {
              parsedValue = int.parse(value);
            } catch (_) {
              try {
                parsedValue = double.parse(value);
              } catch (_) {
                // Keep as string
              }
            }
          }

          params[keyValue[0].trim()] = parsedValue;
        }
      }
    }

    // Get the custom widget builder if available
    CustomWidgetBuilder? builder = customWidgetBuilders != null &&
            customWidgetBuilders.containsKey(widgetType)
        ? customWidgetBuilders[widgetType]
        : null;

    return CustomWidgetElement(
      widgetType: widgetType,
      id: id,
      params: params,
      widgetBuilder: builder,
      isInline: isInline,
      onValueChanged: handleWidgetValueChanged,
    );
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
