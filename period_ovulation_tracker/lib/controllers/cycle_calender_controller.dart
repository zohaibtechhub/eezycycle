import 'dart:async';

import 'package:get/get.dart';

import '../core/services/api_service.dart';
import '../core/services/cycle_display_mapper.dart';
import 'home/home_hero_controller.dart';
import 'onboarding_controller.dart';

enum CalendarMode { onboarding, partner, tracker }

class CycleCalendarController extends GetxController {
  final CalendarMode mode;

  CycleCalendarController({this.mode = CalendarMode.onboarding});

  final RxSet<DateTime> loggedPeriodDates = <DateTime>{}.obs;
  final RxSet<DateTime> predictedPeriodDates = <DateTime>{}.obs;
  final RxSet<DateTime> predictedFertileDates = <DateTime>{}.obs;
  final RxSet<DateTime> predictedOvulationDates = <DateTime>{}.obs;
  final RxSet<int> customizedMonths = <int>{}.obs;

  /// Full-screen/top spinner — only for the first fetch, never on each day tap.
  final RxBool isLoading = false.obs;

  /// True while an explicit Log PUT is in flight.
  final RxBool isSaving = false.obs;

  /// True when local period taps differ from the last saved/server snapshot.
  final RxBool hasUnsavedChanges = false.obs;

  final ApiClient _api = ApiClient();
  bool _hasLoadedOnce = false;

  /// Last successfully saved (or server-loaded) logged days — for dirty checks.
  Set<DateTime> _baselineLogged = {};

  static String tagFor(CalendarMode mode) => mode.name;

  @override
  void onInit() {
    super.onInit();
    if (mode == CalendarMode.tracker || mode == CalendarMode.partner) {
      Future.microtask(loadFromServer);
    }
  }

  Future<void> loadFromServer({int? year, bool showLoading = true}) async {
    if (mode == CalendarMode.onboarding) return;
    final shouldShow = showLoading && !_hasLoadedOnce;
    if (shouldShow) isLoading.value = true;
    try {
      final y = year ?? DateTime.now().year;
      final path = mode == CalendarMode.partner
          ? '${ApiEndPoints.partnerCalendar}?from=$y-01-01&to=$y-12-31'
          : '${ApiEndPoints.cycleCalendar}?from=$y-01-01&to=$y-12-31';
      final response = await _api.get(path);
      final data = ApiClient.unwrapData(response);
      // Don't wipe in-progress edits the user hasn't logged yet.
      if (hasUnsavedChanges.value) {
        _applyPredictionsOnly(data);
      } else {
        applyServerCalendar(data);
      }
      _hasLoadedOnce = true;
    } catch (_) {
      // keep existing optimistic / last-known state
    } finally {
      if (shouldShow) isLoading.value = false;
    }
  }

  void applyServerCalendar(Map<String, dynamic>? calendar) {
    final parsed = _parseCalendarDays(calendar);
    loggedPeriodDates
      ..clear()
      ..addAll(parsed.logged);
    _setPredictions(
      period: parsed.predPeriod,
      fertile: parsed.fertile,
      ovulation: parsed.ovulation,
    );
    loggedPeriodDates.refresh();
    _captureBaseline();
  }

  void _captureBaseline() {
    _baselineLogged = loggedPeriodDates.map(normalizeDate).toSet();
    hasUnsavedChanges.value = false;
  }

  void _recomputeDirty() {
    if (mode != CalendarMode.tracker) {
      hasUnsavedChanges.value = false;
      return;
    }
    final current = loggedPeriodDates.map(normalizeDate).toSet();
    if (current.length != _baselineLogged.length) {
      hasUnsavedChanges.value = true;
      return;
    }
    hasUnsavedChanges.value =
        !current.every((d) => _baselineLogged.any((b) => isSameDay(b, d)));
  }

  /// Updates predictions without touching the user's optimistic logged days.
  void _applyPredictionsOnly(Map<String, dynamic>? calendar) {
    final parsed = _parseCalendarDays(calendar);
    _setPredictions(
      period: parsed.predPeriod,
      fertile: parsed.fertile,
      ovulation: parsed.ovulation,
    );
  }

  ({
    Set<DateTime> logged,
    Set<DateTime> predPeriod,
    Set<DateTime> fertile,
    Set<DateTime> ovulation,
  }) _parseCalendarDays(Map<String, dynamic>? calendar) {
    final logged = <DateTime>{};
    final predPeriod = <DateTime>{};
    final fertile = <DateTime>{};
    final ovulation = <DateTime>{};
    final periodOnly = mode == CalendarMode.tracker;

    final days = calendar?['days'];
    if (days is List) {
      for (final raw in days) {
        if (raw is! Map) continue;
        final date =
            CycleDisplayMapper.parseDate(raw['date']?.toString() ?? '');
        final type = raw['day_type']?.toString();
        final isPredicted = raw['is_predicted'] == true ||
            raw['is_predicted'] == 1 ||
            raw['is_predicted']?.toString() == '1';

        if (type == 'period' && !isPredicted) {
          logged.add(normalizeDate(date));
        } else if (type == 'period' && isPredicted) {
          predPeriod.add(normalizeDate(date));
        } else if (!periodOnly && type == 'ovulation') {
          ovulation.add(normalizeDate(date));
          fertile.add(normalizeDate(date));
        } else if (!periodOnly &&
            (type == 'fertility' || type == 'fertile')) {
          fertile.add(normalizeDate(date));
        }
      }
    }

    return (
      logged: logged,
      predPeriod: predPeriod,
      fertile: fertile,
      ovulation: ovulation,
    );
  }

  void _setPredictions({
    required Set<DateTime> period,
    required Set<DateTime> fertile,
    required Set<DateTime> ovulation,
  }) {
    // Never show a prediction ring on a day the user currently marked.
    bool overlapsLogged(DateTime d) =>
        loggedPeriodDates.any((l) => isSameDay(l, d));

    predictedPeriodDates
      ..clear()
      ..addAll(period.where((d) => !overlapsLogged(d)));
    predictedFertileDates
      ..clear()
      ..addAll(fertile.where((d) => !overlapsLogged(d)));
    predictedOvulationDates
      ..clear()
      ..addAll(ovulation.where((d) => !overlapsLogged(d)));

    predictedPeriodDates.refresh();
    predictedFertileDates.refresh();
    predictedOvulationDates.refresh();
  }

  DateTime normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isLogged(DateTime date) {
    final norm = normalizeDate(date);
    return loggedPeriodDates.any((d) => isSameDay(d, norm));
  }

  bool isPredicted(DateTime date) {
    final norm = normalizeDate(date);
    return predictedPeriodDates.any((d) => isSameDay(d, norm)) ||
        predictedFertileDates.any((d) => isSameDay(d, norm)) ||
        predictedOvulationDates.any((d) => isSameDay(d, norm));
  }

  bool isPredictedPeriod(DateTime date) {
    final norm = normalizeDate(date);
    return predictedPeriodDates.any((d) => isSameDay(d, norm));
  }

  bool isFertile(DateTime date) {
    final norm = normalizeDate(date);
    return predictedFertileDates.any((d) => isSameDay(d, norm));
  }

  bool isOvulation(DateTime date) {
    final norm = normalizeDate(date);
    return predictedOvulationDates.any((d) => isSameDay(d, norm));
  }

  bool isDateInteractive(DateTime date) {
    final norm = normalizeDate(date);
    final today = normalizeDate(DateTime.now());

    switch (mode) {
      case CalendarMode.partner:
        return false;
      case CalendarMode.onboarding:
      case CalendarMode.tracker:
        return !norm.isAfter(today);
    }
  }

  /// Instant UI toggle only — network save happens via [logPeriods].
  Future<void> onDayTapped(DateTime date) async {
    if (!isDateInteractive(date)) return;

    final normalized = normalizeDate(date);
    final today = normalizeDate(DateTime.now());
    final monthKey = normalized.month;

    if (mode == CalendarMode.tracker) {
      if (isLogged(normalized)) {
        loggedPeriodDates.removeWhere((d) => isSameDay(d, normalized));
      } else {
        loggedPeriodDates.add(normalized);
        predictedPeriodDates.removeWhere((d) => isSameDay(d, normalized));
        predictedPeriodDates.refresh();
      }
      loggedPeriodDates.refresh();
      _recomputeDirty();
      return;
    }

    if (isLogged(normalized)) {
      loggedPeriodDates.removeWhere((d) => isSameDay(d, normalized));
      customizedMonths.add(monthKey);
    } else if (customizedMonths.contains(monthKey)) {
      loggedPeriodDates.add(normalized);
    } else {
      customizedMonths.add(monthKey);
      for (int i = 0; i < 5; i++) {
        final target = normalized.add(Duration(days: i));
        if (!target.isAfter(today)) {
          loggedPeriodDates.add(target);
        }
      }
    }

    loggedPeriodDates.refresh();
    customizedMonths.refresh();

    if (Get.isRegistered<OnboardingController>()) {
      Get.find<OnboardingController>().calendarSelectionCount.value =
          loggedPeriodDates.length;
    }
  }

  /// Persists all currently selected period days in one PUT.
  /// Returns `true` on success.
  Future<bool> logPeriods() async {
    if (mode != CalendarMode.tracker) return true;
    if (isSaving.value) return false;

    isSaving.value = true;
    final dates = loggedPeriodDates.map(_ymd).toList()..sort();

    try {
      final response = await _api.put(ApiEndPoints.cyclePeriodDays, {
        'dates': dates,
      });
      final data = ApiClient.unwrapData(response);

      if (data != null) {
        applyServerCalendar(data);
      } else {
        _captureBaseline();
      }

      if (Get.isRegistered<HomeHeroController>()) {
        unawaited(
          Get.find<HomeHeroController>().loadCycleData(silent: true),
        );
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
