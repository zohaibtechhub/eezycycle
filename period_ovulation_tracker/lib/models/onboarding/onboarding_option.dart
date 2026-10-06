class OnboardingOption {
  final String id;
  final String title;
  final String? description;
  final String? image;
  final bool isExclusive;

  const OnboardingOption({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.isExclusive = false,
  });
}
