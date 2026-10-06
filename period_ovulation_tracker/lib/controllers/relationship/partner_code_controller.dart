import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/services/api_service.dart';
import 'package:period_ovulation_tracker/core/utils/pref_util.dart';
import 'package:period_ovulation_tracker/core/utils/short_message.dart';

/// Woman's Partner tab: generate / share invite code and connection status.
class PartnerController extends GetxController {
  final ApiClient _api = ApiClient();

  final RxBool isLoading = true.obs;
  final RxBool isConnected = false.obs;
  final RxBool isBusy = false.obs;
  final RxString partnerCode = ''.obs;
  final RxString linkStatus = ''.obs;
  final RxString role = ''.obs;
  final RxnString ownerAvatarUrl = RxnString();
  final TextEditingController codeInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    refreshStatus();
  }

  Future<void> refreshStatus() async {
    isLoading.value = true;
    try {
      final response = await _api.get(ApiEndPoints.partnerStatus);
      final data = ApiClient.unwrapData(response);
      if (data != null) {
        _applyStatus(data);
      }
      // Owner without a code yet → generate one for share UI
      if (role.value != 'partner' &&
          (partnerCode.value.isEmpty || linkStatus.value.isEmpty)) {
        await generateCode(silent: true);
      }
    } catch (_) {
      // Keep last known state
    } finally {
      isLoading.value = false;
    }
  }

  void _applyStatus(Map<String, dynamic> data) {
    isConnected.value = data['connected'] == true;
    partnerCode.value = data['code']?.toString() ?? partnerCode.value;
    linkStatus.value = data['status']?.toString() ?? '';
    role.value = data['role']?.toString() ?? '';

    final ownerAvatar = data['owner_avatar_url']?.toString();
    if (ownerAvatar != null && ownerAvatar.isNotEmpty) {
      ownerAvatarUrl.value = ownerAvatar;
      PrefUtil.setString(PrefUtil.partnerOwnerAvatarUrl, ownerAvatar);
    } else if (role.value == 'partner') {
      final cached = PrefUtil.getString(PrefUtil.partnerOwnerAvatarUrl);
      ownerAvatarUrl.value = cached.isEmpty ? null : cached;
    } else {
      ownerAvatarUrl.value = null;
    }
  }

  Future<void> generateCode({bool silent = false}) async {
    if (isBusy.value) return;
    isBusy.value = true;
    try {
      final response = await _api.post(ApiEndPoints.partnerCode, {
        'consented': true,
      });
      final data = ApiClient.unwrapData(response);
      if (data != null) {
        partnerCode.value = data['code']?.toString() ?? '';
        linkStatus.value = data['status']?.toString() ?? 'pending';
        isConnected.value = data['linked'] == true;
        role.value = 'owner';
      }
    } catch (e) {
      if (!silent) {
        final ctx = Get.context;
        if (ctx != null) {
          ShortMessageUtils.showError(
            ctx,
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> connectWithCode(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.length < 4) {
      Get.snackbar(
        'Invalid Code',
        'Please enter a valid 6-character partner code.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: AppColors.error,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (isBusy.value) return;
    isBusy.value = true;
    try {
      final response = await _api.post(ApiEndPoints.partnerLink, {
        'code': trimmed,
        'consented': true,
      });
      final data = ApiClient.unwrapData(response);
      if (data != null) {
        isConnected.value = true;
        partnerCode.value = data['code']?.toString() ?? trimmed;
        linkStatus.value = data['status']?.toString() ?? 'active';
        role.value = 'partner';
      }
      codeInputController.clear();
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Partner Connected',
        'You are now linked. Shared cycle phases will appear on Partner Today.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: AppColors.textPrimary,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showError(
          ctx,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> disconnectPartner() async {
    if (isBusy.value) return;
    isBusy.value = true;
    try {
      await _api.delete(ApiEndPoints.partnerLink);
      isConnected.value = false;
      linkStatus.value = 'revoked';
      // Owner can generate a fresh code after disconnect
      partnerCode.value = '';
      await generateCode(silent: true);
      Get.snackbar(
        'Partner Disconnected',
        'Shared cycle insights have been unlinked.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: AppColors.textPrimary,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      final ctx = Get.context;
      if (ctx != null) {
        ShortMessageUtils.showError(
          ctx,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      isBusy.value = false;
    }
  }

  @override
  void onClose() {
    codeInputController.dispose();
    super.onClose();
  }
}
