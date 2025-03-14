import 'dart:developer';

import 'package:flex_markdown/flex_markdown.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    const markdownData = '''
-># Flex Markdown Demo<-

## Basic Typography

Regular paragraph text. Lorem ipsum dolor sit amet, consectetur adipiscing elit.

**Bold text** and *italic text* with ***bold and italic*** combinations.
Inline `code` with backticks.

## Text Colors

This demonstrates {color:red|colored text} using named colors.

Available named colors include:
- {color:red|Red text}
- {color:blue|Blue text}
- {color:green|Green text}
- {color:yellow|Yellow text}
- {color:orange|Orange text}
- {color:purple|Purple text}
- {color:black|Black text}
- {color:white|White text on default background}
- {color:grey|Grey text} (can also use "gray")

You can also use {color:#FF5733|hex color codes} like this: {color:#33A8FF|custom blue}.

Colors can be combined with other formatting:
- {color:red|**Bold red text**}
- {color:blue|*Italic blue text*}
- {color:green|***Bold italic green text***}
- {color:purple|`Purple code text`}
- {color:#FF5733|[Colored link](https://example.com)}

## Headings

# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

## Centered Content

->## Centered Heading<-

->This is centered paragraph text with **bold** and *italic* formatting.<-

## Links

[Basic link](https://flutter.dev)

## Lists

### Unordered List
* Item 1
* Item 2
  * Nested item 2.1
  * Nested item 2.2
* Item 3

### Ordered List
1. First item
2. Second item
   1. Nested item 2.1
   2. Nested item 2.2
3. Third item

## Blockquotes

> This is a blockquote.
> 
> Multiple paragraphs can be included.
>
> Nested blockquotes are possible too.

## Code

Inline `code` example.

```dart
// Code block
void main() {
  print('Hello, Flex Markdown!');
}
```

## Horizontal Rule

---

## Tables

| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Row 1    | Data     | Data     |
| Row 2    | Data     | Data     |

## Indented Content

[[indent|20|This text is indented by 20 pixels from the left margin.]]

## Mixed Formatting

->### Centered heading with [***Bold Link***](https://example.com)<-

- List item with [*italic link*](https://flutter.dev)
- List item with **bold text** and `inline code`

## Form Elements

### Text Field
This is a sample text field: {{textfield|name_field|Name|Enter your name}}

### Checkbox
Here's a checkbox: {{checkbox|terms_check|I agree to the terms and conditions|false}}

### Radio Buttons
Choose one: 
{{radio|option1|Option 1|group1|false}} 
{{radio|option2|Option 2|group1|false}}
{{radio|option3|Option 3|group1|false}}

### Dropdown Select
Select your country: {{select|country|Country|USA,Canada,Mexico,UK,Australia,Japan}}

### Mixed Forms in Paragraph
This paragraph contains {{textfield|inline_field|inline text field|example}} and also 
{{checkbox|inline_check|an inline checkbox|true}} mixed with regular text.

---

Built with Flutter and FlexMarkdown.
''';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FlexMarkdownWidget(
              // Required parameter
              data: markdownData,
              // Optional parameters
              isHorizontalLayout: true,
              showTextField: true,
              showController: true,
              enableTextSelection: true,
              isPrintMode: false,
              controllerPosition: MarkdownControllerPosition.above,
              baseFontSize: 16.0,
              formFieldConfigurations: {
                'name_field': TextFieldConfiguration(
                  id: 'name_field',
                  label: 'Name',
                  placeholder: 'Enter your full name',
                  placeholderDots: 40,
                  onValueChanged:
                      (id, value, [fieldType]) => log(
                        'Field "$id" changed to "$value" (${fieldType ?? 'text'})',
                      ),
                ),
                'terms_check': CheckboxConfiguration(
                  id: 'terms_check',
                  label: 'I agree to the terms and conditions',
                  defaultValue: true,
                  onValueChanged:
                      (id, value, [fieldType]) => log(
                        'Field "$id" changed to "$value" (${fieldType ?? 'text'})',
                      ),
                ),
                'country': SelectConfiguration(
                  id: 'country',
                  label: 'Country I live in',
                  options: [
                    'Vietnam',
                    'Thailand',
                    'Laos',
                    'Cambodia',
                    'Singapore',
                    'Malaysia',
                    'Japan',
                  ],
                  defaultValue: 'Vietnam',
                  onValueChanged:
                      (id, value, [fieldType]) => log(
                        'Field "$id" changed to "$value" (${fieldType ?? 'text'})',
                      ),
                ),
                'option1': RadioConfiguration(
                  id: 'option1',
                  label: 'Option 1',
                  groupName: 'group1',
                  defaultSelected: true,
                  onValueChanged:
                      (id, value, [fieldType]) => log(
                        'Field "$id" changed to "$value" (${fieldType ?? 'text'})',
                      ),
                ),
                'option2': RadioConfiguration(
                  id: 'option2',
                  label: 'Option 22',
                  groupName: 'group1',
                  onValueChanged:
                      (id, value, [fieldType]) => log(
                        'Field "$id" changed to "$value" (${fieldType ?? 'text'})',
                      ),
                ),
                'inline_field': TextFieldConfiguration(
                  id: 'inline_field',
                  label: 'Inline text field',
                  defaultValue: 'example',
                  onValueChanged:
                      (id, value, [fieldType]) => log(
                        'Field "$id" changed to "$value" (${fieldType ?? 'text'})',
                      ),
                ),
                'inline_check': CheckboxConfiguration(
                  id: 'inline_check',
                  label: 'An inline checkbox',
                  defaultValue: true,
                  onValueChanged:
                      (id, value, [fieldType]) => log(
                        'Field "$id" changed to "$value" (${fieldType ?? 'text'})',
                      ),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
