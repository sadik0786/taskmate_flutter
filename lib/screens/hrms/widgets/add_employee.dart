import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/services/api_service.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({super.key});

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final LeaveController leaveController = Get.put(LeaveController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? userName;
  String? _currentUserRole;
  List<Map<String, dynamic>> _roles = [];
  int? _selectedRoleId;

  Future<void> _initializeData() async {
    await _loadUserRole();
    await _loadRoles();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "Employee";
      _currentUserRole = prefs.getString("role")?.toLowerCase();
    });
  }

  Future<void> _loadRoles() async {
    String? loggedRole = _currentUserRole;
    if (loggedRole == null) {
      loggedRole = await ApiService.getCurrentUserRole();
      if (loggedRole != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("role", loggedRole);
        setState(() => _currentUserRole = loggedRole);
      }
    }

    final res = await ApiService.getRoles();

    if (!mounted) return;
    setState(() {
      if (res["success"] == true && res["data"] != null) {
        _roles = List<Map<String, dynamic>>.from(res["data"]);

        // Filter roles based on logged-in role
        final roleLower = (loggedRole ?? "").toLowerCase();

        if (roleLower == "superadmin") {
          // Show only admin (or admin + employee if you want)
          _roles = _roles.where((r) {
            final roleName = (r["RoleName"] ?? "").toString().toLowerCase();
            return roleName == "admin" || roleName == "employee";
          }).toList();
        } else if (roleLower == "admin") {
          // Show only employee
          _roles = _roles
              .where((r) => (r["RoleName"] ?? "").toString().toLowerCase() == "employee")
              .toList();
        } else {
          // no roles for employees
          _roles = [];
        }
        // Set default selection if roles exist
        if (_roles.isNotEmpty) {
          _selectedRoleId = _roles.first["RoleId"];
        } else {
          _selectedRoleId = null;
        }
      } else {
        _roles = [];
        _selectedRoleId = null;
      }
    });
  }

  Future<void> onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoleId == null) {
      CustomSnackBar.error("Please select a role");
      return;
    }

    // final userId = await ApiService.getLoggedInUserId();
    final res = await ApiService.registerEmployee(
      _name.text.trim(),
      _email.text.trim(),
      _password.text.trim(),
      _selectedRoleId!,
      mobile: _mobile.text.trim().isNotEmpty ? _mobile.text.trim() : null,
      reportingId: 1,
      // reportingId:
      //     (_currentUserRole?.toLowerCase() == 'superadmin' &&
      //         _roles.firstWhere((r) => r["RoleId"] == _selectedRoleId)["RoleName"].toLowerCase() ==
      //             'employee')
      //     ? _selectedAdminId
      //     : null,
    );
    if (res["success"] == true) {
      CustomSnackBar.success("added successfully!");
      Navigator.pop(context);
    } else {
      final error = res["error"] ?? "Failed to add employee";
      CustomSnackBar.error("$error");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ThemeClass.darkBgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdownField<int>(
                      labelText: "Role",
                      isRequired: true,
                      hintText: "Select role type",
                      prefixIcon: Icons.person_2,
                      items: _roles,
                      valueKey: "id",
                      labelKey: "name",
                      value: _selectedRoleId,
                      isEnabled: true,
                      onChanged: (value) async {
                        setState(() {
                          _selectedRoleId = value;
                        });
                      },
                    ),
                    SizedBox(height: 10.h),
                    CustomDropdownField<int>(
                      labelText: "Assing",
                      isRequired: true,
                      hintText: "Select Assign to",
                      prefixIcon: Icons.person_2,
                      items: _roles,
                      valueKey: "id",
                      labelKey: "name",
                      value: _selectedRoleId,
                      isEnabled: true,
                      onChanged: (value) async {
                        setState(() {
                          _selectedRoleId = value;
                        });
                      },
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      labelText: "Employee Name",
                      isRequired: true,
                      hintText: "Enter name",
                      prefixIcon: Icons.person,
                      controller: _name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name cannot be empty";
                        }
                        if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value.trim())) {
                          return "Name must contain only letters";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      labelText: "Employee Email",
                      isRequired: true,
                      hintText: "Enter email",
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.endsWith('@5nance.com')) {
                          return 'Only @5nance.com emails are allowed';
                        }
                        if (!RegExp(
                          r"^[a-zA-Z][a-zA-Z0-9._-]*@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$",
                        ).hasMatch(value.trim())) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      labelText: "Employee Number",
                      isRequired: false,
                      hintText: "Enter number (Optional)",
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.number,
                      controller: _mobile,
                      maxLength: 10,
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      labelText: "Employee Password",
                      isRequired: true,
                      hintText: "Enter password",
                      prefixIcon: Icons.lock,
                      keyboardType: TextInputType.emailAddress,
                      controller: _password,
                      isObscure: true,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password cannot be empty";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: CustomButton(icon: Icons.save, text: "Add Employee", onPressed: onSubmit),
        ),
      ),
    );
  }
}
