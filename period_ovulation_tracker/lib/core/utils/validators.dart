import 'package:get/get.dart';

/// A utility class for validation functions commonly used in form fields.
class Validators {
  /// Validates if the password and confirm password match.
  ///
  /// Returns a validation error message if they do not match.
  static String? validatePasswordMatch(
    String? password,
    String? confirmPassword,
  ) {
    if (GetUtils.isNullOrBlank(confirmPassword)!) {
      return "Confirm password is required".tr;
    }
    if (password != confirmPassword) {
      return "Passwords do not match".tr;
    }
    return null;
  }

  /// Validates if the length of the input value is within a specified range.
  ///
  /// Returns a validation error message if the length is not within the range.
  static String? Function(String?) validateLengthRange(
    String name,
    int minLength, {
    int? maxLength,
  }) {
    return (String? value) {
      if (GetUtils.isNullOrBlank(value)!) {
        return "${name.tr} ${"is required".tr}";
      }
      if (!GetUtils.isLengthGreaterThan(value!, minLength)) {
        return "${"$name length must be greater than".tr} $minLength";
      }
      if (maxLength != null && GetUtils.isLengthGreaterThan(value, maxLength)) {
        return "${"$name length must be less than".tr} $maxLength";
      }
      // Return null when the value is valid
      return null;
    };
  }

  /// Validates if the input value is a valid email address.
  ///
  /// Returns a validation error message if the value is not a valid email address.
  static String? validateEmail(String? value) {
    if (GetUtils.isNullOrBlank(value)!) {
      return "Email is required".tr;
    }
    if (!GetUtils.isEmail(value!)) {
      return "Email must be valid".tr;
    }
    // Return null when the value is valid
    return null;
  }

  /// Validates if the input value is not null or blank.
  ///
  /// Returns a validation error message if the value is null or blank.
  static String? Function(String?) validateRequired(String name) {
    return (String? value) {
      if (GetUtils.isNullOrBlank(value)!) {
        return "${name.tr} ${"is required".tr}";
      }
      // Return null when the value is valid
      return null;
    };
  }

  /// Validates if the input value is a valid phone number.
  ///
  /// Ensures the phone number contains only digits and is at least 10 digits long.
  static String? validatePhoneNumber(String? value) {
    if (GetUtils.isNullOrBlank(value)!) {
      return "Phone number is required".tr;
    }

    // Remove spaces and symbols
    final cleaned = value!.replaceAll(RegExp(r'[^0-9]'), '');

    // Pakistani phone number pattern:
    // 03XXXXXXXXX, 923XXXXXXXXX, or +923XXXXXXXXX
    final regex = RegExp(r'^(?:\+92|92|0)?3[0-9]{9}$');

    if (!regex.hasMatch(cleaned)) {
      return "Enter a valid Pakistani phone number".tr;
    }

    return null;
  }

  static String? validateStartDate(String? value) {
    final parsedDate = _parseDate(value);
    if (parsedDate == null) {
      return "Start date is required".tr;
    }

    final today = _today();
    if (parsedDate.isBefore(today)) {
      return "Start date cannot be in the past".tr;
    }

    return null;
  }

  static String? validateEndDate(String? startDate, String? value) {
    final end = _parseDate(value);
    if (end == null) {
      return "End date is required".tr;
    }

    final today = _today();
    if (end.isBefore(today)) {
      return "End date cannot be in the past".tr;
    }

    final start = _parseDate(startDate);
    if (start != null && end.isBefore(start)) {
      return "End date cannot be before start date".tr;
    }

    return null;
  }

  static String? validateDeadline(String? startDate, String? value) {
    final deadline = _parseDate(value);
    if (deadline == null) {
      return "Registration deadline is required".tr;
    }

    final today = _today();
    if (deadline.isBefore(today)) {
      return "Registration deadline cannot be in the past".tr;
    }

    final start = _parseDate(startDate);

    return null;
  }

  static DateTime? _parseDate(String? value) {
    if (GetUtils.isNullOrBlank(value)!) {
      return null;
    }
    final raw = value!.trim();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
