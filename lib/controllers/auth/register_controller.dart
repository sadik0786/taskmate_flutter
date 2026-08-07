import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/model/auth/register_request_model.dart';
import 'package:task_mate/services/auth_service.dart';
import 'package:task_mate/services/user_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final mobile = TextEditingController();

  // Reactive states
  final loading = false.obs;
  final roleLoading = false.obs;

  final userName = ''.obs;
  final currentUserRole = ''.obs;

  RxList<Map<String, dynamic>> admins = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> roles = <Map<String, dynamic>>[].obs;
  RxBool adminLoading = false.obs;
  RxnInt selectedAdminId = RxnInt();

  final selectedRoleId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    password.dispose();
    mobile.dispose();
    super.onClose();
  }

  Future<void> _initializeData() async {
    await loadUserRole();
    await loadRoles();
    // if (currentUserRole.value == "ceo") {
    //   await loadAdmins();
    // }
  }

  Future<void> loadAdmins() async {
    adminLoading.value = true;

    try {
      final res = await UserService.getAdmins();

      adminLoading.value = false;

      if (res["success"] == true && res["ceo"] != null) {
        admins.value = List<Map<String, dynamic>>.from(res["ceo"]);
        selectedAdminId.value = null;
      } else {
        admins.clear();
        selectedAdminId.value = null;
      }
    } catch (e) {
      adminLoading.value = false;
      admins.clear();
      selectedAdminId.value = null;
    }
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString("name") ?? "Employee";
    currentUserRole.value = prefs.getString("role")?.toLowerCase() ?? '';
  }

  Future<void> loadRoles() async {
    roleLoading.value = true;

    try {
      String? loggedRole = currentUserRole.value;
      if (loggedRole.isEmpty) {
        loggedRole = await UserService.getCurrentUserRole();
        if (loggedRole != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("role", loggedRole);
          currentUserRole.value = loggedRole;
        }
      }

      final res = await AuthService.getRoles();

      roleLoading.value = false;

      if (res["success"] == true && res["data"] != null) {
        var allRoles = List<Map<String, dynamic>>.from(res["data"]);

        // Filter roles based on logged-in role
        final roleLower = (loggedRole ?? "").toLowerCase();

        if (roleLower == "ceo") {
          allRoles = allRoles.where((r) {
            final roleName = (r["RoleName"] ?? "").toString().toLowerCase();
            return roleName == "hr" || roleName == "accountant" || roleName == "superadmin";
          }).toList();
        } else if (roleLower == "hr") {
          allRoles = allRoles.where((r) {
            final roleName = (r["RoleName"] ?? "").toString().toLowerCase();
            return roleName == "admin" || roleName == "employee";
          }).toList();
        } else {
          allRoles = [];
        }

        roles.value = allRoles;

        // Set default selection if roles exist
        if (roles.isNotEmpty) {
          selectedRoleId.value = roles.first["RoleId"];
        } else {
          selectedRoleId.value = null;
        }
      } else {
        roles.clear();
        selectedRoleId.value = null;
      }
    } catch (e) {
      roleLoading.value = false;
      roles.clear();
      selectedRoleId.value = null;
    }
  }

  Future<void> loadSuperAdmins() async {
    adminLoading.value = true;
    selectedAdminId.value = null;
    admins.clear();

    try {
      final res = await UserService.getUsersByRole("superadmin");

      if (res["success"] == true && res["data"] != null) {
        admins.value = List<Map<String, dynamic>>.from(res["data"]);
      } else {
        admins.clear();
      }
    } catch (e) {
      admins.clear();
    }

    adminLoading.value = false;
  }

  Future<void> loadAdminsAndSuperAdmins() async {
    adminLoading.value = true;
    selectedAdminId.value = null;
    admins.clear();

    try {
      final res = await UserService.getUsersByRoles(["admin", "superadmin"]);

      if (res["success"] == true && res["data"] != null) {
        admins.value = List<Map<String, dynamic>>.from(res["data"]);
      } else {
        admins.clear();
      }
    } catch (e) {
      admins.clear();
    }

    adminLoading.value = false;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    final roleId = selectedRoleId.value;
    if (roleId == null) {
      CustomSnackBar.error("Please select a role");
      return;
    }

    loading.value = true;

    final currentRole = currentUserRole.value.toLowerCase();

    final selectedRoleData = roles.firstWhere((r) => r["RoleId"] == roleId, orElse: () => {});

    final selectedRoleName = (selectedRoleData["RoleName"] ?? "").toString().toLowerCase();

    // Superadmin assigning employee must select admin
    if ((currentRole == 'hr' || currentRole == 'superadmin') &&
        (selectedRoleName == 'admin' || selectedRoleName == 'employee') &&
        selectedAdminId.value == null) {
      loading.value = false;
      CustomSnackBar.error("Please select Assign To");
      return;
    }

    // ✅ Create Request Model
    final request = RegisterRequestModel(
      name: name.value.text.trim(),
      email: email.value.text.trim(),
      mobile: mobile.value.text.trim(),
      password: password.value.text.trim(),
      roleId: roleId,
      reportingId: selectedAdminId.value,
    );

    // ✅ Call API
    final response = await AuthService.registerEmployee(request);

    loading.value = false;

    // ✅ Handle Typed Response
    if (response.success == true) {
      CustomSnackBar.success("Added successfully!");
      Get.back();
    } else {
      CustomSnackBar.error("Failed to add employee");
    }
  }
}

