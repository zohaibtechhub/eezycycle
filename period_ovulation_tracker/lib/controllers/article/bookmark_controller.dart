import 'package:get/get.dart';

import '../../core/services/api_service.dart';
import '../../core/utils/short_message.dart';
import '../../data/article_repository.dart';
import '../../models/article/cycle_article_model.dart';

/// Syncs article bookmarks with the backend for the current user (guest or registered).
class BookmarkController extends GetxController {
  final ApiClient _api = ApiClient();

  final RxSet<String> bookmarkedIds = <String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isToggling = false.obs;

  /// Prevents the empty-list → reload → fail → empty loop.
  bool _hasFetched = false;
  Future<void>? _inFlightLoad;

  @override
  void onInit() {
    super.onInit();
    // Defer until after first frame / session hydrate — avoid racing splash guest auth.
    Future.microtask(() => loadBookmarks());
  }

  bool isBookmarked(String? articleId) {
    if (articleId == null || articleId.isEmpty) return false;
    return bookmarkedIds.contains(articleId);
  }

  /// [force] refreshes even if we already loaded (pull-to-refresh / after login).
  Future<void> loadBookmarks({bool force = false}) async {
    if (!force) {
      if (_inFlightLoad != null) return _inFlightLoad!;
      if (_hasFetched) return;
    } else if (_inFlightLoad != null) {
      await _inFlightLoad;
    }

    _inFlightLoad = _fetchBookmarks();
    try {
      await _inFlightLoad;
    } finally {
      _inFlightLoad = null;
    }
  }

  Future<void> _fetchBookmarks() async {
    isLoading.value = true;
    try {
      final response = await _api.get(
        ApiEndPoints.articleBookmarks,
        doesLoginRequired: true,
      );
      final data = ApiClient.unwrapData(response);
      final ids = <String>{};
      if (data is Map) {
        final list = data!['article_ids'];
        if (list is List) {
          for (final item in list) {
            final id = item?.toString() ?? '';
            if (id.isNotEmpty) ids.add(id);
          }
        }
      }
      bookmarkedIds
        ..clear()
        ..addAll(ids);
      bookmarkedIds.refresh();
      _hasFetched = true;
    } catch (_) {
      // Mark fetched so an empty/error state does not spam the API.
      _hasFetched = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBookmark(String articleId) async {
    if (articleId.isEmpty || isToggling.value) return;

    final wasBookmarked = bookmarkedIds.contains(articleId);
    // Optimistic UI
    if (wasBookmarked) {
      bookmarkedIds.remove(articleId);
    } else {
      bookmarkedIds.add(articleId);
    }
    bookmarkedIds.refresh();

    isToggling.value = true;
    try {
      if (wasBookmarked) {
        await _api.delete(ApiEndPoints.articleBookmark(articleId));
      } else {
        await _api.post(ApiEndPoints.articleBookmark(articleId), {});
      }
      _hasFetched = true;
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showSuccess(
          ctx,
          wasBookmarked ? 'Bookmark removed' : 'Article saved',
        );
      }
    } catch (e) {
      // Revert
      if (wasBookmarked) {
        bookmarkedIds.add(articleId);
      } else {
        bookmarkedIds.remove(articleId);
      }
      bookmarkedIds.refresh();
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showError(
          ctx,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      isToggling.value = false;
    }
  }

  Future<List<CycleArticleModel>> resolveBookmarkedArticles() async {
    await loadBookmarks();
    final all = await ArticleRepository.instance.loadAll();
    final byId = {for (final a in all) a.id: a};
    final ordered = <CycleArticleModel>[];
    for (final id in bookmarkedIds) {
      final article = byId[id];
      if (article != null) ordered.add(article);
    }
    return ordered;
  }

  /// Call after logout so the next guest session starts clean.
  void clearLocal() {
    bookmarkedIds.clear();
    bookmarkedIds.refresh();
    _hasFetched = false;
  }

  /// After login / new session — one forced refresh (not on every token write).
  Future<void> reloadForSession() => loadBookmarks(force: true);
}
