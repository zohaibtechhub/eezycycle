import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/models/insight/personal_cycle_insight.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class InsightView extends StatelessWidget {
  final String tagText;
  final String title;
  final String? category;
  final String? readTime;
  final String? summary;
  final List<String>? keyPoints;
  final String? actionTip;

  const InsightView({
    super.key,
    this.tagText = 'Check-in',
    this.title = 'How to support her mood and energy today',
    this.category = 'Emotional & Cycle Balance',
    this.readTime = '2 min read',
    this.summary =
        'During this phase, estrogen levels begin to rise, increasing overall energy, social drive, and mental sharpness. Here is how you can best support and connect with her today.',
    this.keyPoints = const [
      'Encourage social plans or trying a new activity together.',
      'Her communication flow is at its peak—great time for deep conversations.',
      'Plan high-protein meals to sustain rising stamina.',
    ],
    this.actionTip =
        'Take initiative on planning dinner tonight or suggest an impromptu outdoor walk.',
  });

  factory InsightView.fromPersonalInsight(PersonalCycleInsight insight) {
    return InsightView(
      tagText: insight.kindLabel,
      title: insight.title,
      category: 'From your logs',
      readTime: 'Pattern',
      summary: insight.body,
      keyPoints: const [],
      actionTip: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = keyPoints?.where((p) => p.trim().isNotEmpty).toList() ?? [];
    final tip = actionTip?.trim() ?? '';
    final showPoints = points.isNotEmpty;
    final showTip = tip.isNotEmpty;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surface,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: context.onSurface,
            ),
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Container(
        //       padding: const EdgeInsets.all(8),
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color: context.surface,
        //         border: Border.all(
        //           color: AppColors.primary.withValues(alpha: 0.12),
        //         ),
        //       ),
        //       child: const Icon(
        //         Icons.bookmark_border_rounded,
        //         size: 18,
        //         color: AppColors.primary,
        //       ),
        //     ),
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Metadata Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextWidget(
                    title: tagText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                TextWidget(
                  title: '•  $readTime',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            TextWidget(
              title: title,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              textColor: AppColors.textPrimary,
            ),
            const SizedBox(height: 18),

            // Hero Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.softGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextWidget(
                      title: summary ?? '',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      textColor: AppColors.textPrimary,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Key Takeaways Section
            if (showPoints) ...[
              const TextWidget(
                title: "What's Happening",
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 12),
              ...points.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextWidget(
                          title: point,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.textSecondary,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Actionable Support Tip
            if (showTip) ...[
              const TextWidget(
                title: 'Helpful Action For You',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextWidget(
                        title: tip,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
