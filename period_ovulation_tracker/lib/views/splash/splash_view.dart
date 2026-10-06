import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/splash_controller.dart';
import '../../core/constants/app_colors.dart';
// import 'app_colors.dart'; // Adjust to your file path

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Only create once — putting in build recreates the controller and
    // freezes/restarts the animation mid-flight.
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController());
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: controller.animController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.softGradient),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated decorative rings
                _buildPulseRing(180, 0.0),
                _buildPulseRing(260, 0.15),

                // Main Logo & Branding content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 4),

                    // Logo Icon with ambient pink glow
                    Transform.scale(
                      scale: controller.scaleAnimation.value,
                      child: Opacity(
                        opacity: controller.fadeAnimation.value,
                        child: Center(
                          child: Image.asset(
                            AppImages.logo, // Replace with your logo path
                            width: 94,
                            height: 94,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.favorite_rounded,
                              size: 54,
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Staggered Title & Tagline
                    SlideTransition(
                      position: controller.taglineSlideAnimation,
                      child: FadeTransition(
                        opacity: controller.taglineFadeAnimation,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.appGradient.createShader(bounds),
                              child: TextWidget(
                                title: "EezyCycle",
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                textColor: context.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextWidget(
                              title: "Period and Ovulation Tracker",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              textColor: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Dynamic Color-Interpolated Loader
                    FadeTransition(
                      opacity: controller.taglineFadeAnimation,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(
                              AppColors.primary,
                              AppColors.accent,
                              math.sin(
                                controller.animController.value * math.pi,
                              ),
                            )!,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseRing(double baseSize, double delayFactor) {
    final effectiveProgress = math.max(
      0.0,
      controller.pulseAnimation.value - delayFactor,
    );

    final size = baseSize + (effectiveProgress * 70);

    // Make the outer/last ring disappear earlier
    final fadeProgress = delayFactor > 0.1
        ? (1.0 - (effectiveProgress / 0.65)).clamp(0.0, 1.0)
        : (1.0 - effectiveProgress).clamp(0.0, 1.0);

    final opacity = (fadeProgress * 0.4).clamp(0.0, 0.4);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }
}
