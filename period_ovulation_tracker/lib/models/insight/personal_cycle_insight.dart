/// Personal cycle insight from `GET /cycle/today` or `GET /cycle/insights`.
/// Symptom-timing patterns only — never fertility claims.
class PersonalCycleInsight {
  final String id;
  final String kind;
  final String title;
  final String body;
  final bool safe;

  const PersonalCycleInsight({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.safe = true,
  });

  factory PersonalCycleInsight.fromJson(Map<String, dynamic> json) {
    return PersonalCycleInsight(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'symptom_timing',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      safe: json['safe'] != false,
    );
  }

  static List<PersonalCycleInsight> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => PersonalCycleInsight.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.title.isNotEmpty)
        .toList();
  }

  String get kindLabel {
    switch (kind) {
      case 'symptom_timing':
        return 'Symptom timing';
      default:
        return 'Your pattern';
    }
  }
}
