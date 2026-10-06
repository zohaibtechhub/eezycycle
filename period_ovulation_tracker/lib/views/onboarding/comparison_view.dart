import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/constants/app_images.dart';
import 'package:period_ovulation_tracker/core/extensions/theme_extension.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';
import 'package:period_ovulation_tracker/widgets/button/custom_button.dart';
import 'package:period_ovulation_tracker/widgets/common/global_back_behaviour.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/onboarding_controller.dart';

class ComparisonView extends StatelessWidget {
  const ComparisonView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    final comparisonItems = [
      {
        'title': 'Cycle Predictions',
        'without': 'Uncertain dates & unexpected surprises',
        'withEezy': 'Precise ovulation & period forecasts',
      },
      {
        'title': 'Body & Fertility Signals',
        'without': 'Guessing symptoms without context',
        'withEezy': 'Decoded discharge & personalized insights',
      },
      {
        'title': 'Health Guidance',
        'without': 'Scattered internet searches',
        'withEezy': 'Doctor-backed health knowledge & plans',
      },
      {
        'title': 'Intimate Well-being',
        'without': 'Unclear fertile windows & stress',
        'withEezy': 'Confidence in pregnancy & wellness goals',
      },
    ];

    return DoubleBackToExitWrapper(
      child: Scaffold(
        backgroundColor: context.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Title
                TextWidget(
                  title: 'See the difference',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  textColor: context.onSurface,
                ),

                SizedBox(height: AppSize.h1),

                TextWidget(
                  title:
                      'Empower your daily life with personalized cycle care.',
                  fontSize: 15,
                  textColor: context.onSurface.withValues(alpha: 0.65),
                ),

                SizedBox(height: AppSize.h3),

                // 2. Comparison Headers (Without vs With EezyCycle)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextWidget(
                          title: 'Without EezyCycle',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          textColor: context.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.logo,
                              height: 18,
                              width: 18,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.favorite,
                                size: 16,
                                color: context.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            TextWidget(
                              title: 'With EezyCycle',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              textColor: context.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSize.h2),

                // 3. Comparison List Cards
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: comparisonItems.length,
                    separatorBuilder: (_, __) => SizedBox(height: AppSize.h2),
                    itemBuilder: (context, index) {
                      final item = comparisonItems[index];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.onSurface.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              title: item['title']!,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              textColor: context.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: Without EezyCycle
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: context.onSurface.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: TextWidget(
                                          title: item['without']!,
                                          fontSize: 13,
                                          textColor: context.onSurface
                                              .withValues(alpha: 0.55),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Vertical Divider
                                Container(
                                  width: 1,
                                  height: 36,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  color: context.onSurface.withValues(
                                    alpha: 0.08,
                                  ),
                                ),

                                // Right: With EezyCycle
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: context.primaryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: TextWidget(
                                          title: item['withEezy']!,
                                          fontSize: 13,
                                          textColor: context.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 4. Continue Button
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CustomButton(
                    title: 'Continue',
                    onTap: () {
                      Get.offAllNamed(AppPages.commit);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
