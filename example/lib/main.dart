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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FlexMarkdownWidget(
        isHorizontalLayout: true,
        showTextField: true,
        showController: true,
        enableTextSelection: true,
        isPrintMode: false,
        controllerPosition: MarkdownControllerPosition.above,
        data: '''
# Markdown Demo

## Basic Typography

Regular paragraph text. Lorem ipsum dolor sit amet, consectetur adipiscing elit.

**Bold text** and *italic text* with ***bold and italic*** combinations.

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

[**Bold link**](https://flutter.dev)

[*Italic link*](https://flutter.dev)

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
3. Third item

## Blockquotes

> This is a blockquote.
> 
> Multiple paragraphs can be included.
>
> Nested blockquotes are also possible.

## Code

Inline `code` example.

```dart
// Code block
void main() {
  print('Hello, Markdown!');
}
```

## Horizontal Rule

---

## Tables

| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Row 1    | Data     | Data     |
| Row 2    | Data     | Data     |

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
{{radio|option1|Option 1|group1|true}} 
{{radio|option2|Option 2|group1|false}}
{{radio|option3|Option 3|group1|false}}

### Dropdown Select
Select your country: {{select|country|Country|USA,Canada,Mexico,UK,Australia,Japan}} and it should be a required field.

### Mixed Forms in Paragraph
This paragraph contains {{textfield|inline_field|inline text field|example}} and also 
{{checkbox|inline_check|an inline checkbox|true}} mixed with regular text.

---

Made with Flutter and FlexMarkdown
''',
      ),
    );
  }
}
