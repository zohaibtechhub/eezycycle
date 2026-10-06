import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/constants/google_auth.dart';
import '../core/services/api_service.dart';
import '../core/services/notification_service.dart';
import '../core/utils/pref_util.dart';
import '../core/utils/short_message.dart';
import '../routes/app_pages.dart';
import '../widgets/common/app_loading.dart';
import 'article/bookmark_controller.dart';
import 'cycle_calender_controller.dart';
import 'cycle_ovulation_controller.dart';
import 'home/home_hero_controller.dart';
import 'profile_controller.dart';
import 'relationship/partner_code_controller.dart';
import 'secret_chat/secret_profile_controller.dart';

class AuthController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool agreeToTerms = false.obs;

  final ApiClient _api = ApiClient();

  final RxnInt currentUserId = RxnInt();
  final RxString accountStatus = 'guest'.obs;
  final RxnString userEmail = RxnString();
  final RxnString avatarUrl = RxnString();

  bool _googleReady = false;

  bool get isRegistered => accountStatus.value == 'registered';

  @override
  void onInit() {
    super.onInit();
    _hydrateFromPrefs();
  }

  void _hydrateFromPrefs() {
    final id = PrefUtil.getInt(PrefUtil.userId);
    if (id > 0) currentUserId.value = id;
    final status = PrefUtil.getString(PrefUtil.accountStatus);
    accountStatus.value = status.isEmpty ? 'guest' : status;
    final avatar = PrefUtil.getString(PrefUtil.avatarUrl);
    avatarUrl.value = avatar.isEmpty ? null : avatar;
  }

  void changeVisibility(bool isPassword) {
    if (isPassword) {
      isPasswordVisible.value = !isPasswordVisible.value;
    } else {
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
    }
  }

  /// Ensures a guest JWT exists (create/reuse by device_id).
  /// Always re-issues tokens so device picks up permanent JWTs after server updates.
  Future<bool> ensureGuestSession() async {
    try {
      final deviceId = await _ensureDeviceId();
      final response = await _api.post(ApiEndPoints.authGuest, {
        'device_id': deviceId,
        'platform': _platform(),
        'app_version': '1.0.0',
      });

      final data = ApiClient.unwrapData(response);
      if (data == null) {
        throw Exception('Guest auth failed');
      }

      await _persistSession(data);
      return true;
    } catch (e) {
      // Fallback: keep existing token if network failed but we already have one
      final existing = PrefUtil.getString(PrefUtil.token);
      if (existing.isNotEmpty) {
        currentUserId.value = PrefUtil.getInt(PrefUtil.userId);
        accountStatus.value =
            PrefUtil.getString(PrefUtil.accountStatus).isEmpty
            ? 'guest'
            : PrefUtil.getString(PrefUtil.accountStatus);
        return true;
      }
      _showError(e);
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchMe() async {
    try {
      final response = await _api.get(ApiEndPoints.me, doesLoginRequired: true);
      final data = ApiClient.unwrapData(response);
      if (data != null) {
        await _syncMeProfile(data);
      }
      return data;
    } catch (e) {
      // Access token may be expired — try refresh once
      final refreshed = await refreshSession();
      if (!refreshed) {
        _showError(e);
        return null;
      }
      try {
        final response = await _api.get(
          ApiEndPoints.me,
          doesLoginRequired: true,
        );
        final data = ApiClient.unwrapData(response);
        if (data != null) {
          await _syncMeProfile(data);
        }
        return data;
      } catch (err) {
        _showError(err);
        return null;
      }
    }
  }

  Future<void> _syncMeProfile(Map<String, dynamic> me) async {
    final id = me['id'];
    final parsed = id is int ? id : int.tryParse('$id');
    if (parsed != null) {
      currentUserId.value = parsed;
      await PrefUtil.setInt(PrefUtil.userId, parsed);
    }
    final status = me['account_status']?.toString();
    if (status != null && status.isNotEmpty) {
      accountStatus.value = status;
      await PrefUtil.setString(PrefUtil.accountStatus, status);
    }
    final email = me['email']?.toString();
    if (email != null && email.isNotEmpty) {
      userEmail.value = email;
    }
    await applyAvatarUrl(me['avatar_url']?.toString());
    await _syncPushIdentity();
  }

  Future<void> applyAvatarUrl(String? url) async {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) {
      avatarUrl.value = null;
      await PrefUtil.remove(PrefUtil.avatarUrl);
    } else {
      avatarUrl.value = trimmed;
      await PrefUtil.setString(PrefUtil.avatarUrl, trimmed);
    }
    // Keep secret chat header/posts in sync for guests + registered.
    if (Get.isRegistered<SecretProfileController>()) {
      Get.find<SecretProfileController>().avatarUrl.value =
          trimmed.isEmpty ? null : trimmed;
    }
  }

  Future<bool> refreshSession() async {
    final refresh = PrefUtil.getString(PrefUtil.refreshToken);
    if (refresh.isEmpty) return false;

    try {
      final response = await _api.post(ApiEndPoints.authRefresh, {
        'refresh_token': refresh,
      });
      final data = ApiClient.unwrapData(response);
      if (data == null) return false;
      await _persistSession(data);
      return true;
    } catch (_) {
      await PrefUtil.clearSession();
      return false;
    }
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    final access = data['access_token']?.toString() ?? '';
    final refresh = data['refresh_token']?.toString() ?? '';
    final user = data['user'];
    if (access.isEmpty) {
      throw Exception('Missing access token');
    }

    await PrefUtil.setString(PrefUtil.token, access);
    if (refresh.isNotEmpty) {
      await PrefUtil.setString(PrefUtil.refreshToken, refresh);
    }

    if (user is Map) {
      final id = user['id'];
      if (id is int) {
        currentUserId.value = id;
        await PrefUtil.setInt(PrefUtil.userId, id);
      } else if (id != null) {
        final parsed = int.tryParse(id.toString());
        if (parsed != null) {
          currentUserId.value = parsed;
          await PrefUtil.setInt(PrefUtil.userId, parsed);
        }
      }
      final status = user['account_status']?.toString() ?? 'guest';
      accountStatus.value = status;
      await PrefUtil.setString(PrefUtil.accountStatus, status);
      final email = user['email']?.toString();
      if (email != null && email.isNotEmpty) {
        userEmail.value = email;
      }
    }

    await _syncPushIdentity();
  }

  Future<void> _syncPushIdentity() async {
    if (!Get.isRegistered<NotificationService>()) return;
    await Get.find<NotificationService>().loginUser(currentUserId.value);
  }

  Future<String> _ensureDeviceId() async {
    var id = PrefUtil.getString(PrefUtil.deviceId);
    if (id.isNotEmpty) return id;
    id = _generateUuidV4();
    await PrefUtil.setString(PrefUtil.deviceId, id);
    return id;
  }

  String _platform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  void _showError(Object e) {
    final ctx = Get.context;
    if (ctx == null) return;
    final msg = e.toString().replaceFirst('Exception: ', '');
    ShortMessageUtils.showError(ctx, msg);
  }

  void _showSuccess(String message) {
    final ctx = Get.context;
    if (ctx == null) return;
    ShortMessageUtils.showSuccess(ctx, message);
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: kGoogleServerClientId,
    );
    _googleReady = true;
  }

  Future<String?> _googleIdToken() async {
    await _ensureGoogleInitialized();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google did not return an ID token. Check OAuth client configuration.',
      );
    }
    return idToken;
  }

  /// Existing account sign-in (email/password). Guest JWT is sent automatically.
  Future<void> login() async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    try {
      final previousUserId = currentUserId.value;
      final response = await _api.post(ApiEndPoints.authLogin, {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });
      final data = ApiClient.unwrapData(response);
      if (data == null) throw Exception('Sign in failed');

      await _persistSession(data);
      _showSuccess(
        previousUserId != null &&
                currentUserId.value != null &&
                previousUserId == currentUserId.value
            ? 'Welcome back — your cycle data is ready.'
            : 'Signed in successfully.',
      );
      _clearPasswordFields();
      await _reloadAppDataForSession();
      Get.offNamedUntil(AppPages.mainBottomNavView, (route) => false);
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Finish creating account on the current guest (same user_id — no data move).
  Future<void> signup() async {
    if (!(signupFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    try {
      final previousUserId = currentUserId.value;
      // Guests upgrade in place; already-registered users shouldn't hit this.
      final endpoint = isRegistered
          ? ApiEndPoints.authLogin
          : ApiEndPoints.authUpgrade;
      final response = await _api.post(endpoint, {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });
      final data = ApiClient.unwrapData(response);
      if (data == null) throw Exception('Could not create account');

      await _persistSession(data);

      final sameId =
          previousUserId != null &&
          currentUserId.value != null &&
          previousUserId == currentUserId.value;
      _showSuccess(
        sameId
            ? 'Account ready — all your cycle data stays with you.'
            : 'Account created successfully.',
      );
      _clearPasswordFields();
      await _reloadAppDataForSession();
      Get.offNamedUntil(AppPages.mainBottomNavView, (route) => false);
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Google: upgrade guest in place, or login if already registered / email exists.
  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;
    try {
      final idToken = await _googleIdToken();
      final previousUserId = currentUserId.value;

      Map<String, dynamic>? data;
      if (!isRegistered) {
        try {
          final response = await _api.post(ApiEndPoints.authUpgrade, {
            'google_id_token': idToken,
          });
          data = ApiClient.unwrapData(response);
        } catch (e) {
          // Email/Google already registered → fall through to login
          final msg = e.toString().toLowerCase();
          if (!msg.contains('already') && !msg.contains('sign in')) {
            rethrow;
          }
        }
      }

      if (data == null) {
        final response = await _api.post(ApiEndPoints.authLogin, {
          'google_id_token': idToken,
        });
        data = ApiClient.unwrapData(response);
      }

      if (data == null) throw Exception('Google sign-in failed');

      await _persistSession(data);
      final sameId =
          previousUserId != null &&
          currentUserId.value != null &&
          previousUserId == currentUserId.value;
      _showSuccess(
        sameId
            ? 'Signed in — your cycle data is unchanged.'
            : 'Signed in with Google.',
      );
      await _reloadAppDataForSession();
      Get.offNamedUntil(AppPages.mainBottomNavView, (route) => false);
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _showError(Exception(e.description ?? 'Google sign-in failed'));
      }
    } catch (e) {
      _showError(e);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void _clearPasswordFields() {
    passwordController.clear();
    confirmPasswordController.clear();
  }

  /// After login / upgrade / Google: refresh permanent controllers that loaded
  /// once for the previous (often empty guest) session.
  Future<void> _reloadAppDataForSession() async {
    if (Get.isRegistered<BookmarkController>()) {
      // ignore: unawaited_futures
      Get.find<BookmarkController>().reloadForSession();
    }

    // Avatar + account fields for the signed-in user.
    await fetchMe();

    if (Get.isRegistered<HomeHeroController>()) {
      await Get.find<HomeHeroController>().loadCycleData(jumpToToday: true);
    }

    for (final mode in [CalendarMode.tracker, CalendarMode.partner]) {
      final tag = CycleCalendarController.tagFor(mode);
      if (Get.isRegistered<CycleCalendarController>(tag: tag)) {
        await Get.find<CycleCalendarController>(
          tag: tag,
        ).loadFromServer(showLoading: false);
      }
    }

    if (Get.isRegistered<CycleOvulationController>()) {
      await Get.find<CycleOvulationController>().load();
    }

    if (Get.isRegistered<ProfileController>()) {
      // ignore: unawaited_futures
      Get.find<ProfileController>().load();
    }

    if (Get.isRegistered<PartnerController>()) {
      // ignore: unawaited_futures
      Get.find<PartnerController>().refreshStatus();
    }

    if (Get.isRegistered<SecretProfileController>()) {
      // ignore: unawaited_futures
      Get.find<SecretProfileController>().loadProfile();
    }
  }

  /// Ends the current session for guests and registered users.
  /// Revokes refresh tokens, clears local auth, rotates [deviceId] so the next
  /// open creates a fresh guest (registered account data stays on the server).
  Future<void> logout() async {
    if (isLoading.value) return;
    isLoading.value = true;
    AppLoading.show(
      isRegistered ? 'Signing out…' : 'Ending session…',
    );
    try {
      final refresh = PrefUtil.getString(PrefUtil.refreshToken);
      try {
        await _api.post(ApiEndPoints.authLogout, {
          if (refresh.isNotEmpty) 'refresh_token': refresh,
        });
      } catch (_) {
        // Best-effort: still clear local session if the network call fails.
      }

      try {
        if (_googleReady) {
          await GoogleSignIn.instance.signOut();
        }
      } catch (_) {}

      if (Get.isRegistered<NotificationService>()) {
        await Get.find<NotificationService>().logoutUser();
      }

      await PrefUtil.clearSession();
      await PrefUtil.setBool(PrefUtil.onboardingCompleted, false);
      await PrefUtil.setBool(PrefUtil.isPartnerMode, false);
      // New device_id → POST /auth/guest creates a new guest instead of
      // re-attaching to the previous (possibly registered) user.
      await PrefUtil.setString(PrefUtil.deviceId, _generateUuidV4());

      currentUserId.value = null;
      accountStatus.value = 'guest';
      userEmail.value = null;
      avatarUrl.value = null;

      if (Get.isRegistered<BookmarkController>()) {
        Get.find<BookmarkController>().clearLocal();
      }
      // Drop previous account's strip so it can't flash after splash.
      if (Get.isRegistered<HomeHeroController>()) {
        Get.find<HomeHeroController>().yearDays.clear();
        Get.find<HomeHeroController>().personalInsights.clear();
        Get.find<HomeHeroController>().selectedHeroOverride.value = null;
      }

      AppLoading.hide();
      Get.offAllNamed(AppPages.splash);
    } catch (e) {
      AppLoading.hide();
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
