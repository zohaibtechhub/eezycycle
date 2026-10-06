import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/drawer/drawer_controller.dart';
import '../controllers/onboarding_controller.dart';
import '../core/services/api_service.dart';
import '../core/services/notification_service.dart';
import '../core/utils/app_role.dart';
import '../core/utils/pref_util.dart';
import '../routes/app_pages.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static const String _tag = 'SplashController';
  static const Duration _bootstrapTimeout = Duration(seconds: 5);
  static const Duration _animDuration = Duration(milliseconds: 2800);
  static const Duration _postAnimHold = Duration(milliseconds: 250);

  late final AnimationController animController;

  late final Animation<double> scaleAnimation;
  late final Animation<double> fadeAnimation;
  late final Animation<double> pulseAnimation;
  late final Animation<double> taglineFadeAnimation;
  late final Animation<Offset> taglineSlideAnimation;

  String _nextRoute = AppPages.privacy;
  bool _didNavigate = false;

  @override
  void onInit() {
    super.onInit();
    log('onInit — starting splash bootstrap', name: _tag);
    _initAnimations();
    _initializeApp();
  }

  void _initAnimations() {
    animController = AnimationController(
      vsync: this,
      duration: _animDuration,
    );

    scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOutSine),
      ),
    );

    taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animController,
        curve: const Interval(0.45, 0.8, curve: Curves.easeIn),
      ),
    );

    taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animController,
            curve: const Interval(0.45, 0.8, curve: Curves.easeOutCubic),
          ),
        );
  }

  Future<void> _initializeApp() async {
    final sw = Stopwatch()..start();
    try {
      // Keep brand animation running to the end — never cut it off at 1.2s.
      final animFuture = animController.forward();
      final bootFuture = _bootstrapSession().timeout(
        _bootstrapTimeout,
        onTimeout: () {
          log(
            'bootstrap timed out after ${_bootstrapTimeout.inSeconds}s '
            '(API likely unreachable — check ApiClient baseUrl)',
            name: _tag,
          );
          _nextRoute = AppPages.privacy;
        },
      );

      await Future.wait<void>([animFuture, bootFuture]);
      // Brief hold on the finished frame so it doesn't feel abrupt.
      await Future.delayed(_postAnimHold);

      log(
        'init done in ${sw.elapsedMilliseconds}ms → $_nextRoute',
        name: _tag,
      );
    } catch (e, st) {
      log('init failed: $e', name: _tag, error: e, stackTrace: st);
      _nextRoute = AppPages.privacy;
      // If animation was interrupted, still try not to flash away instantly.
      if (animController.status != AnimationStatus.completed) {
        try {
          await animController.forward();
        } catch (_) {}
      }
    }
    _navigateToNext();
  }

  Future<void> _bootstrapSession() async {
    log('bootstrap start', name: _tag);

    if (!Get.isRegistered<AuthController>()) {
      log('AuthController missing — aborting to privacy', name: _tag);
      _nextRoute = AppPages.privacy;
      return;
    }

    final auth = Get.find<AuthController>();
    log('calling ensureGuestSession…', name: _tag);
    final ok = await auth.ensureGuestSession();
    log('ensureGuestSession → $ok', name: _tag);
    if (!ok) {
      _nextRoute = AppPages.privacy;
      return;
    }

    log('calling fetchMe…', name: _tag);
    final me = await auth.fetchMe();
    if (me == null) {
      log('fetchMe returned null → privacy', name: _tag);
      _nextRoute = AppPages.privacy;
      return;
    }
    log('fetchMe ok (keys=${me.keys.toList()})', name: _tag);

    final profile = me['profile'] is Map
        ? Map<String, dynamic>.from(me['profile'] as Map)
        : <String, dynamic>{};
    final consents = me['consents'] is List ? me['consents'] as List : const [];
    final goals = me['goals'] is List ? me['goals'] as List : const [];

    // SECURITY: partner path without a linked code must never reach home,
    // even if a bad backfill set onboarding_completed_at / local prefs.
    if (AppRole.needsPartnerCode(profile)) {
      await _resetIncompletePartnerGate(profile);
      _nextRoute = AppPages.partnerCodeEntry;
      log('route: partnerCodeEntry (blocked — no linked code)', name: _tag);
      return;
    }

    final completedAt = profile['onboarding_completed_at'];
    final serverDone =
        completedAt != null && completedAt.toString().isNotEmpty;

    // Partner with a linked code is only "home-ready" after real completion.
    final isPartnerLinked = AppRole.isPartnerFromProfile(profile);
    if (serverDone && isPartnerLinked) {
      await PrefUtil.setBool(PrefUtil.onboardingCompleted, true);
      await AppRole.persistFromProfile(profile);
      _applyDrawerMode(profile);
      _nextRoute = AppRole.homeRoute();
      log('route: home (partner completed)', name: _tag);
      return;
    }

    if (serverDone && !isPartnerLinked) {
      await PrefUtil.setBool(PrefUtil.onboardingCompleted, true);
      await AppRole.persistFromProfile(profile);
      _applyDrawerMode(profile);
      _nextRoute = AppRole.homeRoute();
      log('route: home (server onboarding_completed_at)', name: _tag);
      return;
    }

    final localDone = PrefUtil.getBool(PrefUtil.onboardingCompleted);
    if (localDone) {
      log(
        'local onboardingCompleted=true but server incomplete — continue',
        name: _tag,
      );
    }

    // Partner linked code but didn't finish Q&A
    if (isPartnerLinked && _hasRequiredConsents(consents)) {
      if (Get.isRegistered<OnboardingController>()) {
        Get.find<OnboardingController>().startOnboardingFlow(
          OnboardingFlow.partner,
        );
      }
      await PrefUtil.setBool(PrefUtil.onboardingCompleted, false);
      _nextRoute = AppPages.onboarding;
      log('route: onboarding (partner mid-flow)', name: _tag);
      return;
    }

    // Forms were saved but complete flag never stuck — treat as done
    // (self path only; partner never backfills without a linked code)
    if (_looksOnboardingDone(profile, goals)) {
      await PrefUtil.setBool(PrefUtil.onboardingCompleted, true);
      await _backfillOnboardingComplete(profile, goals);
      await AppRole.persistFromProfile(profile);
      _applyDrawerMode(profile);
      _nextRoute = AppRole.homeRoute();
      log('route: home (looksOnboardingDone backfill)', name: _tag);
      return;
    }

    // Already accepted privacy — don't show policy again
    if (_hasRequiredConsents(consents)) {
      _nextRoute = AppPages.usage;
      log('route: usage (consents already accepted)', name: _tag);
      return;
    }

    _nextRoute = AppPages.privacy;
    log('route: privacy (default)', name: _tag);
  }

  /// Clears false "done" state so failed code entry cannot unlock the app.
  Future<void> _resetIncompletePartnerGate(
    Map<String, dynamic> profile,
  ) async {
    await PrefUtil.setBool(PrefUtil.onboardingCompleted, false);
    await PrefUtil.setBool(PrefUtil.isPartnerMode, false);

    final completedAt = profile['onboarding_completed_at'];
    final mode = profile['experience_mode']?.toString();
    final needsServerClear =
        (completedAt != null && completedAt.toString().isNotEmpty) ||
        mode == 'partner';

    if (!needsServerClear) return;

    // Fire-and-forget so a slow PATCH cannot stall / freeze splash.
    unawaited(() async {
      try {
        final api = ApiClient();
        await api.patch(ApiEndPoints.meProfile, {
          'onboarding_completed_at': null,
          'experience_mode': null,
          'usage_path': 'partner',
          'partner_code_entered': null,
        });
      } catch (_) {}
    }());
  }

  bool _hasRequiredConsents(List consents) {
    final accepted = <String>{};
    for (final item in consents) {
      if (item is! Map) continue;
      if (item['accepted'] == true) {
        accepted.add(item['consent_type']?.toString() ?? '');
      }
    }
    return accepted.contains('terms') && accepted.contains('health_data');
  }

  /// Enough profile data that the user clearly finished the main forms.
  /// Never treat "chose partner path" alone as finished.
  bool _looksOnboardingDone(Map<String, dynamic> profile, List goals) {
    final usage = profile['usage_path']?.toString();
    final mode = profile['experience_mode']?.toString();

    // Partner must link a code + finish onboardingComplete — no shortcut.
    if (usage == 'partner' || mode == 'partner') return false;

    final hasUsage = usage != null && usage.isNotEmpty;
    final hasMode = mode != null && mode.isNotEmpty;
    final hasBirth = profile['birth_year'] != null;
    final hasGoals = goals.isNotEmpty;
    final hasBody =
        profile['height_cm'] != null && profile['weight_kg'] != null;

    return hasUsage && hasMode && (hasBirth || hasGoals) && hasBody;
  }

  Future<void> _backfillOnboardingComplete(
    Map<String, dynamic> profile,
    List goals,
  ) async {
    try {
      final api = ApiClient();
      await api.post(ApiEndPoints.onboardingComplete, {
        if (profile['experience_mode'] != null)
          'experience_mode': profile['experience_mode'],
        if (profile['usage_path'] != null) 'usage_path': profile['usage_path'],
        if (profile['discovery_source'] != null)
          'discovery_source': profile['discovery_source'],
        if (profile['birth_year'] != null) 'birth_year': profile['birth_year'],
        if (profile['height_cm'] != null) 'height_cm': profile['height_cm'],
        if (profile['weight_kg'] != null) 'weight_kg': profile['weight_kg'],
        if (profile['is_metric'] != null) 'is_metric': profile['is_metric'],
        if (goals.isNotEmpty) 'goals': goals,
      });
    } catch (_) {
      // Local flag already set — server flag can catch up next time
    }
  }

  void _applyDrawerMode(Map<String, dynamic> profile) {
    final mode = profile['experience_mode']?.toString();
    if (mode == null || mode.isEmpty) return;
    if (!Get.isRegistered<DrawerViewController>()) return;
    Get.find<DrawerViewController>().applyServerMode(mode);
  }

  void _navigateToNext() {
    if (_didNavigate) {
      log('navigate skipped (already navigated)', name: _tag);
      return;
    }
    _didNavigate = true;
    log('navigating → $_nextRoute', name: _tag);
    Get.offNamed(_nextRoute);

    // Returning users who never hit a reminder step still need the OS prompt once.
    final goingHome =
        _nextRoute == AppPages.mainBottomNavView ||
        _nextRoute == AppPages.home ||
        _nextRoute == AppPages.partnerHome;
    if (goingHome && Get.isRegistered<NotificationService>()) {
      // ignore: discarded_futures
      Get.find<NotificationService>().promptIfNeeded(
        delay: const Duration(milliseconds: 1200),
      );
    }
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}
