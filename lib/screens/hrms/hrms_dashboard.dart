import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/screens/hrms/admin/all_employee.dart'; // File kept the same name, but we will rename the widget inside

import 'package:task_mate/screens/hrms/user/apply_leave.dart';
import 'package:task_mate/screens/hrms/admin/approve_leave.dart';
import 'package:task_mate/screens/hrms/user/dashboard.dart';
import 'package:task_mate/widgets/base_layout.dart';

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
    final List<String> titles = ["Dashboard"];

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

    return "Dashboard";
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
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      onTap: _onItemTapped,
    );

    final content = _buildBody();

    return BaseLayout(
      title: _getPageTitle(),
      showBackButton: false,
      customActions: customActions,
      bottomNavigationBar: bottomNavBar,
      child: content,
    );
  }
}
