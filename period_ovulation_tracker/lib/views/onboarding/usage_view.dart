import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/onboarding_controller.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/common/global_back_behaviour.dart';
import 'package:period_ovulation_tracker/widgets/container/selectable_container.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../widgets/button/custom_button.dart';

class UsageView extends StatelessWidget {
  const UsageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return DoubleBackToExitWrapper(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: AppSize.h7),
              TextWidget(
                title: 'Are you using EezyCycle for yourself?',
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: AppSize.h4),
              Obx(
                () => Column(
                  spacing: AppSize.h2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: controller.usageOptions.map((option) {
                    return SelectableContainer(
                      title: option,
                      isSelected: controller.selectedUsage.value == option,
                      onTap: () {
                        controller.selectUsage(option);
                      },
                    );
                  }).toList(),
                ),
              ),
              Spacer(),
              Obx(
                () => CustomButton(
                  title: controller.isSyncing.value ? 'Saving…' : 'Next',
                  isLoading: controller.isSyncing.value,
                  isDisabled: controller.selectedUsage.value == null ||
                      controller.isSyncing.value,
                  onTap: controller.continueUsageNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
