import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_insight_models.dart';

/// Local catalog for pregnancy daily insights (weeks 1–40).
class PregnancyInsightsRepository {
  PregnancyInsightsRepository._();
  static final PregnancyInsightsRepository instance =
      PregnancyInsightsRepository._();

  static const _assetPath = 'assets/pregnancy/weekly_insights.json';

  List<PregnancyWeekInsight>? _cache;
  int? _cachedVersion;

  Future<List<PregnancyWeekInsight>> loadAll() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw);
    final version = decoded is Map ? (decoded['version'] as int? ?? 1) : 1;
    if (_cache != null && _cachedVersion == version) return _cache!;

    final list = decoded is Map ? decoded['weeks'] : decoded;
    if (list is! List) {
      _cache = const [];
      _cachedVersion = version;
      return _cache!;
    }
    _cache = list
        .whereType<Map>()
        .map(
          (e) => PregnancyWeekInsight.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList()
      ..sort((a, b) => a.week.compareTo(b.week));
    _cachedVersion = version;
    return _cache!;
  }

  void invalidateCache() {
    _cache = null;
    _cachedVersion = null;
  }

  /// Resolve content for gestational [weeks] (0–40+), with fallback chain.
  Future<PregnancyWeekInsight?> forWeek(int weeks, {int? dayInWeek}) async {
    final all = await loadAll();
    if (all.isEmpty) return null;
    final target = weeks <= 0 ? 1 : (weeks > 40 ? 40 : weeks);

    if (dayInWeek != null) {
      for (final e in all) {
        if (e.week == target && e.dayInWeek == dayInWeek) return e;
      }
    }
    for (final e in all) {
      if (e.week == target && e.dayInWeek == null) return e;
    }
    PregnancyWeekInsight? best;
    for (final e in all) {
      if (e.dayInWeek != null) continue;
      if (e.week <= target) best = e;
    }
    return best ?? all.first;
  }
}
