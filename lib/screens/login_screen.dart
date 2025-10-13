import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/services/api_service.dart';

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
  bool _obscurePassword = true;

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
        final error = res["error"] ?? "Login failed. Please try again.";
        Get.snackbar("Login Failed", error, backgroundColor: Colors.red, colorText: Colors.white);
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
      backgroundColor: const Color(0xFF1a1a1a),
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
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        "Employee Task Management",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Login Card
              Card(
                color: Colors.white.withOpacity(0.05),
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Access Account",
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ✅ Email Field
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Email ID",
                            labelStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.email, color: Colors.white70),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2.w),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                          ),
                          validator: _validateEmail,
                        ),

                        SizedBox(height: 20.h),

                        // Password Field
                        TextFormField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.lock, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                          ),
                          validator: _validatePassword,
                        ),

                        SizedBox(height: 30.h),

                        //  Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _loading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

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
