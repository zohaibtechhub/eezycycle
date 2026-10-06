import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/auth_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/pref_util.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/container/what_like_container.dart';
import 'package:period_ovulation_tracker/widgets/text/custom_rich_text.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/bottom_nav/bottom_nav_controller.dart';
import '../../controllers/drawer/drawer_controller.dart';
import '../../controllers/relationship/partner_code_controller.dart';
import '../../widgets/common/drawer_tile.dart';
import '../../widgets/common/user_avatar.dart';
import '../../widgets/header/drawer_header.dart';
import '../basic_need/legal_document_view.dart';

class ExperienceModeModel {
  final String title;
  final String image;

  const ExperienceModeModel({required this.title, required this.image});
}

class DrawerView extends StatelessWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrawerViewController>();
    final auth = Get.find<AuthController>();
    final isPartner = PrefUtil.getBool(PrefUtil.isPartnerMode);

    if (isPartner && !Get.isRegistered<PartnerController>()) {
      Get.put(PartnerController());
    }

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CustomDrawerHeader(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  Obx(
                    () => _buildUserProfileCard(
                      context,
                      isPartner: isPartner,
                      isRegistered: auth.isRegistered,
                      email: auth.userEmail.value,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Women only: experience mode switcher
                  if (!isPartner) ...[
                    _buildSectionHeader('Your EezyCycle Experience'),
                    _buildExperienceGrid(controller, context),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (auth.isRegistered) {
                        return _buildSignedInBanner(context, auth);
                      }
                      return _buildEmailQuickActionBanner(context);
                    }),
                    const SizedBox(height: 20),
                  ],

                  _buildPartnerStatusCard(context, isPartner: isPartner),
                  const SizedBox(height: 24),

                  // Women: cycle graphs. Partners: read-only calendar only.
                  if (!isPartner) ...[
                    _buildSectionHeader('Graphs & reports'),
                    _buildSettingsContainer(context, [
                      DrawerTile(
                        icon: Icons.insert_chart_outlined_rounded,
                        iconBg: const Color(0xFFFCE4EC),
                        iconColor: AppColors.accent,
                        title: 'Cycle and ovulation',
                        subtitle: 'View history and trends',
                        onTap: () {
                          Get.toNamed(AppPages.cycleOvulation);
                        },
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ] else ...[
                    _buildSectionHeader('Shared cycle'),
                    _buildSettingsContainer(context, [
                      DrawerTile(
                        icon: Icons.calendar_month_rounded,
                        iconBg: const Color(0xFFFCE4EC),
                        iconColor: AppColors.accent,
                        title: "Her cycle calendar",
                        subtitle: 'Read-only phase predictions',
                        onTap: () {
                          Get.toNamed(AppPages.calenderView);
                        },
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  _buildSectionHeader('Preferences'),
                  _buildSettingsContainer(context, [
                    DrawerTile(
                      icon: Icons.bookmark_outline_rounded,
                      iconBg: const Color(0xFFFFF3E0),
                      iconColor: AppColors.warning,
                      title: 'Saved articles',
                      subtitle: 'Your bookmarked insights',
                      onTap: () {
                        Get.toNamed(AppPages.bookmarks);
                      },
                    ),
                    _buildDivider(),
                    DrawerTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'Daily Relationship Tips',
                      subtitle: 'Actionable daily advice',
                      onTap: () {
                        Get.toNamed(AppPages.dailyTipsView);
                      },
                    ),
                    // User Privacy — guests and registered (JWT session required)
                    if (!isPartner) ...[
                      _buildDivider(),
                      DrawerTile(
                        icon: Icons.lock_outline_rounded,
                        iconBg: const Color(0xFFEDE7F6),
                        iconColor: AppColors.accent,
                        title: 'User Privacy',
                        subtitle: 'Private community space',
                        onTap: () {
                          if (Get.isRegistered<BottomNavController>()) {
                            Get.find<BottomNavController>().changeIndex(1);
                          }
                          Get.until(
                            (route) =>
                                route.settings.name ==
                                    AppPages.mainBottomNavView ||
                                route.isFirst,
                          );
                          if (Get.currentRoute != AppPages.mainBottomNavView) {
                            Get.offNamed(AppPages.mainBottomNavView);
                            if (Get.isRegistered<BottomNavController>()) {
                              Get.find<BottomNavController>().changeIndex(1);
                            }
                          }
                          log('Click User Privacy');
                        },
                      ),
                    ],
                  ]),

                  const SizedBox(height: 20),

                  _buildSectionHeader('About & Help'),
                  _buildSettingsContainer(context, [
                    DrawerTile(
                      icon: Icons.help_outline_rounded,
                      iconBg: const Color(0xFFE3F2FD),
                      iconColor: AppColors.info,
                      title: 'Help & FAQ',
                      onTap: () {
                        Get.toNamed(AppPages.helpFaq);
                      },
                    ),
                    _buildDivider(),
                    DrawerTile(
                      icon: Icons.star_outline_rounded,
                      iconBg: const Color(0xFFFFF8E1),
                      iconColor: AppColors.warning,
                      title: 'Rate the App',
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Logout — available for registered and guest users
                  _buildSectionHeader('Account'),
                  _buildSettingsContainer(context, [
                    Obx(
                      () => DrawerTile(
                        icon: Icons.logout_rounded,
                        iconBg: const Color(0xFFFFEBEE),
                        iconColor: AppColors.error,
                        title: 'Log out',
                        subtitle: auth.isRegistered
                            ? 'Sign out of your account'
                            : 'End guest session and start fresh',
                        onTap: () => _confirmLogout(context, auth),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 28),

                  Center(
                    child: CustomRichText(
                      textAlign: TextAlign.center,
                      firstPart: 'Read our ',
                      firstPartStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      highlightedPart: 'Privacy Policy',
                      highlightedPartStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                      onHighlightedPartTap: () {
                        Get.to(
                          () => const LegalDocumentView(
                            type: LegalDocType.privacyPolicy,
                          ),
                        );
                      },
                      middlePart: ' and ',
                      middlePartStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      secondHighlightedPart: 'Terms of Use',
                      secondHighlightedPartStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                      onSecondHighlightedPartTap: () {
                        Get.to(
                          () => const LegalDocumentView(
                            type: LegalDocType.termsOfUse,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Center(
                    child: TextWidget(
                      title: 'Version 1.0.0',
                      fontSize: 11,
                      textColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    final isRegistered = auth.isRegistered;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              TextWidget(
                title: isRegistered ? 'Log out?' : 'End guest session?',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 10),
              TextWidget(
                title: isRegistered
                    ? 'You can sign back in anytime. Your account data stays safe on the server.'
                    : 'This ends your current session and starts a fresh guest experience on this device.',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                textColor: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        auth.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Log out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerStatusCard(
    BuildContext context, {
    required bool isPartner,
  }) {
    if (isPartner) {
      final partnerCtrl = Get.find<PartnerController>();
      return Obx(() {
        final linked = partnerCtrl.isConnected.value;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.softGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      title: 'Linked to her cycle',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      textColor: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 2),
                    TextWidget(
                      title: linked ? 'Active Connection' : 'Not linked',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextWidget(
                  title: linked ? 'Linked' : 'Pending',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  textColor: linked ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
        );
      });
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.softGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title: 'Partner Space',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.textSecondary,
                ),
                SizedBox(height: 2),
                TextWidget(
                  title: 'Invite from Partner tab',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(
    BuildContext context, {
    required bool isPartner,
    required bool isRegistered,
    String? email,
  }) {
    final subtitle = isPartner
        ? 'Supportive insights only'
        : isRegistered
        ? (email?.isNotEmpty == true ? email! : 'Signed in account')
        : 'Personal health metrics';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: isPartner
                ? (Get.isRegistered<PartnerController>()
                    ? Obx(() {
                        final url =
                            Get.find<PartnerController>().ownerAvatarUrl.value;
                        final cached =
                            PrefUtil.getString(PrefUtil.partnerOwnerAvatarUrl);
                        return UserAvatar(
                          imageUrl: url ?? (cached.isEmpty ? null : cached),
                          size: 52,
                        );
                      })
                    : UserAvatar(
                        imageUrl: () {
                          final cached = PrefUtil.getString(
                            PrefUtil.partnerOwnerAvatarUrl,
                          );
                          return cached.isEmpty ? null : cached;
                        }(),
                        size: 52,
                      ))
                : const UserAvatar(useAuthAvatar: true, size: 52),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title: isPartner ? 'Partner profile' : 'My Profile',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.textPrimary,
                ),
                const SizedBox(height: 2),
                TextWidget(
                  title: subtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          if (!isPartner)
            GestureDetector(
              onTap: () {
                Get.toNamed(AppPages.profileView);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: const TextWidget(
                  title: 'View profile',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSignedInBanner(BuildContext context, AuthController auth) {
    final email = auth.userEmail.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextWidget(
                  title: 'Account secured',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  textColor: AppColors.success,
                ),
                const SizedBox(height: 2),
                TextWidget(
                  title: email?.isNotEmpty == true
                      ? email!
                      : 'Your cycle data is linked to this account.',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailQuickActionBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 16,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              const TextWidget(
                title: 'One last quick action',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                textColor: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const TextWidget(
            title: 'Add your email to finish creating your account.',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            textColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          CustomButton(
            title: 'Continue',
            onTap: () {
              Get.toNamed(AppPages.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceGrid(
    DrawerViewController controller,
    BuildContext context,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: controller.experienceModes.length,
      itemBuilder: (context, index) {
        final mode = controller.experienceModes[index];

        return Obx(() {
          final isSelected = controller.selectedExperience.value == mode.title;

          return WhatLikeContainer(
            image: mode.image,
            title: mode.title,
            isSelected: isSelected,
            showCheckIcon: true,
            onTap: () => controller.onRequestModeChange(context, mode.title),
          );
        });
      },
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: TextWidget(
        title: title,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        textColor: AppColors.textSecondary,
        textAlign: TextAlign.left,
      ),
    );
  }

  static Widget _buildSettingsContainer(
    BuildContext context,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(children: children),
    );
  }

  static Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 58,
      endIndent: 16,
      color: AppColors.primary.withValues(alpha: 0.06),
    );
  }
}
