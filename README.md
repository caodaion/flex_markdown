# flex_markdown

A flexible Markdown rendering package for Flutter applications.

## Features

- Customizable Markdown rendering
- Support for extended Markdown syntax
- Easy integration with Flutter widgets
- Responsive design support
- Customizable styling options

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flex_markdown: ^latest_version
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Implementation

```dart
import 'package:flex_markdown/flex_markdown.dart';

// In your widget build method
@override
Widget build(BuildContext context) {
  return FlexMarkdown(
    data: '# Hello World\n\nThis is a simple markdown example.',
  );
}
```

### Styling Options

```dart
FlexMarkdown(
  data: markdownText,
  styleSheet: FlexMarkdownStyleSheet(
    h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
    p: TextStyle(fontSize: 16, height: 1.5),
    a: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
  ),
)
```

### Advanced Usage

```dart
FlexMarkdown(
  data: markdownText,
  onTapLink: (text, href, title) {
    // Handle link taps
    if (href != null) {
      launchUrl(href);
    }
  },
  builders: {
    'customTag': CustomTagBuilder(),
  },
)
```

## Markdown Syntax Guide

### Headings

Create headings using `#` symbols:

```
# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6
```

### Links

```
[Link Text](https://example.com)
```

### Centered Text

To center text, use arrow syntax:

```
->This text will be centered<-
```

### Form Elements

Form elements can be embedded using double curly braces with pipe-separated parameters:

```
{{textfield|id|label|hint}}
```

#### Available Form Elements:

1. **Text Field**
```
{{textfield|username|Username|Enter your username}}
```
Parameters: type, id, label, hint text

2. **Select Dropdown**
```
{{select|country|Select Country|USA,Canada,UK,Australia}}
```
Parameters: type, id, label, comma-separated options

3. **Checkbox**
```
{{checkbox|terms|Accept Terms and Conditions|true}}
```
Parameters: type, id, label, initial value (true/false)

4. **Radio Button**
```
{{radio|option1|First Option|question1|true}}
{{radio|option2|Second Option|question1|false}}
```
Parameters: type, id, label, group name, selected status (true/false)

### Line Breaks

Empty lines in your markdown will be rendered as line breaks.

```
First paragraph

Second paragraph
```

### Additional Formatting

FlexMarkdown supports a rich set of formatting options:

#### Text Styling
```
**Bold Text**
*Italic Text*
~~Strikethrough~~
`Inline Code`
```

#### Blockquotes
```
> This is a blockquote.
> It can span multiple lines.
```

#### Lists
- **Unordered List**
```
- Item 1
- Item 2
- Item 3
```
- **Ordered List**
```
1. First item
2. Second item
3. Third item
```

#### Code Blocks
```
```dart
void main() {
  print('Hello, world!');
}
```

#### Tables
```
| Syntax | Description |
|--------|-------------|
| Header | Title       |
| Cell   | Content     |
```

#### Horizontal Rules
```
---
```

### Additional Formatting

Additional formatting options may be available - check the documentation in the example app for the most up-to-date features.

## API Reference

### FlexMarkdownWidget Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| data | String | The Markdown content to be rendered |
| isHorizontalLayout | bool | Whether to layout the editor and preview horizontally (default: true) |
| showTextField | bool | Whether to show the text input field (default: true) |
| enableTextSelection | bool | Whether text selection is enabled in the preview (default: true) |
| showController | bool | Whether to show the formatting toolbar (default: true) |
| controllerPosition | MarkdownControllerPosition | Position of the toolbar (above/below) |
| isPrintMode | bool | Whether to render in print mode which affects form elements (default: false) |

## Examples

Check out the `/example` directory for complete implementation examples.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
