import 'package:flutter/material.dart';
import '../models.dart';

/// Function type for building widgets from parameters
typedef CustomWidgetBuilder = Widget Function(
    BuildContext context, Map<String, String> params);

/// Element that renders a custom widget
class CustomWidgetElement extends MarkdownElement {
  final String widgetName;
  final Map<String, String> parameters;
  final bool isInline;
  final Map<String, CustomWidgetBuilder>? customWidgets;

  CustomWidgetElement({
    required this.widgetName,
    required this.parameters,
    this.isInline = false,
    this.customWidgets,
    required super.baseFontSize,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we have a builder for this widget
    if (customWidgets != null && customWidgets!.containsKey(widgetName)) {
      final widget = customWidgets![widgetName]!(context, parameters);

      // If inline, wrap in IntrinsicWidth for proper sizing
      if (isInline) {
        return IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: widget,
          ),
        );
      }

      // Block-level widget
      return widget;
    }

    // Fallback for unregistered widgets
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Widget not found: $widgetName\nParameters: ${parameters.toString()}',
        style: TextStyle(fontSize: baseFontSize, color: Colors.red),
      ),
    );
  }
}
