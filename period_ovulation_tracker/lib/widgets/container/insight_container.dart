import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class InsightContainer extends StatelessWidget {
  final Color? color;
  final String tagText;
  final String centerText;
  final VoidCallback? onTap;

  const InsightContainer({
    super.key,
    this.color,
    required this.tagText,
    required this.centerText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.getWidth(42), // Set width for horizontal scrolling
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag Chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextWidget(
                title: tagText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                textColor: AppColors.accent,
              ),
            ),
            const Spacer(),
            TextWidget(
              title: centerText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              textColor: AppColors.textPrimary,
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
