import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/controllers/onboarding_controller.dart';
import 'package:period_ovulation_tracker/core/utils/app_role.dart';
import 'package:period_ovulation_tracker/core/utils/pref_util.dart';

class CommitController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController holdAnimController;
  late final Animation<double> expandAnimation;

  final RxDouble holdProgress = 0.0.obs;
  final RxBool isCompleted = false.obs;
  final RxString statusText = 'Tap logo and hold to commit'.obs;

  @override
  void onInit() {
    super.onInit();

    holdAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    expandAnimation = CurvedAnimation(
      parent: holdAnimController,
      curve: Curves.easeInOutCubic,
    );

    holdAnimController.addListener(_onAnimationProgress);
  }

  void _onAnimationProgress() {
    final value = holdAnimController.value;
    holdProgress.value = value;

    if (isCompleted.value) return;

    if (value >= 0.96) {
      _triggerCompletion();
    } else if (value >= 0.50) {
      statusText.value = 'Almost there...';
    } else if (value > 0.05) {
      statusText.value = 'Keep Holding...';
    }
  }

  void onHoldStart() {
    if (isCompleted.value) return;
    HapticFeedback.selectionClick();
    holdAnimController.forward();
  }

  void onHoldEnd() {
    if (isCompleted.value) return;
    HapticFeedback.lightImpact();
    holdAnimController.reverse();
    statusText.value = 'Keep Holding...';
  }

  void _triggerCompletion() {
    if (isCompleted.value) return;
    isCompleted.value = true;
    statusText.value = 'Welcome to EezyCycle!';
    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 1600), () async {
      // Ensure one-time onboarding flag is set even if progress sync lagged
      if (!PrefUtil.getBool(PrefUtil.onboardingCompleted)) {
        final onboarding = Get.find<OnboardingController>();
        await onboarding.syncCompleteOnboarding();
      }

      final isPartner = PrefUtil.getBool(PrefUtil.isPartnerMode) ||
          Get.find<OnboardingController>().isPartnerFlow;

      if (isPartner) {
        await PrefUtil.setBool(PrefUtil.isPartnerMode, true);
        await PrefUtil.setString(PrefUtil.experienceMode, 'partner');
        Get.offAllNamed(AppRole.homeRoute(isPartner: true));
        // PartnerHomeView.ensurePartnerDataLoaded runs on mount — no restart.
        return;
      }

      if (Get.isRegistered<HomeHeroController>()) {
        final hero = Get.find<HomeHeroController>();
        hero.setPregnancyModeActive(false);
        await hero.loadCycleData(jumpToToday: true);
      }
      Get.offAllNamed(AppRole.homeRoute(isPartner: false));
    });
  }

  @override
  void onClose() {
    holdAnimController.removeListener(_onAnimationProgress);
    holdAnimController.dispose();
    super.onClose();
  }
}
