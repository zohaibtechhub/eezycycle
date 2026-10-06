import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/utils/app_role.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../routes/app_pages.dart';

class CustomDrawerHeader extends StatelessWidget {
  final String title;
  const CustomDrawerHeader({super.key, this.title = 'Settings & Profile'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (Get.previousRoute == AppPages.progress ||
                Get.previousRoute == '/progress') {
              Get.offAllNamed(AppRole.homeRoute());
            } else {
              Get.back();
            }
            if (Get.isRegistered<HomeHeroController>()) {
              Future.delayed(const Duration(milliseconds: 50), () {
                Get.find<HomeHeroController>().jumpToTodayDate(force: true);
              });
            }
          },
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextWidget(
          title: title,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
      ],
    );
  }
}
