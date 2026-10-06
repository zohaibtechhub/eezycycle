import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/forgot_password_controller.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/core/utils/validators.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';
import 'package:period_ovulation_tracker/widgets/text_field/custom_text_field.dart';

class ForgotPasswordResetView extends StatelessWidget {
  const ForgotPasswordResetView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();

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
            key: controller.resetFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title: 'New password',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  textColor: context.onSurface,
                ),
                const SizedBox(height: 6),
                TextWidget(
                  title:
                      'Choose a new password for your account. You’ll use it the next time you sign in.',
                  fontSize: 14,
                  textAlign: TextAlign.start,
                  textColor: context.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(height: AppSize.h4),
                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    labelText: 'New password',
                    hintText: 'At least 6 characters',
                    obscureText: !controller.isPasswordVisible.value,
                    validator: Validators.validateLengthRange('Password', 6),
                    onSuffixIconClick: () =>
                        controller.togglePasswordVisibility(confirm: false),
                  ),
                ),
                SizedBox(height: AppSize.h2),
                Obx(
                  () => CustomTextField(
                    controller: controller.confirmPasswordController,
                    labelText: 'Confirm password',
                    hintText: 'Re-enter password',
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    validator: (value) => Validators.validatePasswordMatch(
                      controller.passwordController.text,
                      value,
                    ),
                    onSuffixIconClick: () =>
                        controller.togglePasswordVisibility(confirm: true),
                  ),
                ),
                SizedBox(height: AppSize.h3),
                Obx(
                  () => CustomButton(
                    title: 'Update password',
                    isLoading: controller.isLoading.value,
                    onTap: controller.submitNewPassword,
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
