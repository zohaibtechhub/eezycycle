import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_suggestion.dart';

class PregnancySuggestionsRepository {
  PregnancySuggestionsRepository._();
  static final instance = PregnancySuggestionsRepository._();

  static const _assetPath = 'assets/pregnancy/weekly_suggestions.json';

  List<PregnancySuggestion>? _cache;
  String? _disclaimer;

  String get disclaimer =>
      _disclaimer ??
      'Educational suggestions only — not medical advice.';

  Future<List<PregnancySuggestion>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw);
    if (decoded is! Map) {
      _cache = const [];
      return _cache!;
    }
    _disclaimer = decoded['disclaimer']?.toString();
    final tips = decoded['tips'];
    if (tips is! List) {
      _cache = const [];
      return _cache!;
    }
    _cache = tips
        .whereType<Map>()
        .map((e) => PregnancySuggestion.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.id.isNotEmpty && t.title.isNotEmpty)
        .toList(growable: false);
    return _cache!;
  }

  Future<List<PregnancySuggestion>> forWeek(int week) async {
    final all = await loadAll();
    final w = week.clamp(1, 40);
    return all.where((t) => t.week == w).toList(growable: false);
  }
}
