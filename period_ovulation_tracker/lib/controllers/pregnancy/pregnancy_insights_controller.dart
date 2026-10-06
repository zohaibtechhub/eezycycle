import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/controllers/pregnancy/pregnancy_suggestion_controller.dart';
import 'package:period_ovulation_tracker/data/pregnancy_insights_repository.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_insight_models.dart';
import 'package:period_ovulation_tracker/views/pregnancy/pregnancy_expect_detail_view.dart';
import 'package:period_ovulation_tracker/views/pregnancy/pregnancy_story_view.dart';

class PregnancyInsightsController extends GetxController {
  final _repo = PregnancyInsightsRepository.instance;

  final Rxn<PregnancyWeekInsight> insight = Rxn<PregnancyWeekInsight>();
  final RxBool loading = false.obs;
  /// Brief shimmer when gestational week number changes (not every day).
  final RxBool weekShimmering = false.obs;
  final RxInt contentWeek = 1.obs;
  final RxInt contentDay = 0.obs;

  Worker? _modeWorker;
  Worker? _dateWorker;

  int? _appliedWeek;
  bool _catalogReady = false;

  HomeHeroController get _hero => Get.find<HomeHeroController>();

  String get sectionDateLabel {
    final d = _hero.selectedDate.value;
    final now = DateTime.now();
    if (d.year != now.year) {
      return DateFormat('d MMM y').format(d);
    }
    return DateFormat('d MMM').format(d);
  }

  String get gestationalLabel {
    final w = contentWeek.value;
    final d = contentDay.value;
    final weekPart = w == 1 ? '1 week' : '$w weeks';
    final dayPart = d == 1 ? '1 day' : '$d days';
    return '$weekPart $dayPart';
  }

  @override
  void onInit() {
    super.onInit();
    // Pick up catalog version bumps (richer story pages) after asset updates.
    _repo.invalidateCache();
    _modeWorker = ever(_hero.pregnancyModeActive, (_) => _onModeOrDateChanged());
    _dateWorker = ever(_hero.selectedDate, (_) => _onModeOrDateChanged());
    _onModeOrDateChanged();
  }

  @override
  void onClose() {
    _modeWorker?.dispose();
    _dateWorker?.dispose();
    super.onClose();
  }

  void _onModeOrDateChanged() {
    if (!_hero.pregnancyModeActive.value) {
      insight.value = null;
      _appliedWeek = null;
      weekShimmering.value = false;
      return;
    }
    applyLocalForSelectedDate();
  }

  Future<void> applyLocalForSelectedDate() async {
    if (!_hero.pregnancyModeActive.value) return;

    final selected = _hero.selectedDate.value;
    final age = _hero.gestationalAgeForDate(selected);
    final weeks = age.weeks <= 0 ? 1 : age.weeks;
    final days = age.days;

    contentWeek.value = weeks;
    contentDay.value = days;

    final showSpinner = !_catalogReady && insight.value == null;
    if (showSpinner) loading.value = true;

    try {
      if (_catalogReady && _appliedWeek == weeks && insight.value != null) {
        return;
      }

      final weekChanged = _appliedWeek != null && _appliedWeek != weeks;
      if (weekChanged) {
        weekShimmering.value = true;
      }

      final local = await _repo.forWeek(weeks);
      if (local != null) {
        insight.value = local;
        _appliedWeek = weeks;
        _catalogReady = true;
      }

      if (weekChanged) {
        await Future<void>.delayed(const Duration(milliseconds: 520));
        if (!isClosed) weekShimmering.value = false;
      }
    } finally {
      if (showSpinner) loading.value = false;
    }
  }

  void openStory(String storyId) {
    final week = insight.value;
    if (week == null || week.stories.isEmpty) return;
    final index = week.stories.indexWhere((s) => s.id == storyId);
    Get.to(
      () => PregnancyStoryView(
        stories: week.stories,
        initialStoryIndex: index < 0 ? 0 : index,
      ),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
    )?.then((_) {
      if (Get.isRegistered<PregnancySuggestionController>()) {
        Get.find<PregnancySuggestionController>().offerForAction('story');
      }
    });
  }

  void openExpect(PregnancyExpectItem item) {
    Get.to(() => PregnancyExpectDetailView(item: item))?.then((_) {
      if (Get.isRegistered<PregnancySuggestionController>()) {
        Get.find<PregnancySuggestionController>().offerForAction('expect');
      }
    });
  }
}
