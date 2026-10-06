import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/data/article_repository.dart';
import 'package:period_ovulation_tracker/data/recommended_actions_catalog.dart';
import 'package:period_ovulation_tracker/models/article/cycle_article_model.dart';
import 'package:period_ovulation_tracker/views/article/article_view.dart';
import 'package:period_ovulation_tracker/views/insight/insight_view.dart';
import 'package:period_ovulation_tracker/widgets/container/insight_container.dart';
import 'package:period_ovulation_tracker/widgets/container/recommendation_card.dart';
import 'package:period_ovulation_tracker/widgets/home/cycle_articles_section.dart';
import 'package:period_ovulation_tracker/widgets/home/cycle_daily_insights_section.dart';
import 'package:period_ovulation_tracker/widgets/home/home_cycle_hero.dart';
import 'package:period_ovulation_tracker/widgets/home/pregnancy_daily_insights_section.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';
import 'package:period_ovulation_tracker/controllers/cycle/cycle_insights_controller.dart';

import '../article/all_articles.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  CyclePhaseType _resolvePhase(HomeHeroController hero) {
    final data = hero.currentSelectedData;
    final payload = hero.todayPayload.value;
    // Only trust API phase when it matches the selected date — otherwise the
    // previous day's phase would lag until /today returns.
    final payloadDate = payload?['date']?.toString();
    final selectedYmd =
        '${data.date.year.toString().padLeft(4, '0')}-'
        '${data.date.month.toString().padLeft(2, '0')}-'
        '${data.date.day.toString().padLeft(2, '0')}';
    String? apiPhase;
    if (payload != null && payloadDate == selectedYmd) {
      apiPhase = payload['phase']?.toString();
    }
    return ArticleRepository.phaseFromHome(
      dayType: data.type,
      apiPhase: apiPhase,
      pregnancyModeActive: hero.pregnancyModeActive.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hero = Get.find<HomeHeroController>();
    if (!Get.isRegistered<CycleInsightsController>()) {
      Get.put(CycleInsightsController());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeCycleHero(mode: HeroViewMode.woman),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                36 + 68 + 20 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Obx(() {
                final phase = _resolvePhase(hero);
                final phaseLabel = ArticleRepository.phaseLabel(phase);
                final actions = RecommendedActionsCatalog.pickForPhase(
                  phase,
                  limit: 3,
                );
                final patterns = hero.personalInsights.toList();
                final pregnancy = hero.pregnancyModeActive.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pregnancy) ...[
                      const PregnancyDailyInsightsSection(),
                      const SizedBox(height: 28),
                    ] else ...[
                      const CycleDailyInsightsSection(),
                      const SizedBox(height: 28),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TextWidget(
                          title: 'Discover articles',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          textColor: AppColors.textPrimary,
                        ),
                        TextWidget(
                          title: phaseLabel,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const TextWidget(
                      title: 'Up to 6 educational picks matched to your cycle',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.textSecondary,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: _DiscoverArticlesStrip(phase: phase),
                    ),
                    const SizedBox(height: 28),
                    CycleArticlesSection(
                      currentPhase: phase,
                      phaseName: phaseLabel,
                      itemLimit: 5,
                      discoverLimit: 6,
                      onSeeAllTap: () {
                        Get.to(() => const AllArticlesView());
                      },
                      onArticleTap: (article) {
                        Get.to(() => ArticleView.fromArticle(article));
                      },
                    ),
                    if (patterns.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      const TextWidget(
                        title: 'Your patterns',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      const TextWidget(
                        title:
                            'Personal timing patterns from your symptom logs — not a diagnosis',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.textSecondary,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 14),
                      for (var i = 0; i < patterns.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        RecommendationCard(
                          icon: Icons.insights_rounded,
                          iconBgColor: AppColors.primaryLight,
                          iconColor: AppColors.accent,
                          title: patterns[i].title,
                          description: patterns[i].body,
                          onTap: () {
                            Get.to(
                              () => InsightView.fromPersonalInsight(
                                patterns[i],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                    const SizedBox(height: 28),
                    const TextWidget(
                      title: 'Recommended Actions',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    TextWidget(
                      title: '3 ideas for your $phaseLabel phase today',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.textSecondary,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 14),
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      RecommendationCard(
                        icon: actions[i].icon,
                        iconBgColor: actions[i].iconBg,
                        iconColor: actions[i].iconColor,
                        title: actions[i].title,
                        description: actions[i].description,
                        onTap: () {
                          Get.to(
                            () => actions[i].toDetailView(
                              phaseLabel: phaseLabel,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps the last article list visible while the next phase loads — no spinner flash.
class _DiscoverArticlesStrip extends StatefulWidget {
  final CyclePhaseType phase;

  const _DiscoverArticlesStrip({required this.phase});

  @override
  State<_DiscoverArticlesStrip> createState() => _DiscoverArticlesStripState();
}

class _DiscoverArticlesStripState extends State<_DiscoverArticlesStrip> {
  List<CycleArticleModel> _items = const [];
  CyclePhaseType? _loadedPhase;
  int _loadGen = 0;

  @override
  void initState() {
    super.initState();
    _load(widget.phase);
  }

  @override
  void didUpdateWidget(covariant _DiscoverArticlesStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _load(widget.phase);
    }
  }

  Future<void> _load(CyclePhaseType phase) async {
    final gen = ++_loadGen;
    final items = await ArticleRepository.instance.forPhase(phase, limit: 6);
    if (!mounted || gen != _loadGen) return;
    setState(() {
      _items = items;
      _loadedPhase = phase;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      if (_loadedPhase == null) {
        return const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        );
      }
      return const Center(
        child: TextWidget(
          title: 'Articles coming soon',
          fontSize: 13,
          textColor: AppColors.textSecondary,
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (context, index) {
        final article = _items[index];
        return InsightContainer(
          tagText: article.category,
          centerText: article.title,
          onTap: () {
            Get.to(() => ArticleView.fromArticle(article));
          },
        );
      },
    );
  }
}
