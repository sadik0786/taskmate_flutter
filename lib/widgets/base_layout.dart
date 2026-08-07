import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/theme_controller.dart';
import 'package:task_mate/widgets/app_drawer.dart';
import 'package:task_mate/widgets/custom_appbar.dart';
import 'package:task_mate/widgets/responsive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final List<Widget>? customActions;
  final bool showBackButton;

  const BaseLayout({
    super.key,
    required this.child,
    required this.title,
    this.customActions,
    this.showBackButton = false,
  });

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  String? userName;
  String role = "employee";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name");
      role = prefs.getString("role")?.toLowerCase() ?? "employee";
    });
  }

  @override
  Widget build(BuildContext context) {
    // Make sure ThemeController is initialized
    final themeController = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : Get.put(ThemeController());

    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            AppDrawer(role: role),
            Expanded(
              child: Column(
                children: [
                  DesktopAppBar(
                    title: widget.title,
                    userName: userName,
                    onLogout: () {},
                    isDarkMode: themeController.isDarkMode,
                    onToggleTheme: themeController.toggleTheme,
                    customActions: widget.customActions,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48.0,
                            vertical: 32.0,
                          ),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MobileAppBar(
        title: widget.title,
        userName: userName,
        onLogout: () {}, // Handled in Drawer
        isDarkMode: themeController.isDarkMode,
        onToggleTheme: themeController.toggleTheme,
        customActions: widget.customActions,
      ),
      drawer: AppDrawer(role: role),
      body: SafeArea(child: widget.child),
    );
  }
}
