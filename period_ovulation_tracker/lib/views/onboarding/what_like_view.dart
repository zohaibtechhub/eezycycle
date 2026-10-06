import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/common/global_back_behaviour.dart';
import 'package:period_ovulation_tracker/widgets/container/what_like_container.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/onboarding_controller.dart';
import '../../widgets/common/onboarding_header.dart';

class WhatLikeView extends StatelessWidget {
  const WhatLikeView({super.key});

  static const int _crossAxisCount = 2;
  static const double _spacing = 12;
  static const double _minItemHeight = 120;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final itemCount = controller.whatYouLike.length;

    return DoubleBackToExitWrapper(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: AppSize.h1),
                Align(
                  alignment: Alignment.topRight,
                  child: OnboardingHeader(
                    skipText: 'Login',
                    onSkipTap: () => Get.toNamed(AppPages.login),
                  ),
                ),
                SizedBox(height: AppSize.h2),
                const TextWidget(
                  title: 'What would you like to focus on?',
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: AppSize.h1),
                const TextWidget(
                  title: 'Choose what matters most to you.',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: AppSize.h2),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final rows = (itemCount / _crossAxisCount).ceil();
                      final maxH = constraints.maxHeight.isFinite
                          ? constraints.maxHeight
                          : MediaQuery.sizeOf(context).height * 0.55;

                      final fittedHeight =
                          (maxH - _spacing * (rows - 1)) / rows;
                      final needsScroll = fittedHeight < _minItemHeight;
                      final mainAxisExtent =
                          needsScroll ? _minItemHeight : fittedHeight;

                      return GridView.builder(
                        physics: needsScroll
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        itemCount: itemCount,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _crossAxisCount,
                          crossAxisSpacing: _spacing,
                          mainAxisSpacing: _spacing,
                          mainAxisExtent: mainAxisExtent,
                        ),
                        itemBuilder: (context, index) {
                          return Obx(() {
                            final option = controller.whatYouLike[index];
                            final title = option['title']!;
                            final image = option['image']!;
                            final isSelected =
                                controller.selectedGoals.contains(title);

                            return WhatLikeContainer(
                              image: image,
                              title: title,
                              isSelected: isSelected,
                              onTap: () => controller.toggleGoal(title),
                            );
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Obx(
                  () => CustomButton(
                    title: controller.isSyncing.value ? 'Saving…' : 'Next',
                    isLoading: controller.isSyncing.value,
                    onTap: controller.onClickGoalNext,
                    isDisabled: controller.selectedGoals.isEmpty ||
                        controller.isSyncing.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
