import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class RelationshipTipModel {
  final String id;
  final String title;
  final String description;
  final String body;
  final String category;
  final String iconKey;
  final String timeToRead;
  final String tryThis;
  final List<String> takeaways;
  final bool isFeatured;

  const RelationshipTipModel({
    required this.id,
    required this.title,
    required this.description,
    this.body = '',
    required this.category,
    this.iconKey = 'favorite',
    this.timeToRead = '1 min',
    this.tryThis = '',
    this.takeaways = const [],
    this.isFeatured = false,
  });

  IconData get icon => _iconFor(iconKey);

  Color get iconBg => _styleFor(category).$1;

  Color get iconColor => _styleFor(category).$2;

  factory RelationshipTipModel.fromJson(Map<String, dynamic> json) {
    final takeawaysRaw = json['takeaways'];
    return RelationshipTipModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Communication',
      iconKey: json['icon']?.toString() ?? 'favorite',
      timeToRead: json['time_to_read']?.toString() ??
          json['timeToRead']?.toString() ??
          '1 min',
      tryThis: json['try_this']?.toString() ??
          json['tryThis']?.toString() ??
          '',
      takeaways: takeawaysRaw is List
          ? takeawaysRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
          : const [],
      isFeatured: json['is_featured'] == true || json['isFeatured'] == true,
    );
  }

  RelationshipTipModel copyWith({bool? isFeatured}) {
    return RelationshipTipModel(
      id: id,
      title: title,
      description: description,
      body: body,
      category: category,
      iconKey: iconKey,
      timeToRead: timeToRead,
      tryThis: tryThis,
      takeaways: takeaways,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  static IconData _iconFor(String key) {
    switch (key) {
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'hearing':
        return Icons.hearing_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'night':
        return Icons.nightlight_round;
      case 'sparkle':
        return Icons.auto_awesome_rounded;
      case 'tea':
        return Icons.emoji_food_beverage_outlined;
      case 'walk':
        return Icons.directions_walk_rounded;
      case 'home':
        return Icons.home_outlined;
      case 'heart_hand':
        return Icons.volunteer_activism_rounded;
      case 'calendar':
        return Icons.calendar_month_rounded;
      case 'music':
        return Icons.music_note_outlined;
      case 'phone':
        return Icons.phone_in_talk_outlined;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'smile':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'shield':
        return Icons.health_and_safety_outlined;
      default:
        return Icons.favorite_rounded;
    }
  }

  static (Color, Color) _styleFor(String category) {
    switch (category) {
      case 'Cycle Support':
        return (AppColors.primaryLight, AppColors.accent);
      case 'Communication':
        return (const Color(0xFFE3F2FD), AppColors.info);
      case 'Quality Time':
        return (const Color(0xFFEDE7F6), const Color(0xFF7E57C2));
      case 'Care & Comfort':
        return (const Color(0xFFE8F5E9), AppColors.success);
      case 'Appreciation':
        return (const Color(0xFFFFF8E1), AppColors.warning);
      default:
        return (AppColors.primaryLight, AppColors.accent);
    }
  }
}
