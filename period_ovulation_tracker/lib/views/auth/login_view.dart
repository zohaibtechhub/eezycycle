import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/auth_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/core/utils/validators.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../widgets/text_field/custom_text_field.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: context.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSize.h3),

                // 1. Logo & Welcome Header
                Center(
                  child: Image.asset(
                    AppImages.logo,
                    fit: BoxFit.contain,
                    width: AppSize.h10,
                    height: AppSize.h10,
                  ),
                ),

                SizedBox(height: AppSize.h3),

                TextWidget(
                  title: 'Welcome back',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  textColor: context.onSurface,
                ),

                const SizedBox(height: 6),

                TextWidget(
                  title:
                      'Sign in to access your personal insights and cycle data. Finishing signup keeps the same data on this device.',
                  fontSize: 14,
                  textAlign: TextAlign.start,
                  textColor: context.onSurface.withValues(alpha: 0.6),
                ),

                SizedBox(height: AppSize.h4),

                // 2. Email Field
                CustomTextField(
                  controller: controller.emailController,
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                SizedBox(height: AppSize.h2),

                // 3. Password Field
                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: !controller.isPasswordVisible.value,
                    validator: Validators.validateLengthRange('Password', 5),
                    onSuffixIconClick: () => controller.changeVisibility(true),
                    // If using icons without SVG asset:
                    // Suffix handled cleanly via Flutter Icon or SVG asset if available
                  ),
                ),

                const SizedBox(height: 10),

                // 4. Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppPages.forgotPassword);
                    },
                    child: TextWidget(
                      title: 'Forgot Password?',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      textColor: context.primaryColor,
                    ),
                  ),
                ),

                SizedBox(height: AppSize.h3),

                // 5. Login Button
                Obx(
                  () => CustomButton(
                    title: 'Sign In',
                    isLoading: controller.isLoading.value,
                    onTap: controller.login,
                  ),
                ),

                SizedBox(height: AppSize.h3),

                // 6. Divider "Or continue with"
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
                        title: 'Or continue with',
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

                // 7. Google Sign-In Button
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
                                  title: 'Sign in with Google',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  textColor: context.onSurface,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                SizedBox(height: AppSize.h4),

                // 8. Sign Up Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      title: "Don't have an account? ",
                      fontSize: 14,
                      textColor: context.onSurface.withValues(alpha: 0.6),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppPages.signup);
                      },
                      child: TextWidget(
                        title: 'Sign Up',
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
