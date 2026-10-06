import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefUtil {
  static const String token = 'token';
  static const String refreshToken = 'refresh_token';
  static const String deviceId = 'device_id';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String accountStatus = 'account_status';
  static const String userId = 'user_id';
  /// True when this device is the male partner experience (not the cycle owner).
  static const String isPartnerMode = 'is_partner_mode';
  static const String experienceMode = 'experience_mode';
  static const String avatarUrl = 'avatar_url';
  /// Linked woman's avatar when this device is in partner mode.
  static const String partnerOwnerAvatarUrl = 'partner_owner_avatar_url';
  /// Dismissed pregnancy week tip ids (string list).
  static const String pregnancySeenTipIds = 'pregnancy_seen_tip_ids';
  /// Last yyyy-MM-dd a pregnancy tip was auto-shown on home open.
  static const String pregnancyTipLastHomeDay = 'pregnancy_tip_last_home_day';
  /// OneSignal push subscription id (cached until PATCH /me/push exists).
  static const String onesignalSubscriptionId = 'onesignal_subscription_id';
  /// Last subscription id successfully saved via PATCH /me/push.
  static const String onesignalSyncedSubscriptionId =
      'onesignal_synced_subscription_id';
  /// Whether we already prompted for notification permission.
  static const String pushPermissionAsked = 'push_permission_asked';

  static Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  static SharedPreferences? _prefs;

  /// Call from [main] before runApp.
  static Future<SharedPreferences?> init() async {
    _prefs = await _instance;
    return _prefs;
  }

  static Future<bool> setBool(String key, bool value) async =>
      await _prefs!.setBool(key, value);
  static bool getBool(String key) => _prefs!.getBool(key) ?? false;

  static Future<bool> setString(String key, String value) async =>
      await _prefs!.setString(key, value);
  static String getString(String key) => _prefs!.getString(key) ?? '';
  static Future<bool> setDouble(String key, double value) async =>
      await _prefs!.setDouble(key, value);

  static double getDouble(String key) => _prefs!.getDouble(key) ?? 0.0;

  static Future<bool> setInt(String key, int value) async =>
      await _prefs!.setInt(key, value);
  static int getInt(String key) => _prefs!.getInt(key) ?? 0;

  static List<String> getStringList(String key) =>
      _prefs?.getStringList(key) ?? const [];

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs!.setStringList(key, value);

  static List<Map<String, dynamic>> getList(String key) {
    List<String>? jsonStringList = _prefs?.getStringList(key);
    if (jsonStringList == null) {
      return [];
    } else {
      List<Map<String, dynamic>> decodedList = jsonStringList
          .map((jsonString) => json.decode(jsonString) as Map<String, dynamic>)
          .toList();
      return decodedList;
    }
  }

  static Future<bool> setList(String key, List<Map<String, dynamic>> value) {
    List<String> jsonStringList = value
        .map((item) => json.encode(item))
        .toList();
    return _prefs!.setStringList(key, jsonStringList);
  }

  static Future<bool> remove(String key) async => await _prefs!.remove(key);

  static Future<void> clearSession() async {
    await remove(token);
    await remove(refreshToken);
    await remove(accountStatus);
    await remove(userId);
    await remove(avatarUrl);
    await remove(partnerOwnerAvatarUrl);
    await remove(onesignalSubscriptionId);
    await remove(onesignalSyncedSubscriptionId);
  }
}
