import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/theme_extension.dart';
import '../text/text_widget.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final double borderRadius;
  final VoidCallback onTap;

  final bool isLoading;
  final bool isDisabled;

  final Color? color;
  final Color? disabledColor;

  final Gradient? gradient;
  final bool useGradient;
  final bool isTextGradient;

  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderRadius = 16,
    this.color,
    this.disabledColor,
    this.gradient,
    this.useGradient = false,
    this.isTextGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    const double loaderSize = 20;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultGradient = isDark
        ? AppColors.darkBackground
        : AppColors.appGradient;

    final backgroundColor = color ?? context.primaryColor;

    final finalDisabledColor = disabledColor ?? Colors.grey.shade300;

    final isButtonDisabled = isDisabled || isLoading;

    final foregroundColor = (isDisabled && !isLoading)
        ? Colors.grey.shade600
        : context.onPrimary;

    return GestureDetector(
      onTap: isButtonDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: isLoading
              ? backgroundColor
              : isDisabled
              ? finalDisabledColor
              : useGradient
              ? null
              : backgroundColor,
          gradient: !isLoading && useGradient ? gradient : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                height: loaderSize,
                width: loaderSize,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  strokeWidth: 2,
                ),
              )
            : TextWidget(
                title: title,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
                fontSize: 17,
                isGradient: isTextGradient && !isDisabled,
                textColor: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
      ),
    );
  }
}
