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
import 'package:task_mate/widgets/responsive_desktop_wrappers.dart';

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
      // customActions: [
      //   IconButton(
      //     icon: const Icon(Icons.home),
      //     onPressed: () {
      //       Get.until(
      //         (route) =>
      //             route.settings.name == Routes.adminDashboard || route.isFirst,
      //       );
      //     },
      //   ),
      // ],
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: loading
            ? const Center(child: PageLoader())
            : Column(
                key: const ValueKey('content'),
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
                        : Builder(
                            builder: (context) {
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
                                      color: ThemeClass.errorColor,
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                      ),
                                      child: Icon(
                                        Icons.delete,
                                        color: ThemeClass.textWhite,
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
                                              color: Colors.black.withOpacity(
                                                0,
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: AlertDialog(
                                              backgroundColor: Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
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
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .surfaceVariant,
                                                    padding:
                                                        EdgeInsets.symmetric(
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
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.onSurface,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        ThemeClass.errorColor,
                                                    padding:
                                                        EdgeInsets.symmetric(
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
                                                      color:
                                                          ThemeClass.textWhite,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                          backgroundColor:
                                              ThemeClass.successColor,
                                          colorText: ThemeClass.textWhite,
                                        );
                                        return true; // actually remove item from the list
                                      } else {
                                        Get.snackbar(
                                          "$name",
                                          "Failed to delete employee",
                                          backgroundColor:
                                              ThemeClass.errorColor,
                                          colorText: ThemeClass.textWhite,
                                        );
                                        return false; // keep the item
                                      }
                                    }
                                    return false; // user canceled
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
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
                                      alignment: Alignment.topCenter,
                                      children: [
                                        ListTile(
                                          isThreeLine: true,
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  Theme.of(context).primaryColor
                                                      .withOpacity(0.8),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(
                                                  12.r,
                                                ),
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

                              return ResponsiveGridListWrapper(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 8.h,
                                ),
                                itemCount: filteredEmployees.length,
                                desktopMainAxisExtent: 110.h,
                                itemBuilder: (context, index) =>
                                    buildCard(index),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
