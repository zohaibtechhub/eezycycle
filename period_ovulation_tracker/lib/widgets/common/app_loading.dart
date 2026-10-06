import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

/// Blocking full-screen loader for long API work (logout, onboarding sync, etc.).
abstract final class AppLoading {
  static bool _visible = false;

  static bool get isVisible => _visible;

  static void show([String message = 'Please wait…']) {
    if (_visible) return;
    _visible = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextWidget(
                    title: message,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.textPrimary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      useSafeArea: true,
    );
  }

  static void hide() {
    if (!_visible) return;
    _visible = false;
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
