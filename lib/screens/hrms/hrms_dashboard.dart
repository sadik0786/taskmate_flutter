import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/screens/hrms/widgets/apply_leave.dart';
import 'package:task_mate/screens/hrms/widgets/approve_leave.dart';
import 'package:task_mate/screens/hrms/widgets/dashboard.dart';

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

  // static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  // static const List<Widget> _widgetOptions = <Widget>[Dashboard(), ApplyLeave(), ApproveLeave()];
  // Widget _buildBody() {
  //   switch (_selectedIndex) {
  //     case 0:
  //       return const Dashboard();
  //     case 1:
  //       return const ApplyLeave();
  //     case 2:
  //       if (role == "hr" || role == "superadmin") {
  //         return const ApproveLeave();
  //       }
  //       return const Dashboard();
  //     default:
  //       return const Dashboard();
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text("Dashboard - $userName", style: Theme.of(context).textTheme.titleLarge),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              if (role == "superadmin") {
                Get.offAllNamed('/adminDashboard');
              } else if (role == "employee") {
                Get.offAllNamed('/homeScreen');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            const Dashboard(),
            const ApplyLeave(),
            if (role == "hr" || role == "superadmin") const ApproveLeave() else const SizedBox(),
          ],
        ),
      ),
      drawer: Drawer(
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150.h,
              padding: EdgeInsets.all(15.w).copyWith(top: 80.h),
              decoration: BoxDecoration(color: ThemeClass.primaryGreen),
              child: Text(
                'Manage Leaves',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: ThemeClass.textWhite,
                ),
              ),
            ),
            ListTile(
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),

            ListTile(
              title: const Text('Apply Leave'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            if (role == "hr" || role == "superadmin") ...[
              ListTile(
                title: const Text('Approve Leave'),
                selected: _selectedIndex == 2,
                onTap: () {
                  _onItemTapped(2);
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
