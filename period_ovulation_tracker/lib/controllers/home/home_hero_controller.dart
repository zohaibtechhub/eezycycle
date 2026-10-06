import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';

import '../../core/services/api_service.dart';
import '../../core/services/cycle_display_mapper.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/pref_util.dart';
import '../../core/utils/short_message.dart';
import '../../models/home/day_cycle_model.dart';
import '../../models/insight/personal_cycle_insight.dart';
import '../../widgets/bottomsheet/log_tracking_bottomsheet.dart';
import '../auth_controller.dart';
import '../cycle_calender_controller.dart';
import '../drawer/drawer_controller.dart';

class HomeHeroController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = true.obs;
  final ScrollController horizontalScrollController = ScrollController();

  static const double dayCellExtent = 56.0;
  static const double dayStripPadding = 12.0;

  final ApiClient _api = ApiClient();
  final RxList<DayCycleModel> yearDays = <DayCycleModel>[].obs;
  final Rxn<Map<String, dynamic>> todayPayload = Rxn<Map<String, dynamic>>();

  /// Personal symptom-timing patterns from `/cycle/today` + `/cycle/insights`.
  final RxList<PersonalCycleInsight> personalInsights =
      <PersonalCycleInsight>[].obs;

  /// Hero copy for the selected date from `/cycle/today` — does not paint the strip.
  final Rxn<DayCycleModel> selectedHeroOverride = Rxn<DayCycleModel>();
  final RxBool pregnancyModeActive = false.obs;

  /// Bumps when we must rebuild the date strip without restoring old scroll.
  final RxInt dateStripEpoch = 0.obs;

  /// When true, date strip should jump to today after the next layout.
  bool _scrollToTodayPending = true;
  int _scrollGeneration = 0;
  int _todayRefreshGeneration = 0;
  bool _partnerShellReady = false;
  Timer? _todayRefreshDebounce;

  /// Suppresses scroll→select while we programmatically center a date.
  bool _programmaticStripScroll = false;
  Timer? _programmaticScrollTimer;

  /// Strip colors come only from `/cycle/calendar`. `/today` may invent period,
  /// fertility, ovulation, or pregnancy for any tapped date — never write those
  /// onto empty (or differently typed) strip cells.
  bool _shouldWriteTodayToStrip(DayCycleModel? existing, DayCycleModel model) {
    if (existing == null) return false;
    if (model.type != DayCycleType.none && model.type != existing.type) {
      return false;
    }
    if (model.type == DayCycleType.none &&
        existing.type != DayCycleType.none) {
      return false;
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day);
    _seedEmptyYear();
    _scrollToTodayPending = true;
    horizontalScrollController.addListener(_onDateStripScroll);
    Future.microtask(_bootstrapAndLoad);
  }

  bool get _isPartnerViewer => PrefUtil.getBool(PrefUtil.isPartnerMode);

  Future<void> _bootstrapAndLoad() async {
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().ensureGuestSession();
    }
    // Existing installs: save OneSignal subscription without forcing logout.
    if (Get.isRegistered<NotificationService>()) {
      // ignore: discarded_futures
      Get.find<NotificationService>().ensurePushLinkedForCurrentUser();
    }
    await loadCycleData();
  }

  /// Call when Partner Home opens so we don't keep stale woman /cycle data
  /// loaded during onboarding (which forced an app restart before).
  Future<void> ensurePartnerDataLoaded() async {
    await PrefUtil.setBool(PrefUtil.isPartnerMode, true);
    await PrefUtil.setString(PrefUtil.experienceMode, 'partner');
    if (_partnerShellReady && yearDays.any((d) => d.type != DayCycleType.none)) {
      // Already have partner phases — still refresh today strip quietly.
      await loadCycleData(jumpToToday: true, forcePartner: true);
      return;
    }
    await loadCycleData(jumpToToday: true, forcePartner: true);
    _partnerShellReady = true;
  }

  /// Home strip + calendar range: current year through end of next year.
  ({DateTime start, DateTime end, String from, String to}) get _dateStripRange {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year + 1, 12, 31);
    return (
      start: start,
      end: end,
      from: _ymd(start),
      to: _ymd(end),
    );
  }

  Future<void> loadCycleData({
    bool jumpToToday = false,
    bool forcePartner = false,
    bool silent = false,
  }) async {
    if (!silent) isLoading.value = true;
    try {
      final range = _dateStripRange;
      final from = range.from;
      final to = range.to;
      final isPartner = forcePartner || _isPartnerViewer;

      if (jumpToToday) {
        final now = DateTime.now();
        selectedDate.value = DateTime(now.year, now.month, now.day);
      }

      final todayPath = isPartner
          ? '${ApiEndPoints.partnerToday}?date=${_ymd(selectedDate.value)}'
          : '${ApiEndPoints.cycleToday}?date=${_ymd(selectedDate.value)}';
      final calendarPath = isPartner
          ? '${ApiEndPoints.partnerCalendar}?from=$from&to=$to'
          : '${ApiEndPoints.cycleCalendar}?from=$from&to=$to';

      final futures = <Future>[
        _api.get(todayPath),
        _api.get(calendarPath),
      ];

      final results = await Future.wait(futures);

      final today = ApiClient.unwrapData(results[0]);
      final calendar = ApiClient.unwrapData(results[1]);

      Map<String, dynamic>? insightsPayload;
      if (!isPartner) {
        try {
          final insightsRes = await _api.get(ApiEndPoints.cycleInsights);
          insightsPayload = ApiClient.unwrapData(insightsRes);
        } catch (_) {
          // Today.insights is enough fallback — don't fail Home load.
        }
      }

      if (today != null) {
        todayPayload.value = today;
        _applyExperienceMode(today['profile'] ?? today);
        _syncPregnancyMode(today['profile'] ?? today);
        if (isPartner) {
          await PrefUtil.setBool(PrefUtil.isPartnerMode, true);
          await PrefUtil.setString(PrefUtil.experienceMode, 'partner');
          _partnerShellReady = true;
          personalInsights.clear();
        } else {
          _applyPersonalInsights(
            fromToday: today['insights'],
            fromInsightsEndpoint: insightsPayload?['insights'],
          );
        }
      } else if (!isPartner) {
        _applyPersonalInsights(
          fromToday: null,
          fromInsightsEndpoint: insightsPayload?['insights'],
        );
      }

      final byDate = <String, DayCycleModel>{};
      final startOfRange = range.start;
      final totalDays =
          range.end.difference(startOfRange).inDays + 1;
      for (int i = 0; i < totalDays; i++) {
        final date = startOfRange.add(Duration(days: i));
        byDate[_ymd(date)] = DayCycleModel(
          date: date,
          type: DayCycleType.none,
          headline: '',
          highlight: '',
          partnerHeadline: "Your partner's cycle",
          partnerHighlight: 'Steady day',
          partnerSubtitle: 'Small gestures of care make a big difference',
        );
      }

      final days = calendar?['days'];
      if (days is List) {
        for (final raw in days) {
          if (raw is! Map) continue;
          final model = CycleDisplayMapper.fromCalendarDay(
            Map<String, dynamic>.from(raw),
          );
          byDate[_ymd(model.date)] = model;
        }
      }

      if (today != null) {
        final todayModel = CycleDisplayMapper.fromTodayPayload(today);
        selectedHeroOverride.value = todayModel;
        final key = _ymd(todayModel.date);
        if (_shouldWriteTodayToStrip(byDate[key], todayModel)) {
          byDate[key] = todayModel;
        }
      }

      final sorted = byDate.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      yearDays.assignAll(sorted);

      final calendarMode =
          isPartner ? CalendarMode.partner : CalendarMode.tracker;
      final tag = CycleCalendarController.tagFor(calendarMode);
      if (Get.isRegistered<CycleCalendarController>(tag: tag)) {
        Get.find<CycleCalendarController>(
          tag: tag,
        ).applyServerCalendar(calendar);
      }
    } catch (_) {
      if (yearDays.isEmpty) {
        _seedEmptyYear();
      }
    } finally {
      if (!isClosed) {
        if (!silent) isLoading.value = false;
        if (jumpToToday) {
          jumpToTodayDate(force: true);
        } else {
          _scrollToTodayPending = true;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (!isClosed) ensureScrolledToToday();
          });
        }
      }
    }
  }

  void _seedEmptyYear() {
    final range = _dateStripRange;
    final totalDays = range.end.difference(range.start).inDays + 1;
    yearDays.assignAll(
      List.generate(totalDays, (i) {
        final date = range.start.add(Duration(days: i));
        return DayCycleModel(
          date: date,
          type: DayCycleType.none,
          headline: '',
          highlight: '',
        );
      }),
    );
  }

  void _applyExperienceMode(dynamic profile) {
    if (profile is! Map) return;
    final mode = profile['experience_mode']?.toString();
    if (mode == null || mode.isEmpty) return;
    if (!Get.isRegistered<DrawerViewController>()) return;
    final drawer = Get.find<DrawerViewController>();
    drawer.applyServerMode(mode);
  }

  void _syncPregnancyMode(dynamic profile) {
    if (profile is! Map) {
      // Don't clobber an active pregnancy session if payload shape is odd.
      return;
    }
    final raw = profile['pregnancy_mode_active'];
    final active = raw == true ||
        raw == 1 ||
        raw?.toString() == '1' ||
        raw?.toString().toLowerCase() == 'true';
    // Only update when we got an explicit flag — avoid flicker clearing insights.
    if (raw != null) {
      pregnancyModeActive.value = active;
    }
  }

  /// Prefer dedicated `/cycle/insights`, fall back to embedded `today.insights`.
  void _applyPersonalInsights({
    dynamic fromToday,
    dynamic fromInsightsEndpoint,
  }) {
    if (pregnancyModeActive.value) {
      personalInsights.clear();
      return;
    }
    final fromEndpoint = PersonalCycleInsight.listFrom(fromInsightsEndpoint);
    if (fromEndpoint.isNotEmpty) {
      personalInsights.assignAll(fromEndpoint);
      return;
    }
    personalInsights.assignAll(PersonalCycleInsight.listFrom(fromToday));
  }

  void setPregnancyModeActive(bool value) {
    pregnancyModeActive.value = value;
    if (value) personalInsights.clear();
  }

  String get headerDateLabel {
    final d = selectedDate.value;
    final now = DateTime.now();
    if (d.year != now.year) {
      return DateFormat('d MMMM y').format(d);
    }
    return DateFormat('d MMMM').format(d);
  }

  bool get isSelectedDateInFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return selectedDate.value.isAfter(today);
  }

  void selectDate(DateTime date, {bool scrollIntoView = true}) {
    final next = DateTime(date.year, date.month, date.day);
    if (isSameDay(selectedDate.value, next) &&
        selectedHeroOverride.value != null &&
        isSameDay(selectedHeroOverride.value!.date, next)) {
      if (scrollIntoView) _scrollToDate(next, animate: true);
      return;
    }
    selectedDate.value = next;
    // Instant hero from calendar predictions — never wait on /today.
    selectedHeroOverride.value = _heroModelForDate(next);
    if (scrollIntoView) {
      _scrollToDate(next, animate: true);
    }
    yearDays.refresh();
    _scheduleTodayRefresh();
  }

  /// Maps the day under the strip center to [selectedDate] while the user scrolls.
  void _onDateStripScroll() {
    if (_programmaticStripScroll || _scrollToTodayPending) return;
    if (!horizontalScrollController.hasClients) return;
    if (yearDays.isEmpty) return;

    final position = horizontalScrollController.position;
    final viewport = position.viewportDimension;
    if (viewport <= 0) return;

    final centerX = position.pixels + viewport / 2;
    final rawIndex =
        (centerX - dayStripPadding - (dayCellExtent / 2)) / dayCellExtent;
    final index = rawIndex.round().clamp(0, yearDays.length - 1);
    final date = yearDays[index].date;
    if (isSameDay(selectedDate.value, date)) return;
    selectDate(date, scrollIntoView: false);
  }

  void _beginProgrammaticStripScroll({int holdMs = 480}) {
    _programmaticStripScroll = true;
    _programmaticScrollTimer?.cancel();
    _programmaticScrollTimer = Timer(Duration(milliseconds: holdMs), () {
      _programmaticStripScroll = false;
    });
  }

  DayCycleModel _stripModelFor(DateTime date) {
    for (final d in yearDays) {
      if (isSameDay(d.date, date)) return d;
    }
    return DayCycleModel(
      date: date,
      type: DayCycleType.none,
      headline: 'Cycle day',
      highlight: 'Tracking',
      partnerHeadline: "Your partner's cycle",
      partnerHighlight: 'Steady day',
      partnerSubtitle: 'Small gestures of care make a big difference',
    );
  }

  /// Flo-style hero from the year strip alone (no network). Used for instant
  /// taps — especially future days, where /today was the visible lag.
  DayCycleModel _heroModelForDate(DateTime date) {
    // Pregnancy mode: always show gestational age for the tapped date
    // (calendar strip has no pregnancy day types while mode is on).
    if (pregnancyModeActive.value) {
      return _pregnancyHeroForDate(date);
    }

    final strip = _stripModelFor(date);

    if (strip.type == DayCycleType.period ||
        strip.type == DayCycleType.ovulation ||
        strip.type == DayCycleType.pregnancy) {
      return strip;
    }

    final nextOv = _nextDateOfType(DayCycleType.ovulation, from: date);
    final nextPeriod = _nextDateOfType(DayCycleType.period, from: date);
    final ovIn = nextOv?.difference(date).inDays;
    final periodIn = nextPeriod?.difference(date).inDays;

    if (strip.type == DayCycleType.fertility) {
      if (ovIn != null) {
        return DayCycleModel(
          date: date,
          type: DayCycleType.fertility,
          headline: ovIn > 0
              ? 'Higher chance of getting pregnant in'
              : 'Higher chance of getting pregnant',
          highlight: ovIn <= 0
              ? 'today'
              : ovIn == 1
              ? '1 day'
              : '$ovIn days',
          subtitle: ovIn > 0
              ? 'Estimated fertile window (timing estimate only — not contraception)'
              : 'Estimated fertile window — not contraceptive advice',
          partnerHeadline: ovIn > 0
              ? 'Higher chance of conceiving in'
              : 'Higher chance of conceiving',
          partnerHighlight: ovIn <= 0
              ? 'today'
              : ovIn == 1
              ? '1 day'
              : '$ovIn days',
          partnerSubtitle: 'Estimated fertile window — timing estimate only',
        );
      }
      return strip;
    }

    // Untyped day: countdown toward ovulation or period from the strip.
    if (ovIn != null && ovIn > 0 && (periodIn == null || ovIn <= periodIn)) {
      return DayCycleModel(
        date: date,
        type: DayCycleType.none,
        headline: 'Ovulation in',
        highlight: ovIn == 1 ? '1 day' : '$ovIn days',
        subtitle: 'Energy often rises after your period',
        partnerHeadline: 'Her ovulation in',
        partnerHighlight: ovIn == 1 ? '1 day' : '$ovIn days',
        partnerSubtitle: 'A great stretch for shared plans and energy',
      );
    }

    if (periodIn != null && periodIn > 0) {
      return DayCycleModel(
        date: date,
        type: DayCycleType.none,
        headline: 'Period in',
        highlight: periodIn == 1 ? '1 day' : '$periodIn days',
        subtitle: 'Estimates only — your cycle can vary',
        partnerHeadline: 'Her period in',
        partnerHighlight: periodIn == 1 ? '1 day' : '$periodIn days',
        partnerSubtitle: 'A gentle heads-up so you can plan ahead',
      );
    }

    return strip;
  }

  DateTime? _nextDateOfType(DayCycleType type, {required DateTime from}) {
    DateTime? best;
    for (final d in yearDays) {
      if (d.type != type) continue;
      if (d.date.isBefore(from)) continue;
      if (best == null || d.date.isBefore(best)) best = d.date;
    }
    return best;
  }

  void _scheduleTodayRefresh() {
    _todayRefreshDebounce?.cancel();
    // Future days (cycle mode): strip countdown only — no /today lag.
    if (isSelectedDateInFuture) return;
    // Pregnancy mode: hero + insights are computed locally from due date /
    // last payload (day 5 → day 6). Do not refetch /today on every strip tap.
    if (pregnancyModeActive.value) return;
    _todayRefreshDebounce = Timer(const Duration(milliseconds: 140), () {
      if (isClosed) return;
      _refreshTodayForSelected();
    });
  }

  Future<void> _refreshTodayForSelected() async {
    final generation = ++_todayRefreshGeneration;
    final requested = selectedDate.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (requested.isAfter(today)) return;
    // Pregnancy: local projection handles date taps; only refresh when on today.
    if (pregnancyModeActive.value && !isSameDay(requested, today)) return;

    try {
      final isPartner = _isPartnerViewer;
      final path = isPartner
          ? '${ApiEndPoints.partnerToday}?date=${_ymd(requested)}'
          : '${ApiEndPoints.cycleToday}?date=${_ymd(requested)}';
      final response = await _api.get(path);
      // Ignore stale responses from an earlier date tap.
      if (generation != _todayRefreshGeneration) return;
      if (!isSameDay(selectedDate.value, requested)) return;
      if (selectedDate.value.isAfter(today)) return;

      final data = ApiClient.unwrapData(response);
      if (data == null) return;
      final model = CycleDisplayMapper.fromTodayPayload(data);
      todayPayload.value = data;
      _syncPregnancyMode(data['profile'] ?? data);
      if (!isPartner) {
        final fromToday = PersonalCycleInsight.listFrom(data['insights']);
        if (fromToday.isNotEmpty || personalInsights.isEmpty) {
          _applyPersonalInsights(
            fromToday: data['insights'],
            fromInsightsEndpoint: null,
          );
        }
      } else {
        personalInsights.clear();
      }
      selectedHeroOverride.value = model;

      final idx = yearDays.indexWhere((d) => isSameDay(d.date, model.date));
      if (idx != -1 &&
          _shouldWriteTodayToStrip(yearDays[idx], model)) {
        yearDays[idx] = model;
        yearDays.refresh();
      }
    } catch (_) {}
  }

  /// Instant pregnancy hero for [date] from due date / last payload (no network).
  DayCycleModel _pregnancyHeroForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final age = gestationalAgeForDate(day);
    final weeks = age.weeks;
    final days = age.days;
    final daysUntilDue = age.daysUntilDue;

    final weekPart = weeks == 1 ? '1 week' : '$weeks weeks';
    final dayPart = days == 1 ? '1 day' : '$days days';
    final ageLabel = (weeks <= 0 && days <= 0)
        ? '1 day pregnant'
        : weeks <= 0
            ? '$dayPart pregnant'
            : days == 0
                ? '$weekPart pregnant'
                : '$weekPart, $dayPart';

    final dueSubtitle = daysUntilDue == null
        ? 'Estimates only — not medical advice'
        : daysUntilDue >= 0
            ? daysUntilDue == 0
                ? 'Your due date is today'
                : daysUntilDue == 1
                    ? '1 day until your due date'
                    : '$daysUntilDue days until your due date'
            : '${-daysUntilDue} day${daysUntilDue == -1 ? '' : 's'} past your due date';

    return DayCycleModel(
      date: day,
      type: DayCycleType.pregnancy,
      headline: "You're",
      highlight: ageLabel,
      subtitle: dueSubtitle,
      partnerHeadline: "She's",
      partnerHighlight: ageLabel,
      partnerSubtitle: daysUntilDue == null
          ? 'A gentle check-in means a lot today'
          : daysUntilDue >= 0
              ? 'Due date in $daysUntilDue day${daysUntilDue == 1 ? '' : 's'} — be her calm support'
              : 'Stay close and supportive right now',
    );
  }

  /// Gestational age for [date] from due date, else project from last `/today` payload.
  ({int weeks, int days, int? daysUntilDue}) gestationalAgeForDate(
    DateTime date,
  ) {
    const pregnancyLengthDays = 280;
    final day = DateTime(date.year, date.month, date.day);
    final payload = todayPayload.value;
    final profile = payload?['profile'];

    DateTime? due;
    for (final raw in [
      if (profile is Map) profile['due_date'],
      if (profile is Map) profile['clinician_edd'],
      if (profile is Map) profile['lmp_based_edd'],
      payload?['due_date'],
    ]) {
      final parsed = DateTime.tryParse(raw?.toString() ?? '');
      if (parsed != null) {
        due = DateTime(parsed.year, parsed.month, parsed.day);
        break;
      }
    }

    if (due != null) {
      final daysUntilDue = due.difference(day).inDays;
      final daysPregnant =
          (pregnancyLengthDays - daysUntilDue).clamp(0, 300);
      return (
        weeks: daysPregnant ~/ 7,
        days: daysPregnant % 7,
        daysUntilDue: daysUntilDue,
      );
    }

    // Project from last known payload age + day delta.
    if (payload != null) {
      final payloadDate = DateTime.tryParse(payload['date']?.toString() ?? '');
      final pw = payload['pregnancy_weeks'] is int
          ? payload['pregnancy_weeks'] as int
          : int.tryParse('${payload['pregnancy_weeks']}');
      final pd = payload['pregnancy_days'] is int
          ? payload['pregnancy_days'] as int
          : int.tryParse('${payload['pregnancy_days']}') ?? 0;
      if (payloadDate != null && pw != null) {
        final base = DateTime(
          payloadDate.year,
          payloadDate.month,
          payloadDate.day,
        );
        final total =
            (pw * 7 + pd + day.difference(base).inDays).clamp(0, 300);
        return (
          weeks: total ~/ 7,
          days: total % 7,
          daysUntilDue: pregnancyLengthDays - total,
        );
      }
    }

    return (weeks: 1, days: 0, daysUntilDue: null);
  }

  DayCycleModel get currentSelectedData {
    final override = selectedHeroOverride.value;
    if (override != null && isSameDay(override.date, selectedDate.value)) {
      return override;
    }
    return yearDays.firstWhere(
      (d) => isSameDay(d.date, selectedDate.value),
      orElse: () {
        final payload = todayPayload.value;
        if (payload != null &&
            payload['date']?.toString() == _ymd(selectedDate.value)) {
          return CycleDisplayMapper.fromTodayPayload(payload);
        }
        return DayCycleModel(
          date: selectedDate.value,
          type: DayCycleType.none,
          headline: '',
          highlight: 'Tracking your cycle',
          partnerHeadline: "Your partner's cycle",
          partnerHighlight: 'Steady day',
          partnerSubtitle: 'Small gestures of care make a big difference',
          subtitle: null,
        );
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double _screenWidth() {
    // Never use Get.width here — bindings run before navigator exists.
    if (horizontalScrollController.hasClients) {
      final viewport = horizontalScrollController.position.viewportDimension;
      if (viewport > 0) return viewport;
    }
    final ctx = Get.context;
    if (ctx != null && ctx.mounted) {
      final w = MediaQuery.sizeOf(ctx).width;
      if (w > 0) return w;
    }
    return 390.0;
  }

  double _offsetForDate(DateTime date) {
    final index = yearDays.indexWhere((d) => isSameDay(d.date, date));
    if (index < 0) return 0;
    final screenWidth = _screenWidth();
    return (index * dayCellExtent) -
        (screenWidth / 2) +
        (dayCellExtent / 2) +
        dayStripPadding;
  }

  /// Force-select today and center the date strip.
  /// Call after experience-mode changes and when MainBottomNav mounts.
  void jumpToTodayDate({bool force = true}) {
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day);
    _scrollToTodayPending = true;
    if (force) {
      // Drop PageStorage-style sticky offsets by rebuilding the ListView.
      dateStripEpoch.value++;
    }
    _scheduleScrollToToday();
  }

  /// Called from the date strip after layout so TODAY is centered.
  void ensureScrolledToToday() {
    if (!_scrollToTodayPending) return;
    _scheduleScrollToToday();
  }

  void _scrollToDate(DateTime date, {bool animate = true}) {
    _applyScrollOffset(
      date,
      animate: animate,
      attempt: 0,
      clearPending: false,
    );
  }

  void _scheduleScrollToToday() {
    final generation = ++_scrollGeneration;
    var attempt = 0;

    void tryScroll() {
      if (isClosed || generation != _scrollGeneration) return;
      if (!_scrollToTodayPending && attempt > 0) return;

      attempt++;
      final today = selectedDate.value;

      if (!horizontalScrollController.hasClients) {
        if (attempt < 80) {
          Future.delayed(const Duration(milliseconds: 40), tryScroll);
        }
        return;
      }

      final index = yearDays.indexWhere((d) => isSameDay(d.date, today));
      final max = horizontalScrollController.position.maxScrollExtent;
      final target = _offsetForDate(today).clamp(0.0, max);

      // Strip not laid out yet (extent still tiny for a mid-year day).
      final needsExtent = index > 5 && max < (index * dayCellExtent * 0.4);
      if (needsExtent && attempt < 80) {
        Future.delayed(const Duration(milliseconds: 40), tryScroll);
        return;
      }

      _beginProgrammaticStripScroll(holdMs: 220);
      horizontalScrollController.jumpTo(target);

      final pixels = horizontalScrollController.offset;
      if ((pixels - target).abs() > 3.0 && attempt < 80) {
        Future.delayed(const Duration(milliseconds: 40), tryScroll);
        return;
      }

      _scrollToTodayPending = false;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isClosed && generation == _scrollGeneration) tryScroll();
    });
    // Second pass after IndexedStack / route transitions settle.
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!isClosed &&
          generation == _scrollGeneration &&
          _scrollToTodayPending) {
        tryScroll();
      }
    });
  }

  void _applyScrollOffset(
    DateTime date, {
    required bool animate,
    required int attempt,
    required bool clearPending,
  }) {
    if (isClosed) return;

    if (!horizontalScrollController.hasClients) {
      if (attempt >= 40) return;
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        if (!isClosed) {
          _applyScrollOffset(
            date,
            animate: animate,
            attempt: attempt + 1,
            clearPending: clearPending,
          );
        }
      });
      return;
    }

    final max = horizontalScrollController.position.maxScrollExtent;
    final target = _offsetForDate(date).clamp(0.0, max);

    _beginProgrammaticStripScroll(holdMs: animate ? 520 : 160);

    if (!animate || attempt > 0) {
      horizontalScrollController.jumpTo(target);
      if (clearPending) _scrollToTodayPending = false;
      return;
    }

    horizontalScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    if (clearPending) _scrollToTodayPending = false;
  }

  void onQuickActionTap(BuildContext context, String actionType) {
    if (PrefUtil.getBool(PrefUtil.isPartnerMode)) {
      ShortMessageUtils.showError(
        context,
        'Partners can view cycle phases only — logging is private to her.',
      );
      return;
    }

    // Daily logs are only for today / past — never open sheet for future dates.
    if (actionType != 'period' && isSelectedDateInFuture) {
      ShortMessageUtils.showError(
        context,
        'You can only log for today or past days.',
      );
      return;
    }

    switch (actionType) {
      case 'period':
        Get.toNamed(AppPages.calenderView);
        break;
      case 'symptoms':
        LogTrackingBottomSheet.show(
          context,
          targetDate: selectedDate.value,
        );
        break;
      case 'sex':
        LogTrackingBottomSheet.show(
          context,
          targetDate: selectedDate.value,
          initialCategoryFilter: 'Sex & Sex Drive',
        );
        break;
      case 'tests':
        LogTrackingBottomSheet.show(
          context,
          targetDate: selectedDate.value,
          initialCategoryFilter: 'Ovulation Test',
        );
        break;
    }
  }

  @override
  void onClose() {
    _todayRefreshDebounce?.cancel();
    _programmaticScrollTimer?.cancel();
    horizontalScrollController.removeListener(_onDateStripScroll);
    horizontalScrollController.dispose();
    super.onClose();
  }
}
