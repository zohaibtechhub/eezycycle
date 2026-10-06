import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/cycle_ovulation_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/common/app_shimmer.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class CycleOvulationView extends StatelessWidget {
  const CycleOvulationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CycleOvulationController());

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Get.back(),
        ),
        title: const TextWidget(
          title: 'Cycle & Ovulation',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            color: AppColors.textSecondary,
            onPressed: controller.load,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasLoaded.value) {
          return const CycleOvulationShimmer();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.softGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          controller.pregnancyMode.value
                              ? Icons.pregnant_woman_rounded
                              : Icons.calendar_month_rounded,
                          color: AppColors.accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              title: controller.pregnancyMode.value
                                  ? 'Pregnancy'
                                  : controller.needsPeriodLog.value
                                      ? 'Get started'
                                      : 'Predicted Ovulation',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 4),
                            TextWidget(
                              title: controller.ovulationHeadline.value,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              textColor: AppColors.textPrimary,
                            ),
                            const SizedBox(height: 2),
                            TextWidget(
                              title: controller.ovulationSubtitle.value,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              textColor: AppColors.accent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (controller.hasError.value) ...[
                  const SizedBox(height: 12),
                  TextWidget(
                    title: "Couldn't reach the server. Pull to retry.",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.textSecondary,
                  ),
                ],

                const SizedBox(height: 24),

                const TextWidget(
                  title: 'Cycle Statistics',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Avg. Cycle Length',
                        value: controller.avgCycleLabel.value,
                        subtitle: controller.avgCycleHint.value,
                        icon: Icons.autorenew_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Avg. Period Length',
                        value: controller.avgPeriodLabel.value,
                        subtitle: controller.avgPeriodHint.value,
                        icon: Icons.water_drop_outlined,
                      ),
                    ),
                  ],
                ),

                if (!controller.pregnancyMode.value &&
                    !controller.needsPeriodLog.value &&
                    controller.phases.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const TextWidget(
                    title: 'Current Phase Breakdown',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < controller.phases.length; i++) ...[
                          if (i > 0) const Divider(height: 24),
                          _buildPhaseRow(
                            title: controller.phases[i].title,
                            days: controller.phases[i].daysLabel,
                            status: controller.phases[i].status,
                            statusColor: controller.phases[i].isCurrent
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                const TextWidget(
                  title: 'Recent History Trends',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        title: controller.historyTitle.value,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        title: controller.historyBody.value,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 12),
          TextWidget(
            title: value,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            textColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 2),
          TextWidget(
            title: title,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            textColor: AppColors.textSecondary,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            TextWidget(
              title: subtitle,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              textColor: AppColors.success,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhaseRow({
    required String title,
    required String days,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              title: title,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              textColor: AppColors.textPrimary,
            ),
            const SizedBox(height: 2),
            TextWidget(
              title: days,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              textColor: AppColors.textSecondary,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextWidget(
            title: status,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            textColor: statusColor,
          ),
        ),
      ],
    );
  }
}
