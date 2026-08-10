import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/widgets/responsive_layout.dart';

class AppDrawer extends StatefulWidget {
  final String role;
  const AppDrawer({super.key, required this.role});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "Employee";
    });
  }

  Future<void> _logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    Widget drawerContent = Container(
      width: 260.w,
      color: ThemeClass.darkBgColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            decoration: const BoxDecoration(color: ThemeClass.primaryGreen),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25.r,
                  child: Text(
                    userName?.isNotEmpty == true
                        ? userName![0].toUpperCase()
                        : "?",
                    style: TextStyle(
                      color: ThemeClass.primaryGreen,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName ?? "User",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.role.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              children: _buildMenuItems(),
            ),
          ),
          Divider(color: Colors.grey.shade800, height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: _buildDrawerItem(
              Icons.logout,
              "Logout",
              "logout",
              isLogout: true,
            ),
          ),
        ],
      ),
    );

    return isDesktop
        ? Material(child: drawerContent)
        : Drawer(
            width: 260.w,
            backgroundColor: ThemeClass.darkBgColor,
            child: drawerContent,
          );
  }

  List<Widget> _buildMenuItems() {
    if (widget.role == "ceo" ||
        widget.role == "hr" ||
        widget.role == "manager" ||
        widget.role == "superadmin") {
      final List<Widget> items = [];
      items.add(
        _buildDrawerItem(Icons.dashboard, "Dashboard", Routes.adminDashboard),
      );

      if (widget.role == "ceo" ||
          widget.role == "hr" ||
          widget.role == "superadmin") {
        items.add(
          _buildDrawerItem(
            Icons.person_add,
            "Add Employee",
            Routes.registerScreen,
          ),
        );
      }
      items.add(
        _buildDrawerItem(Icons.people, "Employees", Routes.employeeScreen),
      );

      if (widget.role == "manager" || widget.role == "superadmin") {
        items.add(
          _buildDrawerItem(
            Icons.task,
            "Task Details",
            Routes.employeeTaskScreen,
          ),
        );
      }

      if (widget.role == "superadmin") {
        items.add(
          _buildDrawerItem(
            Icons.password_sharp,
            "Reset Password",
            Routes.resetPasswordPage,
          ),
        );
      }

      items.add(
        _buildDrawerItem(
          Icons.manage_history,
          "Manage Leave",
          Routes.hrmsDashboard,
        ),
      );
      items.add(
        _buildDrawerItem(
          Icons.account_circle,
          "My Profile",
          Routes.profileScreen,
        ),
      );

      return items;
    } else if (widget.role == "admin") {
      return [
        _buildDrawerItem(Icons.dashboard, "Dashboard", Routes.adminDashboard),
        _buildDrawerItem(
          Icons.person_add,
          "Add Employee",
          Routes.registerScreen,
        ),
        _buildDrawerItem(Icons.people, "Employees", Routes.employeeScreen),
        _buildDrawerItem(
          Icons.library_add,
          "Add Project",
          Routes.projectScreen,
        ),
        _buildDrawerItem(Icons.add_task, "Add Task", Routes.addTaskScreen),
        _buildDrawerItem(Icons.task, "Task Details", Routes.taskScreen),
        _buildDrawerItem(
          Icons.account_circle,
          "My Profile",
          Routes.profileScreen,
        ),
      ];
    } else {
      // Regular employee
      return [
        _buildDrawerItem(Icons.dashboard, "Dashboard", Routes.homeScreen),
        _buildDrawerItem(Icons.add_task, "Add Task", Routes.addTaskScreen),
        _buildDrawerItem(Icons.list, "Task Details", Routes.taskScreen),
        _buildDrawerItem(
          Icons.library_add,
          "Add Project",
          Routes.projectScreen,
        ),
        _buildDrawerItem(
          Icons.manage_history,
          "Manage Leave",
          Routes.hrmsDashboard,
        ),
        _buildDrawerItem(
          Icons.account_circle,
          "My Profile",
          Routes.profileScreen,
        ),
      ];
    }
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    String route, {
    bool isLogout = false,
  }) {
    final bool isActive = Get.currentRoute == route && !isLogout;
    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: StatefulBuilder(
        builder: (context, setState) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() {}),
            onExit: (_) => setState(() {}),
            child: GestureDetector(
              onTap: () {
                if (!isDesktop) {
                  Get.back(); // close drawer only on mobile
                }

                if (isLogout) {
                  _logOut();
                  return;
                }

                if (Get.currentRoute != route) {
                  Get.toNamed(route);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? ThemeClass.primaryGreen.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isActive
                        ? ThemeClass.primaryGreen.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isLogout
                          ? ThemeClass.errorColor
                          : isActive
                          ? ThemeClass.primaryGreen
                          : Colors.white70,
                      size: 22.sp,
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      title,
                      style: TextStyle(
                        color: isLogout
                            ? ThemeClass.errorColor
                            : isActive
                            ? ThemeClass.primaryGreen
                            : Colors.white,
                        fontSize: 15.sp,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
