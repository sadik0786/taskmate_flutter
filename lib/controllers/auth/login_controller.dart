import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/model/auth/login_request_model.dart';
import 'package:task_mate/services/base_api_service.dart';
import 'package:task_mate/services/auth/auth_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

class LoginController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  final formKey = GlobalKey<FormState>();
  Rx<TextEditingController> email = TextEditingController().obs;
  Rx<TextEditingController> password = TextEditingController().obs;
  RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
        );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    animationController.repeat(reverse: true);
    _autoFillDemoCredentials();
  }

  @override
  void onClose() {
    animationController.dispose();
    email.value.dispose();
    password.value.dispose();
    super.onClose();
  }

  void _autoFillDemoCredentials() {
    email.value.text = "dinesh@5nance.com";
    password.value.text = "admin\$123";
  }

  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!value.endsWith("@5nance.com")) {
      return "Only @5nance.com emails allowed";
    }
    if (!RegExp(r'^[\w-\.]+@5nance\.com$').hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<void> login() async {
    try {
      loading.value = true;
      if (!formKey.currentState!.validate()) return;
      // Check internet before hitting API
      if (!await BaseApiService.hasInternetConnection()) {
        loading.value = false;
        CustomSnackBar.info("No Internet-Please check your connection");
        return;
      }
      final request = LoginRequestModel(
        email: email.value.text.trim(),
        password: password.value.text.trim(),
      );
      final res = await AuthService.login(request);
      if (res.success == true && res.token != null) {
        final user = res.user;
        if (user == null) throw Exception("User data missing");
        final role = (user.role ?? user.roleId ?? "").toString().toLowerCase();
        final userId = user.id ?? user.id;
        if (role.isEmpty || userId == null) {
          throw Exception("Invalid user data");
        }
        // Persist session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", res.token ?? "");
        await prefs.setString("role", role);
        await prefs.setInt("userId", userId);
        if (kDebugMode) {
          print("token is: ${res.token}");
        }
        //  role-based navigation
        switch (role) {
          case "ceo":
          case "hr":
            Get.offNamed('/adminDashboard');
            break;
          case "superadmin":
          case "admin":
          case "employee":
            Get.offNamed('/homeScreen');
            break;
          default:
            await prefs.clear();
            Get.offNamed('/login');
            return;
        }
        CustomSnackBar.show(
          message: "Welcome ${user.name ?? 'User'}!",
          backgroundColor: Colors.green,
          icon: Icons.verified_user,
        );
      } else {
        final errorMsg = res.message ?? "Unable to login. Please try again.";
        CustomSnackBar.error(errorMsg);
      }
    } catch (e) {
      loading.value = false;
      CustomSnackBar.error(
        "Unable to connect to server. Please try again later.",
      );
    } finally {
      loading.value = false;
    }
  }
}
