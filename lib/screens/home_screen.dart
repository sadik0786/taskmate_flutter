import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/widgets/base_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? role;

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
      role = prefs.getString("role")?.toLowerCase() ?? "employee";
    });
  }

  Future<void> _loadTasks() async {
    // await TaskService.fetchTasks();
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
        gradient: [Colors.green.shade400, Colors.green.shade600],
        onTap: () {
          Get.toNamed(Routes.projectScreen);
        },
      ),
      _DashboardItem(
        title: 'Change Password',
        icon: Icons.password,
        gradient: [Colors.redAccent, Colors.red.shade700],
        onTap: () {
          Get.toNamed(Routes.forgotPasswordPage);
        },
      ),
      _DashboardItem(
        title: 'My Profile',
        icon: Icons.manage_accounts,
        gradient: [Colors.purpleAccent.shade200, Colors.purpleAccent.shade400],
        onTap: () {
          Get.toNamed(Routes.profileScreen);
        },
      ),
      _DashboardItem(
        title: 'Manage Leave',
        icon: Icons.manage_history,
        gradient: [Colors.tealAccent.shade400, Colors.teal.shade400],
        onTap: () {
          Get.toNamed(Routes.hrmsDashboard);
        },
      ),
    ];

    return BaseLayout(
      title: "Task Mate",
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            if (constraints.maxWidth >= 1024) {
              crossAxisCount = 4; // Desktop
            } else if (constraints.maxWidth >= 600) {
              crossAxisCount = 3; // Tablet
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 24.h,
                crossAxisSpacing: 24.w,
                childAspectRatio: 1.15,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _ModernCard(item: items[index]);
              },
            );
          },
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

class _ModernCard extends StatefulWidget {
  final _DashboardItem item;

  const _ModernCard({required this.item});

  @override
  State<_ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<_ModernCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isHovered
                    ? widget.item.gradient
                    : [theme.colorScheme.surface, theme.colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: _isHovered
                    ? Colors.transparent
                    : theme.colorScheme.outlineVariant.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.item.gradient[0].withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                if (_isHovered)
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      widget.item.icon,
                      size: 100.sp,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? Colors.white.withOpacity(0.2)
                              : widget.item.gradient[0].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.item.icon,
                          size: 36.sp,
                          color: _isHovered
                              ? Colors.white
                              : widget.item.gradient[0],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        widget.item.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                          color: _isHovered
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
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

