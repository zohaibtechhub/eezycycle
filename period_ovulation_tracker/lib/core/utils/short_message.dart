import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/text/text_widget.dart';
import '../extensions/theme_extension.dart';

class ShortMessageUtils {
  static Future<void> showSuccess(BuildContext context, String message) async {
    await Future.delayed(const Duration(milliseconds: 50));

    Get.snackbar(
      '',
      message,
      icon: Icon(Icons.check_circle_outline, color: context.onPrimary),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: context.primaryColor,
      borderRadius: 20,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      animationDuration: const Duration(milliseconds: 800),
      snackStyle: SnackStyle.FLOATING,
      boxShadows: [
        const BoxShadow(
          color: Colors.black45,
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
      titleText: TextWidget(
        title: 'Success!',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        textColor: context.onPrimary,
        textAlign: TextAlign.start,
      ),
      messageText: TextWidget(
        title: message,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        textColor: context.onPrimary,
        textAlign: TextAlign.start,
      ),
    );
  }

  static Future<void> showError(BuildContext context, String message) async {
    await Future.delayed(const Duration(milliseconds: 50));

    Get.snackbar(
      '',
      message,
      icon: null,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: context.error,
      borderRadius: 20,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeInCirc,
      animationDuration: const Duration(milliseconds: 800),
      snackStyle: SnackStyle.FLOATING,
      boxShadows: [
        const BoxShadow(
          color: Colors.black45,
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
      titleText: SizedBox.shrink(), // No title
      messageText: Row(
        children: [
          Icon(Icons.error_outline, color: context.onError), // Error icon
          SizedBox(width: 8), // Space between icon and message
          Expanded(
            child: TextWidget(
              title: message,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              textColor: context.onError,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
