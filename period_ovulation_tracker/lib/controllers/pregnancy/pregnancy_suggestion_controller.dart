import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/core/utils/pref_util.dart';
import 'package:period_ovulation_tracker/data/article_repository.dart';
import 'package:period_ovulation_tracker/data/cycle_suggestions_repository.dart';
import 'package:period_ovulation_tracker/data/pregnancy_suggestions_repository.dart';
import 'package:period_ovulation_tracker/models/article/cycle_article_model.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_suggestion.dart';

/// One tip at a time after meaningful actions (pregnancy week OR cycle phase).
class PregnancySuggestionController extends GetxController {
  final _pregRepo = PregnancySuggestionsRepository.instance;
  final _cycleRepo = CycleSuggestionsRepository.instance;

  final Rxn<PregnancySuggestion> active = Rxn<PregnancySuggestion>();
  final RxBool visible = false.obs;

  Worker? _modeWorker;
  Worker? _dateWorker;
  Timer? _settleDebounce;
  int? _lastWeekShown;
  String? _lastPhaseShown;
  bool _pregReady = false;
  bool _cycleReady = false;

  HomeHeroController get _hero => Get.find<HomeHeroController>();

  Set<String> get _seen {
    return PrefUtil.getStringList(PrefUtil.pregnancySeenTipIds).toSet();
  }

  Future<void> _markSeen(String id) async {
    final next = {..._seen, id}.toList()..sort();
    await PrefUtil.setStringList(PrefUtil.pregnancySeenTipIds, next);
  }

  @override
  void onInit() {
    super.onInit();
    _modeWorker = ever(_hero.pregnancyModeActive, (_) => _onContextChanged());
    _dateWorker = ever(_hero.selectedDate, (_) => _onDateMoved());
    ever(_hero.todayPayload, (_) {});
    _onContextChanged();
  }

  @override
  void onClose() {
    _modeWorker?.dispose();
    _dateWorker?.dispose();
    _settleDebounce?.cancel();
    super.onClose();
  }

  void _onContextChanged() {
    hide(dismissAsSeen: false);
    _lastWeekShown = null;
    _lastPhaseShown = null;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final last = PrefUtil.getString(PrefUtil.pregnancyTipLastHomeDay);
    if (last != today) {
      PrefUtil.setString(PrefUtil.pregnancyTipLastHomeDay, today);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!isClosed) offerForAction('home_open');
      });
    }
  }

  void _onDateMoved() {
    _settleDebounce?.cancel();
    _settleDebounce = Timer(const Duration(milliseconds: 650), () {
      if (isClosed) return;
      if (_hero.pregnancyModeActive.value) {
        final week = _currentWeek();
        if (_lastWeekShown != null && _lastWeekShown != week) {
          offerForAction('week_change');
        }
        _lastWeekShown = week;
      } else {
        final phase = _currentPhaseKey();
        if (_lastPhaseShown != null && _lastPhaseShown != phase) {
          offerForAction('phase_change');
        }
        _lastPhaseShown = phase;
      }
    });
  }

  int _currentWeek() {
    final age = _hero.gestationalAgeForDate(_hero.selectedDate.value);
    final w = age.weeks <= 0 ? 1 : age.weeks;
    return w.clamp(1, 40);
  }

  String _currentPhaseKey() {
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
    final phase = ArticleRepository.phaseFromHome(
      dayType: data.type,
      apiPhase: apiPhase,
      pregnancyModeActive: false,
    );
    switch (phase) {
      case CyclePhaseType.menstrual:
        return 'menstrual';
      case CyclePhaseType.follicular:
        return 'follicular';
      case CyclePhaseType.ovulation:
        return 'ovulation';
      case CyclePhaseType.luteal:
        return 'luteal';
      case CyclePhaseType.pregnancy:
      case CyclePhaseType.general:
        return 'follicular';
    }
  }

  Future<void> offerForAction(String action) async {
    if (visible.value && active.value != null) return;

    final seen = _seen;
    PregnancySuggestion? next;

    if (_hero.pregnancyModeActive.value) {
      if (!_pregReady) {
        await _pregRepo.loadAll();
        _pregReady = true;
      }
      final week = _currentWeek();
      for (final t in await _pregRepo.forWeek(week)) {
        if (!seen.contains(t.id)) {
          next = t;
          break;
        }
      }
      _lastWeekShown = week;
    } else {
      if (!_cycleReady) {
        await _cycleRepo.loadAll();
        _cycleReady = true;
      }
      final phase = _currentPhaseKey();
      for (final t in await _cycleRepo.forPhase(phase)) {
        if (!seen.contains(t.id)) {
          next = t;
          break;
        }
      }
      _lastPhaseShown = phase;
    }

    if (next == null) return;
    active.value = next;
    visible.value = true;
  }

  Future<void> dismiss() async {
    final tip = active.value;
    if (tip != null) await _markSeen(tip.id);
    hide(dismissAsSeen: false);
  }

  void hide({bool dismissAsSeen = true}) {
    if (dismissAsSeen && active.value != null) {
      // ignore: unawaited_futures
      _markSeen(active.value!.id);
    }
    visible.value = false;
    active.value = null;
  }
}
