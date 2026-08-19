import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/screens/hrms/admin/all_employee.dart'; // File kept the same name, but we will rename the widget inside

import 'package:task_mate/screens/hrms/user/apply_leave.dart';
import 'package:task_mate/screens/hrms/admin/approve_leave.dart';
import 'package:task_mate/screens/hrms/user/dashboard.dart';
import 'package:task_mate/controllers/theme_controller.dart';
import 'package:task_mate/widgets/responsive_layout.dart';
import 'package:task_mate/widgets/custom_appbar.dart';
import 'package:task_mate/widgets/app_drawer.dart';

class HrmsDashboard extends StatefulWidget {
  const HrmsDashboard({super.key});

  @override
  State<HrmsDashboard> createState() => _HrmsDashboardState();
}

class _HrmsDashboardState extends State<HrmsDashboard> {
  final LeaveController leaveController = Get.put(LeaveController());

  int _selectedIndex = 0;
  String? userName;
  String? role;

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "Employee";
      role = prefs.getString("role")?.toLowerCase() ?? "employee";
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    final List<Widget> pages = [const Dashboard()];

    if (role != "ceo") {
      pages.add(const ApplyLeave());
    }

    if (role == "hr" || role == "ceo" || role == "manager") {
      pages.add(const ApproveLeave());
    }

    if (role == "hr" || role == "ceo" || role == "manager") {
      pages.add(const AllLeavesReport()); // Changed from AllEmployee
    }

    if (_selectedIndex >= 0 && _selectedIndex < pages.length) {
      return pages[_selectedIndex];
    }

    return const Dashboard();
  }

  String _getPageTitle() {
    final List<String> titles = ["Dashboard"];

    if (role != "ceo") {
      titles.add("Apply Leave");
    }

    if (role == "hr" || role == "ceo" || role == "manager") {
      titles.add("Approve Leave");
    }

    if (role == "hr" || role == "ceo" || role == "manager") {
      titles.add("Leave Report");
    }

    if (_selectedIndex >= 0 && _selectedIndex < titles.length) {
      return titles[_selectedIndex];
    }

    return "Dashboard";
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final customActions = [
      IconButton(
        icon: const Icon(Icons.home, color: Colors.white),
        onPressed: () {
          if (role == "hr" || role == "ceo" || role == "manager") {
            Get.offAllNamed('/adminDashboard');
          } else if (role == "admin" || role == "employee") {
            Get.offAllNamed('/homeScreen');
          }
        },
      ),
    ];

    final desktopAppBar = DesktopAppBar(
      title: _getPageTitle(),
      userName: userName,
      onLogout: () {},
      isDarkMode: Get.find<ThemeController>().isDarkMode,
      onToggleTheme: Get.find<ThemeController>().toggleTheme,
      customActions: customActions,
    );

    final mobileAppBar = MobileAppBar(
      title: _getPageTitle(),
      userName: userName,
      onLogout: () {},
      isDarkMode: Get.find<ThemeController>().isDarkMode,
      onToggleTheme: Get.find<ThemeController>().toggleTheme,
      customActions: customActions,
    );

    final bottomNavBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: ThemeClass.darkBgColor,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        if (role != "ceo")
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Apply Leave',
          ),
        if (role == "hr" || role == "ceo" || role == "manager")
          const BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Approve Leave',
          ),
        if (role == "hr" || role == "ceo" || role == "manager")
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Leave Report',
          ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: ThemeClass.primaryGreen,
      unselectedItemColor: Colors.white60,
      onTap: _onItemTapped,
    );

    final content = _buildBody();

    if (isDesktop) {
      return Scaffold(
        backgroundColor: ThemeClass.darkBgColor,
        body: Row(
          children: [
            AppDrawer(role: role ?? "employee"),
            Expanded(
              child: Column(
                children: [
                  desktopAppBar,
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          child: content,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: bottomNavBar,
      );
    }

    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      appBar: mobileAppBar,
      body: SafeArea(child: content),
      drawer: AppDrawer(role: role ?? "employee"),
      bottomNavigationBar: bottomNavBar,
    );
  }
}
