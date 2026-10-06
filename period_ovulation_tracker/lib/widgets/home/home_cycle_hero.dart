import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:period_ovulation_tracker/controllers/pregnancy/pregnancy_insights_controller.dart';
import 'package:period_ovulation_tracker/core/constants/app_colors.dart';
import 'package:period_ovulation_tracker/core/utils/app_size.dart';
import 'package:period_ovulation_tracker/widgets/pregnancy/pregnancy_asset_image.dart';
import 'package:period_ovulation_tracker/widgets/text/text_widget.dart';

import '../../controllers/home/home_hero_controller.dart';
import '../../models/home/day_cycle_model.dart';
import '../header/custom_home_header.dart';

enum HeroViewMode { partner, woman }

class HomeCycleHero extends StatelessWidget {
  final HeroViewMode mode;

  const HomeCycleHero({super.key, this.mode = HeroViewMode.woman});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeHeroController>();

    if (mode == HeroViewMode.partner) {
      return _PartnerHero(controller: controller);
    }

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final data = controller.currentSelectedData;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isLoading ? AppColors.softGradient : data.heroGradient,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
          // Fixed child count so date-strip element is never displaced
          child: const Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(child: _HeroWaveLayer()),
              _WomanHeroForeground(),
            ],
          ),
        ),
      );
    });
  }
}

class _HeroWaveLayer extends StatelessWidget {
  const _HeroWaveLayer();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeHeroController>();
    return Obx(() {
      if (controller.isLoading.value) return const SizedBox.shrink();
      final data = controller.currentSelectedData;
      return CustomPaint(
        painter: _HeroWavePainter(accent: data.heroAccent),
      );
    });
  }
}

class _WomanHeroForeground extends StatelessWidget {
  const _WomanHeroForeground();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeHeroController>();

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Obx(
            () => CustomHomeHeader(
              dateMonth: controller.headerDateLabel,
              onLightBackground: true,
              showCalendar: !controller.pregnancyModeActive.value,
            ),
          ),
          SizedBox(height: AppSize.h1),
          _DateStrip(controller: controller),
          SizedBox(height: AppSize.h2),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.6),
                ),
              );
            }
            final data = controller.currentSelectedData;
            final pregnancy = controller.pregnancyModeActive.value;
            final canLog = !controller.isSelectedDateInFuture;
            return Column(
              children: [
                _HeroStatusCopy.fromData(data),
                if (pregnancy) ...[
                  SizedBox(height: AppSize.h2),
                  const _PregnancyHeroVisual(),
                ] else if (canLog) ...[
                  SizedBox(height: AppSize.h2),
                  _QuickActions(controller: controller),
                ],
                SizedBox(height: AppSize.h2),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date strip — every day is a circle
// ---------------------------------------------------------------------------

class _DateStrip extends StatelessWidget {
  final HomeHeroController controller;

  const _DateStrip({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Rebuild when epoch bumps (mode switch) or year list length changes.
    return Obx(() {
      final epoch = controller.dateStripEpoch.value;
      final itemCount = controller.yearDays.length;
      if (itemCount == 0) return const SizedBox.shrink();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.ensureScrolledToToday();
      });

      return SizedBox(
        height: 92,
        child: ListView.builder(
          // No PageStorageKey — it was restoring Jan-1 after mode switches.
          key: ValueKey<String>('home_year_date_strip_$epoch'),
          controller: controller.horizontalScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: HomeHeroController.dayStripPadding,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Obx(() {
              if (index >= controller.yearDays.length) {
                return SizedBox(width: HomeHeroController.dayCellExtent);
              }
              final item = controller.yearDays[index];
              final selected = controller.isSameDay(
                item.date,
                controller.selectedDate.value,
              );
              final today = controller.isSameDay(item.date, DateTime.now());

              return _CircularDayCell(
                item: item,
                isSelected: selected,
                isToday: today,
                onTap: () => controller.selectDate(item.date),
              );
            });
          },
        ),
      );
    });
  }
}

class _CircularDayCell extends StatelessWidget {
  final DayCycleModel item;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _CircularDayCell({
    required this.item,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayLetter = DateFormat('E').format(item.date).substring(0, 1);
    final circle = _circleDecoration();
    final numberColor = _numberColor();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: HomeHeroController.dayCellExtent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 14,
              child: TextWidget(
                title: isToday ? 'TODAY' : '',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                textColor: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            TextWidget(
              title: dayLetter,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              textColor: isToday
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isSelected ? 42 : 38,
              height: isSelected ? 42 : 38,
              alignment: Alignment.center,
              decoration: circle,
              child: TextWidget(
                title: '${item.date.day}',
                fontSize: isSelected ? 15 : 14,
                fontWeight: FontWeight.w700,
                textColor: numberColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _circleDecoration() {
    // Period — solid filled circle
    if (item.type == DayCycleType.period) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.period,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.period.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
        border: isSelected
            ? Border.all(color: AppColors.surface, width: 2.5)
            : null,
      );
    }

    // Ovulation — solid amber circle
    if (item.type == DayCycleType.ovulation) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.ovulation,
        border: isSelected
            ? Border.all(color: AppColors.surface, width: 2.5)
            : null,
      );
    }

    // Fertility — soft fill + tinted ring
    if (item.type == DayCycleType.fertility) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.fertility.withValues(alpha: 0.14),
        border: Border.all(
          color: AppColors.fertility.withValues(alpha: isSelected ? 1 : 0.55),
          width: isSelected ? 2.2 : 1.5,
        ),
      );
    }

    // Pregnancy-test window — soft green ring
    if (item.type == DayCycleType.pregnancy) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.pregnancy.withValues(alpha: 0.12),
        border: Border.all(
          color: AppColors.pregnancy.withValues(alpha: 0.7),
          width: isSelected ? 2.2 : 1.4,
        ),
      );
    }

    // Selected / today — clear soft circle
    if (isSelected || isToday) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? AppColors.border.withValues(alpha: 0.85)
            : AppColors.surface,
        border: Border.all(
          color: isSelected ? AppColors.textSecondary.withValues(alpha: 0.25) : AppColors.border,
          width: 1.5,
        ),
      );
    }

    // Default — light circle so every date reads as circular
    return BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.surface.withValues(alpha: 0.55),
      border: Border.all(color: AppColors.border, width: 1.2),
    );
  }

  Color _numberColor() {
    if (item.type == DayCycleType.period ||
        item.type == DayCycleType.ovulation) {
      return AppColors.surface;
    }
    if (item.type == DayCycleType.fertility) {
      return AppColors.fertility;
    }
    if (item.type == DayCycleType.pregnancy) {
      return AppColors.pregnancy;
    }
    return AppColors.textPrimary;
  }
}

// ---------------------------------------------------------------------------
// Status copy — Flo-style hierarchy
// ---------------------------------------------------------------------------

class _HeroStatusCopy extends StatelessWidget {
  final String headline;
  final String highlight;
  final String? subtitle;
  final String animationKey;

  const _HeroStatusCopy({
    required this.headline,
    required this.highlight,
    this.subtitle,
    required this.animationKey,
  });

  factory _HeroStatusCopy.fromData(DayCycleModel data) {
    return _HeroStatusCopy(
      headline: data.headline,
      highlight: data.highlight,
      subtitle: data.subtitle,
      animationKey:
          '${data.date.toIso8601String()}_${data.highlight}_${data.subtitle}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasHeadline = headline.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Padding(
        key: ValueKey(animationKey),
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.w6,
          vertical: AppSize.h1,
        ),
        child: Column(
          children: [
            if (hasHeadline) ...[
              TextWidget(
                title: headline,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                textColor: AppColors.textPrimary,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              SizedBox(height: AppSize.h1),
            ],
            TextWidget(
              title: highlight,
              fontSize: hasHeadline ? 34 : 28,
              fontWeight: FontWeight.w800,
              textColor: AppColors.textPrimary,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            if (hasSubtitle) ...[
              SizedBox(height: AppSize.h1_5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextWidget(
                      title: subtitle!,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      textColor: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pregnancy week visual (baby + size) under gestational age copy
// ---------------------------------------------------------------------------

class _PregnancyHeroVisual extends StatefulWidget {
  const _PregnancyHeroVisual();

  @override
  State<_PregnancyHeroVisual> createState() => _PregnancyHeroVisualState();
}

class _PregnancyHeroVisualState extends State<_PregnancyHeroVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _babyScale;
  late final Animation<double> _sizeFloat;
  late final Animation<double> _sizeScale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _babyScale = Tween<double>(begin: 1.0, end: 1.045).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _sizeFloat = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _sizeScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _padWeek(int weeks) {
    final w = weeks.clamp(1, 40);
    return w.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final hero = Get.find<HomeHeroController>();
    final insights = Get.isRegistered<PregnancyInsightsController>()
        ? Get.find<PregnancyInsightsController>()
        : Get.put(PregnancyInsightsController());

    return Obx(() {
      final age = hero.gestationalAgeForDate(hero.selectedDate.value);
      final week = age.weeks <= 0 ? 1 : age.weeks.clamp(1, 40);
      final ww = _padWeek(week);
      final babyPath = 'assets/pregnancy/images/baby/week_$ww.jpg';
      final sizePath = 'assets/pregnancy/images/size/week_$ww.svg';
      final sizeLabel =
          insights.insight.value?.baby.sizeLabel ?? "This week's size";

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.w5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => insights.openStory('baby'),
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              height: 156,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.pregnancy.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pregnancy.withValues(alpha: 0.1),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                      child: AnimatedBuilder(
                        animation: _babyScale,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _babyScale.value,
                            child: child,
                          );
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 420),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: KeyedSubtree(
                            key: ValueKey(babyPath),
                            child: PregnancyAssetImage(
                              path: babyPath,
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.child_care_rounded,
                              backgroundColor: const Color(0xFFF3E6EA),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Week $week',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: AppColors.pregnancy.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _pulse,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _sizeFloat.value),
                                  child: Transform.scale(
                                    scale: _sizeScale.value,
                                    child: child,
                                  ),
                                );
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 420),
                                child: KeyedSubtree(
                                  key: ValueKey(sizePath),
                                  child: PregnancyAssetImage(
                                    path: sizePath,
                                    fit: BoxFit.contain,
                                    fallbackIcon: Icons.eco_rounded,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            child: Text(
                              sizeLabel,
                              key: ValueKey(sizeLabel),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _QuickActions extends StatelessWidget {
  final HomeHeroController controller;

  const _QuickActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _QuickAction(
              icon: Icons.water_drop_rounded,
              label: 'Log Period',
              color: AppColors.period,
              onTap: () => controller.onQuickActionTap(context, 'period'),
            ),
            _QuickAction(
              icon: Icons.sentiment_satisfied_alt_rounded,
              label: 'Symptoms',
              color: AppColors.secondary,
              onTap: () => controller.onQuickActionTap(context, 'symptoms'),
            ),
            _QuickAction(
              icon: Icons.favorite_rounded,
              label: 'Sex / Drive',
              color: AppColors.accent,
              onTap: () => controller.onQuickActionTap(context, 'sex'),
            ),
            _QuickAction(
              icon: Icons.science_outlined,
              label: 'Tests / LH',
              color: AppColors.fertility,
              onTap: () => controller.onQuickActionTap(context, 'tests'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          TextWidget(
            title: label,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            textColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Partner mode — same visual system, partner-facing copy (read-only)
// ---------------------------------------------------------------------------

class _PartnerHero extends StatelessWidget {
  final HomeHeroController controller;

  const _PartnerHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final data = controller.currentSelectedData;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isLoading ? AppColors.softGradient : data.heroGradient,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
          child: Stack(
            children: [
              if (!isLoading)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HeroWavePainter(accent: data.heroAccent),
                  ),
                ),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Obx(
                      () => CustomHomeHeader(
                        dateMonth: controller.headerDateLabel,
                        onLightBackground: true,
                        showCalendar: !controller.pregnancyModeActive.value,
                      ),
                    ),
                    SizedBox(height: AppSize.h1),
                    _DateStrip(controller: controller),
                    SizedBox(height: AppSize.h2),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.6),
                        ),
                      )
                    else ...[
                      _HeroStatusCopy(
                        headline: data.resolvedPartnerHeadline,
                        highlight: data.resolvedPartnerHighlight,
                        subtitle: data.resolvedPartnerSubtitle,
                        animationKey:
                            '${data.date.toIso8601String()}_partner_${data.resolvedPartnerHighlight}',
                      ),
                      SizedBox(height: AppSize.h2),
                      _PartnerSupportTips(data: data),
                      SizedBox(height: AppSize.h2),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _PartnerSupportTips extends StatelessWidget {
  final DayCycleModel data;

  const _PartnerSupportTips({required this.data});

  String get _tip {
    switch (data.type) {
      case DayCycleType.period:
        return 'Offer rest, heat packs, or a quiet evening in';
      case DayCycleType.ovulation:
        return 'A thoughtful check-in goes a long way today';
      case DayCycleType.fertility:
        return 'Stay aligned on plans and intimacy together';
      case DayCycleType.pregnancy:
        return 'Be ready with calm, supportive energy';
      case DayCycleType.none:
        return 'Small gestures of care make a big difference';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.w5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: data.color == AppColors.border
                    ? AppColors.primaryLight
                    : data.color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 20,
                color: data.color == AppColors.border
                    ? AppColors.primary
                    : data.color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    title: 'How you can support her',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.textSecondary,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 2),
                  TextWidget(
                    title: _tip,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.textPrimary,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Soft organic wave (state-tinted)
// ---------------------------------------------------------------------------

class _HeroWavePainter extends CustomPainter {
  final Color accent;

  _HeroWavePainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.35, 0)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.15,
        size.width,
        size.height * 0.08,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);

    final lower = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.7,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.9,
        size.width,
        size.height * 0.82,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      lower,
      Paint()..color = accent.withValues(alpha: accent.a * 0.65),
    );

    // Soft highlight orb
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.28),
      math.min(size.width, size.height) * 0.22,
      Paint()..color = accent.withValues(alpha: accent.a * 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _HeroWavePainter oldDelegate) =>
      oldDelegate.accent != accent;
}
