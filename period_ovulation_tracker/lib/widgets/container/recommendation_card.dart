import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class RecommendationCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const RecommendationCard({
    super.key,
    required this.icon,
    this.iconBgColor = AppColors.primaryLight,
    this.iconColor = AppColors.accent,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading Icon Container
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    title: title,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    title: description,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.textSecondary,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Trailing Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
