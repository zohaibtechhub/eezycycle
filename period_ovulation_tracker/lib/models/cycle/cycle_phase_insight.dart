import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_insight_models.dart';

/// Cycle-phase daily insights (Flo-style cards + stories).
class CyclePhaseInsight {
  final String id;
  final String phase;
  final String phaseLabel;
  final String headline;
  final String subheadline;
  final List<PregnancyStory> stories;
  final List<PregnancyExpectItem> whatToExpect;

  const CyclePhaseInsight({
    required this.id,
    required this.phase,
    required this.phaseLabel,
    required this.headline,
    required this.subheadline,
    required this.stories,
    this.whatToExpect = const [],
  });

  factory CyclePhaseInsight.fromJson(Map<String, dynamic> json) {
    final expect = json['what_to_expect'];
    final items = expect is Map
        ? (expect['items'] as List? ?? [])
            .whereType<Map>()
            .map(
              (e) =>
                  PregnancyExpectItem.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList()
        : <PregnancyExpectItem>[];

    return CyclePhaseInsight(
      id: json['id']?.toString() ?? 'cycle_insight',
      phase: json['phase']?.toString() ?? 'follicular',
      phaseLabel: json['phase_label']?.toString() ?? 'Cycle',
      headline: json['headline']?.toString() ?? 'My daily insights',
      subheadline: json['subheadline']?.toString() ?? '',
      stories: (json['stories'] as List? ?? [])
          .whereType<Map>()
          .map((e) => PregnancyStory.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      whatToExpect: items,
    );
  }
}
