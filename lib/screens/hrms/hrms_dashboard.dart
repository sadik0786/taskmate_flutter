import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/screens/hrms/admin/all_employee.dart'; // File kept the same name, but we will rename the widget inside

import 'package:task_mate/screens/hrms/user/apply_leave.dart';
import 'package:task_mate/screens/hrms/admin/approve_leave.dart';
import 'package:task_mate/screens/hrms/user/dashboard.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/responsive_layout.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final List<String> titles = ["HRMS Dashboard"];

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

    return "HRMS Dashboard";
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final customActions = [
      IconButton(
        icon: const Icon(Icons.home),
        onPressed: () {
          if (role == "hr" || role == "ceo" || role == "manager") {
            Get.offAllNamed('/adminDashboard');
          } else if (role == "admin" || role == "employee") {
            Get.offAllNamed('/homeScreen');
          }
        },
      ),
    ];

    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    final bottomNavBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(
        context,
      ).colorScheme.onSurface.withOpacity(0.6),
      onTap: _onItemTapped,
    );

    Widget content = _buildBody();

    if (isDesktop) {
      final List<Map<String, dynamic>> tabs = [
        {"icon": Icons.dashboard, "label": "Dashboard"},
      ];
      if (role != "ceo") {
        tabs.add({"icon": Icons.add, "label": "Apply Leave"});
      }
      if (role == "hr" || role == "ceo" || role == "manager") {
        tabs.add({"icon": Icons.check_circle, "label": "Approve Leave"});
        tabs.add({"icon": Icons.analytics_outlined, "label": "Leave Report"});
      }

      final desktopTabBar = Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: tabs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tab = entry.value;
                        final isSelected = _selectedIndex == index;

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: InkWell(
                            onTap: () => _onItemTapped(index),
                            borderRadius: BorderRadius.circular(12.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    tab["icon"],
                                    size: 20.sp,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    tab["label"],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            SizedBox(
              width: 250.w,
              child: Obx(
                () => CustomDropdownField<int>(
                  hintText: "Financial Year",
                  prefixIcon: Icons.calendar_today_rounded,
                  items: leaveController.financialYears
                      .map(
                        (year) => {
                          'id': year.id,
                          'year': year.yearString ?? "",
                        },
                      )
                      .toList(),
                  valueKey: 'id',
                  labelKey: 'year',
                  value: leaveController.selectedFinancialYearId.value,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      leaveController.changeFinancialYear(newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );

      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          desktopTabBar,
          Expanded(child: content),
        ],
      );
    }

    return BaseLayout(
      title: _getPageTitle(),
      showBackButton: false,
      customActions: customActions,
      bottomNavigationBar: isDesktop ? null : bottomNavBar,
      child: content,
    );
  }
}
