import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/widgets/base_layout.dart';

import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/services/admin/user_service.dart';
import 'package:task_mate/services/user/task_service.dart';
import 'package:task_mate/services/admin/project_service.dart';
import 'package:task_mate/widgets/responsive_layout.dart';
import 'package:task_mate/screens/hrms/shared/attendance_widget.dart';
import 'package:task_mate/screens/shared/holidays_screen.dart';
import 'package:task_mate/screens/hrms/shared/events_widget.dart';
import 'package:task_mate/screens/hrms/shared/attendance_history_screen.dart';

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

  List<Color> _getGradient(Color baseColor) {
    return [baseColor, baseColor.withOpacity(0.7)];
  }

  List<_DashboardItem> _getMenuItems(BuildContext context) {
    if (role == "ceo" || role == "hr") {
      return [
        _DashboardItem(
          title: 'Add Employee',
          icon: Icons.person_add_rounded,
          gradient: _getGradient(const Color(0xFF8B5CF6)), // Purple
          onTap: () async {
            await Get.toNamed(Routes.registerScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Employee',
          icon: Icons.people_rounded,
          gradient: _getGradient(const Color(0xFF3B82F6)), // Blue
          onTap: () async {
            await Get.toNamed(Routes.employeeScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'My Profile',
          icon: Icons.account_circle_rounded,
          gradient: _getGradient(const Color(0xFF14B8A6)), // Teal
          onTap: () async {
            await Get.toNamed(Routes.profileScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Holidays',
          icon: Icons.celebration_rounded,
          gradient: _getGradient(const Color(0xFFF59E0B)), // Amber
          onTap: () {
            Get.to(() => const HolidaysScreen());
          },
        ),
        _DashboardItem(
          title: 'View Timeline',
          icon: Icons.history_rounded,
          gradient: _getGradient(const Color(0xFF6366F1)), // Indigo
          onTap: () {
            Get.to(() => const AttendanceHistoryScreen());
          },
        ),
      ];
    }
    if (role == "superadmin") {
      return [
        _DashboardItem(
          title: 'Add Employee',
          icon: Icons.person_add_rounded,
          gradient: _getGradient(const Color(0xFF8B5CF6)),
          onTap: () async {
            await Get.toNamed(Routes.registerScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Employee',
          icon: Icons.people_rounded,
          gradient: _getGradient(const Color(0xFF3B82F6)),
          onTap: () async {
            await Get.toNamed(Routes.employeeScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Task Details',
          icon: Icons.task_rounded,
          gradient: _getGradient(const Color(0xFF10B981)), // Green
          onTap: () async {
            await Get.toNamed(Routes.employeeTaskScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Reset Password',
          icon: Icons.lock_reset_rounded,
          gradient: _getGradient(const Color(0xFFEF4444)), // Red
          onTap: () async {
            await Get.toNamed(Routes.resetPasswordPage);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'My Profile',
          icon: Icons.account_circle_rounded,
          gradient: _getGradient(const Color(0xFF14B8A6)),
          onTap: () async {
            await Get.toNamed(Routes.profileScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Manage Leave',
          icon: Icons.manage_history_rounded,
          gradient: _getGradient(const Color(0xFF06B6D4)), // Cyan
          onTap: () async {
            await Get.toNamed(Routes.hrmsDashboard);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Attendance Report',
          icon: Icons.assignment_ind_rounded,
          gradient: _getGradient(const Color(0xFF8B5CF6)),
          onTap: () {
            Get.toNamed(Routes.adminAttendanceReport);
          },
        ),
        _DashboardItem(
          title: 'Regularization',
          icon: Icons.edit_calendar_rounded,
          gradient: _getGradient(const Color(0xFFF43F5E)), // Rose
          onTap: () {
            Get.toNamed(Routes.adminRegularizationRequests);
          },
        ),
        _DashboardItem(
          title: 'Company Holidays',
          icon: Icons.celebration_rounded,
          gradient: _getGradient(const Color(0xFFF59E0B)),
          onTap: () {
            Get.to(() => const HolidaysScreen());
          },
        ),
        _DashboardItem(
          title: 'View Timeline',
          icon: Icons.history_rounded,
          gradient: _getGradient(const Color(0xFF6366F1)),
          onTap: () {
            Get.to(() => const AttendanceHistoryScreen());
          },
        ),
      ];
    } else if (role == "admin") {
      return [
        _DashboardItem(
          title: 'Add Employee',
          icon: Icons.person_add_rounded,
          gradient: _getGradient(const Color(0xFF8B5CF6)),
          onTap: () async {
            await Get.toNamed(Routes.registerScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Attendance Report',
          icon: Icons.assignment_ind_rounded,
          gradient: _getGradient(const Color(0xFF8B5CF6)),
          onTap: () {
            Get.toNamed(Routes.adminAttendanceReport);
          },
        ),
        _DashboardItem(
          title: 'Regularization',
          icon: Icons.edit_calendar_rounded,
          gradient: _getGradient(const Color(0xFFF43F5E)),
          onTap: () {
            Get.toNamed(Routes.adminRegularizationRequests);
          },
        ),
        _DashboardItem(
          title: 'Employee',
          icon: Icons.people_rounded,
          gradient: _getGradient(const Color(0xFF3B82F6)),
          onTap: () async {
            await Get.toNamed(Routes.employeeScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Add Project',
          icon: Icons.library_add_rounded,
          gradient: _getGradient(const Color(0xFFEC4899)), // Pink
          onTap: () async {
            await Get.toNamed(Routes.projectScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Add Task',
          icon: Icons.add_task_rounded,
          gradient: _getGradient(const Color(0xFF06B6D4)),
          onTap: () async {
            await Get.toNamed(Routes.addTaskScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Task Details',
          icon: Icons.task_rounded,
          gradient: _getGradient(const Color(0xFF10B981)),
          onTap: () async {
            await Get.toNamed(Routes.taskScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'My Profile',
          icon: Icons.account_circle_rounded,
          gradient: _getGradient(const Color(0xFF14B8A6)),
          onTap: () async {
            await Get.toNamed(Routes.profileScreen);
            loadSummaryData();
          },
        ),
        _DashboardItem(
          title: 'Company Holidays',
          icon: Icons.celebration_rounded,
          gradient: _getGradient(const Color(0xFFF59E0B)),
          onTap: () {
            Get.to(() => const HolidaysScreen());
          },
        ),
        _DashboardItem(
          title: 'View Timeline',
          icon: Icons.history_rounded,
          gradient: _getGradient(const Color(0xFF6366F1)),
          onTap: () {
            Get.to(() => const AttendanceHistoryScreen());
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
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
            padding: EdgeInsets.all(24.w),
            transform: Matrix4.identity()
              ..translate(0.0, isHovered ? -6.0 : 0.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isHovered
                    ? color.withOpacity(0.5)
                    : Theme.of(context).dividerColor.withOpacity(0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? color.withOpacity(0.15)
                      : Theme.of(context).shadowColor.withOpacity(0.03),
                  blurRadius: isHovered ? 24 : 12,
                  offset: Offset(0, isHovered ? 12 : 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(icon, size: 36.sp, color: color),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isHovered ? 1.0 : 0.0,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color.withOpacity(0.5),
                    size: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _getMenuItems(context);
    final isDesktop =
        ResponsiveLayout.isDesktop(context) ||
        ResponsiveLayout.isTablet(context);

    return BaseLayout(
      title: "Dashboard",
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (isDesktop)
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              title: "Total Employees",
                              value: totalEmployees,
                              icon: Icons.people_alt_rounded,
                              color: const Color(0xFF3B82F6), // Blue
                            ),
                          ),
                          Expanded(
                            child: _summaryCard(
                              title: "Total Projects",
                              value: totalProjects,
                              icon: Icons.layers_rounded,
                              color: const Color(0xFF10B981), // Emerald Green
                            ),
                          ),
                          Expanded(
                            child: _summaryCard(
                              title: "Total Tasks",
                              value: totalTasks,
                              icon: Icons.task_alt_rounded,
                              color: const Color(0xFFF59E0B), // Amber
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
                            icon: Icons.people_alt_rounded,
                            color: const Color(0xFF3B82F6),
                          ),
                          _summaryCard(
                            title: "Total Projects",
                            value: totalProjects,
                            icon: Icons.layers_rounded,
                            color: const Color(0xFF10B981),
                          ),
                          _summaryCard(
                            title: "Total Tasks",
                            value: totalTasks,
                            icon: Icons.task_alt_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    SizedBox(height: 32.h),
                    Text(
                      "Quick Actions",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                                mainAxisSpacing: 16.h,
                                crossAxisSpacing: 16.w,
                                childAspectRatio: 1.25,
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
    final primaryColor = widget.item.gradient[0];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: _isHovered
                  ? primaryColor.withOpacity(0.5)
                  : theme.dividerColor.withOpacity(0.05),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? primaryColor.withOpacity(0.2)
                    : theme.shadowColor.withOpacity(0.03),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 10 : 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? primaryColor
                        : primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    widget.item.icon,
                    size: 28.sp,
                    color: _isHovered ? Colors.white : primaryColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                    color: _isHovered
                        ? primaryColor
                        : theme.colorScheme.onSurface,
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
