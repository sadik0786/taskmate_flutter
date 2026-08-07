import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/screens/hrms/widgets/all_employee.dart';
import 'package:task_mate/screens/hrms/widgets/apply_leave.dart';
import 'package:task_mate/screens/hrms/widgets/approve_leave.dart';
import 'package:task_mate/screens/hrms/widgets/dashboard.dart';
import 'package:task_mate/controllers/theme_controller.dart';
import 'package:task_mate/widgets/responsive_layout.dart';
import 'package:task_mate/widgets/custom_appbar.dart';

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

  // static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  // static const List<Widget> _widgetOptions = <Widget>[Dashboard(), ApplyLeave(), ApproveLeave()];
  // Widget _buildBody() {
  //   switch (_selectedIndex) {
  //     case 0:
  //       return const Dashboard();
  //     case 1:
  //       return const ApplyLeave();
  //     case 2:
  //       if (role == "hr" || role == "superadmin") {
  //         return const ApproveLeave();
  //       }
  //       return const Dashboard();
  //     default:
  //       return const Dashboard();
  //   }
  // }

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
          if (role == "superadmin") {
            Get.offAllNamed('/adminDashboard');
          } else if (role == "hr") {
            Get.offAllNamed('/dashboard');
          } else if (role == "employee") {
            Get.offAllNamed('/homeScreen');
          }
        },
      ),
    ];

    final desktopAppBar = DesktopAppBar(
      title: "Dashboard - $userName",
      userName: userName,
      onLogout: () {},
      isDarkMode: Get.find<ThemeController>().isDarkMode,
      onToggleTheme: Get.find<ThemeController>().toggleTheme,
      customActions: customActions,
    );

    final mobileAppBar = MobileAppBar(
      title: "Dashboard - $userName",
      userName: userName,
      onLogout: () {},
      isDarkMode: Get.find<ThemeController>().isDarkMode,
      onToggleTheme: Get.find<ThemeController>().toggleTheme,
      customActions: customActions,
    );

    final hrmsDrawer = Drawer(
      width: 250,
      backgroundColor: ThemeClass.darkBgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 150.h,
            padding: EdgeInsets.all(15.w).copyWith(top: 80.h),
            decoration: const BoxDecoration(color: ThemeClass.primaryGreen),
            child: Text(
              'Manage Leaves',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: ThemeClass.textWhite,
              ),
            ),
          ),
          ListTile(
            title: Text('Dashboard', style: TextStyle(color: Colors.white)),
            selected: _selectedIndex == 0,
            selectedTileColor: ThemeClass.primaryGreen.withOpacity(0.2),
            onTap: () {
              _onItemTapped(0);
              if (!isDesktop) Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Apply Leave', style: TextStyle(color: Colors.white)),
            selected: _selectedIndex == 1,
            selectedTileColor: ThemeClass.primaryGreen.withOpacity(0.2),
            onTap: () {
              _onItemTapped(1);
              if (!isDesktop) Navigator.pop(context);
            },
          ),
          if (role == "hr" || role == "superadmin") ...[
            ListTile(
              title: Text(
                'Approve Leave',
                style: TextStyle(color: Colors.white),
              ),
              selected: _selectedIndex == 2,
              selectedTileColor: ThemeClass.primaryGreen.withOpacity(0.2),
              onTap: () {
                _onItemTapped(2);
                if (!isDesktop) Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Add Employee',
                style: TextStyle(color: Colors.white),
              ),
              selected: _selectedIndex == 3,
              selectedTileColor: ThemeClass.primaryGreen.withOpacity(0.2),
              onTap: () {
                _onItemTapped(3);
                if (!isDesktop) Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'All Employee',
                style: TextStyle(color: Colors.white),
              ),
              selected: _selectedIndex == 4,
              selectedTileColor: ThemeClass.primaryGreen.withOpacity(0.2),
              onTap: () {
                _onItemTapped(4);
                if (!isDesktop) Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );

    final content = IndexedStack(
      index: _selectedIndex,
      children: [
        const Dashboard(),
        const ApplyLeave(),
        if (role == "hr" || role == "superadmin") ...[
          const ApproveLeave(),
          const AllEmployee(),
        ],
      ],
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: ThemeClass.darkBgColor,
        body: Row(
          children: [
            hrmsDrawer,
            Expanded(
              child: Column(
                children: [
                  desktopAppBar,
                  Expanded(child: content),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      appBar: mobileAppBar,
      body: SafeArea(child: content),
      drawer: hrmsDrawer,
    );
  }
}
