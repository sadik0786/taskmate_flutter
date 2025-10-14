import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/theme_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/widgets/custom_appbar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ThemeController _themeController = Get.find();

  String? userName;
  String? role;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "Employee";
      role = prefs.getString("role")?.toLowerCase() ?? "employee";
    });
  }

  Future<void> _logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Get.offNamed(Routes.login);
  }

  List<_DashboardItem> _getMenuItems() {
    if (role == "superadmin") {
      return [
        _DashboardItem(
          title: 'Add Employee',
          icon: Icons.person_add,
          gradient: [Colors.lightBlueAccent.shade400, Colors.lightBlueAccent.shade200],
          onTap: () {
            Get.toNamed(Routes.registerScreen);
          },
        ),
        _DashboardItem(
          title: 'Employee',
          icon: Icons.people,
          gradient: [Colors.greenAccent.shade400, Colors.greenAccent.shade200],
          onTap: () {
            Get.toNamed(Routes.employeeScreen);
          },
        ),
        _DashboardItem(
          title: 'Task Details',
          icon: Icons.task,
          gradient: [Colors.orangeAccent.shade400, Colors.orangeAccent.shade200],
          onTap: () {
            Get.toNamed(Routes.employeeTaskScreen);
          },
        ),
        _DashboardItem(
          title: 'Reset Password',
          icon: Icons.password_sharp,
          gradient: [Colors.red.shade400, Colors.red.shade300],
          onTap: () {
            Get.toNamed(Routes.resetPasswordPage);
          },
        ),
        _DashboardItem(
          title: 'My Profile',
          icon: Icons.account_circle,
          gradient: [Colors.purpleAccent.shade200, Colors.purpleAccent.shade100],
          onTap: () {
            Get.toNamed(Routes.profileScreen);
          },
        ),
      ];
    } else if (role == "admin") {
      return [
        _DashboardItem(
          title: 'Add Employee',
          icon: Icons.person_add,
          gradient: [Colors.lightBlueAccent.shade400, Colors.lightBlueAccent.shade200],
          onTap: () {
            Get.toNamed(Routes.registerScreen);
          },
        ),
        _DashboardItem(
          title: 'Employee',
          icon: Icons.people,
          gradient: [Colors.greenAccent.shade400, Colors.greenAccent.shade200],
          onTap: () {
            Get.toNamed(Routes.employeeScreen);
          },
        ),
        _DashboardItem(
          title: 'Add Project',
          icon: Icons.library_add,
          gradient: [Colors.green.shade400, Colors.green.shade300],
          onTap: () {
            Get.toNamed(Routes.projectScreen);
          },
        ),
        _DashboardItem(
          title: 'Add Task',
          icon: Icons.add_task,
          gradient: [Colors.orangeAccent.shade400, Colors.orangeAccent.shade200],
          onTap: () {
            Get.toNamed(Routes.addTaskScreen);
          },
        ),
        _DashboardItem(
          title: 'Task Details',
          icon: Icons.task,
          gradient: [Colors.red.shade400, Colors.red.shade300],
          onTap: () {
            Get.toNamed(Routes.taskScreen);
          },
        ),
        // _DashboardItem(
        //   title: 'Reset Password',
        //   icon: Icons.password_sharp,
        //   gradient: [Colors.deepOrange.shade600, Colors.deepOrange.shade300],
        //   onTap: () {
        //     Get.toNamed(Routes.resetPasswordPage);
        //   },
        // ),
        _DashboardItem(
          title: 'My Profile',
          icon: Icons.account_circle,
          gradient: [Colors.purpleAccent.shade200, Colors.purpleAccent.shade100],
          onTap: () {
            Get.toNamed(Routes.profileScreen);
          },
        ),
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getMenuItems();

    return Scaffold(
      appBar: CommonAppBar(
        title: "Task Mate",
        userName: userName,
        onLogout: _logOut,
        isDarkMode: _themeController.isDarkMode,
        onToggleTheme: _themeController.toggleTheme,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [Color(0x60121212), Color(0x20121212)],
            //   begin: Alignment.bottomRight,
            //   end: Alignment.topLeft,
            // ),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20.w, vertical: 20.h),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20.h,
              crossAxisSpacing: 30.w,
              children: items.map((item) => _GlassCard(item: item)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}

class _GlassCard extends StatefulWidget {
  final _DashboardItem item;

  const _GlassCard({required this.item});

  @override
  State<_GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<_GlassCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.item.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.item.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: widget.item.gradient.last.withValues(alpha: 0.4),
                blurRadius: 12.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.item.icon, size: 50.sp, color: Colors.white),
                SizedBox(height: 14.h),
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
