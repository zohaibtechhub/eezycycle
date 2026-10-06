import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/article/cycle_article_model.dart';
import '../models/home/day_cycle_model.dart';

/// Frontend-only article catalog (no backend).
class ArticleRepository {
  ArticleRepository._();
  static final ArticleRepository instance = ArticleRepository._();

  static const _assetPath = 'assets/articles/articles.json';

  List<CycleArticleModel>? _cache;

  Future<List<CycleArticleModel>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw);
    final list = decoded is Map ? decoded['articles'] : decoded;
    if (list is! List) {
      _cache = const [];
      return _cache!;
    }
    _cache = list
        .whereType<Map>()
        .map((e) => CycleArticleModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return _cache!;
  }

  /// Clear cache after hot-reload / asset updates in debug.
  void invalidateCache() => _cache = null;

  Future<CycleArticleModel?> byId(String id) async {
    final all = await loadAll();
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Articles that match [phase], then `general`, then remaining — up to [limit].
  /// When [partnerSafe] is true, sex/intimacy articles are excluded.
  Future<List<CycleArticleModel>> forPhase(
    CyclePhaseType phase, {
    int? limit,
    bool partnerSafe = false,
  }) async {
    final all = await loadAll();
    if (all.isEmpty) return const [];

    final matched = <CycleArticleModel>[];
    final general = <CycleArticleModel>[];
    final rest = <CycleArticleModel>[];

    for (final a in all) {
      if (partnerSafe && a.isSexArticle) continue;
      if (a.matchesPhase(phase)) {
        matched.add(a);
      } else if (a.matchesPhase(CyclePhaseType.general)) {
        general.add(a);
      } else {
        rest.add(a);
      }
    }

    final ordered = [...matched, ...general, ...rest];
    if (limit == null) return ordered;
    return ordered.take(limit).toList();
  }

  /// Home "For you" picks — [limit] articles that are **not** in Discover.
  ///
  /// Discover uses the first [discoverLimit] from [forPhase]; For you continues
  /// further down the same ranking so the two rows never overlap.
  Future<List<CycleArticleModel>> forYouRecommended(
    CyclePhaseType phase, {
    int discoverLimit = 6,
    int limit = 5,
    bool partnerSafe = false,
  }) async {
    final ordered = await forPhase(phase, partnerSafe: partnerSafe);
    if (ordered.isEmpty) return const [];
    final exclude = ordered.take(discoverLimit).map((a) => a.id).toSet();
    return ordered
        .where((a) => !exclude.contains(a.id))
        .take(limit)
        .toList();
  }

  Future<List<CycleArticleModel>> sexArticles() async {
    final all = await loadAll();
    return all.where((a) => a.isSexArticle).toList();
  }

  /// Map home day / today payload → article phase filter.
  static CyclePhaseType phaseFromHome({
    required DayCycleType dayType,
    String? apiPhase,
    bool pregnancyModeActive = false,
  }) {
    if (pregnancyModeActive || dayType == DayCycleType.pregnancy) {
      return CyclePhaseType.pregnancy;
    }
    final p = (apiPhase ?? '').toLowerCase();
    switch (p) {
      case 'menstrual':
      case 'period':
        return CyclePhaseType.menstrual;
      case 'follicular':
        return CyclePhaseType.follicular;
      case 'ovulation':
      case 'fertility':
        return CyclePhaseType.ovulation;
      case 'luteal':
        return CyclePhaseType.luteal;
      case 'pregnancy':
        return CyclePhaseType.pregnancy;
    }
    switch (dayType) {
      case DayCycleType.period:
        return CyclePhaseType.menstrual;
      case DayCycleType.ovulation:
      case DayCycleType.fertility:
        return CyclePhaseType.ovulation;
      case DayCycleType.pregnancy:
        return CyclePhaseType.pregnancy;
      case DayCycleType.none:
        return CyclePhaseType.follicular;
    }
  }

  static String phaseLabel(CyclePhaseType phase) {
    switch (phase) {
      case CyclePhaseType.menstrual:
        return 'Period';
      case CyclePhaseType.follicular:
        return 'Follicular';
      case CyclePhaseType.ovulation:
        return 'Ovulation';
      case CyclePhaseType.luteal:
        return 'Luteal';
      case CyclePhaseType.pregnancy:
        return 'Pregnancy';
      case CyclePhaseType.general:
        return 'For you';
    }
  }
}
