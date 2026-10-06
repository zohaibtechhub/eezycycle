import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';

/// Cycle / life stage used to show relatable articles on Home.
enum CyclePhaseType {
  menstrual,
  follicular,
  ovulation,
  luteal,
  pregnancy,
  general,
}

/// Content topic (includes Sex & Intimacy).
enum ArticleCategoryType {
  energyHormones,
  fitness,
  fertility,
  pmsCare,
  restFlow,
  sleep,
  nutrition,
  sexIntimacy,
  pregnancy,
  wellness,
}

class ArticleSection {
  final String heading;
  final String body;

  const ArticleSection({required this.heading, required this.body});

  factory ArticleSection.fromJson(Map<String, dynamic> json) {
    return ArticleSection(
      heading: json['heading']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'heading': heading, 'body': body};
}

/// Full frontend article: card + reader (cover image, sex topics, sections, takeaways).
///
/// Structure every article must follow:
/// - id, title, description (card blurb)
/// - category + categoryType (e.g. Sex & Intimacy)
/// - imageUrl (hero cover — network or assets/...)
/// - phase / phases (when it shows on Home)
/// - heroSummary, sections[], takeaways[]
class CycleArticleModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final ArticleCategoryType categoryType;
  final String readTime;
  final String author;
  final String publishedDate;

  /// Cover / hero image (https://... or assets/articles/images/...).
  final String imageUrl;

  final Color themeColor;
  final CyclePhaseType phase;
  final List<CyclePhaseType> phases;
  final String heroSummary;
  final List<ArticleSection> sections;
  final List<String> takeaways;

  const CycleArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryType,
    required this.readTime,
    required this.imageUrl,
    required this.themeColor,
    required this.phase,
    this.phases = const [],
    this.author = 'EezyCycle Editorial',
    this.publishedDate = 'Updated recently',
    this.heroSummary = '',
    this.sections = const [],
    this.takeaways = const [],
  });

  List<CyclePhaseType> get allPhases =>
      phases.isEmpty ? [phase] : {phase, ...phases}.toList();

  bool matchesPhase(CyclePhaseType p) => allPhases.contains(p);

  bool get isSexArticle =>
      categoryType == ArticleCategoryType.sexIntimacy ||
      category.toLowerCase().contains('sex');

  bool get hasLocalImage => imageUrl.startsWith('assets/');

  factory CycleArticleModel.fromJson(Map<String, dynamic> json) {
    final phase = phaseFrom(json['phase']?.toString());
    final extra = (json['phases'] as List?)
            ?.map((e) => phaseFrom(e.toString()))
            .toList() ??
        const <CyclePhaseType>[];
    final categoryType = categoryTypeFrom(
      json['category_type']?.toString() ?? json['category']?.toString(),
    );

    return CycleArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Wellness',
      categoryType: categoryType,
      readTime: json['read_time']?.toString() ?? '4 min read',
      author: json['author']?.toString() ?? 'EezyCycle Editorial',
      publishedDate: json['published_date']?.toString() ?? 'Updated recently',
      imageUrl: json['image']?.toString() ?? json['image_url']?.toString() ?? '',
      themeColor: colorForCategory(categoryType),
      phase: phase,
      phases: extra,
      heroSummary: json['hero_summary']?.toString() ??
          json['description']?.toString() ??
          '',
      sections: (json['sections'] as List?)
              ?.whereType<Map>()
              .map((e) => ArticleSection.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      takeaways: (json['takeaways'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  static CyclePhaseType phaseFrom(String? raw) {
    switch (raw) {
      case 'menstrual':
        return CyclePhaseType.menstrual;
      case 'follicular':
        return CyclePhaseType.follicular;
      case 'ovulation':
        return CyclePhaseType.ovulation;
      case 'luteal':
        return CyclePhaseType.luteal;
      case 'pregnancy':
        return CyclePhaseType.pregnancy;
      default:
        return CyclePhaseType.general;
    }
  }

  static ArticleCategoryType categoryTypeFrom(String? raw) {
    final v = (raw ?? '').toLowerCase();
    if (v.contains('sex') || v.contains('intimacy')) {
      return ArticleCategoryType.sexIntimacy;
    }
    if (v.contains('fertil')) return ArticleCategoryType.fertility;
    if (v.contains('fitness') || v.contains('workout')) {
      return ArticleCategoryType.fitness;
    }
    if (v.contains('pms') || v.contains('care')) {
      return ArticleCategoryType.pmsCare;
    }
    if (v.contains('rest') || v.contains('flow') || v.contains('period')) {
      return ArticleCategoryType.restFlow;
    }
    if (v.contains('sleep')) return ArticleCategoryType.sleep;
    if (v.contains('nutrition') || v.contains('food')) {
      return ArticleCategoryType.nutrition;
    }
    if (v.contains('pregnan')) return ArticleCategoryType.pregnancy;
    if (v.contains('energy') || v.contains('hormone')) {
      return ArticleCategoryType.energyHormones;
    }
    return ArticleCategoryType.wellness;
  }

  static Color colorForCategory(ArticleCategoryType type) {
    switch (type) {
      case ArticleCategoryType.sexIntimacy:
        return AppColors.accent;
      case ArticleCategoryType.fertility:
        return AppColors.ovulation;
      case ArticleCategoryType.fitness:
        return AppColors.secondary;
      case ArticleCategoryType.pmsCare:
        return AppColors.fertility;
      case ArticleCategoryType.restFlow:
        return AppColors.period;
      case ArticleCategoryType.sleep:
        return AppColors.info;
      case ArticleCategoryType.nutrition:
        return AppColors.success;
      case ArticleCategoryType.pregnancy:
        return AppColors.pregnancy;
      case ArticleCategoryType.energyHormones:
        return AppColors.primary;
      case ArticleCategoryType.wellness:
        return AppColors.primary;
    }
  }
}
