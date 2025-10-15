import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/services/api_service.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.repeat(reverse: true);

    _autoFillDemoCredentials();
  }

  // ✅ Auto-fill for testing
  void _autoFillDemoCredentials() {
    _email.text = "deepak.kadam@5nance.com";
    _password.text = "admin\$123";
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // ✅ Check internet before hitting API
    if (!await ApiService.hasInternetConnection()) {
      setState(() => _loading = false);
      Get.snackbar(
        "No Internet",
        "Please check your connection",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final res = await ApiService.login(_email.text.trim(), _password.text.trim());
      if (!mounted) return;

      setState(() => _loading = false);

      if (res["success"] == true && res["token"] != null) {
        final user = res["user"];
        if (user == null) throw Exception("User data missing");

        final role = (user?["role"] ?? user["RoleName"] ?? "").toString().toLowerCase();
        final userId = user["id"] ?? user["ID"];

        if (role.isEmpty || userId == null) throw Exception("Invalid user data");

        // ✅ Persist session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", res["token"]);
        await prefs.setString("role", role);
        await prefs.setInt("userId", userId);

        // ✅ Enhanced role-based navigation
        switch (role) {
          case "superadmin":
          case "admin":
            Get.offNamed('/adminDashboard');
            break;
          case "employee":
            Get.offNamed('/homeScreen');
            break;
          default:
            await prefs.clear();
            Get.offNamed('/login');
            return;
        }

        // ✅ Show welcome message
        Get.snackbar(
          "Welcome ${user['name'] ?? 'User'}!",
          "Logged in as ${role.toUpperCase()}",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final errorMsg = res["error"] ?? "Unable to login. Please try again.";

        Get.snackbar(
          "Login Failed",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      Get.snackbar(
        "Server Error",
        "Unable to connect to server. Please try again later.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Email validation
  String? _validateEmail(String? value) {
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
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6.sp),
          child: Column(
            children: [
              SizedBox(height: 50.h),
              // Animated Logo
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: 40.sp, color: Colors.white),
                      SizedBox(height: 10.h),
                      Text(
                        "Task Mate",
                        style: Theme.of(context).textTheme.bodyLarge,
                        // style: TextStyle(
                        //   fontSize: 28.sp,
                        //   fontWeight: FontWeight.bold,
                        //   color: Colors.white,
                        //   letterSpacing: 1.5,
                        // ),
                      ),
                      Text(
                        "Employee Task Management",
                        style: Theme.of(context).textTheme.titleMedium,
                        // style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Login Card
              Card(
                margin: EdgeInsets.only(left: 10.w, right: 10.w),
                color: ThemeClass.darkCardColor,
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Access Account",
                          style: Theme.of(context).textTheme.bodyMedium,
                          //  TextStyle(
                          //   fontSize: 26.sp,
                          //   fontWeight: FontWeight.w700,
                          //   color: ThemeClass.textWhite,
                          // ),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          isEnabled: true,
                          labelText: "Email ID",
                          isRequired: true,
                          hintText: "Enter username Id",
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          controller: _email,
                          validator: _validateEmail,
                        ),
                        SizedBox(height: 20.h),
                        CustomTextField(
                          labelText: "Password",
                          isRequired: true,
                          hintText: "Enter password",
                          prefixIcon: Icons.lock,
                          controller: _password,
                          isObscure: true,
                          validator: _validatePassword,
                        ),

                        SizedBox(height: 30.h),

                        //  Login Button
                        CustomButton(text: "Login", onPressed: _login, isLoading: _loading),

                        // const SizedBox(height: 10),
                        // GestureDetector(
                        //   onTap: () {
                        //     Get.toNamed(Routes.forgotPasswordPage);
                        //   },
                        //   child: Row(
                        //     children: [
                        //       SizedBox(width: 8),
                        //       Text(
                        //         "Forgot password?",
                        //         style: TextStyle(
                        //           color: Theme.of(context).primaryColor,
                        //           fontWeight: FontWeight.w500,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: 20.h),

                        // ✅ Demo Credentials Hint
                        // Container(
                        //   padding: EdgeInsets.all(12),
                        //   decoration: BoxDecoration(
                        //     color: Colors.blueAccent.withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(8),
                        //     border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       Icon(Icons.info, color: Colors.blueAccent, size: 16),
                        //       SizedBox(width: 8),
                        //       Expanded(
                        //         child: Text(
                        //           "Demo credentials pre-filled for testing",
                        //           style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
