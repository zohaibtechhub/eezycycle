import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/theme_extension.dart';

class TextWidget extends StatelessWidget {
  final String title;
  final bool isGradient;
  final Color? textColor;
  final double fontSize;
  final double? minFontSize;
  final FontWeight fontWeight;
  final TextDecoration textDecoration;
  final Color? underLineColor;
  final TextAlign textAlign;
  final TextOverflow? textOverflow;
  final int? maxLines;

  const TextWidget({
    super.key,
    required this.title,
    this.isGradient = false,
    this.textColor,
    this.fontSize = 15,
    this.minFontSize,
    this.fontWeight = FontWeight.w500,
    this.textDecoration = TextDecoration.none,
    this.textAlign = TextAlign.center,
    this.underLineColor,
    this.textOverflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: 'Inter',
      color: textColor ?? context.onSurface,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: textDecoration,
      decorationColor: underLineColor ?? context.primaryColor,
    );

    Widget text = AutoSizeText(
      title,
      textAlign: textAlign,
      overflow: textOverflow ?? TextOverflow.clip,
      softWrap: true,
      maxLines: maxLines,
      minFontSize: minFontSize ?? fontSize,
      maxFontSize: fontSize,
      style: textStyle,
    );

    if (isGradient) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return text;
    }

    return text;
  }
}
