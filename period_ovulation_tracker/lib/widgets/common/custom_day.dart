import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cycle_calender_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/theme_extension.dart';
import '../../widgets/text/text_widget.dart';

class CustomCalendarDay extends StatelessWidget {
  final int dayNumber;
  final DateTime date;
  final String? tag;

  const CustomCalendarDay({
    super.key,
    required this.dayNumber,
    required this.date,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CycleCalendarController>(tag: tag);

    return Obx(() {
      final loggedCount = controller.loggedPeriodDates.length;
      final predPeriodCount = controller.predictedPeriodDates.length;
      final fertileCount = controller.predictedFertileDates.length;
      final ovCount = controller.predictedOvulationDates.length;

      final today = DateTime.now();
      final isToday = controller.isSameDay(date, today);
      final isFuture = date.isAfter(controller.normalizeDate(today));
      final isLogged = loggedCount > 0 && controller.isLogged(date);
      final isPredPeriod =
          predPeriodCount > 0 && controller.isPredictedPeriod(date);
      final isOvulation = ovCount > 0 && controller.isOvulation(date);
      final isFertile =
          !isOvulation && fertileCount > 0 && controller.isFertile(date);
      final isInteractive = controller.isDateInteractive(date);

      Color textColor = context.onSurface;
      if (isLogged) {
        textColor = AppColors.period;
      } else if (isOvulation) {
        textColor = AppColors.ovulation;
      } else if (isFertile) {
        textColor = AppColors.fertility;
      } else if (isPredPeriod) {
        textColor = AppColors.period.withValues(alpha: 0.75);
      } else if (isFuture) {
        textColor = context.onSurface.withValues(alpha: 0.25);
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isInteractive ? () => controller.onDayTapped(date) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTodayBadge(context, isToday),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday || isLogged || isOvulation
                    ? FontWeight.w800
                    : FontWeight.w500,
                color: textColor,
              ),
              child: Text('$dayNumber'),
            ),
            const SizedBox(height: 6),
            _buildIndicator(
              context,
              isLogged: isLogged,
              isPredPeriod: isPredPeriod,
              isOvulation: isOvulation,
              isFertile: isFertile,
              isFuture: isFuture,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTodayBadge(BuildContext context, bool isToday) {
    if (!isToday) return const SizedBox(height: 14);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: context.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const TextWidget(
        title: 'TODAY',
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildIndicator(
    BuildContext context, {
    required bool isLogged,
    required bool isPredPeriod,
    required bool isOvulation,
    required bool isFertile,
    required bool isFuture,
  }) {
    return SizedBox(
      height: 20,
      width: 20,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: isLogged
            ? Container(
                key: const ValueKey('logged'),
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.period,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              )
            : isOvulation
            ? Container(
                key: const ValueKey('ovulation'),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.ovulation.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ovulation, width: 1.5),
                ),
              )
            : isFertile
            ? Container(
                key: const ValueKey('fertile'),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.fertility.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.fertility, width: 1.5),
                ),
              )
            : isPredPeriod
            ? Container(
                key: const ValueKey('pred_period'),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.period.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.period, width: 1.5),
                ),
              )
            : isFuture
            ? const SizedBox.shrink()
            : Container(
                key: const ValueKey('unselected'),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.onSurface.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              ),
      ),
    );
  }
}
