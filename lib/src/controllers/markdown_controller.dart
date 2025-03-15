import 'package:flutter/widgets.dart';

class MarkdownController {
  final TextEditingController textController;

  MarkdownController({required this.textController});

  /// Inserts the given formatting characters around the selected text
  void insertFormattingAround(String formatting) {
    final text = textController.text;
    final selection = textController.selection;

    if (selection.isValid) {
      final selectedText = selection.textInside(text);
      final newText = '${formatting}${selectedText}${formatting}';
      textController.value = textController.value.copyWith(
        text: selection.textBefore(text) + newText + selection.textAfter(text),
        selection: TextSelection.collapsed(
          offset: selection.start + newText.length,
        ),
      );
    }
  }

  /// Adds necessary formatting to create bold text
  void addBoldFormatting() {
    insertFormattingAround('**');
  }

  /// Adds necessary formatting to create italic text
  void addItalicFormatting() {
    insertFormattingAround('*');
  }

  /// Adds necessary formatting to create underlined text
  void addUnderlineFormatting() {
    insertFormattingAround('++');
  }
}
