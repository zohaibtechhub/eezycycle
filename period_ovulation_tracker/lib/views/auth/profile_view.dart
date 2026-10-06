import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:period_ovulation_tracker/controllers/profile_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/widgets/common/app_shimmer.dart';
import 'package:period_ovulation_tracker/widgets/common/user_avatar.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surface,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: context.onSurface,
            ),
          ),
        ),
        title: const TextWidget(
          title: 'My Profile',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.load,
            icon: Icon(
              Icons.refresh_rounded,
              color: context.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasLoaded.value) {
          return const ProfileShimmer();
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColors.accent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(controller),
                const SizedBox(height: 28),
                _sectionTitle('Cycle metrics'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Cycle length',
                        value:
                            '${controller.avgCycleLength.value ?? 28} days',
                        subtitle: 'Average',
                        icon: HugeIcons.strokeRoundedCalendar03,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Period duration',
                        value:
                            '${controller.avgPeriodLength.value ?? 5} days',
                        subtitle: 'Average',
                        icon: HugeIcons.strokeRoundedDroplet,
                        color: AppColors.period,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Luteal phase',
                        value:
                            '${controller.lutealPhaseDays.value ?? 14} days',
                        subtitle: 'Typical',
                        icon: HugeIcons.strokeRoundedMoon02,
                        color: const Color(0xFF7E57C2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Experience',
                        value: controller.experienceLabel,
                        subtitle: 'Mode',
                        icon: HugeIcons.strokeRoundedTarget02,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionTitle('Account'),
                const SizedBox(height: 12),
                _buildInfoGroup(context, [
                  _infoRow(
                    icon: Icons.verified_user_outlined,
                    title: 'Account status',
                    value: controller.isRegistered ? 'Registered' : 'Guest',
                    valueColor: controller.isRegistered
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  if (controller.email.value != null) ...[
                    _thinDivider(),
                    _infoRow(
                      icon: Icons.mail_outline_rounded,
                      title: 'Email',
                      value: controller.email.value!,
                    ),
                  ],
                  if (controller.ageLabel != null) ...[
                    _thinDivider(),
                    _infoRow(
                      icon: Icons.cake_outlined,
                      title: 'Age',
                      value: controller.ageLabel!,
                    ),
                  ],
                ]),
                if (controller.pregnancyModeActive.value) ...[
                  const SizedBox(height: 24),
                  _sectionTitle('Pregnancy'),
                  const SizedBox(height: 12),
                  _buildInfoGroup(context, [
                    _infoRow(
                      icon: Icons.favorite_border_rounded,
                      title: 'Pregnancy mode',
                      value: 'Active',
                      valueColor: AppColors.accent,
                    ),
                    if (controller.dueDate.value != null) ...[
                      _thinDivider(),
                      _infoRow(
                        icon: Icons.event_outlined,
                        title: 'Due date',
                        value: controller.dueDate.value!,
                      ),
                    ],
                  ]),
                ],
                if (controller.heightCm.value != null ||
                    controller.weightKg.value != null) ...[
                  const SizedBox(height: 24),
                  _sectionTitle('Body metrics'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (controller.heightCm.value != null)
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Height',
                            value:
                                '${controller.heightCm.value!.toStringAsFixed(0)} cm',
                            subtitle: 'Profile',
                            icon: HugeIcons.strokeRoundedRuler,
                            color: AppColors.info,
                          ),
                        ),
                      if (controller.heightCm.value != null &&
                          controller.weightKg.value != null)
                        const SizedBox(width: 12),
                      if (controller.weightKg.value != null)
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Weight',
                            value:
                                '${controller.weightKg.value!.toStringAsFixed(0)} kg',
                            subtitle: 'Profile',
                            icon: HugeIcons.strokeRoundedWeightScale,
                            color: const Color(0xFF26A69A),
                          ),
                        ),
                    ],
                  ),
                ],
                if (controller.goals.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle('Your goals'),
                  const SizedBox(height: 12),
                  _buildInfoGroup(
                    context,
                    [
                      for (var i = 0; i < controller.goals.length; i++) ...[
                        if (i > 0) _thinDivider(),
                        _infoRow(
                          icon: Icons.flag_outlined,
                          title: 'Goal ${i + 1}',
                          value: _prettyGoal(controller.goals[i]),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(ProfileController controller) {
    final email = controller.email.value;
    final subtitle = email?.isNotEmpty == true
        ? email!
        : (controller.isRegistered
              ? 'Signed in account'
              : 'Guest account — add email to finish setup');

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: controller.canChangeAvatar ? controller.changeAvatar : null,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Obx(
                    () => Stack(
                      fit: StackFit.expand,
                      children: [
                        UserAvatar(useAuthAvatar: true, size: 96),
                        if (controller.isUploadingAvatar.value)
                          Container(
                            color: Colors.black.withValues(alpha: 0.35),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (controller.canChangeAvatar)
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextWidget(
            title: subtitle,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            textColor: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          if (controller.canChangeAvatar) ...[
            const SizedBox(height: 6),
            TextWidget(
              title: 'Tap photo to change',
              fontSize: 12,
              textColor: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  static String _prettyGoal(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextWidget(
        title: title,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        textColor: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required List<List<dynamic>> icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(icon: icon, color: color, size: 18),
              ),
              Flexible(
                child: TextWidget(
                  title: subtitle,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.textSecondary,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextWidget(
            title: value,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            textColor: AppColors.textPrimary,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 2),
          TextWidget(
            title: title,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            textColor: AppColors.textSecondary,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title: title,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.textSecondary,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                TextWidget(
                  title: value,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  textColor: valueColor ?? AppColors.textPrimary,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thinDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: AppColors.primary.withValues(alpha: 0.06),
    );
  }
}
