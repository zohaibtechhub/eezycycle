import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';

import '../core/constants/app_images.dart';
import '../core/services/api_service.dart';
import '../core/services/notification_service.dart';
import '../core/utils/pref_util.dart';
import '../core/utils/short_message.dart';
import '../models/onboarding/onboarding_goal.dart';
import '../models/onboarding/onboarding_option.dart';
import '../models/onboarding/onboarding_step.dart';
import 'auth_controller.dart';
import 'cycle_calender_controller.dart';
import 'drawer/drawer_controller.dart';

class ProgressStage {
  final String firstPart;
  final String highlightPart;
  final String? endPart;
  final String subtitle;
  final String image;

  const ProgressStage({
    required this.firstPart,
    required this.highlightPart,
    this.endPart,
    required this.subtitle,
    required this.image,
  });
}

enum OnboardingFlow {
  normal,
  partner,
  trackCycle,
  getPregnant,
  trackPerimenopause,
}

class OnboardingController extends GetxController {
  // ===========================================================================
  // 1. STATE VARIABLES & CONTROLLERS
  // ===========================================================================

  // --- Privacy & Terms ---
  final RxBool acceptedTerms = false.obs;
  final RxBool acceptedHealthData = false.obs;

  // --- Usage Type ---
  final RxnString selectedUsage = RxnString();
  final List<String> usageOptions = const [
    'Yes, I\'m using it for myself',
    'No, I have a partner code',
  ];
  final Rx<OnboardingFlow> onboardingFlow = OnboardingFlow.normal.obs;

  bool get isPartnerFlow => onboardingFlow.value == OnboardingFlow.partner;

  // --- Partner code entry (male partner path) ---
  final TextEditingController partnerCodeController = TextEditingController();
  final RxString partnerCodeInput = ''.obs;
  final RxBool partnerShareConsented = false.obs;
  final RxBool partnerLinked = false.obs;

  bool get canContinuePartnerCode =>
      partnerCodeInput.value.trim().length >= 4 && partnerShareConsented.value;

  // --- Discovery Source ---
  final RxnString selectedSource = RxnString();
  final List<String> sources = const [
    'Google Play or Google Search',
    'Instagram or Facebook',
    'TikTok or YouTube',
    'Friends or Family',
    'Doctor or Healthcare Professional',
    'Online Advertisement',
    'Blog or Online Article',
    'App Recommendation',
    'Reddit or Online Community',
    'WhatsApp or Messaging App',
    'Women’s Health Community',
    'Search Engine',
    'Other',
  ];

  // --- Birth Year & Wheel Picker ---
  final int currentYear = DateTime.now().year;
  late final int maxYear = currentYear - 13;
  late final int minYear = currentYear - 90;
  final RxInt selectedYear = RxInt(DateTime.now().year - 25);
  late final FixedExtentScrollController wheelController;

  // --- Goals Selection ---
  final List<Map<String, String>> whatYouLike = [
    {'title': 'Get pregnant', 'image': AppImages.getPregnant},
    {'title': 'Track my pregnancy', 'image': AppImages.trackPregnancy},
    {'title': 'Track my period', 'image': AppImages.trackPeriod},
    {'title': 'Take charge of my well-being', 'image': AppImages.wellness},
    {'title': 'Manage my weight', 'image': AppImages.manageWeight},
    {'title': 'Enhance my sex life', 'image': AppImages.enhanceSexLife},
    {'title': 'Decode my discharge', 'image': AppImages.decodeDischarge},
    {'title': 'Explore contraception', 'image': AppImages.birthControl},
  ];
  final RxList<String> selectedGoals = <String>[].obs;

  // --- Dynamic Onboarding Steps ---
  final RxList<OnboardingStep> steps = <OnboardingStep>[].obs;
  final RxInt currentStepIndex = 0.obs;
  final RxMap<String, List<String>> answers = <String, List<String>>{}.obs;
  final RxBool isInsightAnalyzing = false.obs;

  // --- Height & Weight Measurements ---
  final RxInt measurementSubStep = 0.obs; // 0 = Height, 1 = Weight
  final RxBool isMetric = true.obs;
  final RxDouble heightCm = 170.0.obs;
  final RxDouble weightKg = 65.0.obs;

  // --- Calendar Date Selection ---
  final RxSet<DateTime> selectedPeriodDates = <DateTime>{}.obs;
  final RxSet<int> customizedMonths = <int>{}.obs;

  // --- Progress Analysis & Generation ---
  final RxDouble progressValue = 0.0.obs;
  final RxInt progressStageIndex = 0.obs;
  Timer? _progressTimer;

  final List<ProgressStage> progressStages = [
    ProgressStage(
      firstPart: 'Get daily personalized ',
      highlightPart: 'insight',
      endPart: ' on your cycle',
      subtitle:
          'Tailoring predictions according to your unique biological rhythm.',
      image: AppImages.cycleFertility,
    ),
    ProgressStage(
      firstPart: 'Get instant insights with our ',
      highlightPart: 'health articles',
      endPart: '',
      subtitle:
          'Evidence-based guidance written by leading reproductive specialists.',
      image: AppImages.expertPregnancyQuestions,
    ),
    ProgressStage(
      firstPart: 'Find answers to your most ',
      highlightPart: 'intimate questions',
      endPart: '',
      subtitle: 'A private and judgment-free space to explore body signals.',
      image: AppImages.bodySignals,
    ),
    ProgressStage(
      firstPart: 'Your ultimate ',
      highlightPart: 'Period and ovulation',
      endPart: ' tracker is ready',
      subtitle: 'Calculating fertile windows and upcoming cycle dates...',
      image: AppImages.fertilityResult,
    ),
  ];

  final RxInt calendarSelectionCount = 0.obs;

  final ApiClient _api = ApiClient();
  final RxBool isSyncing = false.obs;
  final RxBool hasSyncedComplete = false.obs;

  // ===========================================================================
  // 2. COMPUTED GETTERS
  // ===========================================================================

  CycleCalendarController get calendarController =>
      Get.find<CycleCalendarController>(
        tag: CycleCalendarController.tagFor(CalendarMode.onboarding),
      );

  /// Returns true if the user accepted both privacy policy and health data processing

  bool get canContinue => acceptedTerms.value && acceptedHealthData.value;

  /// Retrieves the active onboarding step
  OnboardingStep? get currentStep {
    if (steps.isEmpty || currentStepIndex.value >= steps.length) return null;
    return steps[currentStepIndex.value];
  }

  /// Validates whether the active step satisfies continuation requirements
  bool get canContinueStep {
    final step = currentStep;
    if (step == null) return false;

    if (step.type == OnboardingStepType.calendar) {
      // Accessing this .value forces Obx in OnboardingView to track the calendar selection changes!
      return calendarSelectionCount.value > 0;
    }

    if (step.type == OnboardingStepType.measurement) {
      return measurementSubStep.value == 0
          ? heightCm.value > 0
          : weightKg.value > 0;
    }

    switch (step.selectionType) {
      case OnboardingSelectionType.single:
      case OnboardingSelectionType.multiple:
        return hasSelection;
      case OnboardingSelectionType.none:
        return true;
    }
  }

  /// Computes linear progress (0.0 to 1.0) based on steps marked `countsTowardProgress`
  double? get progress {
    final progressSteps = steps
        .where((step) => step.countsTowardProgress)
        .toList();
    if (progressSteps.isEmpty) return null;

    final current = currentStep;
    if (current == null || !current.countsTowardProgress) return null;

    final currentProgressIndex = progressSteps.indexOf(current);
    if (currentProgressIndex == -1) return null;

    return (currentProgressIndex + 1) / progressSteps.length;
  }

  /// Selected option IDs for the current question step
  List<String> get selectedOptionIds {
    // Touch map length so Obx always subscribes to answers changes
    // ignore: unused_local_variable
    final _ = answers.length;
    final step = currentStep;
    if (step == null) return [];
    return List<String>.from(answers[step.id] ?? const <String>[]);
  }

  /// Whether the user selected at least one option in the current step
  bool get hasSelection => selectedOptionIds.isNotEmpty;

  /// Flags if user is under 16 years old based on selected birth year
  bool get isShowAttention => (currentYear - selectedYear.value) < 16;

  /// Formats height based on unit preference (Metric vs Imperial)
  String get heightDisplay {
    if (isMetric.value) {
      return '${heightCm.value.round()} cm';
    }
    final totalInches = (heightCm.value / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return "$feet' $inches\"";
  }

  final RxnString pendingExperienceMode = RxnString();

  /// Formats weight based on unit preference (Metric vs Imperial)
  String get weightDisplay {
    if (isMetric.value) {
      return '${weightKg.value.round()} kg';
    }
    return '${(weightKg.value * 2.20462).round()} lb';
  }

  // ===========================================================================
  // 3. LIFECYCLE HOOKS
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();
    setSteps(pregnancyOnboardingSteps);
    ever(currentStepIndex, (_) => _handleStepChange());

    final initialIndex = selectedYear.value - minYear;
    wheelController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    wheelController.dispose();
    partnerCodeController.dispose();
    super.onClose();
  }

  // ===========================================================================
  // 4. ACTION METHODS
  // ===========================================================================

  // --- Step & Navigation Methods ---

  /// Initializes the step list and resets onboarding pointers
  void setSteps(List<OnboardingStep> onboardingSteps) {
    steps.assignAll(onboardingSteps);
    currentStepIndex.value = 0;
    measurementSubStep.value = 0;
    answers.clear();
    _handleStepChange();
  }

  /// Moves to the next sub-step or advances to the next step.
  /// Calendar / measurement Continue persists to API immediately (not only at end).
  Future<void> nextStep() async {
    if (isSyncing.value) return;
    final step = currentStep;
    if (step == null) return;

    // Period calendar → save days before leaving this page
    if (step.type == OnboardingStepType.calendar) {
      final ok = await _savePeriodDays();
      if (!ok) return;
    }

    // Height → Weight: save height now so it is not lost later
    if (step.type == OnboardingStepType.measurement &&
        measurementSubStep.value == 0) {
      final ok = await _saveMeasurements();
      if (!ok) return;
      measurementSubStep.value = 1;
      return;
    }

    // Weight done → save height + weight before leaving measurement
    if (step.type == OnboardingStepType.measurement) {
      final ok = await _saveMeasurements();
      if (!ok) return;
      measurementSubStep.value = 0;
    }

    // Reminder screens → await OS permission before leaving (dialog needs focus).
    if (step.type == OnboardingStepType.reminder &&
        Get.isRegistered<NotificationService>()) {
      await Get.find<NotificationService>().promptIfNeeded();
    }

    if (currentStepIndex.value >= steps.length - 1) {
      finishOnboarding();
      return;
    }
    currentStepIndex.value++;
  }

  /// Skips the current step if skippable
  void skipStep() {
    final step = currentStep;
    if (step == null || !step.canSkip) return;
    nextStep();
  }

  /// Triggers the end of onboarding and routes to progress analysis
  void finishOnboarding() {
    if (pendingExperienceMode.value != null) {
      final drawerController = Get.find<DrawerViewController>();
      drawerController.selectedExperience.value = pendingExperienceMode.value!;
      ShortMessageUtils.showSuccess(
        Get.context!,
        "Successfully switched your experience mode!",
      );
    }

    // Flows without a reminder step (track cycle / pregnant / peri) still ask once.
    if (Get.isRegistered<NotificationService>()) {
      // ignore: discarded_futures
      Get.find<NotificationService>().promptIfNeeded(
        delay: const Duration(milliseconds: 600),
      );
    }

    Get.offAllNamed(AppPages.progress);
  }

  /// Simulates analysis delays on insight screens
  void _handleStepChange() {
    final step = currentStep;
    if (step?.type == OnboardingStepType.insight) {
      isInsightAnalyzing.value = true;
      Future.delayed(const Duration(seconds: 5), () {
        if (currentStep?.type == OnboardingStepType.insight) {
          isInsightAnalyzing.value = false;
        }
      });
    } else {
      isInsightAnalyzing.value = false;
    }

    // Ask as soon as the notifications value screen appears.
    if (step?.type == OnboardingStepType.reminder &&
        Get.isRegistered<NotificationService>()) {
      // ignore: discarded_futures
      Get.find<NotificationService>().promptIfNeeded(
        delay: const Duration(milliseconds: 400),
      );
    }
  }

  // --- Question & Option Methods ---

  /// Toggles single or multiple choice option selections
  void selectOption(OnboardingOption option) {
    final step = currentStep;
    if (step == null || step.selectionType == OnboardingSelectionType.none) {
      return;
    }

    if (step.selectionType == OnboardingSelectionType.single) {
      answers[step.id] = [option.id];
      answers.refresh();
      return;
    }

    final selected = List<String>.from(answers[step.id] ?? []);

    if (option.isExclusive) {
      answers[step.id] = [option.id];
      answers.refresh();
      return;
    }

    selected.removeWhere((selectedId) {
      final selectedOption = step.options.firstWhere(
        (item) => item.id == selectedId,
      );
      return selectedOption.isExclusive;
    });

    if (selected.contains(option.id)) {
      selected.remove(option.id);
    } else {
      selected.add(option.id);
    }

    answers[step.id] = selected;
    answers.refresh();
  }

  /// Checks if a specific option ID is selected in the active step
  bool isOptionSelected(String optionId) =>
      selectedOptionIds.contains(optionId);

  // --- Measurement & Unit Methods ---

  /// Toggles unit system (true = Metric, false = Imperial)
  void setMetric(bool value) => isMetric.value = value;

  /// Updates height in centimeters
  void setHeight(double value) => heightCm.value = value;

  /// Updates weight in kilograms
  void setWeight(double value) => weightKg.value = value;

  // --- Calendar Date Selection Methods ---

  /// Strips time components for clean calendar date comparisons
  DateTime normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Checks if two DateTimes land on the same calendar day
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Checks if a specific date is currently highlighted
  bool isDateSelected(DateTime date) {
    final normalizedDate = normalizeDate(date);
    return selectedPeriodDates.any(
      (selectedDate) => isSameDay(selectedDate, normalizedDate),
    );
  }

  /// Handles single-day tapping and default 5-day cycle selections
  void togglePeriodDate(DateTime date) {
    final normalizedDate = normalizeDate(date);
    final today = normalizeDate(DateTime.now());

    if (normalizedDate.isAfter(today)) return;

    final monthKey = normalizedDate.month;

    if (isDateSelected(normalizedDate)) {
      selectedPeriodDates.removeWhere(
        (selectedDate) => isSameDay(selectedDate, normalizedDate),
      );
      customizedMonths.add(monthKey);
      return;
    }

    if (customizedMonths.contains(monthKey)) {
      selectedPeriodDates.add(normalizedDate);
      return;
    }

    customizedMonths.add(monthKey);

    for (int i = 0; i < 5; i++) {
      final targetDate = normalizedDate.add(Duration(days: i));
      if (!targetDate.isAfter(today)) {
        selectedPeriodDates.add(targetDate);
      }
    }
  }

  // --- Progress Flow Timer Methods ---

  /// Starts the 5-second progress ticker and updates visual stages
  void startProgressFlow({VoidCallback? onComplete}) {
    progressValue.value = 0.0;
    progressStageIndex.value = 0;
    _progressTimer?.cancel();

    const totalDurationMs = 5000;
    const tickIntervalMs = 40;
    final stepIncrement = tickIntervalMs / totalDurationMs;

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: tickIntervalMs),
      (timer) {
        if (progressValue.value < 1.0) {
          progressValue.value = (progressValue.value + stepIncrement).clamp(
            0.0,
            1.0,
          );

          final stageIndex = (progressValue.value * progressStages.length)
              .floor()
              .clamp(0, progressStages.length - 1);

          if (stageIndex != progressStageIndex.value) {
            progressStageIndex.value = stageIndex;
          }
        } else {
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (onComplete != null) {
              onComplete();
            } else {
              finishOnboarding();
            }
          });
        }
      },
    );
  }

  // --- Step 1: Privacy First Methods ---

  void setTerms(bool? value) => acceptedTerms.value = value ?? false;
  void setHealthData(bool? value) => acceptedHealthData.value = value ?? false;
  void acceptAll() {
    acceptedTerms.value = true;
    acceptedHealthData.value = true;
  }

  Future<void> continuePrivacyNext() async {
    if (!canContinue || isSyncing.value) return;

    final authOk = await Get.find<AuthController>().ensureGuestSession();
    if (!authOk) return;

    final ok = await _runApi(() async {
      await _api.post(ApiEndPoints.meConsents, {
        'consents': [
          {'type': 'terms', 'accepted': true},
          {'type': 'health_data', 'accepted': true},
        ],
      });
    });
    if (!ok) return;
    Get.offNamed(AppPages.usage);
  }

  // --- Step 2: Usage Selection Methods ---

  void startOnboardingFlow(OnboardingFlow flow, {String? modeLabel}) {
    onboardingFlow.value = flow;
    if (modeLabel != null) {
      pendingExperienceMode.value = modeLabel;
    }
    switch (flow) {
      case OnboardingFlow.normal:
        setSteps(pregnancyOnboardingSteps);
        break;
      case OnboardingFlow.partner:
        setSteps(partnerOnboardingSteps);
        break;
      case OnboardingFlow.trackCycle:
        setSteps(trackCycleOnboardingSteps);
        break;
      case OnboardingFlow.getPregnant:
        setSteps(getPregnantOnboardingSteps);
        break;
      case OnboardingFlow.trackPerimenopause:
        setSteps(perimenopauseOnboardingSteps);
        break;
    }
  }

  Future<void> selectUsage(String option) async {
    selectedUsage.value = option;
    await Future.delayed(const Duration(milliseconds: 300));
    await continueUsageNext();
  }

  Future<void> continueUsageNext() async {
    if (selectedUsage.value == null || isSyncing.value) return;

    final isPartner = selectedUsage.value == 'No, I have a partner code';

    // Only stamp usage_path here. experience_mode=partner is set AFTER a
    // successful code link — otherwise splash can treat them as finished.
    final ok = await _runApi(() async {
      await _api.patch(ApiEndPoints.meProfile, {
        'usage_path': isPartner ? 'partner' : 'self',
      });
    });
    if (!ok) return;

    if (isPartner) {
      onboardingFlow.value = OnboardingFlow.partner;
      await PrefUtil.setBool(PrefUtil.isPartnerMode, false);
      await PrefUtil.setBool(PrefUtil.onboardingCompleted, false);
      // Keep Usage on the stack so partner-code screen can go back.
      Get.toNamed(AppPages.partnerCodeEntry);
      return;
    }

    startOnboardingFlow(OnboardingFlow.normal);
    Get.offNamed(AppPages.discovery);
  }

  void onPartnerCodeChanged(String value) {
    partnerCodeInput.value = value.trim().toUpperCase();
  }

  void setPartnerShareConsent(bool? value) {
    partnerShareConsented.value = value ?? false;
  }

  /// Back from partner-code → Usage so they can pick “for myself” instead.
  void goBackFromPartnerCode() {
    partnerCodeController.clear();
    partnerCodeInput.value = '';
    partnerShareConsented.value = false;
    selectedUsage.value = null;
    onboardingFlow.value = OnboardingFlow.normal;

    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(AppPages.usage);
    }
  }

  /// After Usage → enter woman's code → partner Q&A onboarding.
  Future<void> continuePartnerCodeNext() async {
    if (!canContinuePartnerCode || isSyncing.value) return;

    final code = partnerCodeInput.value.trim().toUpperCase();
    final ok = await _runApi(() async {
      await _api.post(ApiEndPoints.partnerLink, {
        'code': code,
        'consented': true,
      });
      await _api.patch(ApiEndPoints.meProfile, {
        'usage_path': 'partner',
        'experience_mode': 'partner',
        'partner_code_entered': code,
      });
    });
    if (!ok) return;

    partnerLinked.value = true;
    await PrefUtil.setBool(PrefUtil.isPartnerMode, true);
    await PrefUtil.setString(PrefUtil.experienceMode, 'partner');

    startOnboardingFlow(OnboardingFlow.partner);
    Get.offAllNamed(AppPages.onboarding);
  }

  // --- Step 3: Discovery Source Methods ---

  Future<void> selectSource(String source) async {
    selectedSource.value = source;
    await Future.delayed(const Duration(milliseconds: 300));
    await continueDiscoveryNext();
  }

  Future<void> continueDiscoveryNext() async {
    if (selectedSource.value == null || isSyncing.value) return;

    final ok = await _runApi(() async {
      await _api.patch(ApiEndPoints.meProfile, {
        'discovery_source': selectedSource.value,
      });
    });
    if (!ok) return;
    Get.offNamed(AppPages.birthYear);
  }

  // --- Step 4: Birth Year Methods ---

  Future<void> selectYear(int year) async {
    selectedYear.value = year;
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> continueYearNext() async {
    if (isSyncing.value) return;
    final ok = await _runApi(() async {
      await _api.patch(ApiEndPoints.meProfile, {
        'birth_year': selectedYear.value,
      });
    });
    if (!ok) return;
    Get.offNamed(AppPages.whatLike);
  }

  // --- Step 5: What You Like / Goals Methods ---

  void toggleGoal(String goal) {
    if (selectedGoals.contains(goal)) {
      selectedGoals.remove(goal);
    } else {
      selectedGoals.add(goal);
    }
    selectedGoals.refresh();
  }

  Future<void> onClickGoalNext() async {
    if (selectedGoals.isEmpty || isSyncing.value) return;

    final ok = await _runApi(() async {
      await _api.put(ApiEndPoints.onboardingGoals, {
        'goals': selectedGoals.toList(),
      });
      await _api.patch(ApiEndPoints.meProfile, {
        'experience_mode': _experienceModeForGoals(),
      });
    });
    if (!ok) return;

    startOnboardingFlow(OnboardingFlow.normal);
    Get.offNamed(AppPages.onboarding);
  }

  /// Called from ProgressView — one-shot complete + periods + answers.
  Future<bool> syncCompleteOnboarding() async {
    if (hasSyncedComplete.value) return true;
    if (isSyncing.value) return false;

    isSyncing.value = true;
    try {
      final periodDates = _currentPeriodDateStrings();

      // Best-effort extras — must not block marking onboarding complete
      try {
        if (answers.isNotEmpty) {
          await _api.put(ApiEndPoints.onboardingAnswers, {
            'flow_key': _flowKey(),
            'answers': Map<String, List<String>>.from(answers),
          });
        }
      } catch (_) {}

      try {
        await _api.patch(ApiEndPoints.meProfile, {
          'height_cm': heightCm.value,
          'weight_kg': weightKg.value,
          'is_metric': isMetric.value,
          'birth_year': selectedYear.value,
          if (selectedSource.value != null)
            'discovery_source': selectedSource.value,
        });
      } catch (_) {}

      try {
        if (periodDates.isNotEmpty) {
          await _api.put(ApiEndPoints.cyclePeriodDays, {'dates': periodDates});
        }
      } catch (_) {}

      // Identify the user in OneSignal *before* onboardingComplete so the
      // backend planner can update tags / schedule pushes for this External ID.
      try {
        if (Get.isRegistered<NotificationService>()) {
          final uid = PrefUtil.getInt(PrefUtil.userId);
          await Get.find<NotificationService>().loginUser(uid > 0 ? uid : null);
        }
      } catch (_) {}

      try {
        await _api.post(ApiEndPoints.onboardingComplete, {
          'flow_key': _flowKey(),
          'experience_mode': _resolveExperienceMode(),
          'usage_path': _usagePath(),
          if (selectedSource.value != null)
            'discovery_source': selectedSource.value,
          'birth_year': selectedYear.value,
          'height_cm': heightCm.value,
          'weight_kg': weightKg.value,
          'is_metric': isMetric.value,
          if (selectedGoals.isNotEmpty) 'goals': selectedGoals.toList(),
          if (periodDates.isNotEmpty) 'last_period_dates': periodDates,
          'timezone': _timezoneLabel(),
          'reminders': {
            'fertile_days_enabled': true,
            'pregnancy_test_enabled': false,
            'daily_tips_enabled': true,
            'period_reminder_enabled': true,
          },
        });
      } catch (e) {
        final ctx = Get.context;
        if (ctx != null) {
          ShortMessageUtils.showError(
            ctx,
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
        return false;
      }

      hasSyncedComplete.value = true;
      await PrefUtil.setBool(PrefUtil.onboardingCompleted, true);
      if (isPartnerFlow || _usagePath() == 'partner') {
        await PrefUtil.setBool(PrefUtil.isPartnerMode, true);
        await PrefUtil.setString(PrefUtil.experienceMode, 'partner');
      } else {
        await PrefUtil.setBool(PrefUtil.isPartnerMode, false);
      }

      // Ensure subscription is registered with backend after planner may have run.
      try {
        if (Get.isRegistered<NotificationService>()) {
          await Get.find<NotificationService>().ensurePushLinkedForCurrentUser();
        }
      } catch (_) {}

      return true;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<bool> _savePeriodDays() async {
    final tag = CycleCalendarController.tagFor(CalendarMode.onboarding);
    final calendar = Get.isRegistered<CycleCalendarController>(tag: tag)
        ? Get.find<CycleCalendarController>(tag: tag)
        : null;
    final dates = calendar?.loggedPeriodDates ?? selectedPeriodDates;

    if (dates.isEmpty) {
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showError(ctx, 'Please select your period days.');
      }
      return false;
    }

    selectedPeriodDates
      ..clear()
      ..addAll(dates.map(normalizeDate));

    final periodDates = selectedPeriodDates
        .map((d) => DateFormat('yyyy-MM-dd').format(d))
        .toList();

    return _runApi(() async {
      await _api.put(ApiEndPoints.cyclePeriodDays, {'dates': periodDates});
    });
  }

  Future<bool> _saveMeasurements() async {
    return _runApi(() async {
      await _api.patch(ApiEndPoints.meProfile, {
        'height_cm': heightCm.value,
        'weight_kg': weightKg.value,
        'is_metric': isMetric.value,
      });
    });
  }

  /// Period dates from calendar UI (source of truth during onboarding).
  List<String> _currentPeriodDateStrings() {
    final tag = CycleCalendarController.tagFor(CalendarMode.onboarding);
    final calendarDates = Get.isRegistered<CycleCalendarController>(tag: tag)
        ? Get.find<CycleCalendarController>(tag: tag).loggedPeriodDates
        : selectedPeriodDates;
    if (calendarDates.isNotEmpty) {
      selectedPeriodDates
        ..clear()
        ..addAll(calendarDates.map(normalizeDate));
    }
    return selectedPeriodDates
        .map((d) => DateFormat('yyyy-MM-dd').format(normalizeDate(d)))
        .toList();
  }

  String _timezoneLabel() {
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours;
    final mins = offset.inMinutes.remainder(60).abs();
    final sign = hours >= 0 ? '+' : '-';
    return 'UTC$sign${hours.abs().toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  String _flowKey() {
    switch (onboardingFlow.value) {
      case OnboardingFlow.normal:
        return 'normal';
      case OnboardingFlow.partner:
        return 'partner';
      case OnboardingFlow.trackCycle:
        return 'track_cycle';
      case OnboardingFlow.getPregnant:
        return 'get_pregnant';
      case OnboardingFlow.trackPerimenopause:
        return 'perimenopause';
    }
  }

  String _usagePath() {
    if (isPartnerFlow) return 'partner';
    if (selectedUsage.value == 'No, I have a partner code') return 'partner';
    return 'self';
  }

  String _experienceModeForGoals() {
    // Multi-select: prefer the most specific mode, then Track cycle as default.
    if (selectedGoals.contains('Track my period')) return 'track_cycle';
    if (selectedGoals.contains('Get pregnant')) return 'get_pregnant';
    if (selectedGoals.contains('Track my pregnancy')) return 'track_pregnancy';
    return 'track_cycle';
  }

  String _resolveExperienceMode() {
    final pending = pendingExperienceMode.value;
    if (pending != null) {
      switch (pending.toLowerCase()) {
        case 'track cycle':
          return 'track_cycle';
        case 'get pregnant':
          return 'get_pregnant';
        case 'track pregnancy':
          return 'track_pregnancy';
        case 'track perimenopause':
          return 'perimenopause';
      }
    }
    if (isPartnerFlow) return 'partner';
    return _experienceModeForGoals();
  }

  Future<bool> _runApi(Future<void> Function() action) async {
    if (isSyncing.value) return false;
    isSyncing.value = true;
    try {
      await action();
      return true;
    } catch (e) {
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showError(
          ctx,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
      return false;
    } finally {
      isSyncing.value = false;
    }
  }
}
