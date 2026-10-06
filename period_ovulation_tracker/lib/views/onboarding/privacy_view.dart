import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/onboarding_controller.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/button/text_button.dart';
import 'package:period_ovulation_tracker/widgets/common/custom_checkbox.dart';
import 'package:period_ovulation_tracker/widgets/common/global_back_behaviour.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../widgets/text/custom_rich_text.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return DoubleBackToExitWrapper(
      child: Scaffold(
        body: Column(
          spacing: AppSize.h2,
          children: [
            SizedBox(height: AppSize.h6),
            TextWidget(
              title: "Privacy First",
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: AppSize.h2),
            Obx(
              () => CustomCheckbox(
                value: controller.acceptedTerms.value,
                onChanged: controller.setTerms,
                title: CustomRichText(
                  firstPart: 'I accept the ',
                  highlightedPart: 'Privacy Policy',
                  middlePart: ' and ',
                  secondHighlightedPart: 'Terms of Use.',
                  onHighlightedPartTap: () {
                    // Open Privacy Policy
                  },
                  onSecondHighlightedPartTap: () {
                    // Open Terms of Use
                  },
                ),
              ),
            ),
            Obx(
              () => CustomCheckbox(
                value: controller.acceptedHealthData.value,
                onChanged: controller.setHealthData,
                title: CustomRichText(
                  firstPart:
                      'I agree to processing of my personal health data '
                      'for providing me eezyCycle app functions.\n'
                      'See more in ',
                  highlightedPart: 'Privacy Policy',
                  middlePart: '',
                  secondHighlightedPart: '',
                  onHighlightedPartTap: () {
                    // Open Privacy Policy
                  },
                ),
              ),
            ),
            Spacer(),
            CustomTextButton(
              fontSize: 16,
              title: "Accept all",
              onTap: controller.acceptAll,
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  title: controller.isSyncing.value ? 'Saving…' : 'Next',
                  onTap: controller.continuePrivacyNext,
                  isLoading: controller.isSyncing.value,
                  isDisabled:
                      !controller.canContinue || controller.isSyncing.value,
                ),
              ),
            ),

            SizedBox(height: AppSize.h2),
          ],
        ),
      ),
    );
  }
}
