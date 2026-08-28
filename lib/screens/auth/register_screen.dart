import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/auth/register_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_text_field.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/responsive_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController registerController = Get.put(RegisterController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Add Employee",
      customActions: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Get.until(
              (route) =>
                  route.settings.name == Routes.adminDashboard || route.isFirst,
            );
          },
        ),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Obx(
                    () => Card(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 4,
                      shadowColor: Theme.of(
                        context,
                      ).shadowColor.withOpacity(0.1),

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
                                  registerController.userName.value
                                      .toUpperCase(),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "Logged in as: ${registerController.currentUserRole.value.toUpperCase()}",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  "You can add: ${registerController.currentUserRole.value.toLowerCase() == "ceo"
                                      ? "HR / Accountant / Manager"
                                      : registerController.currentUserRole.value.toLowerCase() == "hr"
                                      ? "Admin / Employees"
                                      : "No permission"}",
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
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
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 16.h),
                        if (ResponsiveLayout.isDesktop(context))
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildRoleDropdown()),
                              SizedBox(width: 16.w),
                              Expanded(child: _buildAssignDropdown()),
                            ],
                          )
                        else ...[
                          _buildRoleDropdown(),
                          SizedBox(height: 10.h),
                          _buildAssignDropdown(),
                        ],
                        SizedBox(height: 10.h),
                        if (ResponsiveLayout.isDesktop(context))
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildNameField()),
                              SizedBox(width: 16.w),
                              Expanded(child: _buildEmailField()),
                            ],
                          )
                        else ...[
                          _buildNameField(),
                          SizedBox(height: 10.h),
                          _buildEmailField(),
                        ],
                        SizedBox(height: 10.h),
                        if (ResponsiveLayout.isDesktop(context))
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildMobileField()),
                              SizedBox(width: 16.w),
                              Expanded(child: _buildPasswordField()),
                            ],
                          )
                        else ...[
                          _buildMobileField(),
                          SizedBox(height: 10.h),
                          _buildPasswordField(),
                        ],
                        SizedBox(height: 20.h),
                        Obx(
                          () => CustomButton(
                            text: "Submit",
                            onPressed: () =>
                                registerController.register(_formKey),
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
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Obx(
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
    );
  }

  Widget _buildAssignDropdown() {
    return Obx(() {
      final currentRole = registerController.currentUserRole.value
          .toLowerCase();
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
        labelKey: "DisplayName",
        value: registerController.selectedAdminId.value,
        isEnabled: true,
        onChanged: (value) {
          registerController.selectedAdminId.value = value;
        },
      );
    });
  }

  Widget _buildNameField() {
    return CustomTextField(
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
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      labelText: "Employee Email",
      isRequired: true,
      hintText: "Enter email",
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      controller: registerController.email,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter email';
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
    );
  }

  Widget _buildMobileField() {
    return CustomTextField(
      labelText: "Employee Number",
      isRequired: false,
      hintText: "Enter number (Optional)",
      prefixIcon: Icons.phone,
      keyboardType: TextInputType.number,
      controller: registerController.mobile,
      maxLength: 10,
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
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
        if (value.length < 6) return "Password must be at least 6 characters";
        return null;
      },
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
            Text("Loading roles...", style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return DropdownButtonFormField2<int>(
      isExpanded: true,
      valueListenable: ValueNotifier(registerController.selectedRoleId.value),
      items: registerController.roles
          .map(
            (role) => DropdownItem<int>(
              value: role["RoleId"],
              child: Text(role["RoleName"]),
            ),
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
      buttonStyleData: FormFieldButtonStyleData(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        height: 26.h,
        width: double.infinity,
      ),
    );
  }
}
