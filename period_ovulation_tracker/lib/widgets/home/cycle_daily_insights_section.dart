import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/cycle/cycle_insights_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_insight_models.dart';
import 'package:period_ovulation_tracker/widgets/common/app_shimmer.dart';
import 'package:period_ovulation_tracker/widgets/pregnancy/pregnancy_asset_image.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

/// Flo-style daily insights for cycle phases (non-pregnancy).
class CycleDailyInsightsSection extends StatelessWidget {
  const CycleDailyInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<CycleInsightsController>()
        ? Get.find<CycleInsightsController>()
        : Get.put(CycleInsightsController());

    return Obx(() {
      final insight = c.insight.value;
      final shimmer =
          c.phaseShimmering.value || (c.loading.value && insight == null);
      final _ = c.contentPhase.value;

      if (shimmer) return const _CycleInsightsShimmer();
      if (insight == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            title: insight.headline,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            textColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 4),
          TextWidget(
            title: '${c.sectionDateLabel} · ${insight.phaseLabel}',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          if (insight.subheadline.isNotEmpty) ...[
            const SizedBox(height: 2),
            TextWidget(
              title: insight.subheadline,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              textColor: AppColors.textSecondary,
              textAlign: TextAlign.start,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 248,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: insight.stories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, i) => _CycleInsightCard(
                story: insight.stories[i],
                onTap: () => c.openStory(insight.stories[i].id),
              ),
            ),
          ),
          if (insight.whatToExpect.isNotEmpty) ...[
            const SizedBox(height: 28),
            const TextWidget(
              title: 'What to expect',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              textColor: AppColors.textPrimary,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < insight.whatToExpect.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: _ExpectTile(
                      item: insight.whatToExpect[i],
                      onTap: () => c.openExpect(insight.whatToExpect[i]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      );
    });
  }
}

class _CycleInsightsShimmer extends StatelessWidget {
  const _CycleInsightsShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmerBox(width: 180, height: 18),
          const SizedBox(height: 8),
          const AppShimmerBox(width: 160, height: 12),
          const SizedBox(height: 16),
          SizedBox(
            height: 248,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < 3; i++) ...[
                  AppShimmerBox(
                    width: 196,
                    height: 248,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  const SizedBox(width: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleInsightCard extends StatelessWidget {
  final PregnancyStory story;
  final VoidCallback onTap;

  const _CycleInsightCard({required this.story, required this.onTap});

  Color get _accent {
    switch (story.id) {
      case 'energy':
        return const Color(0xFF8BA4E8);
      case 'care':
        return const Color(0xFFD97706);
      default:
        return AppColors.accent;
    }
  }

  Color get _headerColor {
    final hex = story.cardHeaderColor;
    if (hex == null || hex.isEmpty) return const Color(0xFFF8EBEE);
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final v = int.tryParse(h, radix: 16);
    return v == null ? const Color(0xFFF8EBEE) : Color(v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 196,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _accent.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PregnancyAssetImage(
                    path: story.cardImage,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.auto_awesome,
                    backgroundColor: _headerColor,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Text(
                      story.cardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              color: _headerColor,
              child: Row(
                children: [
                  Text(
                    'Tap for story',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.play_circle_fill_rounded, size: 18, color: _accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpectTile extends StatelessWidget {
  final PregnancyExpectItem item;
  final VoidCallback onTap;

  const _ExpectTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.05,
              child: PregnancyAssetImage(
                path: item.image,
                fit: BoxFit.cover,
                fallbackIcon: Icons.auto_awesome,
                backgroundColor: AppColors.primaryLight,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
              child: Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
