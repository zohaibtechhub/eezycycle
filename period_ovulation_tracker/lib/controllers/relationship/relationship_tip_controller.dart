import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/relationship_tip_repository.dart';
import '../../models/relationship/relationship_tip_model.dart';
import '../../routes/app_pages.dart';

class DailyTipsController extends GetxController {
  final RelationshipTipRepository _repo = RelationshipTipRepository.instance;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<RelationshipTipModel> todaysTips = <RelationshipTipModel>[].obs;
  final Rxn<RelationshipTipModel> featuredTip = Rxn<RelationshipTipModel>();

  final List<String> categories = const [
    'All',
    'Cycle Support',
    'Communication',
    'Quality Time',
    'Care & Comfort',
    'Appreciation',
  ];

  String get dayLabel {
    final now = DateTime.now();
    return DateFormat('EEEE, MMM d').format(now);
  }

  List<RelationshipTipModel> get filteredTips {
    if (selectedCategory.value == 'All') return todaysTips.toList();
    return todaysTips
        .where((tip) => tip.category == selectedCategory.value)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    Future.microtask(load);
  }

  Future<void> load() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final now = DateTime.now();
      final day = DateTime(now.year, now.month, now.day);
      final tips = await _repo.forDay(day);
      todaysTips.assignAll(tips);
      featuredTip.value = tips.isEmpty ? null : tips.first;
    } catch (_) {
      hasError.value = true;
      todaysTips.clear();
      featuredTip.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void openTip(RelationshipTipModel tip) {
    Get.toNamed(AppPages.dailyTipDetail, arguments: tip);
  }
}
