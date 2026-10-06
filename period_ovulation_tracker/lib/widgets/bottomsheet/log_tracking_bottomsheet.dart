import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/home/log_tracking_controller.dart';

class LogTrackingBottomSheet extends StatelessWidget {
  final DateTime targetDate;
  final String? initialCategoryFilter;

  const LogTrackingBottomSheet({
    super.key,
    required this.targetDate,
    this.initialCategoryFilter,
  });

  static void show(
    BuildContext context, {
    required DateTime targetDate,
    String? initialCategoryFilter,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(targetDate.year, targetDate.month, targetDate.day);
    if (day.isAfter(today)) {
      // Future days are predictions only — no daily log sheet.
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogTrackingBottomSheet(
        targetDate: targetDate,
        initialCategoryFilter: initialCategoryFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tag = targetDate.toIso8601String();
    if (Get.isRegistered<LogTrackingController>(tag: tag)) {
      Get.delete<LogTrackingController>(tag: tag);
    }
    final controller = Get.put(
      LogTrackingController(targetDate: targetDate),
      tag: tag,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      title: "Log Daily Activity",
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    TextWidget(
                      title:
                          "${targetDate.day} ${_monthName(targetDate.month)} ${targetDate.year}",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      textColor: AppColors.textSecondary,
                    ),
                  ],
                ),
                Obx(
                  () => TextButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () => controller.saveLogs(),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      controller.isSaving.value ? 'Saving…' : 'Done',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Input Field
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: context.surface,
          //       borderRadius: BorderRadius.circular(16),
          //       border: Border.all(
          //         color: AppColors.primary.withValues(alpha: 0.12),
          //       ),
          //     ),
          //     child: TextField(
          //       controller: controller.searchController,
          //       onChanged: (val) => controller.searchQuery.value = val,
          //       decoration: InputDecoration(
          //         hintText: "Search symptoms, moods, tests...",
          //         hintStyle: const TextStyle(
          //           fontSize: 13,
          //           color: AppColors.textSecondary,
          //         ),
          //         prefixIcon: HugeIcon(
          //           icon: HugeIcons.strokeRoundedSearch01,
          //           color: AppColors.textSecondary,
          //           size: 18,
          //         ),
          //
          //         prefixIconConstraints: const BoxConstraints(
          //           minWidth: 40,
          //           minHeight: 40,
          //         ),
          //         suffixIcon: Obx(
          //           () => controller.searchQuery.isNotEmpty
          //               ? IconButton(
          //                   icon: const Icon(
          //                     Icons.clear,
          //                     size: 18,
          //                     color: AppColors.textSecondary,
          //                   ),
          //                   onPressed: () {
          //                     controller.searchController.clear();
          //                     controller.searchQuery.value = '';
          //                   },
          //                 )
          //               : const SizedBox.shrink(),
          //         ),
          //         border: InputBorder.none,
          //         contentPadding: const EdgeInsets.symmetric(vertical: 14),
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 10),

          // Main Scrollable Body
          Expanded(
            child: Obx(() {
              final activeCategories =
                  initialCategoryFilter != null &&
                      controller.searchQuery.isEmpty
                  ? [initialCategoryFilter!]
                  : controller.categories;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                children: [
                  // Section: "How are you feeling today?" (Today's Date Only)
                  if (controller.isToday &&
                      controller.searchQuery.isEmpty &&
                      initialCategoryFilter == null) ...[
                    _buildTodayFeelingSection(controller, context),
                    const SizedBox(height: 20),
                  ],

                  // Categories and Chips Grid
                  for (final cat in activeCategories) ...[
                    _buildCategoryBlock(cat, controller, context),
                    const SizedBox(height: 18),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayFeelingSection(
    LogTrackingController controller,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextWidget(
                  title: "DAILY CHECK-IN",
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const TextWidget(
            title: "How are you feeling today?",
            fontSize: 16,
            fontWeight: FontWeight.w700,
            textColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeelingChip(
                "mood_happy",
                "Joyful",
                HugeIcons.strokeRoundedSmile,
                controller,
              ),
              _buildFeelingChip(
                "mood_calm",
                "Peaceful",
                HugeIcons.strokeRoundedSun01,
                controller,
              ),
              _buildFeelingChip(
                "mood_anxious",
                "Overwhelmed",
                HugeIcons.strokeRoundedSlowWinds,
                controller,
              ),
              _buildFeelingChip(
                "mood_fatigue",
                "Exhausted",
                HugeIcons.strokeRoundedSleeping,
                controller,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingChip(
    String id,
    String label,
    List<List<dynamic>> icon,
    LogTrackingController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedItemIds.contains(id);
      return GestureDetector(
        onTap: () => controller.toggleItem(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: icon,
                color: isSelected ? Colors.white : AppColors.accent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryBlock(
    String category,
    LogTrackingController controller,
    BuildContext context,
  ) {
    final items = controller.filteredItems
        .where((i) => i.category == category)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          title: category,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map((item) => _buildItemPill(item, controller, context))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildItemPill(
    LogItem item,
    LogTrackingController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final isSelected = controller.selectedItemIds.contains(item.id);

      return GestureDetector(
        onTap: () => controller.toggleItem(item.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : AppColors.primary.withValues(alpha: 0.1),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: item.icon,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
