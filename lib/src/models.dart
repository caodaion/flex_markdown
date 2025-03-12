import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Base class for all markdown elements
abstract class MarkdownElement {
  Widget build(BuildContext context);
}

/// Represents a heading element (h1-h6)
class HeadingElement extends MarkdownElement {
  final int level; // 1-6 for h1-h6
  final String text;
  final TextAlign? textAlign;

  HeadingElement({required this.level, required this.text, this.textAlign});

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        textAlign: textAlign,
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16.0),
        textAlign: textAlign,
      ),
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
  final String text;

  CenterElement({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16.0),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Base class for form elements
abstract class FormElement extends MarkdownElement {
  final String id;

  FormElement({required this.id});
}

/// Represents a span of text with optional formatting
class TextSpanElement {
  final String text;
  final bool isBold;
  final bool isItalic;
  final String? linkUrl;

  TextSpanElement({
    required this.text,
    required this.isBold,
    required this.isItalic,
    this.linkUrl,
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
          return TextSpan(
            text: span.text,
            style: TextStyle(
              fontWeight: span.isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: span.isItalic ? FontStyle.italic : FontStyle.normal,
              color: span.linkUrl != null ? const Color(0xFF2196F3) : null,
              decoration:
                  span.linkUrl != null ? TextDecoration.underline : null,
            ),
            recognizer: span.linkUrl != null
                ? (TapGestureRecognizer()
                  ..onTap = () async {
                    try {
                      // Try to launch using the older API
                      await url_launcher.launch(span.linkUrl!);
                    } catch (e) {
                      // If the older API fails, try with the newer API if available
                      if (await url_launcher.canLaunch(span.linkUrl!)) {
                        await url_launcher.launch(span.linkUrl!);
                      }
                    }
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
