import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/controllers/pregnancy/pregnancy_suggestion_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/services/notification_service.dart';
import 'package:period_ovulation_tracker/views/home/home_view.dart';
import 'package:period_ovulation_tracker/views/secret_chats/posts_view.dart';
import 'package:period_ovulation_tracker/widgets/home/pregnancy_suggestion_banner.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/bottom_nav/bottom_nav_controller.dart';
import '../article/all_articles.dart';
import '../women_partner/partner_view.dart';

class MainBottomNavView extends StatefulWidget {
  const MainBottomNavView({super.key});

  @override
  State<MainBottomNavView> createState() => _MainBottomNavViewState();
}

class _MainBottomNavViewState extends State<MainBottomNavView> {
  static const List<Widget> _pages = [
    HomeView(),
    PostsView(),
    AllArticlesView(showBackButton: false),
    PartnerView(),
  ];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<PregnancySuggestionController>()) {
      Get.put(PregnancySuggestionController(), permanent: true);
    }
    // After login / logout / mode switch the permanent HomeHero may still hold
    // the previous session — refresh if empty, otherwise just re-center today.
    void centerToday() {
      if (!mounted || !Get.isRegistered<HomeHeroController>()) return;
      final hero = Get.find<HomeHeroController>();
      if (hero.yearDays.isEmpty) {
        // ignore: unawaited_futures
        hero.loadCycleData(jumpToToday: true);
      } else {
        hero.jumpToTodayDate(force: true);
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      centerToday();
      if (Get.isRegistered<NotificationService>()) {
        // ignore: discarded_futures
        Get.find<NotificationService>().ensurePushLinkedForCurrentUser();
      }
    });
    Future.delayed(const Duration(milliseconds: 350), centerToday);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController());

    return Scaffold(
      backgroundColor: context.background,
      body: Stack(
        children: [
          Obx(
            () => IndexedStack(
              index: controller.currentIndex.value,
              children: _pages,
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20 + 68 + 10 + MediaQuery.paddingOf(context).bottom,
            child: Obx(() {
              final onHome = controller.currentIndex.value == 0;
              if (!onHome) return const SizedBox.shrink();
              return const PregnancySuggestionBanner();
            }),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: "Today",
                      icon: HugeIcons.strokeRoundedCalendar03,
                      activeIcon: HugeIcons.strokeRoundedCalendar03,
                      controller: controller,
                    ),
                    _buildNavItem(
                      index: 1,
                      label: "User Privacy",
                      icon: HugeIcons.strokeRoundedChat01,
                      activeIcon: HugeIcons.strokeRoundedChat01,
                      controller: controller,
                    ),
                    _buildNavItem(
                      index: 2,
                      label: "Insights",
                      icon: HugeIcons.strokeRoundedBookOpen01,
                      activeIcon: HugeIcons.strokeRoundedBookOpen01,
                      controller: controller,
                    ),
                    _buildNavItem(
                      index: 3,
                      label: "Partner",
                      icon: HugeIcons.strokeRoundedFavourite,
                      activeIcon: HugeIcons.strokeRoundedFavourite,
                      controller: controller,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required List<List<dynamic>> icon,
    required List<List<dynamic>> activeIcon,
    required BottomNavController controller,
    VoidCallback? onTap,
  }) {
    final isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: onTap ?? () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 3),
            TextWidget(
              title: label,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              textColor: isSelected
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
