import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/bottom_nav/bottom_nav_controller.dart';
import 'package:period_ovulation_tracker/controllers/secret_chat/secret_profile_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/common/user_avatar.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class SecretChatView extends StatelessWidget {
  const SecretChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.isRegistered<SecretProfileController>()
        ? Get.find<SecretProfileController>()
        : Get.put(SecretProfileController());

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Get.back(),
        ),
        title: const TextWidget(
          title: "Secret Chat",
          fontSize: 16,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Profile Card with Edit Profile Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Obx(
                      () => UserAvatar(
                        imageUrl: profileController.avatarUrl.value,
                        useAuthAvatar: true,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            title: profileController.username.value,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            textColor: AppColors.textPrimary,
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 2),
                          const TextWidget(
                            title: 'Encrypted & Anonymous',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            textColor: AppColors.textSecondary,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppPages.editSecretProfile);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const TextWidget(
                        title: "Edit profile",
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 2. Ready to see more Banner & Explore Secret Chats Action
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.softGradient,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      color: AppColors.accent,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextWidget(
                    title: "Ready to see more?",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.textPrimary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const TextWidget(
                    title:
                        "Connect privately, share thoughts securely, and explore confidential discussions without leaving a trace.",
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    title: "Explore Secret Chats",
                    onTap: () {
                      // Switch privacy tab without stacking another bottom-nav shell
                      // (stacking was what showed a back button on User Privacy).
                      if (Get.isRegistered<BottomNavController>()) {
                        Get.find<BottomNavController>().changeIndex(1);
                      }
                      Get.until(
                        (route) =>
                            route.settings.name == AppPages.mainBottomNavView ||
                            route.isFirst,
                      );
                      if (Get.currentRoute != AppPages.mainBottomNavView) {
                        Get.offNamed(AppPages.mainBottomNavView);
                        if (Get.isRegistered<BottomNavController>()) {
                          Get.find<BottomNavController>().changeIndex(1);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
