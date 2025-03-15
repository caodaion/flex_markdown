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
## Long Form with Inline Fields

Lorem ipsum dolor sit amet, consectetur adipiscing elit. In this form you need to provide your {{textfield|full_name|Full Name|John Doe}} and your age: {{textfield|user_age|Age|25}}. The form continues with more details about you.

Your address information includes {{textfield|street|Street Address|123 Main St}}, {{textfield|city|City|Your City}}, {{textfield|state|State|Your State}}, and {{textfield|zip|Zip Code|12345}}. Are you a {{radio|citizen_yes|Citizen|citizenship|true}} or {{radio|citizen_no|Non-Citizen|citizenship|false}} of this country?

Please tell us about your educational background. Highest education level: {{select|education|Education Level|High School,Associates,Bachelors,Masters,PhD}}. Currently enrolled in school? {{checkbox|currently_enrolled|Yes, I am enrolled|false}}. If yes, name of institution: {{textfield|institution|Institution|University Name}}.

For employment status, are you: {{radio|emp_full|Full-time|employment|false}} {{radio|emp_part|Part-time|employment|false}} {{radio|emp_self|Self-employed|employment|false}} {{radio|emp_un|Unemployed|employment|false}} {{radio|emp_retired|Retired|employment|true}}?

Please rate your experience with our services from 1-10: {{textfield|rating|Rating|8}}. Would you recommend us to others? {{checkbox|recommend|Yes, I would recommend|true}}. Please provide any additional comments about how we can improve: {{textfield|comments|Comments|Your service is great but could improve in...}}

By submitting this form, I {{checkbox|terms|agree to the terms and conditions|false}} and {{checkbox|privacy|acknowledge the privacy policy|false}}. Contact preference: {{radio|contact_email|Email|contact|true}} {{radio|contact_phone|Phone|contact|false}} {{radio|contact_mail|Mail|contact|false}}.

Thank you for taking the time to complete this extremely detailed form with various {{textfield|additional_field1|Custom Field 1|Custom value}} and {{textfield|additional_field2|Custom Field 2|Another value}} and even {{textfield|additional_field3|Custom Field 3|Yet another value}} fields mixed into a very long paragraph to demonstrate how inline form elements work in extended text content.

## Custom Widgets

### Button Widget
Here's a custom button: {{widget:button|demo_button|text:Click Me!;color:blue;size:large}}

### Counter Widget
This is a counter widget: {{widget:counter|demo_counter|initialValue:5;label:Count;step:1}}

### Progress Widget
Progress indicator: {{widget:progress|demo_progress|value:75;color:green;showLabel:true}}

### Inline Widgets
This paragraph contains an inline {{widget:button|inline_button|text:Press;color:red;size:small}} button and a {{widget:chip|demo_chip|label:Flutter;color:blue}} widget.

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
              customWidgetBuilders: {
                'button': (context, type, id, params, {onValueChanged}) {
                  // Extract parameters with defaults
                  final text = params['text'] ?? 'Button';
                  final colorName = params['color'] ?? 'blue';
                  final size = params['size'] ?? 'medium';

                  // Determine color
                  Color buttonColor;
                  switch (colorName) {
                    case 'red':
                      buttonColor = Colors.red;
                      break;
                    case 'green':
                      buttonColor = Colors.green;
                      break;
                    case 'blue':
                      buttonColor = Colors.blue;
                      break;
                    default:
                      buttonColor = Colors.blue;
                  }

                  // Determine size
                  double fontSize = 14;
                  EdgeInsets padding = EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  );

                  if (size == 'small') {
                    fontSize = 12;
                    padding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
                  } else if (size == 'large') {
                    fontSize = 16;
                    padding = EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    );
                  }

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: padding,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Button $id pressed!')),
                      );
                      if (onValueChanged != null) {
                        onValueChanged('pressed');
                      }
                    },
                    child: Text(
                      text,
                      style: TextStyle(fontSize: fontSize, color: Colors.white),
                    ),
                  );
                },
                'counter': (context, type, id, params, {onValueChanged}) {
                  final initialValue = params['initialValue'] ?? 0;
                  final label = params['label'] ?? 'Counter';
                  final step = params['step'] ?? 1;
                  int value = initialValue;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('$value', style: TextStyle(fontSize: 24)),
                              SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        value--;
                                        if (onValueChanged != null) {
                                          onValueChanged(value);
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        value++;
                                        if (onValueChanged != null) {
                                          onValueChanged(value);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                'progress': (context, type, id, params, {onValueChanged}) {
                  final value = (params['value'] ?? 0) / 100.0;
                  final colorName = params['color'] ?? 'blue';
                  final showLabel = params['showLabel'] ?? false;

                  // Determine color
                  Color progressColor;
                  switch (colorName) {
                    case 'red':
                      progressColor = Colors.red;
                      break;
                    case 'green':
                      progressColor = Colors.green;
                      break;
                    case 'blue':
                      progressColor = Colors.blue;
                      break;
                    default:
                      progressColor = Colors.blue;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showLabel == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text('${(value * 100).toInt()}%'),
                        ),
                      LinearProgressIndicator(
                        value: value,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                        backgroundColor: Colors.grey[200],
                        minHeight: 10,
                      ),
                    ],
                  );
                },
                'chip': (context, type, id, params, {onValueChanged}) {
                  final label = params['label'] ?? 'Chip';
                  final colorName = params['color'] ?? 'blue';

                  // Determine color
                  Color chipColor;
                  switch (colorName) {
                    case 'red':
                      chipColor = Colors.red;
                      break;
                    case 'green':
                      chipColor = Colors.green;
                      break;
                    case 'blue':
                      chipColor = Colors.blue;
                      break;
                    default:
                      chipColor = Colors.blue;
                  }

                  return Chip(
                    label: Text(label),
                    backgroundColor: chipColor,
                    labelStyle: TextStyle(color: chipColor),
                  );
                },
              },
              minHeight: 800,
            ),
          ],
        ),
      ),
    );
  }
}
