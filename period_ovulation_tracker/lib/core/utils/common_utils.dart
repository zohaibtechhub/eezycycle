import 'dart:developer';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_theme.dart';

class CommonUtils {
  /// Shows a time picker with app theme styling
  /// Returns the selected TimeOfDay or null if cancelled
  static Future<TimeOfDay?> showTimePickerDialog(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    final theme = Theme.of(context);

    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.brightness == Brightness.dark
                  ? AppColors.darkPrimary
                  : AppColors.primary,
              onPrimary: theme.brightness == Brightness.dark
                  ? AppColors.darkBackground
                  : Colors.white,
              surface: theme.brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              onSurface: theme.brightness == Brightness.dark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// Converts TimeOfDay to 24-hour format string (HH:mm)
  static String timeOfDayTo24HourString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Parses a 24-hour format string (HH:mm or HH:mm:ss) to TimeOfDay
  /// Returns null if parsing fails
  static TimeOfDay? parse24HourString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  /// Compares two TimeOfDay values
  /// Returns -1 if time1 < time2, 0 if equal, 1 if time1 > time2
  static int compareTime(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;

    if (minutes1 < minutes2) return -1;
    if (minutes1 > minutes2) return 1;
    return 0;
  }

  /// Shows a date picker with app theme styling
  /// Returns the selected DateTime or null if cancelled
  static Future<DateTime?> showDatePickerDialog(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? today,
      firstDate: firstDate ?? today,
      lastDate: lastDate ?? DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Theme(
          data: isDark
              ? AppTheme.dark.copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.darkPrimary,
                    onPrimary: AppColors.darkBackground,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  ),
                )
              : AppTheme.light.copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.surface,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
          child: child!,
        );
      },
    );

    return picked;
  }

  /// Shows a date picker followed by a time picker
  /// Returns a combined DateTime or null if cancelled
  static Future<DateTime?> showDateTimePickerDialog(
    BuildContext context, {
    DateTime? initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    // Pick date first
    final DateTime? pickedDate = await showDatePickerDialog(
      context,
      initialDate: initialDateTime,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate == null) return null;

    // Pick time next
    final TimeOfDay? pickedTime = await showTimePickerDialog(
      context,
      initialTime: initialDateTime != null
          ? TimeOfDay(
              hour: initialDateTime.hour,
              minute: initialDateTime.minute,
            )
          : null,
    );

    if (pickedTime == null) return null;

    // Combine date and time
    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  /// Converts DateTime to YYYY-MM-DD format string
  static String dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parses a YYYY-MM-DD format string to DateTime
  /// Returns null if parsing fails
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      final parsed = DateTime.tryParse(dateString);
      if (parsed == null) return null;
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (e) {
      return null;
    }
  }

  /// Compares two DateTime values (date only, ignoring time)
  /// Returns -1 if date1 < date2, 0 if equal, 1 if date1 > date2
  static int compareDate(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);

    if (d1.isBefore(d2)) return -1;
    if (d1.isAfter(d2)) return 1;
    return 0;
  }

  /// Gets today's date with time set to midnight
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String formatPrice(String priceStr) {
    log("Price str $priceStr");
    // Remove spaces or commas (e.g. "1,200")
    priceStr = priceStr.replaceAll(",", "").trim();

    // Convert to number
    final num? price = num.tryParse(priceStr);

    if (price == null) return priceStr;

    if (price < 1000) return price.toString();

    if (price < 1000000) {
      // If price is less than 100k, keep one decimal place
      double value = price / 1000;
      return value.toStringAsFixed(value % 1 == 0 ? 0 : 1) + "k";
    }

    // For price 100k or more, remove decimal
    double value = price / 1000000;
    return value.toStringAsFixed(0) + "m";
  }

  static String cleanPhone(String phone) {
    if (phone.startsWith("+92")) {
      return phone.substring(3);
    } else if (phone.startsWith("0")) {
      return phone.substring(1);
    } else {
      return phone;
    }
  }
}
