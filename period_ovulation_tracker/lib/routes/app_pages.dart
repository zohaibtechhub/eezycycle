import 'package:get/get.dart';
import 'package:period_ovulation_tracker/views/article/article_view.dart';
import 'package:period_ovulation_tracker/views/article/bookmarks_view.dart';
import 'package:period_ovulation_tracker/views/auth/forgot_password_email_view.dart';
import 'package:period_ovulation_tracker/views/auth/forgot_password_otp_view.dart';
import 'package:period_ovulation_tracker/views/auth/forgot_password_reset_view.dart';
import 'package:period_ovulation_tracker/views/auth/login_view.dart';
import 'package:period_ovulation_tracker/views/auth/profile_view.dart';
import 'package:period_ovulation_tracker/views/auth/signup_view.dart';
import 'package:period_ovulation_tracker/views/basic_need/faq.dart';
import 'package:period_ovulation_tracker/views/bottom_nav/bottom_nav_view.dart';
import 'package:period_ovulation_tracker/views/daily_relationship_tips/daily_tip_detail_view.dart';
import 'package:period_ovulation_tracker/views/daily_relationship_tips/daily_tips_view.dart';
import 'package:period_ovulation_tracker/views/drawer/drawer_view.dart';
import 'package:period_ovulation_tracker/views/graph/cycle_ovulation_view.dart';
import 'package:period_ovulation_tracker/views/home/calender_view.dart';
import 'package:period_ovulation_tracker/views/home/home_view.dart';
import 'package:period_ovulation_tracker/views/home/partner_home_view.dart';
import 'package:period_ovulation_tracker/views/insight/insight_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/birth_year_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/commit_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/comparison_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/onboarding_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/partner_code_entry_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/pregnancy_activation_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/pregnancy_mode.dart';
import 'package:period_ovulation_tracker/views/onboarding/privacy_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/progress_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/usage_view.dart';
import 'package:period_ovulation_tracker/views/onboarding/what_like_view.dart';
import 'package:period_ovulation_tracker/views/secret_chats/secret_chat_view.dart';
import 'package:period_ovulation_tracker/views/secret_chats/edit_profile_view.dart';
import 'package:period_ovulation_tracker/views/splash/splash_view.dart';

import '../views/onboarding/discovery_view.dart';
// import 'package:period_ovulation_tracker/views/auth/login_view.dart';
// import 'package:period_ovulation_tracker/views/product/product_list_view.dart';

class AppPages {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String mainBottomNavView = '/mainBottomNavView';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgotPassword';
  static const String forgotPasswordOtp = '/forgotPasswordOtp';
  static const String forgotPasswordReset = '/forgotPasswordReset';
  static const String privacy = '/privacy';
  static const String usage = '/usage';
  static const String partnerCodeEntry = '/partnerCodeEntry';
  static const String discovery = '/discovery';
  static const String birthYear = '/birthYear';
  static const String whatLike = '/whatLike';
  static const String progress = '/progress';
  static const String comparison = '/comparison';
  static const String commit = '/commit';
  static const String home = '/home';
  static const String drawer = '/drawer';
  static const String calenderView = '/calenderView';
  static const String articleView = '/articleView';
  static const String bookmarks = '/bookmarks';
  static const String insightView = '/insightView';
  static const String dailyTipsView = '/dailyTipsView';
  static const String dailyTipDetail = '/dailyTipDetail';
  static const String helpFaq = '/helpFaq';
  static const String partnerHome = '/partnerHome';
  static const String profileView = '/profileView';
  static const String pregnancyModeView = '/pregnancyModeView';
  static const String pregnancyActivation = '/pregnancyActivation';
  static const String cycleOvulation = '/cycleOvulation';
  static const String secretChat = '/secretChat';
  static const String editSecretProfile = '/editSecretProfile';

  static final routes = [
    GetPage(name: splash, page: () => SplashView()),
    GetPage(name: onboarding, page: () => OnboardingView()),
    GetPage(name: mainBottomNavView, page: () => MainBottomNavView()),
    GetPage(name: login, page: () => LoginView()),
    GetPage(name: signup, page: () => SignupView()),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordEmailView(),
    ),
    GetPage(
      name: forgotPasswordOtp,
      page: () => const ForgotPasswordOtpView(),
    ),
    GetPage(
      name: forgotPasswordReset,
      page: () => const ForgotPasswordResetView(),
    ),

    GetPage(name: privacy, page: () => PrivacyView()),
    GetPage(name: usage, page: () => UsageView()),
    GetPage(name: partnerCodeEntry, page: () => const PartnerCodeEntryView()),
    GetPage(name: discovery, page: () => DiscoveryView()),
    GetPage(name: birthYear, page: () => BirthYearView()),
    GetPage(name: whatLike, page: () => WhatLikeView()),
    GetPage(name: splash, page: () => SplashView()),
    GetPage(name: progress, page: () => ProgressView()),
    GetPage(name: comparison, page: () => ComparisonView()),
    GetPage(name: commit, page: () => CommitView()),
    GetPage(name: home, page: () => HomeView()),
    GetPage(name: drawer, page: () => DrawerView()),
    GetPage(name: calenderView, page: () => CalenderView()),
    GetPage(name: insightView, page: () => InsightView()),
    GetPage(name: articleView, page: () => ArticleView()),
    GetPage(name: bookmarks, page: () => const BookmarksView()),
    GetPage(name: dailyTipsView, page: () => const DailyTipsView()),
    GetPage(name: dailyTipDetail, page: () => const DailyTipDetailView()),
    GetPage(name: helpFaq, page: () => HelpFaqView()),
    GetPage(name: partnerHome, page: () => PartnerHomeView()),
    GetPage(name: profileView, page: () => ProfileView()),
    GetPage(name: pregnancyModeView, page: () => PregnancyModeView()),
    GetPage(name: pregnancyActivation, page: () => PregnancyActivationView()),
    GetPage(name: cycleOvulation, page: () => CycleOvulationView()),
    GetPage(name: secretChat, page: () => SecretChatView()),
    GetPage(name: editSecretProfile, page: () => const EditProfileView()),
    // GetPage(name: '/products', page: () => ProductListView()),
  ];
}
