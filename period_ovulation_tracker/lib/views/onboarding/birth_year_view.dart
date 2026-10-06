import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/common/global_back_behaviour.dart';
import 'package:period_ovulation_tracker/widgets/container/attention_container.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/onboarding_controller.dart';
import '../../core/utils/app_size.dart';
import '../../widgets/button/custom_button.dart';

class BirthYearView extends StatelessWidget {
  const BirthYearView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return DoubleBackToExitWrapper(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              SizedBox(height: AppSize.h7),
              TextWidget(
                title: "When were you born?",
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
              TextWidget(
                title:
                    "Your cycle can change with age. Knowing it helps us make better predictions",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSize.h6),
              SizedBox(
                height: AppSize.getHeight(40),
                child: ListWheelScrollView.useDelegate(
                  controller: controller.wheelController,
                  itemExtent: 52,
                  diameterRatio: 2.5,
                  perspective: 0.002,
                  squeeze: 1.05,
                  physics: const FixedExtentScrollPhysics(),

                  onSelectedItemChanged: (index) {
                    controller.selectYear(controller.minYear + index);
                  },

                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: controller.maxYear - controller.minYear + 1,
                    builder: (context, index) {
                      final year = controller.minYear + index;

                      return Obx(() {
                        final isSelected =
                            year == controller.selectedYear.value;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.primaryColor.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(
                                    color: context.primaryColor.withValues(
                                      alpha: 0.25,
                                    ),
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: isSelected ? 24 : 18,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? context.primaryColor
                                  : context.onSurface.withValues(alpha: 0.45),
                            ),
                            child: Text('$year'),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: AppSize.h3),
              Obx(
                () => controller.isShowAttention
                    ? AttentionContainer(
                        title: 'Important',
                        description:
                            'Due to COPPA requirements, all our users must be at least 13 years old. '
                            'Due to GDPR requirements, all our EU users must be at least 16 years old.',
                      )
                    : const SizedBox.shrink(),
              ),
              Spacer(),
              Obx(
                () => CustomButton(
                  title: controller.isSyncing.value ? 'Saving…' : 'Next',
                  isLoading: controller.isSyncing.value,
                  isDisabled: controller.isSyncing.value,
                  onTap: controller.continueYearNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
