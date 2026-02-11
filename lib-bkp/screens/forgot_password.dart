import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/services/api_service.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _loading = false;
  bool _emailVerified = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _checkEmail() async {
    if (_email.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your email address");
      return;
    }
    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(_email.text.trim())) {
      _showErrorSnackBar("Please enter a valid email address");
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.forgotPasswordRequest(_email.text.trim());
      setState(() {
        _loading = false;
        _emailVerified = res["success"] == true;
      });
      if (!mounted) return;
      if (res["success"] == true) {
        _showErrorSnackBar("Email not found in our system");
      } else {
        _showSuccessSnackBar("Email verified! Please set your new password");
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      _showErrorSnackBar("Error: ${e.toString()}");
    }
  }

  Future<void> _changePassword() async {
    if (_newPassword.text.length < 6) {
      _showErrorSnackBar("Password must be at least 6 characters");
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      _showErrorSnackBar("Passwords do not match");
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService.resetPasswordSelf(_email.text.trim(), _newPassword.text);
      setState(() => _loading = false);

      if (!mounted) return;
      if (res["success"] == true) {
        _showSuccessSnackBar("Password updated successfully!");
        _navigateToHome();
      } else {
        _showErrorSnackBar(res["error"] ?? "Failed to update password");
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      _showErrorSnackBar("Error: ${e.toString()}");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString("role") ?? "user";
    await Future.delayed(const Duration(seconds: 1));

    if (role == "admin" || role == "superadmin") {
      Get.offAllNamed(Routes.login);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  void _resetFlow() {
    setState(() {
      _emailVerified = false;
      _newPassword.clear();
      _confirmPassword.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text("Forgot Password", style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: _navigateToHome,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header Section
            _buildHeaderSection(),
            SizedBox(height: 40.h),
            // Progress Indicator
            _buildProgressIndicator(),
            SizedBox(height: 40.h),
            // Content based on step
            if (!_emailVerified) _buildEmailVerificationStep(),
            if (_emailVerified) _buildPasswordResetStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_reset_rounded, size: 40.sp, color: Theme.of(context).primaryColor),
        ),
        SizedBox(height: 24.h),
        Text(
          "Reset Your Password",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
            fontSize: 28.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          "Enter your email address and we'll help you reset your password",
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600], height: 1.5.h),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep(1, "Verify Email", _emailVerified),
        Expanded(
          child: Container(
            height: 2.h,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              gradient: _emailVerified
                  ? LinearGradient(
                      colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor],
                    )
                  : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade300]),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        _buildProgressStep(2, "New Password", false),
      ],
    );
  }

  Widget _buildProgressStep(int stepNumber, String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: isCompleted ? Theme.of(context).primaryColor : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? Theme.of(context).primaryColor : Colors.grey.shade400,
              width: 2.w,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 20.sp)
                : Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      color: isCompleted ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: isCompleted ? Theme.of(context).primaryColor : Colors.grey.shade600,
            fontSize: 12.sp,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Step 1: Verify Your Identity",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        SizedBox(height: 8.h),
        Text(
          "Enter the email address associated with your account",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 24.h),

        // Email Field
        TextFormField(
          controller: _email,
          decoration: InputDecoration(
            labelText: "Your Email Address",
            hintText: "Enter your registered email",
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.w),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 32.h),

        // Verify Button
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: _loading ? null : _checkEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 2,
            ),
            child: _loading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.w),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined, size: 20.sp),
                      SizedBox(width: 12.w),
                      Text(
                        "Verify Email",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordResetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        InkWell(
          onTap: _resetFlow,
          child: Container(
            padding: EdgeInsets.all(8.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new, size: 16.sp, color: Theme.of(context).primaryColor),
                SizedBox(width: 4.w),
                Text(
                  "Back to email",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),

        Text(
          "Step 2: Create New Password",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        SizedBox(height: 8.h),
        Text(
          "Create a strong password to secure your account",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 24.h),

        // New Password Field
        TextFormField(
          controller: _newPassword,
          obscureText: _obscureNewPassword,
          decoration: InputDecoration(
            labelText: "New Password",
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.w),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Confirm Password Field
        TextFormField(
          controller: _confirmPassword,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            prefixIcon: const Icon(Icons.lock_reset_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.w),
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // Password requirements
        _buildPasswordRequirements(),
        SizedBox(height: 32.h),

        // Update Button
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: _loading ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 2,
            ),
            child: _loading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.w),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_reset, size: 20.sp),
                      SizedBox(width: 12.w),
                      Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password must:",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(
              _newPassword.text.length >= 6 ? Icons.check_circle : Icons.circle,
              size: 14.sp,
              color: _newPassword.text.length >= 6 ? Colors.green : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              "Be at least 6 characters long",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Icon(
              _newPassword.text.isNotEmpty && _newPassword.text == _confirmPassword.text
                  ? Icons.check_circle
                  : Icons.circle,
              size: 14.sp,
              color: _newPassword.text.isNotEmpty && _newPassword.text == _confirmPassword.text
                  ? Colors.green
                  : Colors.grey.shade400,
            ),
            SizedBox(width: 6.w),
            Text(
              "Passwords must match",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
