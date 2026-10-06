import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/basic_need/faq_controller.dart';

class HelpFaqView extends StatelessWidget {
  const HelpFaqView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HelpFaqController());

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
          title: "Help & FAQ",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Container(
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'Search questions…',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),

                  suffixIcon: Obx(
                    () => controller.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.searchQuery.value = '';
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: controller.categories.map((cat) {
                  return Obx(() {
                    final isSelected = controller.selectedCategory.value == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => controller.selectCategory(cat),
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
                                  : AppColors.primary.withValues(alpha: 0.12),
                            ),
                          ),
                          child: TextWidget(
                            title: cat,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            textColor: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            textAlign: TextAlign.start,
                          ),
                          // Text(
                          //   cat,
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     fontWeight: isSelected
                          //         ? FontWeight.w600
                          //         : FontWeight.w500,
                          //     color: isSelected
                          //         ? Colors.white
                          //         : AppColors.textPrimary,
                          //
                          //   ),
                          // ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // FAQ Accordion List
            Obx(() {
              final faqs = controller.filteredFaqs;

              if (faqs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36.0),
                  child: Center(
                    child: Column(
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedHelpCircle,
                          color: AppColors.textSecondary,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        const TextWidget(
                          title: "No questions found",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 4),
                        const TextWidget(
                          title: "Try searching with different keywords",
                          fontSize: 13,
                          textColor: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: faqs
                    .map((faq) => _buildFaqTile(faq, controller, context))
                    .toList(),
              );
            }),

            const SizedBox(height: 20),

            // Contact Support Hero Card
            // Container(
            //   padding: const EdgeInsets.all(18),
            //   decoration: BoxDecoration(
            //     gradient: AppColors.softGradient,
            //     borderRadius: BorderRadius.circular(20),
            //     border: Border.all(
            //       color: AppColors.primary.withValues(alpha: 0.15),
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         height: 46,
            //         width: 46,
            //         decoration: BoxDecoration(
            //           color: AppColors.primary.withValues(alpha: 0.15),
            //           borderRadius: BorderRadius.circular(14),
            //         ),
            //         child: const HugeIcon(
            //           icon: HugeIcons.strokeRoundedCustomerSupport,
            //           color: AppColors.accent,
            //           size: 24,
            //         ),
            //       ),
            //       const SizedBox(width: 14),
            //       const Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             TextWidget(
            //               title: "Still have questions?",
            //               fontSize: 15,
            //               fontWeight: FontWeight.w700,
            //               textColor: AppColors.textPrimary,
            //             ),
            //             SizedBox(height: 2),
            //             TextWidget(
            //               title: "Our support team is here to help 24/7.",
            //               fontSize: 12,
            //               textColor: AppColors.textSecondary,
            //             ),
            //           ],
            //         ),
            //       ),
            //       TextButton(
            //         onPressed: () {},
            //         style: TextButton.styleFrom(
            //           backgroundColor: AppColors.accent,
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 14,
            //             vertical: 8,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(16),
            //           ),
            //         ),
            //         child: const Text(
            //           "Contact",
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 13,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(
    FaqItemModel item,
    HelpFaqController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final isExpanded = item.isExpanded.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isExpanded
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.08),
            width: isExpanded ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              InkWell(
                onTap: () => controller.toggleExpand(item.id),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextWidget(
                          title: item.question,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.answer,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 220),
              ),
            ],
          ),
        ),
      );
    });
  }
}
