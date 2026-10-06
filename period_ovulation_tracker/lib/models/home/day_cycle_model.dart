import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum DayCycleType { none, period, ovulation, fertility, pregnancy }

class DayCycleModel {
  final DateTime date;
  final DayCycleType type;

  /// Small lead-in, e.g. "Best chances of conceiving are in"
  final String headline;

  /// Large focus line, e.g. "2 days" / "Period Day 3" / "today"
  final String highlight;

  /// Supporting line under the highlight
  final String? subtitle;

  /// Partner-facing lead-in (defaults to [headline] when null)
  final String? partnerHeadline;

  /// Partner-facing focus line (defaults to [highlight] when null)
  final String? partnerHighlight;

  /// Partner-facing subtitle (defaults to [subtitle] when null)
  final String? partnerSubtitle;

  /// 1–5 when [type] is period; otherwise null
  final int? periodDay;

  const DayCycleModel({
    required this.date,
    required this.type,
    required this.headline,
    required this.highlight,
    this.subtitle,
    this.partnerHeadline,
    this.partnerHighlight,
    this.partnerSubtitle,
    this.periodDay,
  });

  String get resolvedPartnerHeadline => partnerHeadline ?? headline;
  String get resolvedPartnerHighlight => partnerHighlight ?? highlight;
  String? get resolvedPartnerSubtitle => partnerSubtitle ?? subtitle;

  Color get color {
    switch (type) {
      case DayCycleType.period:
        return AppColors.period;
      case DayCycleType.ovulation:
        return AppColors.ovulation;
      case DayCycleType.fertility:
        return AppColors.fertility;
      case DayCycleType.pregnancy:
        return AppColors.pregnancy;
      case DayCycleType.none:
        return AppColors.border;
    }
  }

  /// Soft hero backdrop — distinct per cycle state (not one shared pink).
  LinearGradient get heroGradient {
    switch (type) {
      case DayCycleType.period:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFFE4EC),
            AppColors.primaryLight,
            AppColors.background,
          ],
        );
      case DayCycleType.ovulation:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFFF3D6),
            Color(0xFFFFF9EF),
            AppColors.background,
          ],
        );
      case DayCycleType.fertility:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFEDE4FF),
            Color(0xFFF7F3FF),
            AppColors.background,
          ],
        );
      case DayCycleType.pregnancy:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFDDF7EE),
            Color(0xFFF0FBF7),
            AppColors.background,
          ],
        );
      case DayCycleType.none:
        return AppColors.softGradient;
    }
  }

  /// Accent blob color for the soft organic shape in the hero.
  Color get heroAccent {
    switch (type) {
      case DayCycleType.period:
        return AppColors.period.withValues(alpha: 0.22);
      case DayCycleType.ovulation:
        return AppColors.ovulation.withValues(alpha: 0.22);
      case DayCycleType.fertility:
        return AppColors.fertility.withValues(alpha: 0.20);
      case DayCycleType.pregnancy:
        return AppColors.pregnancy.withValues(alpha: 0.20);
      case DayCycleType.none:
        return AppColors.primary.withValues(alpha: 0.12);
    }
  }
}
