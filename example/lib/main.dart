import 'dart:developer';

import 'package:flex_markdown/flex_markdown.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  // Add a new counter variable for the StatefulBuilder
  int _builderCounter = 0;

  void _incrementCounter() {
    setState(() {
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

### Inline Widgets
This paragraph contains an inline button <<button|inline|label=Click Me!|color=blue>> that can be clicked.

You can also use other inline widgets like badges <<badge|inline|text=New|color=red>> or chips <<chip|inline|label=Flutter|avatar=F>>.

### Block-Level Widgets
Below is a block-level custom container:

<<container|bg=lightblue|border=rounded|height=100>>

And here's a custom card widget:

<<card|title=Custom Card|subtitle=This is a card widget|image=https://via.placeholder.com/150>>

### Interactive Widgets
This counter widget is interactive: <<counter|value=0|label=Current count:>>

Here's a button that changes its label when clicked: <<changeable_button|label=Click to Change Me|color=purple>>

### Styling Widgets
You can pass styling parameters:

<<button|label=Styled Button|color=green|fontSize=18|borderRadius=8>>


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
            StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'COUNTER VALUE: $_builderCounter',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() => _builderCounter--);
                              log(
                                'Counter decremented. New value: $_builderCounter',
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() => _builderCounter++);
                              log(
                                'Counter incremented. New value: $_builderCounter',
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            FlexMarkdownWidget(
              data: markdownData,
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
              customWidgets: {
                'button': (context, params) {
                  final label = params['label'] ?? 'Button';
                  final color = params['color'] ?? 'blue';
                  final fontSize =
                      double.tryParse(params['fontSize'] ?? '') ?? 14.0;
                  final borderRadius =
                      double.tryParse(params['borderRadius'] ?? '') ?? 4.0;

                  Color buttonColor;
                  switch (color.toLowerCase()) {
                    case 'blue':
                      buttonColor = Colors.blue;
                      break;
                    case 'red':
                      buttonColor = Colors.red;
                      break;
                    case 'green':
                      buttonColor = Colors.green;
                      break;
                    default:
                      buttonColor = Colors.blue;
                  }

                  return ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Button "$label" pressed!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    child: Text(label, style: TextStyle(fontSize: fontSize)),
                  );
                },

                'badge': (context, params) {
                  final text = params['text'] ?? 'Badge';
                  final color = params['color'] ?? 'blue';

                  Color badgeColor = Colors.blue;
                  switch (color.toLowerCase()) {
                    case 'red':
                      badgeColor = Colors.red;
                      break;
                    case 'green':
                      badgeColor = Colors.green;
                      break;
                    case 'orange':
                      badgeColor = Colors.orange;
                      break;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },

                'chip': (context, params) {
                  final label = params['label'] ?? 'Chip';
                  final avatar = params['avatar'];

                  return Chip(
                    avatar:
                        avatar != null
                            ? CircleAvatar(child: Text(avatar[0]))
                            : null,
                    label: Text(label),
                  );
                },

                'container': (context, params) {
                  final bg = params['bg'] ?? 'white';
                  final border = params['border'] ?? 'none';
                  final height =
                      double.tryParse(params['height'] ?? '') ?? 100.0;

                  Color backgroundColor;
                  switch (bg.toLowerCase()) {
                    case 'lightblue':
                      backgroundColor = Colors.lightBlue.shade100;
                      break;
                    case 'lightgreen':
                      backgroundColor = Colors.lightGreen.shade100;
                      break;
                    default:
                      backgroundColor = Colors.white;
                  }

                  BorderRadius borderRadius;
                  switch (border.toLowerCase()) {
                    case 'rounded':
                      borderRadius = BorderRadius.circular(12);
                      break;
                    default:
                      borderRadius = BorderRadius.zero;
                  }

                  return Container(
                    width: double.infinity,
                    height: height,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: borderRadius,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(child: Text('Custom Container Widget')),
                  );
                },

                'card': (context, params) {
                  final title = params['title'] ?? 'Card Title';
                  final subtitle = params['subtitle'] ?? '';
                  final imageUrl = params['image'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (imageUrl != null)
                          Image.network(
                            imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (ctx, error, stack) => Container(
                                  height: 150,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Text('Image not available'),
                                  ),
                                ),
                          ),
                        ListTile(
                          title: Text(title),
                          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                        ),
                        ButtonBar(
                          children: [
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Card action pressed!'),
                                  ),
                                );
                              },
                              child: const Text('ACTION'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },

                'counter': (context, params) {
                  final initialValue =
                      int.tryParse(params['value'] ?? '0') ?? 0;
                  final label = params['label'] ?? 'Count:';

                  // Declare count variable outside the builder to persist its value
                  int count = initialValue;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$label $count',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => setState(() => count--),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => setState(() => count++),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },

                'changeable_button': (context, params) {
                  // Get initial parameters
                  final initialLabel = params['label'] ?? 'Changeable Button';
                  final color = params['color'] ?? 'purple';

                  // Determine button color
                  Color buttonColor;
                  switch (color.toLowerCase()) {
                    case 'purple':
                      buttonColor = Colors.purple;
                      break;
                    case 'blue':
                      buttonColor = Colors.blue;
                      break;
                    case 'red':
                      buttonColor = Colors.red;
                      break;
                    case 'green':
                      buttonColor = Colors.green;
                      break;
                    default:
                      buttonColor = Colors.purple;
                  }
                  String currentLabel = initialLabel;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      // Use a variable to store the current label

                      return ElevatedButton(
                        onPressed: () async {
                          // Show a dialog with text field to change the label
                          final TextEditingController textController =
                              TextEditingController(text: currentLabel);

                          final String? newLabel = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Change Button Label'),
                                content: TextField(
                                  controller: textController,
                                  decoration: const InputDecoration(
                                    labelText: 'New Label',
                                  ),
                                  autofocus: true,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(null);
                                    },
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pop(textController.text);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );

                          // Update the button label if a new value was provided
                          if (newLabel != null && newLabel.isNotEmpty) {
                            setState(() {
                              currentLabel = newLabel;
                            });

                            // Show a confirmation message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Label updated to: $newLabel'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          currentLabel,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
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
