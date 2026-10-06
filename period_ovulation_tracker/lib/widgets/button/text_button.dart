import 'package:flutter/material.dart';

import '../../core/extensions/theme_extension.dart';
import '../text/text_widget.dart';

class CustomTextButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isLoading;
  final bool isUnderline;

  const CustomTextButton({
    super.key,
    required this.title,
    required this.onTap,
    this.textColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.isLoading = false,
    this.isUnderline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: isLoading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor ?? context.primaryColor,
                ),
              )
            : TextWidget(
                title: title,
                fontSize: fontSize,
                fontWeight: fontWeight,
                textColor: textColor ?? context.primaryColor,
                textDecoration: isUnderline
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
      ),
    );
  }
}
