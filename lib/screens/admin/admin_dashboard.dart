import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/base_layout.dart';

import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/services/admin/user_service.dart';
import 'package:task_mate/services/user/task_service.dart';
import 'package:task_mate/services/admin/project_service.dart';
import 'package:task_mate/widgets/responsive_layout.dart';
import 'package:task_mate/screens/hrms/shared/attendance_widget.dart';
import 'package:task_mate/screens/shared/holidays_screen.dart';
import 'package:task_mate/screens/hrms/shared/events_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  String? userName;
  String? role;

  int totalEmployees = 0;
  int totalProjects = 0;
  int totalTasks = 0;
  bool isLoadingSummary = true;

  @override
  void initState() {
    super.initState();
    Get.put<AdminDashboardState>(this);
    _loadUser();
  }

  @override
  void dispose() {
    Get.delete<AdminDashboardState>();
    super.dispose();
  }

  Future<void> loadSummaryData() async {
    try {
      final employees = await UserService.fetchEmployees();
      final projects = await ProjectService.fetchProjects();
      List tasks = [];
      try {
        tasks = await TaskService.fetchAllAdminTasks();
      } catch (e) {
        // Not all admins have access to all admin tasks
      }

      if (mounted) {
        setState(() {
          totalEmployees = employees.length;
          totalProjects = projects.length;
          totalTasks = tasks.length;
          isLoadingSummary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingSummary = false;
        });
      }
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "Employee";
      role = prefs.getString("role")?.toLowerCase() ?? "employee";
    });
    loadSummaryData();
  }

  List<_DashboardItem> _getMenuItems() {
    if (role == "ceo" || role == "hr") {
      return [
        _DashboardItem(
          title: 'Add Employee',
          icon: Icons.person_add,
          gradient: [
            Colors.lightBlueAccent.shade400,
            Colors.lightBlueAccent.shade200,
          ],
          onTap: () async {
            await Get.toNamed(Routes.registerScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Employee',
          icon: Icons.people,
          gradient: [Colors.greenAccent.shade400, Colors.greenAccent.shade200],
          onTap: () async {
            await Get.toNamed(Routes.employeeScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'My Profile',
          icon: Icons.account_circle,
          gradient: [
            Colors.purpleAccent.shade200,
            Colors.purpleAccent.shade100,
          ],
          onTap: () async {
            await Get.toNamed(Routes.profileScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Holidays',
          icon: Icons.celebration,
          gradient: [Colors.pinkAccent.shade200, Colors.pink.shade400],
          onTap: () {
            Get.to(
              () => Scaffold(
                appBar: AppBar(
                  title: const Text("Holidays"),
                  backgroundColor: ThemeClass.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                body: const HolidaysScreen(),
              ),
            );
          },
        ),
      ];
    }
    if (role == "superadmin") {
      return [
        _DashboardItem(
          title: 'Add Employee',
          icon: Icons.person_add,
          gradient: [
            Colors.lightBlueAccent.shade400,
            Colors.lightBlueAccent.shade200,
          ],
          onTap: () async {
            await Get.toNamed(Routes.registerScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Employee',
          icon: Icons.people,
          gradient: [Colors.greenAccent.shade400, Colors.greenAccent.shade200],
          onTap: () async {
            await Get.toNamed(Routes.employeeScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Task Details',
          icon: Icons.task,
          gradient: [
            Colors.orangeAccent.shade400,
            Colors.orangeAccent.shade200,
          ],
          onTap: () async {
            await Get.toNamed(Routes.employeeTaskScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Reset Password',
          icon: Icons.password_sharp,
          gradient: [Colors.red.shade400, Colors.red.shade300],
          onTap: () async {
            await Get.toNamed(Routes.resetPasswordPage);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'My Profile',
          icon: Icons.account_circle,
          gradient: [
            Colors.purpleAccent.shade200,
            Colors.purpleAccent.shade100,
          ],
          onTap: () async {
            await Get.toNamed(Routes.profileScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Manage Leave',
          icon: Icons.manage_history,
          gradient: [
            Colors.lightBlueAccent.shade400,
            Colors.lightBlueAccent.shade200,
          ],
          onTap: () async {
            await Get.toNamed(Routes.hrmsDashboard);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Company Holidays',
          icon: Icons.celebration,
          gradient: [Colors.pinkAccent.shade200, Colors.pink.shade400],
          onTap: () {
            Get.to(
              () => Scaffold(
                appBar: AppBar(
                  title: const Text("Holidays"),
                  backgroundColor: ThemeClass.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                body: const HolidaysScreen(),
              ),
            );
          },
        ),
      ];
    } else if (role == "admin") {
      return [
        _DashboardItem(
          title: 'Add Employee',
          icon: Icons.person_add,
          gradient: [
            Colors.lightBlueAccent.shade400,
            Colors.lightBlueAccent.shade200,
          ],
          onTap: () async {
            await Get.toNamed(Routes.registerScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Employee',
          icon: Icons.people,
          gradient: [Colors.greenAccent.shade400, Colors.greenAccent.shade200],
          onTap: () async {
            await Get.toNamed(Routes.employeeScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Add Project',
          icon: Icons.library_add,
          gradient: [Colors.green.shade400, Colors.green.shade300],
          onTap: () async {
            await Get.toNamed(Routes.projectScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Add Task',
          icon: Icons.add_task,
          gradient: [
            Colors.orangeAccent.shade400,
            Colors.orangeAccent.shade200,
          ],
          onTap: () async {
            await Get.toNamed(Routes.addTaskScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Task Details',
          icon: Icons.task,
          gradient: [Colors.red.shade400, Colors.red.shade300],
          onTap: () async {
            await Get.toNamed(Routes.taskScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'My Profile',
          icon: Icons.account_circle,
          gradient: [
            Colors.purpleAccent.shade200,
            Colors.purpleAccent.shade100,
          ],
          onTap: () async {
            await Get.toNamed(Routes.profileScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Company Holidays',
          icon: Icons.celebration,
          gradient: [Colors.pinkAccent.shade200, Colors.pink.shade400],
          onTap: () {
            Get.to(
              () => Scaffold(
                appBar: AppBar(
                  title: const Text("Holidays"),
                  backgroundColor: ThemeClass.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                body: const HolidaysScreen(),
              ),
            );
          },
        ),
      ];
    } else {
      return [];
    }
  }

  Widget _summaryCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() {}),
          onExit: (_) => setState(() {}),
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color.withOpacity(1.0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
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
                      icon,
                      size: 80.sp,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(icon, size: 28.sp, color: Colors.white),
                          ),
                          Text(
                            value.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _getMenuItems();
    final isDesktop =
        ResponsiveLayout.isDesktop(context) ||
        ResponsiveLayout.isTablet(context);

    return BaseLayout(
      title: "Task Mate",
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: isLoadingSummary
            ? const Center(child: PageLoader())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EventsWidget(),
                    const AttendanceWidget(),
                    Text(
                      "Dashboard Overview",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              title: "Total Employees",
                              value: totalEmployees,
                              icon: Icons.people,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Expanded(
                            child: _summaryCard(
                              title: "Total Projects",
                              value: totalProjects,
                              icon: Icons.library_books,
                              color: Colors.greenAccent.shade700,
                            ),
                          ),
                          Expanded(
                            child: _summaryCard(
                              title: "Total Tasks",
                              value: totalTasks,
                              icon: Icons.task_alt,
                              color: Colors.orangeAccent.shade700,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _summaryCard(
                            title: "Total Employees",
                            value: totalEmployees,
                            icon: Icons.people,
                            color: Colors.blueAccent,
                          ),
                          _summaryCard(
                            title: "Total Projects",
                            value: totalProjects,
                            icon: Icons.library_books,
                            color: Colors.greenAccent.shade700,
                          ),
                          _summaryCard(
                            title: "Total Tasks",
                            value: totalTasks,
                            icon: Icons.task_alt,
                            color: Colors.orangeAccent.shade700,
                          ),
                        ],
                      ),
                    SizedBox(height: 32.h),
                    Text(
                      "Quick Actions",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        if (constraints.maxWidth >= 1024) {
                          crossAxisCount = 4; // Desktop
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 3; // Tablet
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                  ],
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
