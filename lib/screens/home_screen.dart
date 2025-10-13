import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/theme_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/screens/login_screen.dart';
import 'package:task_mate/widgets/custom_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ThemeController _themeController = Get.find();
  String? userName;
  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadTasks();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "Employee";
    });
  }

  Future<void> _loadTasks() async {
    // await ApiService.fetchTasks();
  }

  Future<void> _logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _DashboardItem(
        title: 'Add Task',
        icon: Icons.add_task,
        gradient: [Colors.lightBlueAccent, Colors.blue],
        onTap: () {
          Get.toNamed(Routes.addTaskScreen);
        },
      ),
      _DashboardItem(
        title: 'Task Details',
        icon: Icons.list,
        gradient: [Colors.orangeAccent, Colors.deepOrange],
        onTap: () {
          Get.toNamed(Routes.taskScreen);
          _loadTasks();
        },
      ),
      _DashboardItem(
        title: 'Add Project',
        icon: Icons.library_add,
        gradient: [Colors.green.shade100, Colors.greenAccent],
        onTap: () {
          Get.toNamed(Routes.projectScreen);
        },
      ),
      _DashboardItem(
        title: 'Change Password',
        icon: Icons.password,
        gradient: [Colors.greenAccent.shade400, Colors.green.shade700],
        onTap: () {
          Get.toNamed(Routes.forgotPasswordPage);
        },
      ),
      _DashboardItem(
        title: 'My Profile',
        icon: Icons.manage_accounts,
        gradient: [Colors.lightBlueAccent, Colors.blue],
        onTap: () {
          Get.toNamed(Routes.profileScreen);
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
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
            gradient: LinearGradient(
              colors: [Color(0xFFe0f7fa), Color(0xFF80deea)],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20.w, vertical: 20.h),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20.h,
              crossAxisSpacing: 50.w,
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.item.gradient.last.withValues(alpha: 0.4),
                blurRadius: 12.r,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.item.icon, size: 40.sp, color: Colors.white),
                SizedBox(height: 10.h),
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
