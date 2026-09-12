import 'package:flutter/material.dart';

/// Custom TextEditingController that highlights @mentions in real-time
/// using the theme brand color (#E65100).
class MentionTextEditingController extends TextEditingController {
  final Color mentionColor;
  final Color defaultColor;

  MentionTextEditingController({
    super.text,
    this.mentionColor = const Color(0xFFE65100),
    this.defaultColor = const Color(0xFF2E1C14),
  });

  static final RegExp _mentionRegex = RegExp(
    r'(@(?:Travelyn|all|Alex|Brenda|Charlie|Diana|You\s*\(Diana\)|[A-Za-z0-9_]+(?:\s*\([A-Za-z0-9_]+\))?))',
    caseSensitive: false,
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? TextStyle(color: defaultColor);
    final textVal = value.text;

    if (textVal.isEmpty) {
      return TextSpan(style: baseStyle, text: '');
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in _mentionRegex.allMatches(textVal)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: textVal.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      final mentionText = match.group(0)!;
      spans.add(
        TextSpan(
          text: mentionText,
          style: baseStyle.copyWith(
            color: mentionColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < textVal.length) {
      spans.add(
        TextSpan(
          text: textVal.substring(lastIndex),
          style: baseStyle,
        ),
      );
    }

    if (spans.isEmpty) {
      return TextSpan(style: baseStyle, text: textVal);
    }

    return TextSpan(style: baseStyle, children: spans);
  }
}
