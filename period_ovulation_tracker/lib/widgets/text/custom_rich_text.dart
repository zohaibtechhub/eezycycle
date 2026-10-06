import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/extensions/theme_extension.dart';

class CustomRichText extends StatelessWidget {
  final String firstPart;
  final String highlightedPart;
  final String middlePart;
  final String secondHighlightedPart;

  final TextStyle? firstPartStyle;
  final TextStyle? highlightedPartStyle;
  final TextStyle? middlePartStyle;
  final TextStyle? secondHighlightedPartStyle;

  final VoidCallback? onHighlightedPartTap;
  final VoidCallback? onSecondHighlightedPartTap;

  final TextAlign textAlign;

  const CustomRichText({
    super.key,
    required this.firstPart,
    required this.highlightedPart,
    required this.middlePart,
    required this.secondHighlightedPart,
    this.firstPartStyle,
    this.highlightedPartStyle,
    this.middlePartStyle,
    this.secondHighlightedPartStyle,
    this.onHighlightedPartTap,
    this.onSecondHighlightedPartTap,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        children: [
          TextSpan(
            text: firstPart,
            style:
                firstPartStyle ??
                TextStyle(
                  color: context.onSurface,
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
          ),
          TextSpan(
            text: highlightedPart,
            style:
                highlightedPartStyle ??
                TextStyle(
                  color: context.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
            recognizer: onHighlightedPartTap == null
                ? null
                : (TapGestureRecognizer()..onTap = onHighlightedPartTap),
          ),
          TextSpan(
            text: middlePart,
            style:
                middlePartStyle ??
                TextStyle(
                  color: context.onSurface,
                  fontSize: 18,
                  fontFamily: 'Inter',
                ),
          ),
          TextSpan(
            text: secondHighlightedPart,
            style:
                secondHighlightedPartStyle ??
                TextStyle(
                  color: context.primaryColor,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
            // ✅ FIXED HERE: Using onSecondHighlightedPartTap
            recognizer: onSecondHighlightedPartTap == null
                ? null
                : (TapGestureRecognizer()..onTap = onSecondHighlightedPartTap),
          ),
        ],
      ),
    );
  }
}
