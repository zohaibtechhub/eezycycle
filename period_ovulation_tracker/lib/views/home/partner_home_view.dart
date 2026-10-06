import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/home/home_hero_controller.dart';
import 'package:period_ovulation_tracker/controllers/relationship/partner_code_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/services/notification_service.dart';
import 'package:period_ovulation_tracker/data/article_repository.dart';
import 'package:period_ovulation_tracker/data/relationship_tip_repository.dart';
import 'package:period_ovulation_tracker/models/article/cycle_article_model.dart';
import 'package:period_ovulation_tracker/models/relationship/relationship_tip_model.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/views/article/article_view.dart';
import 'package:period_ovulation_tracker/views/article/all_articles.dart';
import 'package:period_ovulation_tracker/widgets/container/insight_container.dart';
import 'package:period_ovulation_tracker/widgets/container/recommendation_card.dart';
import 'package:period_ovulation_tracker/widgets/home/cycle_articles_section.dart';
import 'package:period_ovulation_tracker/widgets/home/home_cycle_hero.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class PartnerHomeView extends StatefulWidget {
  const PartnerHomeView({super.key});

  @override
  State<PartnerHomeView> createState() => _PartnerHomeViewState();
}

class _PartnerHomeViewState extends State<PartnerHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<HomeHeroController>()) {
        Get.put(HomeHeroController(), permanent: true);
      }
      // Always pull /partner/* when this shell opens (fixes "need restart").
      Get.find<HomeHeroController>().ensurePartnerDataLoaded();
      if (Get.isRegistered<PartnerController>()) {
        Get.find<PartnerController>().refreshStatus();
      } else {
        Get.put(PartnerController()).refreshStatus();
      }
      if (Get.isRegistered<NotificationService>()) {
        // ignore: discarded_futures
        Get.find<NotificationService>().ensurePushLinkedForCurrentUser();
      }
    });
  }

  CyclePhaseType _resolvePhase(HomeHeroController hero) {
    final payload = hero.todayPayload.value;
    final apiPhase = payload?['phase']?.toString();
    return ArticleRepository.phaseFromHome(
      dayType: hero.currentSelectedData.type,
      apiPhase: apiPhase,
      pregnancyModeActive: hero.pregnancyModeActive.value,
    );
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeHeroController>()) {
      Get.put(HomeHeroController(), permanent: true);
    }
    final hero = Get.find<HomeHeroController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeCycleHero(mode: HeroViewMode.partner),
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
                final selectedDay = _dayKey(hero.selectedDate.value);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Discover — partner-safe cycle-matched articles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TextWidget(
                          title: 'Discover Insights',
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
                      title: 'Up to 6 picks matched to her cycle',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.textSecondary,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: FutureBuilder<List<CycleArticleModel>>(
                        key: ValueKey('partner_discover_$phase'),
                        future: ArticleRepository.instance.forPhase(
                          phase,
                          limit: 6,
                          partnerSafe: true,
                        ),
                        builder: (context, snapshot) {
                          final items =
                              snapshot.data ?? const <CycleArticleModel>[];
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              items.isEmpty) {
                            return const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                            );
                          }
                          if (items.isEmpty) {
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
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final article = items[index];
                              return InsightContainer(
                                tagText: article.category,
                                centerText: article.title,
                                onTap: () {
                                  Get.to(
                                    () => ArticleView.fromArticle(article),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 2. For you — more partner-safe reads (no Discover overlap)
                    CycleArticlesSection(
                      currentPhase: phase,
                      phaseName: phaseLabel,
                      itemLimit: 5,
                      discoverLimit: 6,
                      partnerSafe: true,
                      title: 'For you',
                      subtitle: 'More reads to support her through this phase',
                      onSeeAllTap: () {
                        Get.to(() => const AllArticlesView());
                      },
                      onArticleTap: (article) {
                        Get.to(() => ArticleView.fromArticle(article));
                      },
                    ),

                    const SizedBox(height: 28),

                    // 3. Recommended Actions — real relationship tips
                    const TextWidget(
                      title: 'Recommended Actions',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    TextWidget(
                      title: '3 ways to support her in the $phaseLabel phase',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.textSecondary,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 14),
                    FutureBuilder<List<RelationshipTipModel>>(
                      key: ValueKey(
                        'partner_tips_${selectedDay.toIso8601String()}',
                      ),
                      future: RelationshipTipRepository.instance.forDay(
                        selectedDay,
                      ),
                      builder: (context, snapshot) {
                        final tips = (snapshot.data ??
                                const <RelationshipTipModel>[])
                            .take(3)
                            .toList();

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            tips.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                            ),
                          );
                        }

                        if (tips.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: TextWidget(
                              title: 'Tips coming soon',
                              fontSize: 13,
                              textColor: AppColors.textSecondary,
                              textAlign: TextAlign.start,
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (var i = 0; i < tips.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              RecommendationCard(
                                icon: tips[i].icon,
                                iconBgColor: tips[i].iconBg,
                                iconColor: tips[i].iconColor,
                                title: tips[i].title,
                                description: tips[i].description,
                                onTap: () {
                                  Get.toNamed(
                                    AppPages.dailyTipDetail,
                                    arguments: tips[i],
                                  );
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    ),
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
