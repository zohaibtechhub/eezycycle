import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/forgot_password_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';
import 'package:pinput/pinput.dart';

class ForgotPasswordOtpView extends StatelessWidget {
  const ForgotPasswordOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: context.primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: controller.otpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title: 'Enter code',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  textColor: context.onSurface,
                ),
                const SizedBox(height: 6),
                Obx(
                  () => TextWidget(
                    title:
                        'We sent a 6-digit code to ${controller.resetEmail.value}. It expires in 15 minutes.',
                    fontSize: 14,
                    textAlign: TextAlign.start,
                    textColor: context.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: AppSize.h4),
                Center(
                  child: Pinput(
                    length: 6,
                    controller: controller.otpController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    cursor: Container(
                      width: 2,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    separatorBuilder: (index) => const SizedBox(width: 10),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter the code from your email';
                      }
                      if (value.trim().length != 6) {
                        return 'Code must be 6 digits';
                      }
                      return null;
                    },
                    onCompleted: (_) => controller.submitOtp(),
                  ),
                ),
                SizedBox(height: AppSize.h3),
                Obx(
                  () => CustomButton(
                    title: 'Verify code',
                    isLoading: controller.isLoading.value,
                    onTap: controller.submitOtp,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Obx(
                    () => TextButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.resendOtp,
                      child: TextWidget(
                        title: 'Resend code',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        textColor: context.primaryColor,
                      ),
                    ),
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
