// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:period_ovulation_tracker/core/bindings/app_bindings.dart';
import 'package:period_ovulation_tracker/core/services/notification_service.dart';
import 'package:period_ovulation_tracker/firebase_options.dart';
import 'package:period_ovulation_tracker/routes/app_pages.dart';

import 'core/utils/app_theme.dart';
import 'core/utils/pref_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefUtil.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Get.putAsync(() => NotificationService().init(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // locale: DevicePreview.locale(context),
      title: 'Period & Ovulation Tracker',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialBinding: AppBindings(),
      initialRoute: AppPages.splash,
      getPages: AppPages.routes,
      smartManagement: SmartManagement.keepFactory,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
