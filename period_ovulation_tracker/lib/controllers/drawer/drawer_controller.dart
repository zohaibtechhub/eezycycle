import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/extensions/theme_extension.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cycle_display_mapper.dart';
import '../../core/utils/pref_util.dart';
import '../../routes/app_pages.dart';
import '../../views/drawer/drawer_view.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/text/text_widget.dart';
import '../home/home_hero_controller.dart';
import '../onboarding_controller.dart';

class DrawerViewController extends GetxController {
  final RxString selectedExperience = 'Track cycle'.obs;
  final RxBool isSwitchingMode = false.obs;
  final ApiClient _api = ApiClient();

  final List<ExperienceModeModel> experienceModes = [
    ExperienceModeModel(title: 'Track cycle', image: AppImages.trackPeriod),
    ExperienceModeModel(title: 'Get pregnant', image: AppImages.getPregnant),
    ExperienceModeModel(
      title: 'Track pregnancy',
      image: AppImages.trackPregnancy,
    ),
    ExperienceModeModel(
      title: 'Track perimenopause',
      image: AppImages.wellness,
    ),
  ];

  /// Apply mode from GET /me or cycle payload — persists in UI until user changes it.
  void applyServerMode(String experienceMode) {
    selectedExperience.value =
        CycleDisplayMapper.titleForExperienceMode(experienceMode);
  }

  Future<void> persistMode(String title) async {
    selectedExperience.value = title;

    // Optimistic UI: leave pregnancy chrome/copy immediately when switching away.
    if (Get.isRegistered<HomeHeroController>()) {
      final hero = Get.find<HomeHeroController>();
      if (title != 'Track pregnancy') {
        hero.setPregnancyModeActive(false);
      }
    }

    try {
      await _api.patch(ApiEndPoints.meProfile, {
        'experience_mode': CycleDisplayMapper.experienceModeFromTitle(title),
        if (title != 'Track pregnancy') 'pregnancy_mode_active': false,
      });
      if (Get.isRegistered<HomeHeroController>()) {
        await Get.find<HomeHeroController>().loadCycleData(
          jumpToToday: true,
          silent: true,
        );
      }
    } catch (_) {}
  }

  /// Turn on Track pregnancy + pregnancy chrome (optional clinician/ultrasound EDD).
  Future<void> activatePregnancyMode({String? clinicianEdd}) async {
    selectedExperience.value = 'Track pregnancy';
    await PrefUtil.setString(PrefUtil.experienceMode, 'track_pregnancy');
    if (Get.isRegistered<HomeHeroController>()) {
      Get.find<HomeHeroController>().setPregnancyModeActive(true);
    }
    try {
      final body = <String, dynamic>{
        'experience_mode': 'track_pregnancy',
        'pregnancy_mode_active': true,
      };
      if (clinicianEdd != null && clinicianEdd.isNotEmpty) {
        body['clinician_edd'] = clinicianEdd;
      }
      await _api.patch(ApiEndPoints.meProfile, body);
      if (Get.isRegistered<HomeHeroController>()) {
        await Get.find<HomeHeroController>().loadCycleData(
          jumpToToday: true,
          silent: true,
        );
      }
    } catch (_) {}
  }

  void onRequestModeChange(BuildContext context, String newMode) {
    if (selectedExperience.value == newMode || isSwitchingMode.value) return;

    showDialog(
      context: context,
      builder: (_) => _buildSwitchModeDialog(
        context,
        fromMode: selectedExperience.value,
        toMode: newMode,
      ),
    );
  }

  Future<void> _confirmModeSwitch(String newMode) async {
    if (isSwitchingMode.value) return;
    isSwitchingMode.value = true;
    Get.back(); // close confirm dialog
    AppLoading.show('Switching to $newMode…');
    log("New mode is $newMode");

    try {
      final onboardingController = Get.find<OnboardingController>();

      // Persist + reload while still on drawer; scroll-to-today runs when home shows.
      await persistMode(newMode);

      AppLoading.hide();

      if (newMode == 'Track cycle') {
        onboardingController.startOnboardingFlow(
          OnboardingFlow.trackCycle,
          modeLabel: newMode,
        );
      } else if (newMode == 'Get pregnant') {
        onboardingController.startOnboardingFlow(
          OnboardingFlow.getPregnant,
          modeLabel: newMode,
        );
      } else if (newMode == 'Track perimenopause') {
        onboardingController.startOnboardingFlow(
          OnboardingFlow.trackPerimenopause,
          modeLabel: newMode,
        );
      } else if (newMode == 'Track pregnancy') {
        // Replace drawer so back/home isn't stuck under settings.
        Get.offNamed(AppPages.pregnancyModeView);
        return;
      } else {
        onboardingController.startOnboardingFlow(
          OnboardingFlow.normal,
          modeLabel: newMode,
        );
      }

      // Replace drawer (not push on top) → stack: MainBottomNav → Onboarding
      Get.offNamed(AppPages.onboarding);
    } catch (_) {
      AppLoading.hide();
    } finally {
      isSwitchingMode.value = false;
    }
  }

  Widget _buildSwitchModeDialog(
    BuildContext context, {
    required String fromMode,
    required String toMode,
  }) {
    return Dialog(
      backgroundColor: context.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const TextWidget(
              title: "Switch Mode?",
              fontSize: 18,
              fontWeight: FontWeight.w700,
              textColor: AppColors.textPrimary,
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: "Are you sure you want to switch from\n",
                  ),
                  TextSpan(
                    text: '"$fromMode"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const TextSpan(text: " to "),
                  TextSpan(
                    text: '"$toMode"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                  const TextSpan(
                    text:
                        "?\nYour predictions and insights will adjust accordingly.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (isSwitchingMode.value) return;
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmModeSwitch(toMode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Switch",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
