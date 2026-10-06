import 'package:flutter/material.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/data/article_repository.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../models/article/cycle_article_model.dart';

class CycleArticlesSection extends StatelessWidget {
  final CyclePhaseType currentPhase;
  final String phaseName;
  final ValueChanged<CycleArticleModel>? onArticleTap;
  final VoidCallback? onSeeAllTap;

  /// Max cards on Home (full catalog via See all).
  final int itemLimit;

  /// Same count Discover uses — skipped so For you never duplicates Discover.
  final int discoverLimit;

  /// Exclude sex/intimacy articles (partner home).
  final bool partnerSafe;

  final String title;
  final String subtitle;

  const CycleArticlesSection({
    super.key,
    this.currentPhase = CyclePhaseType.follicular,
    this.phaseName = 'Follicular Phase',
    this.onArticleTap,
    this.onSeeAllTap,
    this.itemLimit = 5,
    this.discoverLimit = 6,
    this.partnerSafe = false,
    this.title = 'For you',
    this.subtitle = 'More recommended reads for your phase',
  });

  Color get _phaseAccentColor {
    switch (currentPhase) {
      case CyclePhaseType.menstrual:
        return AppColors.period;
      case CyclePhaseType.ovulation:
        return AppColors.ovulation;
      case CyclePhaseType.luteal:
        return AppColors.fertility;
      case CyclePhaseType.pregnancy:
        return AppColors.pregnancy;
      case CyclePhaseType.follicular:
      case CyclePhaseType.general:
        return AppColors.primary;
    }
  }

  Future<List<CycleArticleModel>> _load() {
    return ArticleRepository.instance.forYouRecommended(
      currentPhase,
      discoverLimit: discoverLimit,
      limit: itemLimit,
      partnerSafe: partnerSafe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CycleArticleModel>>(
      key: ValueKey(
        'for_you_${currentPhase.name}_${itemLimit}_$partnerSafe',
      ),
      future: _load(),
      builder: (context, snapshot) {
        final articlesToShow = snapshot.data ?? const <CycleArticleModel>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextWidget(
                            title: title,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            textColor: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _phaseAccentColor.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextWidget(
                                title: phaseName,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                textColor: _phaseAccentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextWidget(
                        title: subtitle,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.textSecondary,
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                if (onSeeAllTap != null)
                  GestureDetector(
                    onTap: onSeeAllTap,
                    child: const TextWidget(
                      title: 'See all',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (snapshot.connectionState == ConnectionState.waiting &&
                articlesToShow.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                ),
              )
            else if (articlesToShow.isEmpty)
              const TextWidget(
                title: 'More articles coming soon',
                fontSize: 13,
                textColor: AppColors.textSecondary,
              )
            else
              ...articlesToShow.map(
                (article) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildArticleCard(context, article),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildArticleCard(BuildContext context, CycleArticleModel article) {
    return GestureDetector(
      onTap: () => onArticleTap?.call(article),
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: article.themeColor.withValues(alpha: 0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: article.hasLocalImage
                  ? Image.asset(article.imageUrl, fit: BoxFit.cover)
                  : Image.network(
                      article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => Container(
                        color: article.themeColor.withValues(alpha: 0.12),
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      title: article.category,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      textColor: article.themeColor,
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      title: article.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.textPrimary,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 6),
                    TextWidget(
                      title: article.readTime,
                      fontSize: 11,
                      textColor: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
