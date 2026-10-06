import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/article/bookmark_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/models/article/cycle_article_model.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class ArticleView extends StatelessWidget {
  final String? articleId;
  final String category;
  final String title;
  final String readTime;
  final String author;
  final String publishedDate;
  final String? imageUrl;
  final String heroSummary;
  final List<ArticleSection> sections;
  final List<String> takeaways;

  const ArticleView({
    super.key,
    this.articleId,
    this.category = 'Wellness',
    this.title = 'Article',
    this.readTime = '4 min read',
    this.author = 'EezyCycle Editorial',
    this.publishedDate = 'Updated recently',
    this.imageUrl,
    this.heroSummary = '',
    this.sections = const [],
    this.takeaways = const [],
  });

  /// Preferred: open from catalog so image + sex body + takeaways all match.
  factory ArticleView.fromArticle(CycleArticleModel article) {
    return ArticleView(
      articleId: article.id,
      category: article.category,
      title: article.title,
      readTime: article.readTime,
      author: article.author,
      publishedDate: article.publishedDate,
      imageUrl: article.imageUrl,
      heroSummary: article.heroSummary.isNotEmpty
          ? article.heroSummary
          : article.description,
      sections: article.sections,
      takeaways: article.takeaways,
    );
  }

  BookmarkController get _bookmarks {
    if (Get.isRegistered<BookmarkController>()) {
      return Get.find<BookmarkController>();
    }
    return Get.put(BookmarkController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = _bookmarks;
    final canBookmark = articleId != null && articleId!.isNotEmpty;

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
        actions: [
          if (canBookmark)
            Obx(() {
              final saved = bookmarks.isBookmarked(articleId);
              return IconButton(
                onPressed: () => bookmarks.toggleBookmark(articleId!),
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
                    saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              );
            }),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    title: category,
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
            TextWidget(
              title: title,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              textColor: AppColors.textPrimary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextWidget(
                    title: '$author  •  $publishedDate',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: _ArticleCoverImage(url: imageUrl!),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (heroSummary.trim().isNotEmpty) ...[
              TextWidget(
                title: heroSummary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 22),
            ],
            for (final section in sections) ...[
              TextWidget(
                title: section.heading,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 8),
              TextWidget(
                title: section.body,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textColor: AppColors.textSecondary,
              ),
              const SizedBox(height: 20),
            ],
            if (takeaways.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      title: 'Takeaways',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 10),
                    for (final tip in takeaways) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextWidget(
                              title: tip,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const TextWidget(
                title: 'Educational estimates only — not medical advice.',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                textColor: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArticleCoverImage extends StatelessWidget {
  final String url;

  const _ArticleCoverImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.primaryLight,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.primary),
    );
  }
}
