import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/forgot_password_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/core/utils/validators.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';
import 'package:period_ovulation_tracker/widgets/text_field/custom_text_field.dart';

class ForgotPasswordEmailView extends StatelessWidget {
  const ForgotPasswordEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ForgotPasswordController>()
        ? Get.find<ForgotPasswordController>()
        : Get.put(ForgotPasswordController());

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
            key: controller.emailFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  title: 'Forgot password?',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  textColor: context.onSurface,
                ),
                const SizedBox(height: 6),
                TextWidget(
                  title:
                      'Enter the email for your account. We’ll send a 6-digit code to reset your password.',
                  fontSize: 14,
                  textAlign: TextAlign.start,
                  textColor: context.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(height: AppSize.h4),
                CustomTextField(
                  controller: controller.emailController,
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                SizedBox(height: AppSize.h3),
                Obx(
                  () => CustomButton(
                    title: 'Send code',
                    isLoading: controller.isLoading.value,
                    onTap: controller.submitEmail,
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
