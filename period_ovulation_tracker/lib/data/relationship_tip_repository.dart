import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/relationship/relationship_tip_model.dart';

/// Frontend-only relationship tips catalog (50 tips).
class RelationshipTipRepository {
  RelationshipTipRepository._();
  static final RelationshipTipRepository instance =
      RelationshipTipRepository._();

  static const _assetPath = 'assets/relationship_tips/tips.json';
  static const maxTipsPerDay = 10;

  List<RelationshipTipModel>? _cache;

  Future<List<RelationshipTipModel>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw);
    final list = decoded is Map ? decoded['tips'] : decoded;
    if (list is! List) {
      _cache = const [];
      return _cache!;
    }
    _cache = list
        .whereType<Map>()
        .map((e) => RelationshipTipModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return _cache!;
  }

  Future<RelationshipTipModel?> byId(String id) async {
    final all = await loadAll();
    for (final tip in all) {
      if (tip.id == id) return tip;
    }
    return null;
  }

  /// Stable pseudo-random set for a calendar day (max [maxTipsPerDay]).
  Future<List<RelationshipTipModel>> forDay(DateTime day) async {
    final all = await loadAll();
    if (all.isEmpty) return const [];

    final seed = day.year * 10000 + day.month * 100 + day.day;
    final rng = Random(seed);
    final shuffled = List<RelationshipTipModel>.from(all)..shuffle(rng);
    final count = min(maxTipsPerDay, shuffled.length);
    final picked = shuffled.take(count).toList();
    if (picked.isEmpty) return picked;
    return [
      picked.first.copyWith(isFeatured: true),
      ...picked.skip(1),
    ];
  }
}
