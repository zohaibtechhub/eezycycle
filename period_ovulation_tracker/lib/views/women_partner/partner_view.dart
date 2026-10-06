import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/relationship/partner_code_controller.dart';

/// Woman's bottom-nav tab: generate invite code for her male partner.
class PartnerView extends StatelessWidget {
  const PartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PartnerController());

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const TextWidget(
          title: 'Partner Space',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.partnerCode.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isConnected.value)
                _buildConnectedHero(controller, context)
              else
                _buildNotConnectedHero(controller, context),
              const SizedBox(height: 24),
              if (!controller.isConnected.value) ...[
                const TextWidget(
                  title: 'Why Connect Your Partner?',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.textPrimary,
                ),
                const SizedBox(height: 12),
                _buildBenefitTile(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  title: 'Cycle Phase Awareness',
                  subtitle:
                      'Helps them understand your energy shifts, fertile days, and PMS without asking.',
                  color: AppColors.period,
                  context: context,
                ),
                const SizedBox(height: 10),
                _buildBenefitTile(
                  icon: HugeIcons.strokeRoundedFavourite,
                  title: 'Daily Empathy Tips',
                  subtitle:
                      'Delivers tailored advice on when to plan high-energy dates or offer cozy comfort.',
                  color: AppColors.fertility,
                  context: context,
                ),
                const SizedBox(height: 10),
                _buildBenefitTile(
                  icon: HugeIcons.strokeRoundedShield01,
                  title: '100% Private & Protected',
                  subtitle:
                      'Only high-level phase predictions are shared. Your personal notes stay strictly private.',
                  color: AppColors.pregnancy,
                  context: context,
                ),
              ] else ...[
                Center(
                  child: TextButton.icon(
                    onPressed: controller.isBusy.value
                        ? null
                        : () => controller.disconnectPartner(),
                    icon: const Icon(
                      Icons.link_off_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    label: const TextWidget(
                      title: 'Disconnect Partner',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildConnectedHero(
    PartnerController controller,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedFavourite,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      title: 'Linked Partner',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      textColor: AppColors.textSecondary,
                    ),
                    SizedBox(height: 2),
                    TextWidget(
                      title: 'Active Connection',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextWidget(
                  title: 'Connected',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.success,
                ),
              ),
            ],
          ),
          if (controller.partnerCode.value.isNotEmpty) ...[
            const SizedBox(height: 14),
            TextWidget(
              title: 'Code ${controller.partnerCode.value}',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textColor: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotConnectedHero(
    PartnerController controller,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedShare01,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      title: 'Invite your partner',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.textPrimary,
                    ),
                    SizedBox(height: 2),
                    TextWidget(
                      title: 'Share this code so he can link in the app',
                      fontSize: 12,
                      textColor: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => TextWidget(
                    title: controller.partnerCode.value.isEmpty
                        ? '······'
                        : controller.partnerCode.value,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    textColor: AppColors.accent,
                  ),
                ),
                InkWell(
                  onTap: () {
                    final code = controller.partnerCode.value;
                    if (code.isEmpty) return;
                    Clipboard.setData(ClipboardData(text: code));
                    Get.snackbar(
                      'Copied',
                      'Partner code copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 4),
                      TextWidget(
                        title: 'Copy',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const TextWidget(
            title:
                'He chooses “I have a partner code” during onboarding and enters this code. He only sees cycle phases — never symptoms, sex logs, tests, or notes.',
            fontSize: 12,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: controller.isBusy.value
                ? null
                : () => controller.generateCode(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'Refresh code',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              minimumSize: const Size.fromHeight(46),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: HugeIcon(icon: icon, color: color, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.textPrimary,
                ),
                const SizedBox(height: 3),
                TextWidget(
                  title: subtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.textSecondary,
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
