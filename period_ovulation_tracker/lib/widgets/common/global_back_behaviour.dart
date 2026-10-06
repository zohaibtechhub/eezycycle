import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DoubleBackToExitWrapper extends StatefulWidget {
  final Widget child;

  const DoubleBackToExitWrapper({super.key, required this.child});

  @override
  State<DoubleBackToExitWrapper> createState() =>
      _DoubleBackToExitWrapperState();
}

class _DoubleBackToExitWrapperState extends State<DoubleBackToExitWrapper> {
  DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // If there are sub-routes inside the navigator, let them pop normally
        final NavigatorState? navigator = Navigator.maybeOf(context);
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
          return;
        }

        final now = DateTime.now();

        // First back press within 2 seconds
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;

          Get.rawSnackbar(
            title: 'Exit App',
            message: 'Press back again to exit',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
          return;
        }

        // Second press: Exit the application
        _lastBackPress = null;
        await SystemNavigator.pop();
      },
      child: widget.child,
    );
  }
}
