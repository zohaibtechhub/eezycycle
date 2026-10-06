import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/common/global_back_behaviour.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/commit_controller.dart';

class CommitView extends StatelessWidget {
  const CommitView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommitController());

    return DoubleBackToExitWrapper(
      child: Scaffold(
        backgroundColor: context.surface,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Interactive Expanding Logo / Completion Center Piece
            GestureDetector(
              onTapDown: (_) => controller.onHoldStart(),
              onTapUp: (_) => controller.onHoldEnd(),
              onTapCancel: () => controller.onHoldEnd(),
              child: Obx(() {
                final isCompleted = controller.isCompleted.value;

                return AnimatedBuilder(
                  animation: controller.expandAnimation,
                  builder: (context, child) {
                    final progress = controller.holdProgress.value;
                    // The logo circle scales from 1.0x up to 32.0x to cover the screen
                    final scale =
                        1.0 + (controller.expandAnimation.value * 31.0);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Expanding Primary Circle
                        Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: context.primaryColor.withValues(
                                    alpha: 0.35 + (progress * 0.25),
                                  ),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Circular Progress Ring Indicator (Hides when expanding beyond boundary)
                        if (!isCompleted && progress < 0.95) ...[
                          SizedBox(
                            width: 126,
                            height: 126,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4.5,
                              strokeCap: StrokeCap.round,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                        ],

                        // Center Logo
                        if (!isCompleted)
                          Container(
                            width: 104,
                            height: 104,
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Image.asset(
                              AppImages.logo,
                              fit: BoxFit.contain,
                              color: Colors.white,
                              colorBlendMode: BlendMode.srcIn,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.favorite_rounded,
                                size: 46,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        // Completion Celebration State (Logo + Welcome message)
                        if (isCompleted)
                          FadeTransition(
                            opacity: controller.expandAnimation,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 28,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      AppImages.logo,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.favorite_rounded,
                                        size: 50,
                                        color: context.primaryColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppSize.h4),
                                  const TextWidget(
                                    title: 'Welcome to EezyCycle!',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    textColor: Colors.white,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              }),
            ),

            // 2. Foreground Headers and Status (Fades away as background fills screen)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Obx(() {
                  if (controller.isCompleted.value) {
                    return const SizedBox.shrink();
                  }

                  final isDeep = controller.holdProgress.value > 0.45;

                  return Column(
                    children: [
                      SizedBox(height: AppSize.h2),

                      // Top Title
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: isDeep ? Colors.white : context.onSurface,
                          height: 1.25,
                        ),
                        textAlign: TextAlign.center,
                        child: const Text(
                          'I will use EezyCycle to\nincrease my chances of pregnancy',
                        ),
                      ),

                      SizedBox(height: AppSize.h1),

                      TextWidget(
                        title: 'Commit to your daily health & cycle journey.',
                        fontSize: 15,
                        textColor: isDeep
                            ? Colors.white.withValues(alpha: 0.85)
                            : context.onSurface.withValues(alpha: 0.6),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(),

                      // Bottom Instruction Text
                      SizedBox(
                        height: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextWidget(
                              title: controller.statusText.value,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              textColor: isDeep
                                  ? Colors.white
                                  : context.onSurface,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            TextWidget(
                              title: 'Hold down the circle to continue',
                              fontSize: 13,
                              textColor: isDeep
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : context.onSurface.withValues(alpha: 0.45),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSize.h2),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
