import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/auth/register_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController registerController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text("Add Employee", style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
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
                Obx(
                  () => Card(
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
                                registerController.userName.value.toUpperCase(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Logged in as: ${registerController.currentUserRole.value.toUpperCase()}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                "You can add: ${registerController.currentUserRole.value.toLowerCase() == "ceo"
                                    ? "Hr / Accountant / Manager"
                                    : registerController.currentUserRole.value.toLowerCase() == "hr"
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
                ),
                Form(
                  key: registerController.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16.h),
                      Obx(
                        () => CustomDropdownField<int>(
                          isLoading: registerController.roleLoading.value,
                          labelText: "Select Role",
                          isRequired: true,
                          hintText: "Select Role",
                          prefixIcon: Icons.work,
                          items: registerController.roles,
                          valueKey: "RoleId",
                          labelKey: "RoleName",
                          value: registerController.selectedRoleId.value,
                          isEnabled: true,
                          onChanged: (value) async {
                            registerController.selectedRoleId.value = value;

                            final selectedRole = registerController.roles.firstWhere(
                              (r) => r["RoleId"] == value,
                              orElse: () => {},
                            );

                            final selectedRoleName = (selectedRole["RoleName"] ?? "")
                                .toString()
                                .toLowerCase();

                            final currentRole = registerController.currentUserRole.value
                                .toLowerCase();

                            if (currentRole == "hr") {
                              if (selectedRoleName == "admin") {
                                await registerController.loadSuperAdmins();
                              } else if (selectedRoleName == "employee") {
                                await registerController.loadAdminsAndSuperAdmins();
                              }
                            }
                          },

                        ),
                      ),
                      SizedBox(height: 10.h),
                      // select admin
                      Obx(() {
                        final currentRole = registerController.currentUserRole.value.toLowerCase();

                        final selectedRole = registerController.roles.firstWhere(
                          (r) => r["RoleId"] == registerController.selectedRoleId.value,
                          orElse: () => {},
                        );

                        final selectedRoleName = (selectedRole["RoleName"] ?? "")
                            .toString()
                            .toLowerCase();

                        final showAssignDropdown =
                            currentRole == "hr" &&
                            (selectedRoleName == "admin" || selectedRoleName == "employee");

                        if (!showAssignDropdown) return const SizedBox();

                        return CustomDropdownField<int>(
                          isLoading: registerController.adminLoading.value,
                          labelText: "Assign To",
                          isRequired: true,
                          hintText: "Select Reporting Person",
                          prefixIcon: Icons.admin_panel_settings,
                          items: registerController.admins,
                          valueKey: "ID",
                          labelKey: "Name",
                          value: registerController.selectedAdminId.value,
                          isEnabled: true,
                          onChanged: (value) {
                            registerController.selectedAdminId.value = value;
                          },
                        );
                      }),

                      // Dropdown for Role
                      // dropDownList(context),
                      SizedBox(height: 10.h),
                      CustomTextField(
                        labelText: "Employee Name",
                        isRequired: true,
                        hintText: "Enter name",
                        prefixIcon: Icons.person,
                        controller: registerController.name,
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
                        controller: registerController.email,
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
                        controller: registerController.mobile,
                        maxLength: 10,
                      ),
                      SizedBox(height: 0.h),
                      CustomTextField(
                        labelText: "Employee Password",
                        isRequired: true,
                        hintText: "Enter password",
                        prefixIcon: Icons.lock,
                        keyboardType: TextInputType.emailAddress,
                        controller: registerController.password,
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
                      Obx(
                        () => CustomButton(
                          text: "Submit",
                          onPressed: registerController.register,
                          isLoading: registerController.loading.value,
                        ),
                      ),
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
    if (registerController.roleLoading.value) {
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
      value: registerController.selectedRoleId.value,
      items: registerController.roles.value
          .map(
            (role) => DropdownMenuItem<int>(value: role["RoleId"], child: Text(role["RoleName"])),
          )
          .toList(),
      onChanged: (value) {
        registerController.selectedRoleId.value = value;
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
