import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:task_mate/bindings/all_binding.dart';
import 'package:task_mate/controllers/theme_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await ScreenUtil.ensureScreenSize();
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Initialize the theme controller
  // ignore: unused_field
  final ThemeController _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a 1:1 design size for large screens so ScreenUtil doesn't magnify everything.
        // Use the standard 375x812 for mobile screens for proper scaling.
        final isWideScreen = constraints.maxWidth > 600;
        final designSize = isWideScreen
            ? Size(constraints.maxWidth, constraints.maxHeight)
            : const Size(375, 812);

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Task Mate | 5nance',
              theme: ThemeClass.lightTheme,
              darkTheme: ThemeClass.darkTheme,
              themeMode: _themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
              initialRoute: Routes.initialRoute,
              initialBinding: AllBinding(),
              getPages: appPages(),
              builder: (context, widget) {
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(
                    top: false,
                    left: false,
                    right: false,
                    bottom: true,
                    child: widget!,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
