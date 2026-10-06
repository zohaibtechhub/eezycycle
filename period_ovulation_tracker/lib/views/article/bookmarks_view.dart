import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/article/bookmark_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/models/article/cycle_article_model.dart';
import 'package:period_ovulation_tracker/views/article/article_view.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class BookmarksView extends StatefulWidget {
  const BookmarksView({super.key});

  @override
  State<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends State<BookmarksView> {
  late final BookmarkController _bookmarks;
  List<CycleArticleModel> _articles = const [];
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    _bookmarks = Get.isRegistered<BookmarkController>()
        ? Get.find<BookmarkController>()
        : Get.put(BookmarkController(), permanent: true);
    _resolve();
  }

  Future<void> _resolve({bool force = false}) async {
    setState(() => _resolving = true);
    if (force) {
      await _bookmarks.loadBookmarks(force: true);
    } else {
      await _bookmarks.loadBookmarks();
    }
    final articles = await _bookmarks.resolveBookmarkedArticles();
    if (!mounted) return;
    setState(() {
      _articles = articles;
      _resolving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: const TextWidget(
          title: 'Saved articles',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _resolve(force: true),
            icon: Icon(
              Icons.refresh_rounded,
              color: context.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // Rebuild list when bookmark set changes (e.g. unbookmark from here).
        final ids = _bookmarks.bookmarkedIds.toList();
        if (_resolving ||
            (_bookmarks.isLoading.value && ids.isEmpty && _articles.isEmpty)) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // Keep displayed articles in sync with ids without refetching the API.
        final visible = _articles
            .where((a) => ids.contains(a.id))
            .toList(growable: false);

        if (visible.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 48,
                    color: AppColors.primary.withValues(alpha: 0.45),
                  ),
                  const SizedBox(height: 16),
                  const TextWidget(
                    title: 'No saved articles yet',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  const TextWidget(
                    title:
                        'Tap the bookmark icon on any article to save it here.',
                    fontSize: 13,
                    textColor: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _resolve(force: true),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final article = visible[index];
              return _BookmarkCard(
                article: article,
                onOpen: () => Get.to(() => ArticleView.fromArticle(article)),
                onRemove: () async {
                  await _bookmarks.toggleBookmark(article.id);
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final CycleArticleModel article;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const _BookmarkCard({
    required this.article,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _ArticleThumb(
                  url: article.imageUrl,
                  color: article.themeColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    title: article.category,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.accent,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    title: article.title,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    textColor: AppColors.textPrimary,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    title: article.readTime,
                    fontSize: 12,
                    textColor: AppColors.textSecondary,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.bookmark_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleThumb extends StatelessWidget {
  final String url;
  final Color color;

  const _ArticleThumb({required this.url, required this.color});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();

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
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: color.withValues(alpha: 0.08),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: color.withValues(alpha: 0.12),
      child: Icon(Icons.menu_book_rounded, color: color, size: 28),
    );
  }
}
