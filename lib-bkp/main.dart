import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/bindings/all_binding.dart';
import 'package:task_mate/controllers/theme_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'task_mate',
          theme: ThemeClass.lightTheme,
          darkTheme: ThemeClass.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: Routes.initialRoute,
          initialBinding: AllBinding(),
          getPages: appPages(),
          builder: (context, widget) {
            // ScreenUtil.init(context, designSize: const Size(375, 812));
            return Container(
              color: Colors.white,
              child: SafeArea(top: false, left: false, right: false, bottom: true, child: widget!),
            );
          },
        );
      },
    );
  }
}
