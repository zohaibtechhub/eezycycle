import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/models/relationship/relationship_tip_model.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class DailyTipDetailView extends StatelessWidget {
  const DailyTipDetailView({super.key, this.tip});

  final RelationshipTipModel? tip;

  @override
  Widget build(BuildContext context) {
    final resolved = tip ??
        (Get.arguments is RelationshipTipModel
            ? Get.arguments as RelationshipTipModel
            : null);

    if (resolved == null) {
      return Scaffold(
        backgroundColor: context.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        body: const Center(
          child: TextWidget(
            title: 'Tip not found',
            fontSize: 15,
            textColor: AppColors.textSecondary,
          ),
        ),
      );
    }

    final tipData = resolved;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surface,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: context.onSurface,
            ),
          ),
        ),
        title: const TextWidget(
          title: 'Tip detail',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: tipData.iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(tipData.icon, color: tipData.iconColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextWidget(
                          title: tipData.category,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          textColor: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextWidget(
                        title: tipData.timeToRead,
                        fontSize: 12,
                        textColor: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextWidget(
              title: tipData.title,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 10),
            TextWidget(
              title: tipData.description,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              textColor: AppColors.textSecondary,
              textAlign: TextAlign.start,
            ),
            if (tipData.body.isNotEmpty) ...[
              const SizedBox(height: 22),
              TextWidget(
                title: tipData.body,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.start,
              ),
            ],
            if (tipData.tryThis.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.softGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      title: 'TRY THIS TODAY',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.accent,
                    ),
                    const SizedBox(height: 8),
                    TextWidget(
                      title: tipData.tryThis,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      textColor: AppColors.textPrimary,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ],
            if (tipData.takeaways.isNotEmpty) ...[
              const SizedBox(height: 24),
              const TextWidget(
                title: 'Takeaways',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 12),
              ...tipData.takeaways.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextWidget(
                          title: item,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.textSecondary,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
