import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_circular_progress_indicator/gradient_circular_progress_indicator.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/controllers/onboarding_controller.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_role.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/widgets/common/global_back_behaviour.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/drawer/drawer_controller.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startOnce());
  }

  Future<void> _startOnce() async {
    if (_started || !mounted) return;
    _started = true;

    final controller = Get.find<OnboardingController>();
    final syncFuture = controller.syncCompleteOnboarding();

    controller.startProgressFlow(
      onComplete: () async {
        final ok = await syncFuture;
        if (!mounted) return;

        if (!ok) {
          // Allow a retry on next visit to progress if sync failed
          _started = false;
        }

        final drawerController = Get.find<DrawerViewController>();
        log(
          "Pending Experience mode is ${controller.pendingExperienceMode.value} and selected experience is ${drawerController.selectedExperience.value}",
        );
        if (controller.pendingExperienceMode.value != null) {
          if (drawerController.selectedExperience.value == "Track cycle" ||
              drawerController.selectedExperience.value == "Get pregnant" ||
              drawerController.selectedExperience.value ==
                  "Track perimenopause") {
            log("Come here");
            // Mode-switch mini-onboarding → home (not drawer).
            // Drawer was the old destination and left the date strip offstage.
            controller.pendingExperienceMode.value = null;
            if (Get.isRegistered<HomeHeroController>()) {
              final hero = Get.find<HomeHeroController>();
              hero.setPregnancyModeActive(false);
              await hero.loadCycleData(jumpToToday: true);
            }
            Get.offAllNamed(AppRole.homeRoute());
          }
          return;
        }
        // Partners skip comparison marketing → commit → partner home
        if (controller.isPartnerFlow) {
          Get.offNamed(AppPages.commit);
          return;
        }
        Get.offNamed(AppPages.comparison);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    return DoubleBackToExitWrapper(
      child: Scaffold(
        backgroundColor: context.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // 1. Animated Progress Circle with context extension colors
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.primaryColor.withValues(alpha: 0.08),
                        ),
                      ),
                      Obx(
                        () => GradientCircularProgressIndicator(
                          size: 170,
                          stroke: 10,
                          progress: controller.progressValue.value,
                          backgroundColor: context.onSurface.withValues(
                            alpha: 0.06,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.primaryColor,
                              context.primaryColor.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Obx(
                        () => TextWidget(
                          title:
                              '${(controller.progressValue.value * 100).toInt()}%',
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          textColor: context.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // 2. Smooth Image Transition
                SizedBox(
                  height: AppSize.getHeight(24),
                  child: Obx(() {
                    final stage = controller
                        .progressStages[controller.progressStageIndex.value];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.94,
                              end: 1.0,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: ClipRRect(
                        key: ValueKey<String>(stage.image),
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          stage.image,
                          height: AppSize.getHeight(24),
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }),
                ),

                const Spacer(flex: 1),

                // 3. Smooth Text & Rich Title Transition
                SizedBox(
                  height: 120,
                  child: Obx(() {
                    final stage = controller
                        .progressStages[controller.progressStageIndex.value];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.12),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey<int>(controller.progressStageIndex.value),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: context.onSurface,
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(text: stage.firstPart),
                                TextSpan(
                                  text: stage.highlightPart,
                                  style: TextStyle(
                                    color: context.primaryColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (stage.endPart != null &&
                                    stage.endPart!.isNotEmpty)
                                  TextSpan(text: stage.endPart),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextWidget(
                            title: stage.subtitle,
                            fontSize: 14,
                            textColor: context.onSurface.withValues(alpha: 0.6),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                const Spacer(flex: 1),

                Obx(() {
                  final syncing = controller.isSyncing.value;
                  final almostDone = controller.progressValue.value >= 0.99;
                  if (!syncing && !almostDone) {
                    return const SizedBox(height: 28);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (syncing) ...[
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        TextWidget(
                          title: syncing
                              ? 'Saving your cycle setup…'
                              : 'Almost ready…',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          textColor: context.onSurface.withValues(alpha: 0.65),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
