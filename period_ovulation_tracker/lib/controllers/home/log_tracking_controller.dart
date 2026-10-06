import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/services/api_service.dart';
import '../../core/utils/pref_util.dart';
import '../../core/utils/short_message.dart';
import '../../routes/app_pages.dart';
import 'home_hero_controller.dart';

class LogItem {
  final String id;
  final String name;
  final String category;
  final List<List<dynamic>> icon;

  const LogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });
}

class LogTrackingController extends GetxController {
  final DateTime targetDate;
  LogTrackingController({required this.targetDate});

  final ApiClient _api = ApiClient();
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxSet<String> selectedItemIds = <String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  bool get isToday {
    final now = DateTime.now();
    return targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day;
  }

  bool get isFutureDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return day.isAfter(today);
  }

  String get _ymd =>
      '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

  @override
  void onInit() {
    super.onInit();
    if (isFutureDate) return;
    Future.microtask(_loadFromServer);
  }

  Future<void> _loadFromServer() async {
    isLoading.value = true;
    try {
      final response = await _api.get('${ApiEndPoints.logs}?date=$_ymd');
      final data = ApiClient.unwrapData(response);
      final keys = data?['item_keys'];
      if (keys is List) {
        selectedItemIds
          ..clear()
          ..addAll(keys.map((e) => e.toString()));
        selectedItemIds.refresh();
      }
    } catch (_) {
      // keep empty selection
    } finally {
      isLoading.value = false;
    }
  }

  final List<String> categories = const [
    'Sex & Sex Drive',
    'Mood',
    'Symptoms',
    'Ovulation Test',
    'Pregnancy Test',
    'Digestion & Stool',
    'Physical Activity',
    'Other',
  ];

  final List<LogItem> allLogItems = const [
    // Sex & Sex Drive
    LogItem(
      id: 'sex_protected',
      name: 'Protected Sex',
      category: 'Sex & Sex Drive',
      icon: HugeIcons.strokeRoundedShield01,
    ),
    LogItem(
      id: 'sex_unprotected',
      name: 'Unprotected Sex',
      category: 'Sex & Sex Drive',
      icon: HugeIcons.strokeRoundedFavourite,
    ),
    LogItem(
      id: 'sex_high_drive',
      name: 'High Sex Drive',
      category: 'Sex & Sex Drive',
      icon: HugeIcons.strokeRoundedFire,
    ),
    LogItem(
      id: 'sex_low_drive',
      name: 'Low Sex Drive',
      category: 'Sex & Sex Drive',
      icon: HugeIcons.strokeRoundedBatteryLow,
    ),
    LogItem(
      id: 'sex_masturbation',
      name: 'Masturbation',
      category: 'Sex & Sex Drive',
      icon: HugeIcons.strokeRoundedUser,
    ),

    // Mood
    LogItem(
      id: 'mood_happy',
      name: 'Happy',
      category: 'Mood',
      icon: HugeIcons.strokeRoundedSmile,
    ),
    LogItem(
      id: 'mood_calm',
      name: 'Calm',
      category: 'Mood',
      icon: HugeIcons.strokeRoundedSun01,
    ),
    LogItem(
      id: 'mood_anxious',
      name: 'Anxious',
      category: 'Mood',
      icon: HugeIcons.strokeRoundedWindowsOld,
    ),
    LogItem(
      id: 'mood_sad',
      name: 'Low / Sad',
      category: 'Mood',
      icon: HugeIcons.strokeRoundedSad01,
    ),
    LogItem(
      id: 'mood_irritated',
      name: 'Irritated',
      category: 'Mood',
      icon: HugeIcons.strokeRoundedAlertCircle,
    ),
    LogItem(
      id: 'mood_energetic',
      name: 'Energetic',
      category: 'Mood',
      icon: HugeIcons.strokeRoundedFlash,
    ),

    // Symptoms
    LogItem(
      id: 'sym_cramps',
      name: 'Cramps',
      category: 'Symptoms',
      icon: HugeIcons.strokeRoundedActivity01,
    ),
    LogItem(
      id: 'sym_headache',
      name: 'Headache',
      category: 'Symptoms',
      icon: HugeIcons.strokeRoundedBrain,
    ),
    LogItem(
      id: 'sym_bloating',
      name: 'Bloating',
      category: 'Symptoms',
      icon: HugeIcons.strokeRoundedDroplet,
    ),
    LogItem(
      id: 'sym_tender_breasts',
      name: 'Tender Breasts',
      category: 'Symptoms',
      icon: HugeIcons.strokeRoundedHeartCheck,
    ),
    LogItem(
      id: 'sym_acne',
      name: 'Acne Breakout',
      category: 'Symptoms',
      icon: HugeIcons.strokeRoundedSparkles,
    ),
    LogItem(
      id: 'sym_fatigue',
      name: 'Fatigue',
      category: 'Symptoms',
      icon: HugeIcons.strokeRoundedSleeping,
    ),

    // Ovulation Test
    LogItem(
      id: 'ov_positive',
      name: 'LH Surge (Positive)',
      category: 'Ovulation Test',
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
    ),
    LogItem(
      id: 'ov_negative',
      name: 'LH Low (Negative)',
      category: 'Ovulation Test',
      icon: HugeIcons.strokeRoundedCancelCircle,
    ),
    LogItem(
      id: 'ov_faint',
      name: 'Faint Line',
      category: 'Ovulation Test',
      icon: HugeIcons.strokeRoundedTestTube01,
    ),

    // Cervical mucus (Phase 3 — supporting evidence only)
    LogItem(
      id: 'mucus_dry',
      name: 'Dry',
      category: 'Cervical Mucus',
      icon: HugeIcons.strokeRoundedDropletOff,
    ),
    LogItem(
      id: 'mucus_sticky',
      name: 'Sticky',
      category: 'Cervical Mucus',
      icon: HugeIcons.strokeRoundedDroplet,
    ),
    LogItem(
      id: 'mucus_creamy',
      name: 'Creamy',
      category: 'Cervical Mucus',
      icon: HugeIcons.strokeRoundedDroplet,
    ),
    LogItem(
      id: 'mucus_watery',
      name: 'Watery',
      category: 'Cervical Mucus',
      icon: HugeIcons.strokeRoundedWaterfallDown01,
    ),
    LogItem(
      id: 'mucus_egg_white',
      name: 'Egg White',
      category: 'Cervical Mucus',
      icon: HugeIcons.strokeRoundedSparkles,
    ),

    // Pregnancy Test
    LogItem(
      id: 'preg_positive',
      name: 'Positive (+)',
      category: 'Pregnancy Test',
      icon: HugeIcons.strokeRoundedAddCircleHalfDot,
    ),
    LogItem(
      id: 'preg_negative',
      name: 'Negative (-)',
      category: 'Pregnancy Test',
      icon: HugeIcons.strokeRoundedMinusSign,
    ),
    LogItem(
      id: 'preg_faint',
      name: 'Faint Positive',
      category: 'Pregnancy Test',
      icon: HugeIcons.strokeRoundedHelpCircle,
    ),

    // Digestion & Stool
    LogItem(
      id: 'dig_constipated',
      name: 'Constipated',
      category: 'Digestion & Stool',
      icon: HugeIcons.strokeRoundedArchive,
    ),
    LogItem(
      id: 'dig_diarrhea',
      name: 'Loose Stool',
      category: 'Digestion & Stool',
      icon: HugeIcons.strokeRoundedWaterfallDown01,
    ),
    LogItem(
      id: 'dig_nausea',
      name: 'Nausea',
      category: 'Digestion & Stool',
      icon: HugeIcons.strokeRoundedMedicalFile,
    ),
    LogItem(
      id: 'dig_healthy',
      name: 'Healthy Bowel',
      category: 'Digestion & Stool',
      icon: HugeIcons.strokeRoundedCheckmarkBadge01,
    ),

    // Physical Activity
    LogItem(
      id: 'act_yoga',
      name: 'Yoga / Stretch',
      category: 'Physical Activity',
      icon: HugeIcons.strokeRoundedActivity01,
    ),
    LogItem(
      id: 'act_walking',
      name: 'Walking',
      category: 'Physical Activity',
      icon: HugeIcons.strokeRoundedRunningShoes,
    ),
    LogItem(
      id: 'act_gym',
      name: 'Strength / Gym',
      category: 'Physical Activity',
      icon: HugeIcons.strokeRoundedDumbbell01,
    ),
    LogItem(
      id: 'act_rest',
      name: 'Rest Day',
      category: 'Physical Activity',
      icon: HugeIcons.strokeRoundedCoffee01,
    ),

    // Other
    LogItem(
      id: 'oth_alcohol',
      name: 'Alcohol Intake',
      category: 'Other',
      icon: HugeIcons.strokeRoundedGlasses,
    ),
    LogItem(
      id: 'oth_medication',
      name: 'Medication / Pill',
      category: 'Other',
      icon: HugeIcons.strokeRoundedMedicine01,
    ),
    LogItem(
      id: 'oth_travel',
      name: 'Travel / Jetlag',
      category: 'Other',
      icon: HugeIcons.strokeRoundedAirplane01,
    ),
  ];

  List<LogItem> get filteredItems {
    if (searchQuery.value.trim().isEmpty) return allLogItems;
    final query = searchQuery.value.toLowerCase();
    return allLogItems
        .where(
          (item) =>
              item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query),
        )
        .toList();
  }

  void toggleItem(String id) {
    if (selectedItemIds.contains(id)) {
      selectedItemIds.remove(id);
    } else {
      selectedItemIds.add(id);
    }
    selectedItemIds.refresh();
  }

  bool get _loggedPositivePregnancyTest =>
      selectedItemIds.contains('preg_positive') ||
      selectedItemIds.contains('preg_faint');

  Future<void> saveLogs() async {
    if (isSaving.value) return;
    if (isFutureDate) {
      if (Get.context != null) {
        ShortMessageUtils.showError(
          Get.context!,
          'You can only log for today or past days.',
        );
      }
      return;
    }

    // Positive / faint-positive: skip log save — go straight to pregnancy activation.
    if (_loggedPositivePregnancyTest) {
      Get.back();
      await _goToPregnancyActivation();
      return;
    }

    isSaving.value = true;
    try {
      await _api.put('${ApiEndPoints.logs}/$_ymd', {
        'item_keys': selectedItemIds.toList(),
      });
      Get.back();
      if (Get.context != null) {
        ShortMessageUtils.showSuccess(
          Get.context!,
          'Saved for ${targetDate.day}/${targetDate.month}',
        );
      }
      if (Get.isRegistered<HomeHeroController>()) {
        await Get.find<HomeHeroController>().loadCycleData(silent: true);
      }
    } catch (e) {
      if (Get.context != null) {
        ShortMessageUtils.showError(
          Get.context!,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  /// Skip saving logs — open pregnancy activation (user confirms there).
  Future<void> _goToPregnancyActivation() async {
    if (PrefUtil.getBool(PrefUtil.isPartnerMode)) return;

    final alreadyActive = Get.isRegistered<HomeHeroController>() &&
        Get.find<HomeHeroController>().pregnancyModeActive.value;
    if (alreadyActive) {
      if (Get.isRegistered<HomeHeroController>()) {
        await Get.find<HomeHeroController>().loadCycleData(silent: true);
      }
      return;
    }

    Get.toNamed(AppPages.pregnancyActivation);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
