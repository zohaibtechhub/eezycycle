import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/article/bookmark_controller.dart';
import 'package:period_ovulation_tracker/controllers/auth_controller.dart';
import 'package:period_ovulation_tracker/controllers/commit_controller.dart';
import 'package:period_ovulation_tracker/controllers/drawer/drawer_controller.dart';
import 'package:period_ovulation_tracker/controllers/home/home_controller.dart';
import 'package:period_ovulation_tracker/controllers/onboarding_controller.dart';
import 'package:period_ovulation_tracker/controllers/product_controller.dart';
import 'package:period_ovulation_tracker/controllers/relationship/relationship_tip_controller.dart';

import '../../controllers/cycle_calender_controller.dart';
import '../../controllers/home/home_hero_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(BookmarkController(), permanent: true);
    Get.put(
      CycleCalendarController(mode: CalendarMode.onboarding),
      tag: CycleCalendarController.tagFor(CalendarMode.onboarding),
      permanent: true,
    );
    Get.put(OnboardingController(), permanent: true);
    Get.put(HomeHeroController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(DailyTipsController(), permanent: true);
    Get.put(CommitController(), permanent: true);
    Get.put(DrawerViewController(), permanent: true);
    Get.lazyPut<ProductController>(() => ProductController());
  }
}
