import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/theme_extension.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final double horizontalPadding;
  final double verticalPadding;
  final VoidCallback? onTap;
  final bool useGradient;

  const CustomContainer({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.onTap,
    this.borderRadius = 10,
    this.horizontalPadding = 12,
    this.verticalPadding = 14,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: useGradient ? null : color ?? context.background,
          gradient: useGradient ? AppColors.appGradient : null,
          border: Border.all(
            color: borderColor ?? context.onSurface.withValues(alpha: 0.12),
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}
