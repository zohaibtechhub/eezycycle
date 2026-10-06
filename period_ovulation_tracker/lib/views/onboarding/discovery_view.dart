import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/onboarding_controller.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/common/global_back_behaviour.dart';
import 'package:period_ovulation_tracker/widgets/common/onboarding_header.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../routes/app_pages.dart';
import '../../widgets/button/custom_button.dart';
import '../../widgets/container/selectable_container.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return DoubleBackToExitWrapper(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: AppSize.h4),
                      Align(
                        alignment: Alignment.topRight,
                        child: OnboardingHeader(
                          onSkipTap: () {
                            Get.toNamed(AppPages.birthYear);
                          },
                        ),
                      ),
                      SizedBox(height: AppSize.h2),
                      TextWidget(
                        title: "How did you find out about us?",
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: AppSize.h4),

                      Obx(
                        () => Column(
                          spacing: AppSize.h2,
                          children: controller.sources.map((source) {
                            return SelectableContainer(
                              title: source,
                              isSelected:
                                  controller.selectedSource.value == source,
                              onTap: () {
                                controller.selectSource(source);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => CustomButton(
                  title: controller.isSyncing.value ? 'Saving…' : 'Next',
                  isLoading: controller.isSyncing.value,
                  isDisabled: controller.selectedSource.value == null ||
                      controller.isSyncing.value,
                  onTap: controller.continueDiscoveryNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
