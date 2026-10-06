import 'package:flutter/material.dart';

class InsightModel {
  final String tag;
  final String title;
  final String readTime;
  final String category;
  final String summary;
  final List<String> bulletPoints;
  final String actionTip;
  final Color? accentColor;

  const InsightModel({
    required this.tag,
    required this.title,
    this.readTime = '2 min read',
    this.category = 'Hormonal Health',
    required this.summary,
    required this.bulletPoints,
    required this.actionTip,
    this.accentColor,
  });
}
