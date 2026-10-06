import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_insight_models.dart';
import 'package:period_ovulation_tracker/widgets/pregnancy/pregnancy_asset_image.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class PregnancyExpectDetailView extends StatelessWidget {
  final PregnancyExpectItem item;

  const PregnancyExpectDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: TextWidget(
          title: item.label,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          if (item.image != null && item.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: PregnancyAssetImage(
                  path: item.image,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.favorite_rounded,
                  backgroundColor: AppColors.primaryLight,
                ),
              ),
            ),
          const SizedBox(height: 18),
          TextWidget(
            title: item.summary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            textColor: AppColors.textPrimary,
            textAlign: TextAlign.start,
            maxLines: 8,
          ),
          const SizedBox(height: 20),
          for (final section in item.sections) ...[
            TextWidget(
              title: section.heading,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 6),
            TextWidget(
              title: section.body,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              textColor: AppColors.textSecondary,
              textAlign: TextAlign.start,
              maxLines: 12,
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          TextWidget(
            title:
                'Educational only — not a diagnosis or substitute for clinical care.',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.start,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
