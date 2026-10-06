import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/secret_chat/secret_profile_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/common/user_avatar.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';
import 'package:period_ovulation_tracker/widgets/text_field/custom_text_field.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SecretProfileController>()
        ? Get.find<SecretProfileController>()
        : Get.put(SecretProfileController());

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 24),
          color: AppColors.textPrimary,
          onPressed: () => Get.back(),
        ),
        title: const TextWidget(
          title: 'Edit profile',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Obx(
                        () => UserAvatar(
                          imageUrl: controller.avatarUrl.value,
                          useAuthAvatar: true,
                          size: 72,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSize.h3),

                  // Username row (Flo-style)
                  _ProfileNavCard(
                    child: Obx(
                      () => _ProfileNavRow(
                        label: 'Username',
                        value: controller.username.value,
                        onTap: () => _openUsernameEditor(context, controller),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSize.h2),

                  // Profile tags (Flo-style)
                  _ProfileNavCard(
                    child: InkWell(
                      onTap: () => _openTagsEditor(context, controller),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TextWidget(
                                    title: 'Profile tags',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppColors.textSecondary,
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 10),
                                  Obx(() {
                                    if (controller.selectedTags.isEmpty) {
                                      return const TextWidget(
                                        title: 'Add tags',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        textColor: AppColors.textPrimary,
                                        textAlign: TextAlign.left,
                                      );
                                    }
                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: controller.selectedTags
                                          .map(
                                            (tag) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 7,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.18),
                                                ),
                                              ),
                                              child: TextWidget(
                                                title: tag,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                textColor: AppColors.primary,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSize.h3),

                  const TextWidget(
                    title:
                        'All profile information added here is visible to other community members. It\'s not visible to Partner Mode.',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.textSecondary,
                    textAlign: TextAlign.left,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child:                   CustomButton(
                title: 'Done',
                onTap: () async {
                  final ok = await controller.saveProfile(context);
                  if (ok) Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openUsernameEditor(
    BuildContext context,
    SecretProfileController controller,
  ) {
    Get.to(() => _EditUsernameView(controller: controller));
  }

  void _openTagsEditor(
    BuildContext context,
    SecretProfileController controller,
  ) {
    Get.to(() => _EditTagsView(controller: controller));
  }
}

class _ProfileNavCard extends StatelessWidget {
  final Widget child;

  const _ProfileNavCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _ProfileNavRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ProfileNavRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    title: label,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.textSecondary,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    title: value,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.textPrimary,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditUsernameView extends StatelessWidget {
  final SecretProfileController controller;

  const _EditUsernameView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Get.back(),
        ),
        title: const TextWidget(
          title: 'Username',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          children: [
            CustomTextField(
              labelText: 'Username',
              hintText: 'Enter a username',
              controller: controller.usernameController,
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            const TextWidget(
              title:
                  'Pick a name that feels like you. Avoid real names if you want to stay anonymous.',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              textColor: AppColors.textSecondary,
              textAlign: TextAlign.left,
              maxLines: 3,
            ),
            const Spacer(),
            SafeArea(
              child: CustomButton(
                title: 'Save',
                onTap: () {
                  controller.saveUsername(controller.usernameController.text);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditTagsView extends StatelessWidget {
  final SecretProfileController controller;

  const _EditTagsView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Get.back(),
        ),
        title: const TextWidget(
          title: 'Profile tags',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          textColor: AppColors.textPrimary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    title:
                        'Choose topics that describe you. Other members can see these tags.',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.textSecondary,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                  ),
                  SizedBox(height: AppSize.h2),
                  Obx(
                    () => Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: SecretProfileController.availableTags.map((tag) {
                        final selected = controller.isTagSelected(tag);
                        return GestureDetector(
                          onTap: () => controller.toggleTag(tag),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : context.surface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: TextWidget(
                              title: tag,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              textColor: selected
                                  ? AppColors.surface
                                  : AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: CustomButton(
                title: 'Done',
                onTap: () => Get.back(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
