class PregnancySuggestion {
  final String id;
  final int week;
  final String? phase; // menstrual | follicular | ovulation | luteal
  final String category; // food | exercise | rest | wellness
  final String title;
  final String body;
  final String? image;

  const PregnancySuggestion({
    required this.id,
    this.week = 0,
    this.phase,
    required this.category,
    required this.title,
    required this.body,
    this.image,
  });

  factory PregnancySuggestion.fromJson(Map<String, dynamic> json) {
    return PregnancySuggestion(
      id: json['id']?.toString() ?? '',
      week: (json['week'] is int)
          ? json['week'] as int
          : int.tryParse('${json['week']}') ?? 0,
      phase: json['phase']?.toString(),
      category: json['category']?.toString() ?? 'wellness',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}
