import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/controllers/relationship/partner_code_controller.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/pref_util.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/widgets/common/user_avatar.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../core/constants/app_colors.dart';

class CustomHomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final String dateMonth;

  /// When true, sits on a light hero gradient (dark icons/text).
  final bool onLightBackground;

  /// Hide cycle calendar in pregnancy mode (Flo-style).
  final bool showCalendar;

  const CustomHomeHeader({
    super.key,
    required this.dateMonth,
    this.onLightBackground = true,
    this.showCalendar = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = onLightBackground
        ? AppColors.textPrimary
        : context.onPrimary;
    final isPartner = PrefUtil.getBool(PrefUtil.isPartnerMode);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: onLightBackground
          ? null
          : Container(
              decoration: const BoxDecoration(gradient: AppColors.periodGradient),
            ),
      leading: InkWell(
        onTap: () => Get.toNamed(AppPages.drawer),
        splashColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: isPartner
              ? (Get.isRegistered<PartnerController>()
                  ? Obx(() {
                      final url =
                          Get.find<PartnerController>().ownerAvatarUrl.value;
                      final cached =
                          PrefUtil.getString(PrefUtil.partnerOwnerAvatarUrl);
                      return UserAvatar(
                        imageUrl: url ?? (cached.isEmpty ? null : cached),
                        size: 40,
                      );
                    })
                  : UserAvatar(
                      imageUrl: () {
                        final cached = PrefUtil.getString(
                          PrefUtil.partnerOwnerAvatarUrl,
                        );
                        return cached.isEmpty ? null : cached;
                      }(),
                      size: 40,
                    ))
              // UserAvatar already Obx-reads AuthController.avatarUrl.
              : const UserAvatar(useAuthAvatar: true, size: 40),
        ),
      ),
      title: TextWidget(
        title: dateMonth,
        textColor: fg,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      centerTitle: true,
      actions: [
        if (showCalendar)
          IconButton(
            onPressed: () => Get.toNamed(AppPages.calenderView),
            icon: Icon(Icons.calendar_month_rounded, color: fg),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
