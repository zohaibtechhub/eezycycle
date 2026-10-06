import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/services/api_service.dart';
import 'package:period_ovulation_tracker/core/utils/short_message.dart';

class SecretProfileController extends GetxController {
  final ApiClient _api = ApiClient();

  final RxString username = 'Username'.obs;
  final RxnString avatarUrl = RxnString();
  final RxList<String> selectedTags = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasProfile = false.obs;
  late final TextEditingController usernameController;

  static const List<String> availableTags = [
    'Trying to conceive',
    'Period pain',
    'PCOS',
    'Pregnancy',
    'Postpartum',
    'Mood & mental health',
    'Sex & intimacy',
    'Birth control',
    'Perimenopause',
    'Irregular cycles',
    'Endometriosis',
    'Fertility treatment',
  ];

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController(text: username.value);
    loadProfile();
  }

  @override
  void onClose() {
    usernameController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final response = await _api.get(ApiEndPoints.secretProfile);
      final data = ApiClient.unwrapData(response);
      final profile = data?['profile'];
      if (profile is Map) {
        hasProfile.value = true;
        final name = profile['username']?.toString() ?? 'Username';
        username.value = name;
        usernameController.text = name;
        final avatar = profile['avatar_url']?.toString();
        avatarUrl.value =
            (avatar != null && avatar.isNotEmpty) ? avatar : null;
        final tags = profile['tags'];
        if (tags is List) {
          selectedTags.assignAll(
            tags.map((e) => e.toString()).where((e) => e.isNotEmpty),
          );
        }
      } else {
        hasProfile.value = false;
        avatarUrl.value = null;
      }
    } catch (_) {
      // Keep local defaults if offline
    } finally {
      isLoading.value = false;
    }
  }

  void saveUsername(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    username.value = trimmed;
    usernameController.text = trimmed;
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  bool isTagSelected(String tag) => selectedTags.contains(tag);

  /// Persists username + tags to the backend.
  Future<bool> saveProfile(BuildContext context) async {
    final name = username.value.trim();
    if (name.length < 3) {
      ShortMessageUtils.showError(
        context,
        'Username must be at least 3 characters.',
      );
      return false;
    }

    if (isSaving.value) return false;
    isSaving.value = true;
    try {
      final response = await _api.put(ApiEndPoints.secretProfile, {
        'username': name,
        'tags': selectedTags.toList(),
      });
      final data = ApiClient.unwrapData(response);
      final profile = data?['profile'];
      if (profile is Map) {
        hasProfile.value = true;
        final saved = profile['username']?.toString() ?? name;
        username.value = saved;
        usernameController.text = saved;
        final tags = profile['tags'];
        if (tags is List) {
          selectedTags.assignAll(
            tags.map((e) => e.toString()).where((e) => e.isNotEmpty),
          );
        }
      }
      ShortMessageUtils.showSuccess(context, 'Profile updated');
      return true;
    } catch (e) {
      ShortMessageUtils.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
