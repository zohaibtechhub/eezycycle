import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_suggestion.dart';

class CycleSuggestionsRepository {
  CycleSuggestionsRepository._();
  static final instance = CycleSuggestionsRepository._();

  static const _assetPath = 'assets/cycle/daily_suggestions.json';

  List<PregnancySuggestion>? _cache;

  Future<List<PregnancySuggestion>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw);
    if (decoded is! Map) {
      _cache = const [];
      return _cache!;
    }
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

  Future<List<PregnancySuggestion>> forPhase(String phase) async {
    final all = await loadAll();
    return all.where((t) => t.phase == phase).toList(growable: false);
  }
}
