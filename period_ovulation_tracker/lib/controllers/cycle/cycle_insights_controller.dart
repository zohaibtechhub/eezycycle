import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/data/article_repository.dart';
import 'package:period_ovulation_tracker/data/cycle_insights_repository.dart';
import 'package:period_ovulation_tracker/models/article/cycle_article_model.dart';
import 'package:period_ovulation_tracker/models/cycle/cycle_phase_insight.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_insight_models.dart';
import 'package:period_ovulation_tracker/views/pregnancy/pregnancy_expect_detail_view.dart';
import 'package:period_ovulation_tracker/views/pregnancy/pregnancy_story_view.dart';
import 'package:period_ovulation_tracker/controllers/pregnancy/pregnancy_suggestion_controller.dart';

class CycleInsightsController extends GetxController {
  final _repo = CycleInsightsRepository.instance;

  final Rxn<CyclePhaseInsight> insight = Rxn<CyclePhaseInsight>();
  final RxBool loading = false.obs;
  final RxBool phaseShimmering = false.obs;
  final Rx<CyclePhaseType> contentPhase = CyclePhaseType.follicular.obs;

  Worker? _modeWorker;
  Worker? _dateWorker;
  CyclePhaseType? _appliedPhase;
  bool _catalogReady = false;

  HomeHeroController get _hero => Get.find<HomeHeroController>();

  String get sectionDateLabel {
    final d = _hero.selectedDate.value;
    final now = DateTime.now();
    if (d.year != now.year) return DateFormat('d MMM y').format(d);
    return DateFormat('d MMM').format(d);
  }

  String get phaseLabel => insight.value?.phaseLabel ??
      ArticleRepository.phaseLabel(contentPhase.value);

  String get storyStatusLine {
    final d = _hero.selectedDate.value;
    return '${DateFormat('MMMM d').format(d)} · $phaseLabel';
  }

  @override
  void onInit() {
    super.onInit();
    _modeWorker = ever(_hero.pregnancyModeActive, (_) => _sync());
    _dateWorker = ever(_hero.selectedDate, (_) => _sync());
    ever(_hero.todayPayload, (_) => _sync());
    _sync();
  }

  @override
  void onClose() {
    _modeWorker?.dispose();
    _dateWorker?.dispose();
    super.onClose();
  }

  CyclePhaseType _resolvePhase() {
    final data = _hero.currentSelectedData;
    final payload = _hero.todayPayload.value;
    final payloadDate = payload?['date']?.toString();
    final selectedYmd =
        '${data.date.year.toString().padLeft(4, '0')}-'
        '${data.date.month.toString().padLeft(2, '0')}-'
        '${data.date.day.toString().padLeft(2, '0')}';
    String? apiPhase;
    if (payload != null && payloadDate == selectedYmd) {
      apiPhase = payload['phase']?.toString();
    }
    return ArticleRepository.phaseFromHome(
      dayType: data.type,
      apiPhase: apiPhase,
      pregnancyModeActive: false,
    );
  }

  Future<void> _sync() async {
    if (_hero.pregnancyModeActive.value) {
      insight.value = null;
      _appliedPhase = null;
      phaseShimmering.value = false;
      return;
    }
    await applyForCurrentPhase();
  }

  Future<void> applyForCurrentPhase() async {
    if (_hero.pregnancyModeActive.value) return;

    final phase = _resolvePhase();
    contentPhase.value = phase;

    final showSpinner = !_catalogReady && insight.value == null;
    if (showSpinner) loading.value = true;

    try {
      if (_catalogReady && _appliedPhase == phase && insight.value != null) {
        return;
      }

      final changed = _appliedPhase != null && _appliedPhase != phase;
      if (changed) phaseShimmering.value = true;

      final local = await _repo.forPhase(phase);
      if (local != null) {
        insight.value = local;
        _appliedPhase = phase;
        _catalogReady = true;
      }

      if (changed) {
        await Future<void>.delayed(const Duration(milliseconds: 480));
        if (!isClosed) phaseShimmering.value = false;
        if (Get.isRegistered<PregnancySuggestionController>()) {
          Get.find<PregnancySuggestionController>()
              .offerForAction('phase_change');
        }
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
        statusLineOverride: storyStatusLine,
        footerNote: 'Educational cycle insights — not medical advice.',
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
