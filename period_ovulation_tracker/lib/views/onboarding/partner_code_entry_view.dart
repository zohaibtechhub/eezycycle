import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/onboarding_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

/// Onboarding step for male partners: enter the woman's invite code after Usage.
class PartnerCodeEntryView extends StatelessWidget {
  const PartnerCodeEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        controller.goBackFromPartnerCode();
      },
      child: Scaffold(
        backgroundColor: context.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: controller.goBackFromPartnerCode,
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
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextWidget(
                  title: 'Enter partner code',
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                const TextWidget(
                  title:
                      'Ask your partner for the 6-character code from her EezyCycle Partner tab. You’ll see cycle phases only — never private logs.',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.textSecondary,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: AppSize.h4),
                TextField(
                  controller: controller.partnerCodeController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    UpperCaseTextFormatter(),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'ABC123',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.45),
                      letterSpacing: 6,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: context.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: controller.onPartnerCodeChanged,
                ),
                const SizedBox(height: 20),
                Obx(
                  () => InkWell(
                    onTap: () => controller.setPartnerShareConsent(
                      !controller.partnerShareConsented.value,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: controller.partnerShareConsented.value,
                            activeColor: AppColors.primary,
                            onChanged: controller.setPartnerShareConsent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: TextWidget(
                            title:
                                'I understand I will only see cycle phases and predicted fertile / period days — not symptoms, sex logs, tests, or notes.',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            textColor: AppColors.textSecondary,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Obx(
                  () => CustomButton(
                    title: controller.isSyncing.value
                        ? 'Linking…'
                        : 'Continue',
                    isLoading: controller.isSyncing.value,
                    isDisabled:
                        !controller.canContinuePartnerCode ||
                        controller.isSyncing.value,
                    onTap: controller.continuePartnerCodeNext,
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
