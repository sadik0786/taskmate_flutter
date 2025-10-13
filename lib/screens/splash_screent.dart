import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _colorAnimation = ColorTween(begin: Colors.blueAccent, end: Colors.white).animate(_controller);

    _controller.forward();

    // Delay a little to show splash nicely
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _checkAuthAndNavigate();
      }
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      await prefs.clear();
      Get.offNamed('/login');
      return;
    }
    // Check internet first
    if (!await ApiService.hasInternetConnection()) {
      if (mounted) {
        Get.snackbar(
          "No Internet",
          "Please check your connection",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return;
    }
    try {
      // Validate user exists on server
      final res = await ApiService.getCurrentUser();

      if (res["success"] != true || res["user"] == null) {
        await prefs.clear();
        Get.offNamed('/login');
        return;
      }

      // Save the latest info to prefs
      final user = res["user"];
      await prefs.setString("role", user["RoleName"] ?? "");
      await prefs.setInt("userId", user["ID"]);

      final pinVerified = await verifyPin(Get.context!);
      if (!pinVerified) {
        // User entered wrong PIN or closed dialog
        return;
      }

      // Navigate based on role
      final role = (user["RoleName"] ?? "").toLowerCase();
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
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          "Server Error",
          "Unable to connect to server. Please try again later.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                      ),
                      child: Icon(
                        Icons.work_outline,
                        size: 80.sp,
                        color: _colorAnimation.value ?? Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // App Name
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                    child: Column(
                      children: [
                        Text(
                          "Task Mate",
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Employee Task Management System",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 50.h),

              // Loading Indicator
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnimation.value,
                  child: SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.w,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Loading Text
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnimation.value,
                  child: Text(
                    "Loading...",
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> verifyPin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString("appLockPin");
    if (savedPin == null) return true;

    // Controllers and FocusNodes
    final List<TextEditingController> controllers = List.generate(
      4,
      (_) => TextEditingController(),
    );
    final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
    String? errorText;

    final result = await showModalBottomSheet<bool>(
      context: Get.context!,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(Get.context!).dialogBackgroundColor,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30.h),
                Text("Enter App Lock PIN", style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (i) {
                    return SizedBox(
                      width: 70.w,
                      // height: 60.h,
                      child: TextField(
                        autofocus: i == 0,
                        controller: controllers[i],
                        focusNode: focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: true,
                        cursorHeight: 30.sp,
                        cursorWidth: 2,
                        cursorColor: Colors.blueAccent,
                        style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && i < 3) {
                            FocusScope.of(context).requestFocus(focusNodes[i + 1]);
                          }
                          if (val.isEmpty && i > 0) {
                            FocusScope.of(context).requestFocus(focusNodes[i - 1]);
                          }
                        },
                      ),
                    );
                  }),
                ),
                if (errorText != null) ...[
                  SizedBox(height: 8.h),
                  Text(errorText!, style: const TextStyle(color: Colors.red)),
                ],
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await prefs.remove("appLockPin");
                        Navigator.pop(Get.context!, true);
                        Get.snackbar(
                          "Reset",
                          "PIN cleared, set a new one from profile",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      },
                      child: Text(
                        "Reset PIN?",
                        style: TextStyle(color: Colors.red, fontSize: 18.sp),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final enteredPin = controllers.map((c) => c.text).join();
                        if (enteredPin == savedPin) {
                          Navigator.pop(ctx, true);
                        } else {
                          setState(() {
                            errorText = "Incorrect PIN";
                            for (var c in controllers) {
                              c.clear();
                            }
                            FocusScope.of(context).requestFocus(focusNodes[0]);
                          });
                        }
                      },
                      child: const Text("Unlock"),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        );
      },
    );

    // ✅ Don't dispose here — let the framework clean up safely
    return result ?? false;
  }
}
