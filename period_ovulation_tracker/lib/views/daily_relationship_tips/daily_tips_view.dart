import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/relationship/relationship_tip_controller.dart';
import '../../models/relationship/relationship_tip_model.dart';

class DailyTipsView extends StatelessWidget {
  const DailyTipsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DailyTipsController>();

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
          title: 'Daily Relationship Tips',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final featured = controller.featuredTip.value;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title: controller.dayLabel,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                if (featured != null)
                  GestureDetector(
                    onTap: () => controller.openTip(featured),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppColors.softGradient,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const TextWidget(
                                  title: "TODAY'S EMPATHY NUGGET",
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  textColor: AppColors.accent,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.lightbulb_outline_rounded,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextWidget(
                            title: featured.title,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            textColor: AppColors.textPrimary,
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 6),
                          TextWidget(
                            title: featured.description,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            textColor: AppColors.textSecondary,
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 10),
                          const TextWidget(
                            title: 'Tap to read more →',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            textColor: AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  TextWidget(
                    title: controller.hasError.value
                        ? 'Could not load tips. Pull to retry.'
                        : 'No tips available yet.',
                    fontSize: 13,
                    textColor: AppColors.textSecondary,
                  ),

                const SizedBox(height: 24),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: controller.categories.map((category) {
                      return Obx(() {
                        final isSelected =
                            controller.selectedCategory.value == category;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => controller.selectCategory(category),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : context.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                ),
                              ),
                              child: TextWidget(
                                title: category,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                textColor: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                Obx(
                  () => TextWidget(
                    title:
                        "${controller.selectedCategory.value} · ${controller.filteredTips.length} today",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Obx(() {
                  final tips = controller.filteredTips;
                  if (tips.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: TextWidget(
                        title: 'No tips in this category today.',
                        fontSize: 13,
                        textColor: AppColors.textSecondary,
                      ),
                    );
                  }
                  return Column(
                    children: tips
                        .map((tip) => _buildTipCard(tip, context, controller))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTipCard(
    RelationshipTipModel tip,
    BuildContext context,
    DailyTipsController controller,
  ) {
    return GestureDetector(
      onTap: () => controller.openTip(tip),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: tip.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tip.icon, color: tip.iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextWidget(
                          title: tip.category,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.accent,
                        ),
                      ),
                      TextWidget(
                        title: tip.timeToRead,
                        fontSize: 11,
                        textColor: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    title: tip.title,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.textPrimary,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    title: tip.description,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.textSecondary,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4, top: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
