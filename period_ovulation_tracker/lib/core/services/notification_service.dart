import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/onesignal_config.dart';
import '../utils/pref_util.dart';
import 'api_service.dart';
import '../../routes/app_pages.dart';

/// Push (OneSignal) + local notification setup for EezyCycle.
///
/// Registers the subscription id with `PATCH /me/push` after login / permission.
class NotificationService extends GetxService {
  static const String _tag = 'NotificationService';

  static const String channelCycleReminders = 'cycle_reminders';
  static const String channelDailyTips = 'daily_tips';
  static const String channelPartnerTips = 'partner_tips';
  static const String channelCommunity = 'community';

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _oneSignalReady = false;

  String? get subscriptionId {
    final cached = PrefUtil.getString(PrefUtil.onesignalSubscriptionId);
    return cached.isEmpty ? null : cached;
  }

  Future<NotificationService> init() async {
    if (_initialized) return this;

    await _initLocalNotifications();
    await _initOneSignal();

    _initialized = true;
    return this;
  }

  Future<void> _initLocalNotifications() async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      log('timezone fallback UTC: $e', name: _tag);
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelCycleReminders,
          'Cycle reminders',
          description: 'Period, fertile window, and ovulation reminders',
          importance: Importance.high,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelDailyTips,
          'Daily tips',
          description: 'Daily wellness and cycle tips',
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelPartnerTips,
          'Partner tips',
          description: 'High-level partner support tips',
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelCommunity,
          'Secret chat',
          description: 'Community and secret chat alerts',
          importance: Importance.high,
        ),
      );
    }
  }

  Future<void> _initOneSignal() async {
    final appId = kOneSignalAppId.trim();
    if (appId.isEmpty) {
      log(
        'ONESIGNAL_APP_ID is empty — push init skipped. '
        'Set it in onesignal_config.dart or via --dart-define.',
        name: _tag,
      );
      return;
    }

    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }

    OneSignal.initialize(appId);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      // Show the notification while the app is open.
      event.notification.display();
    });

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      _handlePayload(data);
    });

    OneSignal.User.pushSubscription.addObserver((state) {
      final id = state.current.id;
      if (id != null && id.isNotEmpty) {
        PrefUtil.setString(PrefUtil.onesignalSubscriptionId, id);
        // ignore: discarded_futures
        syncSubscriptionToBackend();
      }
    });

    final existing = OneSignal.User.pushSubscription.id;
    if (existing != null && existing.isNotEmpty) {
      await PrefUtil.setString(PrefUtil.onesignalSubscriptionId, existing);
    }

    _oneSignalReady = true;
    log('OneSignal initialized', name: _tag);
  }

  /// Prompt for OS notification permission (iOS + Android 13+).
  ///
  /// Asks the native OS first (more reliable on Android 13+), then OneSignal.
  Future<bool> requestPushPermission({bool fallbackToSettings = true}) async {
    log('requestPushPermission (oneSignalReady=$_oneSignalReady)', name: _tag);

    var granted = false;

    // 1) Native platform prompt (works even if OneSignal init lagged)
    if (Platform.isAndroid) {
      final android = _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      granted = await android?.requestNotificationsPermission() ?? false;
      log('Android POST_NOTIFICATIONS → $granted', name: _tag);
    } else if (Platform.isIOS) {
      final ios = _local
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      granted =
          await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      log('iOS notification permission → $granted', name: _tag);
    }

    // 2) OneSignal (registers for push + may show prompt if still needed)
    if (_oneSignalReady) {
      try {
        final canRequest = await OneSignal.Notifications.canRequest();
        log('OneSignal.canRequest → $canRequest', name: _tag);
        if (canRequest || !granted) {
          final osGranted = await OneSignal.Notifications.requestPermission(
            fallbackToSettings,
          );
          granted = granted || osGranted;
          log('OneSignal.requestPermission → $osGranted', name: _tag);
        }
      } catch (e) {
        log('OneSignal.requestPermission error: $e', name: _tag);
      }
    }

    await PrefUtil.setBool(PrefUtil.pushPermissionAsked, true);
    if (granted) {
      await syncSubscriptionToBackend(enabled: true);
    }
    return granted;
  }

  /// Ask once if the OS can still show a permission dialog.
  Future<bool> promptIfNeeded({Duration delay = Duration.zero}) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (_oneSignalReady) {
      try {
        if (OneSignal.Notifications.permission) {
          await PrefUtil.setBool(PrefUtil.pushPermissionAsked, true);
          await syncSubscriptionToBackend(enabled: true);
          log('promptIfNeeded: already granted', name: _tag);
          return true;
        }
        final canRequest = await OneSignal.Notifications.canRequest();
        if (!canRequest) {
          await PrefUtil.setBool(PrefUtil.pushPermissionAsked, true);
          log('promptIfNeeded: canRequest=false (denied earlier)', name: _tag);
          return false;
        }
        // OS can still show the dialog — ask even if our local flag was set.
        return requestPushPermission();
      } catch (e) {
        log('promptIfNeeded OneSignal check error: $e', name: _tag);
      }
    }

    if (PrefUtil.getBool(PrefUtil.pushPermissionAsked)) {
      log('promptIfNeeded skipped (already asked, OneSignal not ready)', name: _tag);
      return false;
    }

    return requestPushPermission();
  }

  /// Link this device to the backend user id (OneSignal External ID).
  Future<void> loginUser(int? userId) async {
    if (!_oneSignalReady || userId == null || userId <= 0) return;
    try {
      await OneSignal.login(userId.toString());
      log('OneSignal.login($userId)', name: _tag);
      await syncSubscriptionToBackend();
    } catch (e) {
      log('OneSignal.login failed: $e', name: _tag);
    }
  }

  /// Register / refresh OneSignal subscription id with `PATCH /me/push`.
  Future<void> syncSubscriptionToBackend({bool enabled = true}) async {
    final token = PrefUtil.getString(PrefUtil.token);
    if (token.isEmpty) return;

    var subId = OneSignal.User.pushSubscription.id;
    if (subId == null || subId.isEmpty) {
      final cached = PrefUtil.getString(PrefUtil.onesignalSubscriptionId);
      if (cached.isEmpty) return;
      subId = cached;
    }

    await PrefUtil.setString(PrefUtil.onesignalSubscriptionId, subId);

    try {
      final api = ApiClient();
      await api.patch(ApiEndPoints.mePush, {
        'onesignal_subscription_id': subId,
        'platform': Platform.isIOS
            ? 'ios'
            : Platform.isAndroid
            ? 'android'
            : 'other',
        'enabled': enabled,
      });
      await PrefUtil.setString(PrefUtil.onesignalSyncedSubscriptionId, subId);
      log('PATCH /me/push ok ($subId)', name: _tag);
    } catch (e) {
      log('PATCH /me/push failed: $e', name: _tag);
    }
  }

  /// Home / main shell: link External ID + save subscription if missing.
  /// Safe for existing users who never logged out after push was added.
  Future<void> ensurePushLinkedForCurrentUser() async {
    if (!_oneSignalReady) {
      log('ensurePushLinked skipped (OneSignal not ready)', name: _tag);
      return;
    }

    final token = PrefUtil.getString(PrefUtil.token);
    if (token.isEmpty) return;

    final userId = PrefUtil.getInt(PrefUtil.userId);
    if (userId <= 0) return;

    try {
      await OneSignal.login(userId.toString());
      log('ensurePushLinked OneSignal.login($userId)', name: _tag);
    } catch (e) {
      log('ensurePushLinked login failed: $e', name: _tag);
    }

    // Wait briefly for subscription id if permission already granted.
    String subId = OneSignal.User.pushSubscription.id ?? '';
    if (subId.isEmpty) {
      subId = PrefUtil.getString(PrefUtil.onesignalSubscriptionId);
    }
    if (subId.isEmpty) {
      // Permission may still be pending — try OS prompt once if allowed.
      await promptIfNeeded();
      subId = OneSignal.User.pushSubscription.id ??
          PrefUtil.getString(PrefUtil.onesignalSubscriptionId);
    }
    if (subId.isEmpty) {
      log('ensurePushLinked: no subscription id yet', name: _tag);
      return;
    }

    final alreadySynced =
        PrefUtil.getString(PrefUtil.onesignalSyncedSubscriptionId);
    if (alreadySynced == subId) {
      log('ensurePushLinked: already saved ($subId)', name: _tag);
      return;
    }

    await syncSubscriptionToBackend(enabled: true);
  }

  /// Clear External ID on logout / end guest session.
  Future<void> logoutUser() async {
    if (!_oneSignalReady) return;
    try {
      await OneSignal.logout();
      await PrefUtil.remove(PrefUtil.onesignalSubscriptionId);
      log('OneSignal.logout()', name: _tag);
    } catch (e) {
      log('OneSignal.logout failed: $e', name: _tag);
    }
  }

  /// Optional same-device near-term reminder (complements OneSignal remote).
  Future<void> scheduleLocalReminder({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String channelId = channelCycleReminders,
    String? payload,
  }) async {
    if (when.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _channelName(channelId),
      channelDescription: 'EezyCycle reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _local.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelLocalReminder(int id) => _local.cancel(id: id);

  Future<void> cancelAllLocalReminders() => _local.cancelAll();

  String _channelName(String id) {
    switch (id) {
      case channelDailyTips:
        return 'Daily tips';
      case channelPartnerTips:
        return 'Partner tips';
      case channelCommunity:
        return 'Secret chat';
      case channelCycleReminders:
      default:
        return 'Cycle reminders';
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _handlePayload(decoded);
      } else if (decoded is Map) {
        _handlePayload(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      _navigateDeepLink(raw);
    }
  }

  void _handlePayload(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return;

    final deepLink =
        data['deep_link']?.toString() ?? data['deepLink']?.toString();
    if (deepLink != null && deepLink.isNotEmpty) {
      _navigateDeepLink(deepLink);
      return;
    }

    final type = data['notification_type']?.toString() ?? '';
    switch (type) {
      case 'period_soon':
      case 'period_expected':
      case 'log_period_nudge':
        Get.toNamed(AppPages.calenderView);
      case 'daily_tip':
        Get.toNamed(AppPages.dailyTipsView);
      case 'secret_chat_reply':
        Get.toNamed(AppPages.secretChat);
      case 'fertile_start':
      case 'ovulation_day':
      case 'pregnancy_week':
      case 'ttc_test_window':
      case 'partner_phase_tip':
      case 'partner_period_soon':
      case 'welcome':
      default:
        Get.offNamedUntil(AppPages.mainBottomNavView, (route) => false);
    }
  }

  void _navigateDeepLink(String link) {
    final uri = Uri.tryParse(link);
    final path = (uri?.host.isNotEmpty == true ? uri!.host : uri?.path ?? link)
        .replaceAll('/', '')
        .toLowerCase();

    switch (path) {
      case 'calendar':
      case 'calender':
        Get.toNamed(AppPages.calenderView);
      case 'articles':
      case 'tips':
        Get.toNamed(AppPages.dailyTipsView);
      case 'secretchat':
      case 'community':
        Get.toNamed(AppPages.secretChat);
      case 'home':
      case 'log':
      default:
        Get.offNamedUntil(AppPages.mainBottomNavView, (route) => false);
    }
  }
}
