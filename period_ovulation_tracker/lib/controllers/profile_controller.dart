import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../core/services/api_service.dart';
import '../core/services/cycle_display_mapper.dart';
import '../core/utils/pref_util.dart';
import '../core/utils/short_message.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final ApiClient _api = ApiClient();
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = true.obs;
  final RxBool hasLoaded = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxnString email = RxnString();
  final RxString accountStatus = 'guest'.obs;
  final RxnInt avgCycleLength = RxnInt();
  final RxnInt avgPeriodLength = RxnInt();
  final RxnInt lutealPhaseDays = RxnInt();
  final RxnInt birthYear = RxnInt();
  final RxnString experienceMode = RxnString();
  final RxBool pregnancyModeActive = false.obs;
  final RxnString dueDate = RxnString();
  final RxnDouble heightCm = RxnDouble();
  final RxnDouble weightKg = RxnDouble();
  final RxList<String> goals = <String>[].obs;

  bool get isRegistered => accountStatus.value == 'registered';

  bool get canChangeAvatar => !PrefUtil.getBool(PrefUtil.isPartnerMode);

  String get experienceLabel {
    final mode = experienceMode.value;
    if (mode == null || mode.isEmpty) return 'Not set';
    return CycleDisplayMapper.titleForExperienceMode(mode);
  }

  String? get ageLabel {
    final year = birthYear.value;
    if (year == null) return null;
    final age = DateTime.now().year - year;
    if (age < 13 || age > 90) return null;
    return '$age years';
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      Map<String, dynamic>? me;
      if (Get.isRegistered<AuthController>()) {
        me = await Get.find<AuthController>().fetchMe();
      } else {
        final response = await _api.get(
          ApiEndPoints.me,
          doesLoginRequired: true,
        );
        me = ApiClient.unwrapData(response);
      }
      if (me == null) return;
      _apply(me);
    } finally {
      isLoading.value = false;
      hasLoaded.value = true;
    }
  }

  Future<void> changeAvatar() async {
    if (!canChangeAvatar) return;
    if (isUploadingAvatar.value) return;

    final ctx = Get.context;
    try {
      // Guests and registered users both upload — ensure a JWT first.
      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        final token = PrefUtil.getString(PrefUtil.token);
        if (token.isEmpty) {
          final ok = await auth.ensureGuestSession();
          if (!ok) {
            if (ctx != null) {
              ShortMessageUtils.showError(
                ctx,
                'Could not start a session. Check your connection and try again.',
              );
            }
            return;
          }
        }
      }

      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;

      isUploadingAvatar.value = true;
      final response = await _api.postFormData(ApiEndPoints.meAvatar, {
        'avatar': File(picked.path),
      });
      final data = ApiClient.unwrapData(response);
      if (data != null) {
        _apply(data);
        if (Get.isRegistered<AuthController>()) {
          await Get.find<AuthController>().applyAvatarUrl(
            data['avatar_url']?.toString(),
          );
        }
      }
      if (ctx != null) {
        ShortMessageUtils.showSuccess(ctx, 'Profile photo updated.');
      }
    } catch (e) {
      if (ctx != null) {
        ShortMessageUtils.showError(
          ctx,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void _apply(Map<String, dynamic> me) {
    final mail = me['email']?.toString();
    email.value = (mail != null && mail.isNotEmpty) ? mail : null;

    final status = me['account_status']?.toString();
    accountStatus.value =
        (status != null && status.isNotEmpty) ? status : 'guest';

    final profile = me['profile'];
    if (profile is Map) {
      avgCycleLength.value = _asInt(profile['avg_cycle_length']) ?? 28;
      avgPeriodLength.value = _asInt(profile['avg_period_length']) ?? 5;
      lutealPhaseDays.value = _asInt(profile['luteal_phase_days']) ?? 14;
      birthYear.value = _asInt(profile['birth_year']);
      experienceMode.value = profile['experience_mode']?.toString();
      pregnancyModeActive.value =
          profile['pregnancy_mode_active'] == true ||
          profile['pregnancy_mode_active'] == 1;
      final due = profile['due_date']?.toString();
      dueDate.value = (due != null && due.isNotEmpty) ? due : null;
      heightCm.value = _asDouble(profile['height_cm']);
      weightKg.value = _asDouble(profile['weight_kg']);
    }

    final g = me['goals'];
    if (g is List) {
      goals.assignAll(
        g.map((e) => e.toString()).where((e) => e.isNotEmpty).toList(),
      );
    } else {
      goals.clear();
    }
  }

  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v == null) return null;
    return int.tryParse(v.toString());
  }

  double? _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v == null) return null;
    return double.tryParse(v.toString());
  }
}
