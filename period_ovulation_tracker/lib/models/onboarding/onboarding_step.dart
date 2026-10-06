import 'package:flutter/cupertino.dart';

import 'onboarding_option.dart';

enum OnboardingStepType {
  question, // Normal single/multi selection question
  socialProof, // "7 out of 10 women..."
  education, // Educational/content screen
  contentWarning, // Content warning
  sectionIntro, // "Next we'll look at..."
  calendar, // Period date selection
  insight, // Personalized result
  reminder, // Notification/reminder question
  measurement, // Height / weight
  testimonial, // User/doctor testimonial
}

class OnboardingRichText {
  final String firstPart;
  final String highlightedPart;
  final String middlePart;
  final String secondHighlightedPart;

  const OnboardingRichText({
    this.firstPart = '',
    this.highlightedPart = '',
    this.middlePart = '',
    this.secondHighlightedPart = '',
  });
}

enum OnboardingSelectionType { single, multiple, none }

class OnboardingStep {
  final String id;
  final OnboardingStepType type;

  final String? title;
  final String? description;

  final OnboardingRichText? richTitle;
  final OnboardingRichText? richDescription;

  final String? image;
  final IconData? icon;
  final bool showAskEezy;

  final OnboardingSelectionType selectionType;
  final List<OnboardingOption> options;

  final bool canSkip;
  final bool showProgress;
  final bool countsTowardProgress;

  const OnboardingStep({
    required this.id,
    required this.type,
    this.title,
    this.description,
    this.richTitle,
    this.richDescription,
    this.image,
    this.icon,
    this.selectionType = OnboardingSelectionType.none,
    this.options = const [],
    this.showAskEezy = false,
    this.canSkip = true,
    this.showProgress = true,
    this.countsTowardProgress = true,
  });
}
