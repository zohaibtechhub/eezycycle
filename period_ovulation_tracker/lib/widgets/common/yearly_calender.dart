import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../controllers/cycle_calender_controller.dart';
import '../../core/extensions/theme_extension.dart';
import '../../core/utils/app_size.dart';
import '../../widgets/text/text_widget.dart';
import 'custom_day.dart';

class CustomYearlyCalendar extends StatelessWidget {
  final int year;
  final String? tag;
  final CalendarMode mode;

  const CustomYearlyCalendar({
    super.key,
    required this.year,
    this.mode = CalendarMode.onboarding,
    this.tag,
  });

  static const List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    // Generate unique controller tag based on mode if not provided
    final controllerTag = tag ?? mode.name;

    // Register instance for this specific mode
    final controller =
        Get.isRegistered<CycleCalendarController>(tag: controllerTag)
        ? Get.find<CycleCalendarController>(tag: controllerTag)
        : Get.put(CycleCalendarController(mode: mode), tag: controllerTag);

    final currentMonthIndex = DateTime.now().month - 1;

    return Column(
      children: [
        SizedBox(height: AppSize.h2),
        if (mode == CalendarMode.onboarding)
          Obx(() {
            final selectedCount = controller.loggedPeriodDates.length;
            final hasSelectedDate = selectedCount > 0;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: TextWidget(
                key: ValueKey(selectedCount),
                title: hasSelectedDate
                    ? 'We started with a 5 day period\nAdjust for smarter predictions'
                    : 'Select the first day of your period',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
            );
          }),
        SizedBox(height: AppSize.h2),
        _buildWeekDays(context),
        Expanded(
          child: ScrollablePositionedList.builder(
            initialScrollIndex: (year == DateTime.now().year)
                ? currentMonthIndex
                : 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: 12,
            itemBuilder: (context, index) {
              final monthDate = DateTime(year, index + 1, 1);
              return _buildMonth(context, monthDate, controllerTag);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDays(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Center(
              child: TextWidget(
                title: day,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                textColor: context.onSurface.withValues(alpha: 0.55),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonth(
    BuildContext context,
    DateTime monthDate,
    String controllerTag,
  ) {
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstWeekdayOffset =
        DateTime(monthDate.year, monthDate.month, 1).weekday % 7;
    final totalGridItems = firstWeekdayOffset + daysInMonth;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          TextWidget(
            title: DateFormat('MMMM').format(monthDate),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalGridItems,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekdayOffset) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - firstWeekdayOffset + 1;
              final date = DateTime(monthDate.year, monthDate.month, dayNumber);
              return CustomCalendarDay(
                dayNumber: dayNumber,
                date: date,
                tag: controllerTag,
              );
            },
          ),
        ],
      ),
    );
  }
}
