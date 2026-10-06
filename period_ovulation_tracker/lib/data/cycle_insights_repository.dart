import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:period_ovulation_tracker/models/article/cycle_article_model.dart';
import 'package:period_ovulation_tracker/models/cycle/cycle_phase_insight.dart';

class CycleInsightsRepository {
  CycleInsightsRepository._();
  static final instance = CycleInsightsRepository._();

  static const _assetPath = 'assets/cycle/daily_insights.json';

  Map<String, CyclePhaseInsight>? _byPhase;

  Future<void> _ensureLoaded() async {
    if (_byPhase != null) return;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw);
    final map = <String, CyclePhaseInsight>{};
    if (decoded is Map) {
      final phases = decoded['phases'];
      if (phases is List) {
        for (final e in phases.whereType<Map>()) {
          final insight =
              CyclePhaseInsight.fromJson(Map<String, dynamic>.from(e));
          map[insight.phase] = insight;
        }
      }
    }
    _byPhase = map;
  }

  String _keyFor(CyclePhaseType phase) {
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

  Future<CyclePhaseInsight?> forPhase(CyclePhaseType phase) async {
    await _ensureLoaded();
    final key = _keyFor(phase);
    return _byPhase?[key] ?? _byPhase?['follicular'];
  }
}
