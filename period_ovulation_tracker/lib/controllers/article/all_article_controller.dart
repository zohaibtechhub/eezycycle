import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../data/article_repository.dart';
import '../../models/article/cycle_article_model.dart';

class AllArticlesController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<CycleArticleModel> articles = <CycleArticleModel>[].obs;
  final RxBool isLoading = true.obs;

  final List<String> categories = const [
    'All',
    'Sex & Intimacy',
    'Follicular',
    'Ovulation',
    'Luteal',
    'Menstrual',
    'Pregnancy',
  ];

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final list = await ArticleRepository.instance.loadAll();
      articles.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  List<CycleArticleModel> get filteredArticles {
    return articles.where((article) {
      final selected = selectedCategory.value;
      final matchesCategory = selected == 'All' ||
          (selected == 'Sex & Intimacy' && article.isSexArticle) ||
          (selected != 'Sex & Intimacy' &&
              article.phase.name.toLowerCase() == selected.toLowerCase()) ||
          (selected == 'Pregnancy' &&
              article.matchesPhase(CyclePhaseType.pregnancy));

      final query = searchQuery.value.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          article.title.toLowerCase().contains(query) ||
          article.description.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
