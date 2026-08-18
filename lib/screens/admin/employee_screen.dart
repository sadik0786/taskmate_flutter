import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/no_data.dart';
import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/services/admin/user_service.dart';
import 'package:task_mate/widgets/base_layout.dart';

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
  String searchQuery = "";

  List get filteredEmployees {
    if (searchQuery.isEmpty) return employees;
    final query = searchQuery.toLowerCase();
    return employees.where((e) {
      final name = (e["Name"] ?? "").toString().toLowerCase();
      final email = (e["Email"] ?? "").toString().toLowerCase();
      final role = (e["RoleName"] ?? "").toString().toLowerCase();
      final addedBy = (e["AddedByName"] ?? "").toString().toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          role.contains(query) ||
          addedBy.contains(query);
    }).toList();
  }

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
      final data = await UserService.fetchEmployees();
      setState(() {
        employees = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Employees",
      customActions: [
        IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Get.until(
              (route) =>
                  route.settings.name == Routes.adminDashboard || route.isFirst,
            );
          },
        ),
      ],
      child: loading
          ? const PageLoader()
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search employees...",
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: employees.isEmpty
                      ? const Center(
                          child: NoTasksWidget(message: "No Employee added"),
                        )
                      : filteredEmployees.isEmpty
                      ? Center(
                          child: Text(
                            "No employee found",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth > 800;

                            Widget buildCard(int index) {
                              final e = filteredEmployees[index];
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                    ),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
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
                                          filter: ImageFilter.blur(
                                            sigmaX: 5,
                                            sigmaY: 5,
                                          ),
                                          child: Container(
                                            color: Colors.black.withOpacity(0),
                                          ),
                                        ),
                                        Center(
                                          child: AlertDialog(
                                            backgroundColor:
                                                ThemeClass.darkBlue,
                                            title: Text(
                                              "Confirm Delete",
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                              textAlign: TextAlign.center,
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Are you sure you want to delete?🤔",
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  "👉$name",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .copyWith(
                                                        color: ThemeClass
                                                            .textWhite,
                                                        fontSize: 18,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            actionsAlignment:
                                                MainAxisAlignment.center,
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w,
                                                    vertical: 10.h,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8.r,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    color: ThemeClass.textBlack,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w,
                                                    vertical: 10.h,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8.r,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    color: ThemeClass.textWhite,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    // Call API to delete employee
                                    final success =
                                        await UserService.deleteEmployee(
                                          e["ID"],
                                        );
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
                                child: Container(
                                  margin: isDesktop
                                      ? EdgeInsets.zero
                                      : EdgeInsets.symmetric(
                                          vertical: 6.h,
                                          horizontal: 2.w,
                                        ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.1),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).shadowColor.withOpacity(0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 4.h,
                                        ),
                                        leading: CircleAvatar(
                                          radius: 20.r,
                                          backgroundColor:
                                              ThemeClass.primaryGreen,
                                          backgroundImage:
                                              e["ProfileImage"] != null &&
                                                  e["ProfileImage"].isNotEmpty
                                              ? NetworkImage(
                                                  "${e["ProfileImage"]}",
                                                )
                                              : null,
                                          child:
                                              e["ProfileImage"] == null ||
                                                  e["ProfileImage"].isEmpty
                                              ? Text(
                                                  name.isNotEmpty
                                                      ? name[0].toUpperCase()
                                                      : "?",
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleLarge,
                                                )
                                              : null,
                                        ),
                                        title: Text(
                                          "$name",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding: EdgeInsets.only(top: 4.h),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (role.toLowerCase() != 'ceo')
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 4.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person_outline,
                                                        size: 14.sp,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Text(
                                                        "Report to: ${e["AddedByName"] ?? "Admin"}",
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.email_outlined,
                                                    size: 14.sp,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Expanded(
                                                    child: Text(
                                                      email,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          Get.toNamed(
                                            Routes.employeeDetail,
                                            arguments: {
                                              "employee": e,
                                              "currentUserRole":
                                                  currentUserRole,
                                            },
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blueAccent,
                                                Colors.blue.shade700,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(12.r),
                                            ),
                                          ),
                                          child: Text(
                                            role.toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (isDesktop) {
                              return GridView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 8.h,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 400,
                                      mainAxisExtent: 90.h,
                                      crossAxisSpacing: 12.w,
                                      mainAxisSpacing: 12.h,
                                    ),
                                itemCount: filteredEmployees.length,
                                itemBuilder: (context, index) =>
                                    buildCard(index),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 8.h,
                              ),
                              itemCount: filteredEmployees.length,
                              itemBuilder: (context, index) => buildCard(index),
                            );
                          },
                        ),
                ),
              ],
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
  //                           final success = await UserService.deleteEmployee(e["ID"]);
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
