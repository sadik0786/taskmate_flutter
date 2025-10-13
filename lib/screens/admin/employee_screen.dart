import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/screens/no_data.dart';
import 'package:task_mate/screens/page_loader.dart';
import 'package:task_mate/services/api_service.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  List employees = [];
  bool loading = true;
  String currentUserRole = "";
  int currentUserId = 0;
  String roleName = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserRole = prefs.getString("role")?.toLowerCase() ?? "employee";
    currentUserId = prefs.getInt("id") ?? 0;
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.fetchEmployees();
      setState(() {
        employees = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load employees")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text("Employees", style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Get.offAllNamed(Routes.adminDashboard);
            },
          ),
        ],
      ),
      body: loading
          ? const PageLoader()
          : employees.isEmpty
          ? const Center(child: NoTasksWidget(message: "No Employee added"))
          : ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final e = employees[index];
                final role = e["RoleName"] ?? "";
                final name = e["Name"] ?? "";
                final email = e["Email"] ?? "";
                // role == "admin" ?
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5),
                    leading: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Color(0xff00ca9d),
                      backgroundImage: e["ProfileImage"] != null && e["ProfileImage"].isNotEmpty
                          ? NetworkImage("${e["ProfileImage"]}")
                          : null,
                      child: e["ProfileImage"] == null || e["ProfileImage"].isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "?",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(
                          "$name",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(" ($role)", style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Text(email, style: Theme.of(context).textTheme.bodySmall),

                        Text(
                          "Assigned to : ${e["AddedByName"] ?? "Unknown"}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.delete, size: 18.sp, color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            actionsAlignment: MainAxisAlignment.center,
                            title: const Text("Confirm Delete", textAlign: TextAlign.center),
                            content: Text(
                              "Are you sure! \nyou want to delete $name?",
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // print("Deleting employee: ${e["ID"]}");
                          final success = await ApiService.deleteEmployee(e["ID"]);
                          // if (!success) {
                          //   print("Failed to delete employee ID: ${e["ID"]}");
                          // }
                          if (success) {
                            setState(() {
                              employees.removeAt(index);
                            });
                            Get.snackbar(
                              "$name",
                              "deleted successfully",
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              "$name",
                              "Failed to delete employee",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                    ),
                    onTap: () {
                      Get.toNamed(
                        Routes.employeeTaskScreen,
                        arguments: {
                          "empId": e["ID"], // pass employee id
                          "empName": e["Name"] ?? "Employee", // pass employee name
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
