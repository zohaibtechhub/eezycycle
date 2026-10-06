import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/auth_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/core/utils/validators.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../widgets/text_field/custom_text_field.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: context.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: controller.signupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSize.h2),

                // 1. App Logo Header
                Center(
                  child: Image.asset(
                    AppImages.logo,
                    fit: BoxFit.contain,
                    width: AppSize.h10,
                    height: AppSize.h10,
                  ),
                ),
                SizedBox(height: AppSize.h3),

                // 2. Title & Subtitle
                TextWidget(
                  title: 'Finish your account',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  textColor: context.onSurface,
                ),

                const SizedBox(height: 6),

                TextWidget(
                  title:
                      'Add email to keep your cycle data safe across devices. Your existing data stays with you.',
                  fontSize: 14,
                  textAlign: TextAlign.start,
                  textColor: context.onSurface.withValues(alpha: 0.6),
                ),

                SizedBox(height: AppSize.h3),

                // 4. Email Field
                CustomTextField(
                  controller: controller.emailController,
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                SizedBox(height: AppSize.h2),

                // 5. Password Field
                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    labelText: 'Password',
                    hintText: 'Create a password',
                    obscureText: !controller.isPasswordVisible.value,
                    validator: Validators.validateLengthRange('Password', 6),
                    onSuffixIconClick: () => controller.changeVisibility(true),
                  ),
                ),

                SizedBox(height: AppSize.h2),

                // 6. Confirm Password Field
                Obx(
                  () => CustomTextField(
                    controller: controller.confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    validator: (value) => Validators.validatePasswordMatch(
                      controller.passwordController.text,
                      value,
                    ),
                    onSuffixIconClick: () => controller.changeVisibility(false),
                  ),
                ),

                SizedBox(height: AppSize.h3),

                // 7. Sign Up Action Button
                Obx(
                  () => CustomButton(
                    title: 'Save my account',
                    isLoading: controller.isLoading.value,
                    onTap: controller.signup,
                  ),
                ),

                SizedBox(height: AppSize.h3),

                // 8. Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: context.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextWidget(
                        title: 'Or sign up with',
                        fontSize: 13,
                        textColor: context.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: context.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSize.h3),

                // 9. Google Sign-In Option
                Obx(
                  () => InkWell(
                    onTap: controller.isGoogleLoading.value
                        ? null
                        : controller.signInWithGoogle,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: controller.isGoogleLoading.value
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  context.primaryColor,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.google,
                                  height: 20,
                                  width: 20,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.g_mobiledata_rounded,
                                    size: 24,
                                    color: context.primaryColor,
                                  ),
                                ),

                                const SizedBox(width: 10),
                                TextWidget(
                                  title: 'Sign up with Google',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  textColor: context.onSurface,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                SizedBox(height: AppSize.h3),

                // 10. Login Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      title: 'Already have an account? ',
                      fontSize: 14,
                      textColor: context.onSurface.withValues(alpha: 0.6),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: TextWidget(
                        title: 'Sign In',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        textColor: context.primaryColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSize.h2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
