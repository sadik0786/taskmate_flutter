import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/widgets/base_layout.dart';

import 'package:task_mate/screens/page_loader.dart';
import 'package:task_mate/services/user_service.dart';
import 'package:task_mate/services/task_service.dart';
import 'package:task_mate/services/project_service.dart';
import 'package:task_mate/widgets/responsive_layout.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? userName;
  String? role;

  int totalEmployees = 0;
  int totalProjects = 0;
  int totalTasks = 0;
  bool isLoadingSummary = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadSummaryData() async {
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
    _loadSummaryData();
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
          title: 'My Profile',
          icon: Icons.account_circle,
          gradient: [
            Colors.purpleAccent.shade200,
            Colors.purpleAccent.shade100,
          ],
          onTap: () {
            Get.toNamed(Routes.profileScreen);
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
          gradient: [
            Colors.orangeAccent.shade400,
            Colors.orangeAccent.shade200,
          ],
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
          gradient: [
            Colors.purpleAccent.shade200,
            Colors.purpleAccent.shade100,
          ],
          onTap: () {
            Get.toNamed(Routes.profileScreen);
          },
        ),
        _DashboardItem(
          title: 'Manage Leave',
          icon: Icons.manage_history,
          gradient: [
            Colors.lightBlueAccent.shade400,
            Colors.lightBlueAccent.shade200,
          ],
          onTap: () {
            Get.toNamed(Routes.hrmsDashboard);
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
          gradient: [
            Colors.orangeAccent.shade400,
            Colors.orangeAccent.shade200,
          ],
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
          gradient: [
            Colors.purpleAccent.shade200,
            Colors.purpleAccent.shade100,
          ],
          onTap: () {
            Get.toNamed(Routes.profileScreen);
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
              margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).cardColor,
                    Theme.of(context).cardColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 32.sp, color: color),
                      ),
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
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
                    Text(
                      "Dashboard Overview",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    if (ResponsiveLayout.isDesktop(context) ||
                        ResponsiveLayout.isTablet(context))
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

