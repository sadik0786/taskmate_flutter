import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
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
      backgroundColor: ThemeClass.darkBgColor,
      appBar: AppBar(
        backgroundColor: ThemeClass.primaryGreen,
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

                return Dismissible(
                  key: ValueKey(e["ID"]),
                  direction: DismissDirection.endToStart,
                  background: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    // show delete confirmation
                    final confirm = await showDialog<bool>(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (ctx) => Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(color: Colors.black.withOpacity(0)),
                          ),
                          Center(
                            child: AlertDialog(
                              backgroundColor: ThemeClass.darkBlue,
                              title: Text(
                                "Confirm Delete",
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Are you sure you want to delete!",
                                    style: Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "$name?",
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                      color: ThemeClass.warningColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // Call API to delete employee
                      final success = await ApiService.deleteEmployee(e["ID"]);
                      if (success) {
                        Get.snackbar(
                          "$name",
                          "Deleted successfully",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        return true; // actually remove item from the list
                      } else {
                        Get.snackbar(
                          "$name",
                          "Failed to delete employee",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return false; // keep the item
                      }
                    }
                    return false; // user canceled
                  },
                  child: Card(
                    color: ThemeClass.tealGreen,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      side: BorderSide(color: Colors.white, width: 1.2),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.only(
                        left: 12.w,
                        top: 4.h,
                        bottom: 4.h,
                        right: 5.w,
                      ),
                      leading: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: ThemeClass.primaryGreen,
                        backgroundImage: e["ProfileImage"] != null && e["ProfileImage"].isNotEmpty
                            ? NetworkImage("${e["ProfileImage"]}")
                            : null,
                        child: e["ProfileImage"] == null || e["ProfileImage"].isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : "?",
                                style: Theme.of(context).textTheme.titleLarge,
                              )
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text("$name", style: Theme.of(context).textTheme.titleLarge),
                          Text(" ($role)", style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Assigned to : ${e["AddedByName"] ?? "Unknown"}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(email, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      onTap: () {
                        Get.toNamed(
                          Routes.employeeTaskScreen,
                          arguments: {
                "empId": e["ID"], "empName": e["Name"] ?? "Employee"},
                        );
                      },
                    ),
                  ),
                );
              },
            ),

    );
  }
// list builder old
  // ListView.builder(
  //               padding: EdgeInsets.all(12.w),
  //               itemCount: employees.length,
  //               itemBuilder: (context, index) {
  //                 final e = employees[index];
  //                 final role = e["RoleName"] ?? "";
  //                 final name = e["Name"] ?? "";
  //                 final email = e["Email"] ?? "";
  //                 // role == "admin" ?
  //                 return Card(
  //                   color: ThemeClass.tealGreen,
  //                   margin: EdgeInsets.symmetric(vertical: 8.h),
  //                   elevation: 4,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                     side: BorderSide(color: Colors.white, width: 1.2),
  //                   ),
  //                   child: ListTile(
  //                     contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5),
  //                     leading: CircleAvatar(
  //                       radius: 20.r,
  //                       backgroundColor: Color(0xff00ca9d),
  //                       backgroundImage: e["ProfileImage"] != null && e["ProfileImage"].isNotEmpty
  //                           ? NetworkImage("${e["ProfileImage"]}")
  //                           : null,
  //                       child: e["ProfileImage"] == null || e["ProfileImage"].isEmpty
  //                           ? Text(
  //                               name.isNotEmpty ? name[0].toUpperCase() : "?",
  //                               style: Theme.of(context).textTheme.titleLarge
  //                             )
  //                           : null,
  //                     ),
  //                     title: Row(
  //                       children: [
  //                         Text(
  //                           "$name",
  //                           style: Theme.of(
  //                             context,
  //                           ).textTheme.titleLarge,
  //                         ),
  //                         Text(" ($role)", style: Theme.of(context).textTheme.titleMedium),
  //                       ],
  //                     ),
  //                     subtitle: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       spacing: 1,
  //                       children: [
  //                         Text(
  //                           "Assigned to : ${e["AddedByName"] ?? "Unknown"}",
  //                           style: Theme.of(context).textTheme.titleMedium,
  //                         ),
  //                         Text(email, style: Theme.of(context).textTheme.titleMedium),
  //                       ],
  //                     ),
  //                     trailing: IconButton(
  //                       padding: EdgeInsets.all(0),
  //                       icon: Icon(Icons.delete, size: 18.sp, color: ThemeClass.errorColor),
  //                       onPressed: () async {
  //                         final confirm = await showDialog<bool>(
  //                           context: context,
  //                           builder: (ctx) => AlertDialog(
  //                             actionsAlignment: MainAxisAlignment.center,
  //                             title: const Text("Confirm Delete", textAlign: TextAlign.center),
  //                             content: Text(
  //                               "Are you sure! \nyou want to delete $name?",
  //                               textAlign: TextAlign.center,
  //                             ),
  //                             actions: [
  //                               TextButton(
  //                                 onPressed: () => Navigator.pop(ctx, false),
  //                                 child: const Text("Cancel"),
  //                               ),
  //                               TextButton(
  //                                 onPressed: () => Navigator.pop(ctx, true),
  //                                 child: const Text("Delete", style: TextStyle(color: Colors.red)),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                         if (confirm == true) {
  //                           // print("Deleting employee: ${e["ID"]}");
  //                           final success = await ApiService.deleteEmployee(e["ID"]);
  //                           // if (!success) {
  //                           //   print("Failed to delete employee ID: ${e["ID"]}");
  //                           // }
  //                           if (success) {
  //                             setState(() {
  //                               employees.removeAt(index);
  //                             });
  //                             Get.snackbar(
  //                               "$name",
  //                               "deleted successfully",
  //                               backgroundColor: Colors.green,
  //                               colorText: Colors.white,
  //                             );
  //                           } else {
  //                             Get.snackbar(
  //                               "$name",
  //                               "Failed to delete employee",
  //                               backgroundColor: Colors.redAccent,
  //                               colorText: Colors.white,
  //                             );
  //                           }
  //                         }
  //                       },
  //                     ),
  //                     onTap: () {
  //                       Get.toNamed(
  //                         Routes.employeeTaskScreen,
  //                         arguments: {
  //                           "empId": e["ID"], // pass employee id
  //                           "empName": e["Name"] ?? "Employee", // pass employee name
  //                         },
  //                       );
  //                     },
  //                   ),
  //                 );
  //               },
  //             ),
}

