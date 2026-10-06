import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class PregnancyModeView extends StatelessWidget {
  const PregnancyModeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
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
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Illustration Banner
              Center(
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppColors.softGradient,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      AppImages.pregnancySupport, // Or appropriate banner asset
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Title Section
              const TextWidget(
                title: "Pregnancy Mode",
                fontSize: 26,
                fontWeight: FontWeight.w800,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 6),
              const TextWidget(
                title: "Why log your pregnancy with EezyCycle?",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textColor: AppColors.textSecondary,
              ),

              const SizedBox(height: 20),

              // 3. Benefit Feature Tiles
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildBenefitTile(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      title: "See countdown to the birth",
                      subtitle:
                          "Track gestational weeks, trimesters, and milestones effortlessly.",
                      color: AppColors.primary,
                      context: context,
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitTile(
                      icon: HugeIcons.strokeRoundedBaby01,
                      title: "Daily baby development insights",
                      subtitle:
                          "Get daily health info and updates on your baby's growth.",
                      color: AppColors.accent,
                      context: context,
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitTile(
                      icon: HugeIcons.strokeRoundedActivity01,
                      title: "Track weight and nutrition",
                      subtitle:
                          "Monitor vital health metrics and wellness parameters tailored for you.",
                      color: AppColors.success,
                      context: context,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Action Button
              CustomButton(
                title: "LOG PREGNANCY",
                onTap: () {
                  Get.offNamed(AppPages.pregnancyActivation);
                  // Trigger pregnancy logging flow or switch onboarding steps
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitTile({
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: HugeIcon(icon: icon, color: color, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title: title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.textPrimary,
                ),
                const SizedBox(height: 3),
                TextWidget(
                  title: subtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.textSecondary,
                  maxLines: 2,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
