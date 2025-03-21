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

Additional formatting options may be available - check the documentation in the example app for the most up-to-date features.

## API Reference

| Parameter | Type | Description |
|-----------|------|-------------|
| data | String | The Markdown content to be rendered |
| styleSheet | FlexMarkdownStyleSheet | Styling options for Markdown elements |
| onTapLink | Function | Callback for handling link taps |
| builders | Map<String, MarkdownElementBuilder> | Custom element builders |
| padding | EdgeInsets | Padding around the rendered Markdown |

## Examples

Check out the `/example` directory for complete implementation examples.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
