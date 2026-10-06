import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/pregnancy/pregnancy_insights_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/models/pregnancy/pregnancy_insight_models.dart';
import 'package:period_ovulation_tracker/widgets/common/app_shimmer.dart';
import 'package:period_ovulation_tracker/widgets/pregnancy/pregnancy_asset_image.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

/// Flo-style "My daily insights" + "What to expect" for pregnancy Home.
class PregnancyDailyInsightsSection extends StatelessWidget {
  const PregnancyDailyInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<PregnancyInsightsController>()
        ? Get.find<PregnancyInsightsController>()
        : Get.put(PregnancyInsightsController());

    return Obx(() {
      final week = c.insight.value;
      final shimmer =
          c.weekShimmering.value || (c.loading.value && week == null);
      final _ = c.contentDay.value;

      if (shimmer) {
        return const _PregnancyInsightsShimmer();
      }

      if (week == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            title: 'My daily insights',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            textColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 4),
          TextWidget(
            title: '${c.sectionDateLabel} · ${c.gestationalLabel}',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 248,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: week.stories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, i) => _InsightCard(
                story: week.stories[i],
                baby: week.baby,
                commonKeys: week.symptoms.commonKeys,
                onTap: () => c.openStory(week.stories[i].id),
              ),
            ),
          ),
          const SizedBox(height: 28),
          TextWidget(
            title: week.whatToExpect.title,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            textColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < week.whatToExpect.items.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: _ExpectTile(
                    item: week.whatToExpect.items[i],
                    onTap: () => c.openExpect(week.whatToExpect.items[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }
}

class _PregnancyInsightsShimmer extends StatelessWidget {
  const _PregnancyInsightsShimmer();

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
          const SizedBox(height: 28),
          const AppShimmerBox(width: 200, height: 18),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: AppShimmerBox(
                    height: 132,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final PregnancyStory story;
  final PregnancyBabyInsight baby;
  final List<String> commonKeys;
  final VoidCallback onTap;

  const _InsightCard({
    required this.story,
    required this.baby,
    required this.commonKeys,
    required this.onTap,
  });

  Color get _accent {
    switch (story.id) {
      case 'body':
        return const Color(0xFF7EB8D4);
      case 'symptoms':
        return const Color(0xFF8BA4E8);
      default:
        return const Color(0xFFE8A0B0);
    }
  }

  Color get _headerColor {
    final hex = story.cardHeaderColor;
    if (hex == null || hex.isEmpty) {
      return switch (story.id) {
        'body' => const Color(0xFFE8F4FA),
        'symptoms' => const Color(0xFFEEF2FC),
        _ => const Color(0xFFF8EBEE),
      };
    }
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final v = int.tryParse(h, radix: 16);
    return v == null ? const Color(0xFFF8EBEE) : Color(v);
  }

  @override
  Widget build(BuildContext context) {
    final isBaby = story.id == 'baby';
    final isSymptoms = story.id == 'symptoms';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 196,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _accent.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _headerColor,
                    _headerColor.withValues(alpha: 0.72),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isBaby
                          ? 'Baby'
                          : isSymptoms
                              ? 'Symptoms'
                              : 'Body',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    story.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isSymptoms
                  ? _SymptomsPreview(commonKeys: commonKeys)
                  : isBaby
                      ? _BabySizeCompare(
                          babyPath:
                              story.cardBabyImage ?? baby.illustrationAsset,
                          sizePath: story.cardSizeImage ?? baby.sizeAsset,
                          sizeLabel: baby.sizeLabel,
                        )
                      : PregnancyAssetImage(
                          path: story.cardImage,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.favorite_rounded,
                          backgroundColor: const Color(0xFFE8F4FA),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SymptomsPreview extends StatelessWidget {
  final List<String> commonKeys;

  const _SymptomsPreview({required this.commonKeys});

  String _emojiFor(String key) {
    switch (key) {
      case 'sym_fatigue':
        return '🔋';
      case 'sym_cramps':
        return '💢';
      case 'sym_bloating':
        return '🫧';
      case 'sym_headache':
        return '🤕';
      case 'sym_tender_breasts':
        return '💗';
      case 'sym_acne':
        return '✨';
      case 'sym_nausea':
        return '🤢';
      case 'sym_backache':
        return '🧘';
      default:
        return '✨';
    }
  }

  String _labelFor(String key) {
    switch (key) {
      case 'sym_fatigue':
        return 'Fatigue';
      case 'sym_cramps':
        return 'Cramps';
      case 'sym_bloating':
        return 'Bloating';
      case 'sym_headache':
        return 'Headache';
      case 'sym_tender_breasts':
        return 'Soreness';
      case 'sym_acne':
        return 'Skin';
      case 'sym_nausea':
        return 'Nausea';
      case 'sym_backache':
        return 'Back';
      default:
        return 'Common';
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = commonKeys.take(4).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEEF2FC), Color(0xFFE4EAF8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Common this week',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final key in keys)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_emojiFor(key), style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          _labelFor(key),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BabySizeCompare extends StatelessWidget {
  final String? babyPath;
  final String? sizePath;
  final String? sizeLabel;

  const _BabySizeCompare({
    this.babyPath,
    this.sizePath,
    this.sizeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: PregnancyAssetImage(
            path: babyPath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            fallbackIcon: Icons.child_care_rounded,
            backgroundColor: const Color(0xFFF8F1F3),
          ),
        ),
        Expanded(
          flex: 5,
          child: ColoredBox(
            color: const Color(0xFFFFF8F2),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
              child: Column(
                children: [
                  Expanded(
                    child: PregnancyAssetImage(
                      path: sizePath,
                      fit: BoxFit.contain,
                      fallbackIcon: Icons.eco_rounded,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  if (sizeLabel != null && sizeLabel!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      sizeLabel!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
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
          border: Border.all(
            color: AppColors.pregnancy.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.pregnancy.withValues(alpha: 0.08),
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
