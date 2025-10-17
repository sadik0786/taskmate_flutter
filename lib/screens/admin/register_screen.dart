import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/services/api_service.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _loading = false;

  String? userName;
  String? _currentUserRole;

  List<Map<String, dynamic>> _roles = [];
  int? _selectedRoleId;
  bool roleLoading = false;

  List<Map<String, dynamic>> _admins = [];
  int? _selectedAdminId;
  bool adminLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserRole();
    await _loadRoles();
    await _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() => adminLoading = true);

    final res = await ApiService.getAdmins();

    if (!mounted) return;
    setState(() {
      adminLoading = false;

      if (res["success"] == true && res["admins"] != null) {
        _admins = List<Map<String, dynamic>>.from(res["admins"]);
        _selectedAdminId = null;
      } else {
        _admins = [];
        _selectedAdminId = null;
      }
    });
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "Employee";
      _currentUserRole = prefs.getString("role")?.toLowerCase();
    });
  }

  Future<void> _loadRoles() async {
    setState(() => roleLoading = true);

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
      roleLoading = false;

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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoleId == null) {
      CustomSnackBar.error("Please select a role");
      return;
    }

    setState(() => _loading = true);
    // First check if email exists in authorized list
    // final emailCheck = await ApiService.checkEmailExists(_email.text.trim());
    // if (!mounted) return;

    // if (emailCheck["success"] != true) {
    //   setState(() => _loading = false);
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(emailCheck["error"] ?? "Email check failed")));
    //   return;
    // }

    // if (emailCheck["emailExists"] == false) {
    //   setState(() => _loading = false);
    //   Get.snackbar(
    //     "Email not authorized",
    //     "Please contact administrator.",
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );

    //   return;
    // }
    if ((_currentUserRole?.toLowerCase() == 'superadmin' &&
            _roles.firstWhere((r) => r["RoleId"] == _selectedRoleId)["RoleName"].toLowerCase() ==
                'employee') &&
        _selectedAdminId == null) {
      CustomSnackBar.error("Please select an Admin to assign the Employee");
      return;
    }
    final res = await ApiService.registerEmployee(
      _name.text.trim(),
      _email.text.trim(),
      _password.text.trim(),
      _selectedRoleId!,
      mobile: _mobile.text.trim().isNotEmpty ? _mobile.text.trim() : null,
      // reportingId: _selectedAdminId,
      reportingId:
          (_currentUserRole?.toLowerCase() == 'superadmin' &&
              _roles.firstWhere((r) => r["RoleId"] == _selectedRoleId)["RoleName"].toLowerCase() ==
                  'employee')
          ? _selectedAdminId
          : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res["success"] == true) {
      CustomSnackBar.success("added successfully!");
      Navigator.pop(context);
    } else {
      final error = res["error"] ?? "Failed to add employee";
      CustomSnackBar.error("$error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text("Add Employee", style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Get.offAllNamed(Routes.adminDashboard);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Card(
                  color: ThemeClass.darkCardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 4,
                  shadowColor: Colors.white54,

                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon(Icons.person, color: ThemeClass.lightBgColor),
                        // SizedBox(width: 15.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName?.toUpperCase() ?? 'Unknown',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Logged in as: ${_currentUserRole?.toUpperCase() ?? 'Unknown'}",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              "You can add: ${_currentUserRole == "superadmin"
                                  ? "Admin / Employees"
                                  : _currentUserRole == "admin"
                                  ? "Employees"
                                  : "No permission"}",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16.h),
                      CustomDropdownField<int>(
                        isLoading: roleLoading,
                        labelText: "Select Role",
                        isRequired: true,
                        hintText: "Select Role",
                        prefixIcon: Icons.work,
                        items: _roles,
                        valueKey: "RoleId",
                        labelKey: "RoleName",
                        value: _selectedRoleId,
                        isEnabled: true,
                        onChanged: (value) async {
                          setState(() {
                            _selectedRoleId = value;
                          });

                          final selectedRole = _roles.firstWhere(
                            (r) => r["RoleId"] == value,
                            orElse: () => {},
                          );

                          if ((_currentUserRole ?? '').toLowerCase() == 'superadmin' &&
                              (selectedRole["RoleName"] ?? '').toLowerCase() == 'employee') {
                            await _loadAdmins();
                          } else {
                            setState(() {
                              _admins = [];
                              _selectedAdminId = null;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 10.h),
                      // select admin
                      if ((_currentUserRole ?? '').toLowerCase() == 'superadmin' &&
                          _roles.any(
                            (r) =>
                                r["RoleId"] == _selectedRoleId &&
                                (r["RoleName"] ?? '').toLowerCase() == 'employee',
                          )) ...[
                        CustomDropdownField<int>(
                          isLoading: adminLoading,
                          labelText: "Employee Assing to",
                          isRequired: true,
                          hintText: "Select Admin",
                          prefixIcon: Icons.admin_panel_settings,
                          items: _admins,
                          valueKey: "ID",
                          labelKey: "Name",
                          value: _selectedAdminId,
                          isEnabled: true,
                          onChanged: (value) async {
                            setState(() {
                              _selectedAdminId = value;
                            });
                          },
                        ),
                      ],
                      // Dropdown for Role
                      // dropDownList(context),
                      SizedBox(height: 0.h),
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
                      SizedBox(height: 0.h),
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
                      SizedBox(height: 10.h),
                      CustomButton(text: "Submit", onPressed: _register, isLoading: _loading),
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

  Widget dropDownList(BuildContext context) {
    if (roleLoading) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(strokeWidth: 2.w),
            ),
            SizedBox(width: 12.h),
            Text("Loading roles...", style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      );
    }

    return DropdownButtonFormField2<int>(
      isExpanded: true,
      value: _selectedRoleId,
      items: _roles
          .map(
            (role) => DropdownMenuItem<int>(value: role["RoleId"], child: Text(role["RoleName"])),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedRoleId = value;
        });
      },
      decoration: InputDecoration(
        hintText: "Select Role*",
        prefixIcon: const Icon(Icons.work),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null) {
          return "Please select a role";
        }
        return null;
      },
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300.h,
        width: MediaQuery.of(context).size.width - 40.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      ),
      buttonStyleData: ButtonStyleData(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        height: 26.h,
        width: double.infinity,
      ),
    );
  }
}
