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
  static String? _cachedUserName;
  static String? _cachedUserEmail;

  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    userName = _cachedUserName;
    userEmail = _cachedUserEmail;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "Employee";
      userEmail = prefs.getString("email");
      _cachedUserName = userName;
      _cachedUserEmail = userEmail;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget drawerContent = Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainer : theme.cardColor,
        border: isDesktop
            ? Border(
                right: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              )
            : null,
        boxShadow: isDesktop
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(4, 0),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 30.h,
            ).copyWith(top: isDesktop ? 15.h : 60.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        ThemeClass.primaryGreen.withOpacity(0.4),
                        theme.scaffoldBackgroundColor,
                      ]
                    : [ThemeClass.primaryGreen, ThemeClass.tealGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeClass.primaryGreen.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 80.sp,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/5nance-logo-white.png",
                          height: 40.h,
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      children: [
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
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (userEmail != null && userEmail!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        userEmail!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: _buildMenuItems(),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: _buildDrawerItem(
                Icons.logout,
                "Logout",
                "logout",
                isLogout: true,
              ),
            ),
          ),
        ],
      ),
    );

    return isDesktop
        ? Material(color: Colors.transparent, child: drawerContent)
        : Drawer(
            width: 280.w,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color:
                    theme.drawerTheme.backgroundColor ??
                    theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: drawerContent,
            ),
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

      if (widget.role == "manager" || widget.role == "admin") {
        items.add(
          _buildDrawerItem(
            Icons.task,
            "Task Details",
            Routes.employeeTaskScreen,
          ),
        );
      }

      if (widget.role == "admin") {
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
      items.add(
        _buildDrawerItem(Icons.settings, "Settings", Routes.settingsScreen),
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
        _buildDrawerItem(Icons.settings, "Settings", Routes.settingsScreen),
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
        _buildDrawerItem(Icons.settings, "Settings", Routes.settingsScreen),
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            ThemeClass.primaryGreen.withOpacity(0.15),
                            ThemeClass.primaryGreen.withOpacity(0.02),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border(
                    left: BorderSide(
                      color: isActive
                          ? ThemeClass.primaryGreen
                          : Colors.transparent,
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isActive
                            ? ThemeClass.primaryGreen.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isLogout
                            ? ThemeClass.errorColor
                            : isActive
                            ? ThemeClass.primaryGreen
                            : (Theme.of(
                                    context,
                                  ).iconTheme.color?.withOpacity(0.6) ??
                                  Colors.grey),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isLogout
                              ? ThemeClass.errorColor
                              : isActive
                              ? ThemeClass.primaryGreen
                              : Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                          fontSize: 14.sp,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
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
