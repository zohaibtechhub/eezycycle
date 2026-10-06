/// Pregnancy daily insights catalog models (Flo-style).
class PregnancyWeekInsight {
  final String id;
  final int week;
  final int? dayInWeek;
  final PregnancyBabyInsight baby;
  final PregnancyBodyInsight body;
  final PregnancySymptomsInsight symptoms;
  final List<PregnancyStory> stories;
  final PregnancyWhatToExpect whatToExpect;

  const PregnancyWeekInsight({
    required this.id,
    required this.week,
    this.dayInWeek,
    required this.baby,
    required this.body,
    required this.symptoms,
    required this.stories,
    required this.whatToExpect,
  });

  factory PregnancyWeekInsight.fromJson(Map<String, dynamic> json) {
    return PregnancyWeekInsight(
      id: json['id']?.toString() ?? 'preg_insight',
      week: _intOf(json['week']) ?? 1,
      dayInWeek: _intOf(json['day_in_week']),
      baby: PregnancyBabyInsight.fromJson(
        Map<String, dynamic>.from(json['baby'] as Map? ?? {}),
      ),
      body: PregnancyBodyInsight.fromJson(
        Map<String, dynamic>.from(json['body'] as Map? ?? {}),
      ),
      symptoms: PregnancySymptomsInsight.fromJson(
        Map<String, dynamic>.from(json['symptoms'] as Map? ?? {}),
      ),
      stories: (json['stories'] as List? ?? [])
          .whereType<Map>()
          .map((e) => PregnancyStory.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      whatToExpect: PregnancyWhatToExpect.fromJson(
        Map<String, dynamic>.from(json['what_to_expect'] as Map? ?? {}),
      ),
    );
  }
}

class PregnancyBabyInsight {
  final String title;
  final String shortSummary;
  final String? sizeLabel;
  final String? sizeAsset;
  final String? illustrationAsset;
  final String bodyMarkdown;
  final String? lengthLabel;
  final String? weightLabel;
  final List<String> milestones;

  const PregnancyBabyInsight({
    required this.title,
    required this.shortSummary,
    this.sizeLabel,
    this.sizeAsset,
    this.illustrationAsset,
    required this.bodyMarkdown,
    this.lengthLabel,
    this.weightLabel,
    this.milestones = const [],
  });

  factory PregnancyBabyInsight.fromJson(Map<String, dynamic> json) {
    return PregnancyBabyInsight(
      title: json['title']?.toString() ?? 'Your baby',
      shortSummary: json['short_summary']?.toString() ?? '',
      sizeLabel: json['size_label']?.toString(),
      sizeAsset: json['size_asset']?.toString(),
      illustrationAsset: json['illustration_asset']?.toString(),
      bodyMarkdown: json['body_markdown']?.toString() ?? '',
      lengthLabel: json['length_label']?.toString(),
      weightLabel: json['weight_label']?.toString(),
      milestones: (json['milestones'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class PregnancyBodyInsight {
  final String title;
  final String shortSummary;
  final String? illustrationAsset;
  final String bodyMarkdown;
  final List<String> highlights;
  final String? bumpLabel;
  final String? bumpBody;

  const PregnancyBodyInsight({
    required this.title,
    required this.shortSummary,
    this.illustrationAsset,
    required this.bodyMarkdown,
    this.highlights = const [],
    this.bumpLabel,
    this.bumpBody,
  });

  factory PregnancyBodyInsight.fromJson(Map<String, dynamic> json) {
    return PregnancyBodyInsight(
      title: json['title']?.toString() ?? 'Your body',
      shortSummary: json['short_summary']?.toString() ?? '',
      illustrationAsset: json['illustration_asset']?.toString(),
      bodyMarkdown: json['body_markdown']?.toString() ?? '',
      highlights: (json['highlights'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      bumpLabel: json['bump_label']?.toString(),
      bumpBody: json['bump_body']?.toString(),
    );
  }
}

class PregnancySymptomsInsight {
  final String title;
  final List<String> commonKeys;
  final String? tip;

  const PregnancySymptomsInsight({
    required this.title,
    this.commonKeys = const [],
    this.tip,
  });

  factory PregnancySymptomsInsight.fromJson(Map<String, dynamic> json) {
    return PregnancySymptomsInsight(
      title: json['title']?.toString() ?? 'Symptoms',
      commonKeys: (json['common_keys'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      tip: json['tip']?.toString(),
    );
  }
}

class PregnancyStory {
  final String id;
  final String cardTitle;
  final String? cardImage;
  final String? cardBabyImage;
  final String? cardSizeImage;
  final String? cardHeaderColor;
  final List<PregnancyStoryPage> pages;

  const PregnancyStory({
    required this.id,
    required this.cardTitle,
    this.cardImage,
    this.cardBabyImage,
    this.cardSizeImage,
    this.cardHeaderColor,
    required this.pages,
  });

  factory PregnancyStory.fromJson(Map<String, dynamic> json) {
    return PregnancyStory(
      id: json['id']?.toString() ?? 'story',
      cardTitle: json['card_title']?.toString() ?? '',
      cardImage: json['card_image']?.toString(),
      cardBabyImage: json['card_baby_image']?.toString(),
      cardSizeImage: json['card_size_image']?.toString(),
      cardHeaderColor: json['card_header_color']?.toString(),
      pages: (json['pages'] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => PregnancyStoryPage.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

class PregnancyStoryTip {
  final String title;
  final String body;

  const PregnancyStoryTip({required this.title, required this.body});

  factory PregnancyStoryTip.fromJson(Map<String, dynamic> json) {
    return PregnancyStoryTip(
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
    );
  }
}

class PregnancyStoryPage {
  /// focus | tips | baby_compare | body_week | text
  final String type;
  final String? background;
  final String? image;
  final String? babyImage;
  final String? sizeImage;
  final String? sizeLabel;
  final String? lengthLabel;
  final String? weightLabel;
  final String? eyebrow;
  final String? focusWord;
  final String? detailLabel;
  final String? detailBody;
  final String? iconKey;
  final int? milestoneOffsetDays;
  final String title;
  final String body;
  final int durationMs;
  final List<String> commonKeys;
  final List<PregnancyStoryTip> tips;
  final String? cta;

  const PregnancyStoryPage({
    this.type = 'text',
    this.background,
    this.image,
    this.babyImage,
    this.sizeImage,
    this.sizeLabel,
    this.lengthLabel,
    this.weightLabel,
    this.eyebrow,
    this.focusWord,
    this.detailLabel,
    this.detailBody,
    this.iconKey,
    this.milestoneOffsetDays,
    required this.title,
    required this.body,
    this.durationMs = 5000,
    this.commonKeys = const [],
    this.tips = const [],
    this.cta,
  });

  factory PregnancyStoryPage.fromJson(Map<String, dynamic> json) {
    return PregnancyStoryPage(
      type: json['type']?.toString() ?? 'text',
      background: json['background']?.toString(),
      image: json['image']?.toString(),
      babyImage: json['baby_image']?.toString(),
      sizeImage: json['size_image']?.toString(),
      sizeLabel: json['size_label']?.toString(),
      lengthLabel: json['length_label']?.toString(),
      weightLabel: json['weight_label']?.toString(),
      eyebrow: json['eyebrow']?.toString(),
      focusWord: json['focus_word']?.toString(),
      detailLabel: json['detail_label']?.toString(),
      detailBody: json['detail_body']?.toString(),
      iconKey: json['icon_key']?.toString(),
      milestoneOffsetDays: _intOf(json['milestone_offset_days']),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      durationMs: _intOf(json['duration_ms']) ?? 5000,
      commonKeys: (json['common_keys'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      tips: (json['tips'] as List? ?? [])
          .whereType<Map>()
          .map((e) => PregnancyStoryTip.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      cta: json['cta']?.toString(),
    );
  }
}

class PregnancyWhatToExpect {
  final int week;
  final String title;
  final List<PregnancyExpectItem> items;

  const PregnancyWhatToExpect({
    required this.week,
    required this.title,
    this.items = const [],
  });

  factory PregnancyWhatToExpect.fromJson(Map<String, dynamic> json) {
    return PregnancyWhatToExpect(
      week: _intOf(json['week']) ?? 1,
      title: json['title']?.toString() ?? 'What to expect',
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => PregnancyExpectItem.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

class PregnancyExpectItem {
  final String key;
  final String label;
  final String? image;
  final String summary;
  final List<PregnancyExpectSection> sections;

  const PregnancyExpectItem({
    required this.key,
    required this.label,
    this.image,
    required this.summary,
    this.sections = const [],
  });

  factory PregnancyExpectItem.fromJson(Map<String, dynamic> json) {
    return PregnancyExpectItem(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      image: json['image']?.toString(),
      summary: json['summary']?.toString() ?? '',
      sections: (json['sections'] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) =>
                PregnancyExpectSection.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}

class PregnancyExpectSection {
  final String heading;
  final String body;

  const PregnancyExpectSection({required this.heading, required this.body});

  factory PregnancyExpectSection.fromJson(Map<String, dynamic> json) {
    return PregnancyExpectSection(
      heading: json['heading']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
    );
  }
}

int? _intOf(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}
