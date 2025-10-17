import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/services/api_service.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  bool _loading = false;
  bool _emailVerified = false;

  Future<void> _checkEmail() async {
    final email = _email.text.trim();

    if (email.isEmpty) {
      if (!mounted) return;
      CustomSnackBar.error("Please enter an email address");
      return;
    }

    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email)) {
      if (!mounted) return;
      CustomSnackBar.error("Please enter a valid email address");
      return;
    }
    setState(() => _loading = true);
    try {
      final exists = await ApiService.checkUserByEmail(email);
      if (!mounted) return;
      setState(() => _emailVerified = exists);
      CustomSnackBar.error(
        exists
            ? "Email verified. You can now set a new password."
            : "Email not found or you don't have permission",
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       exists
      //           ? "Email verified. You can now set a new password."
      //           : "Email not found or you don't have permission",
      //     ),
      //   ),
      // );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPassword.text.length < 6) {
      CustomSnackBar.warning("Password must be at least 6 characters");
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text("Password must be at least 6 characters")));
      return;
    }

    setState(() => _loading = true);
    final res = await ApiService.changePassword(_email.text.trim(), _newPassword.text);
    setState(() => _loading = false);

    if (!mounted) return;
    if (res["success"] == true) {
      CustomSnackBar.success("Password updated successfully");
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text("Password updated successfully")));
      Navigator.pop(context);
    } else {
      CustomSnackBar.error("Failed to update password");
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text(res["error"] ?? "Failed to update password")));
    }
  }

  void _resetFlow() {
    setState(() {
      _emailVerified = false;
      _newPassword.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text("Reset Password", style: Theme.of(context).textTheme.titleLarge),
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
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.lock_reset, size: 60.sp, color: Theme.of(context).primaryColor.withOpacity(0.8)),
        SizedBox(height: 10.h),
        Text(
          "Reset Employee Password",
          style: Theme.of(
            context,
          ).textTheme.titleLarge,
        ),
        SizedBox(height: 8.h),
        Text(
          "Securely reset passwords for employees under your management",
          style: Theme.of(
            context,
          ).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProgressStep(1, "Verify Email", _emailVerified),
        Expanded(
          child: Divider(thickness: 2.w, color: Colors.grey),
        ),
        _buildProgressStep(2, "Set Password", false),
      ],
    );
  }

  Widget _buildProgressStep(int stepNumber, String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: isCompleted ? Theme.of(context).primaryColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 18.sp)
                : Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      color: isCompleted ? ThemeClass.primaryGreen : ThemeClass.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            color: isCompleted ? ThemeClass.primaryGreen : ThemeClass.darkBlue,
            fontSize: 12.sp,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Step 1: Verify Employee Email",
          style: Theme.of(
            context,
          ).textTheme.titleLarge,
        ),
        SizedBox(height: 8.h),
        Text(
          "Enter the email address of the employee whose password you want to reset",
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),

        // Email Field
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
        // TextFormField(
        //   controller: _email,
        //   decoration: InputDecoration(
        //     labelText: "Employee Email",
        //     // prefixIcon: const Icon(Icons.email_outlined),
        //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        //     focusedBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(12),
        //       borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        //     ),
        //   ),
        //   keyboardType: TextInputType.emailAddress,
        // ),
        SizedBox(height: 32.h),

        // Verify Button
        CustomButton(text: "Verify Email", onPressed: _checkEmail, isLoading: _loading),
        
      ],
    );
  }

  Widget _buildPasswordResetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back button
        InkWell(
          onTap: _resetFlow,
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios_new, size: 16.sp, color: ThemeClass.darkBlue),
              SizedBox(width: 4.w),
              Text(
                "Back to email verification",
                style: TextStyle(
                  color: ThemeClass.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        Text(
          "Step 2: Set New Password",
          style: Theme.of(
            context,
          ).textTheme.titleMedium,
        ),
        SizedBox(height: 8.h),
        Text(
          "Create a strong new password for",
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          _email.text,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: ThemeClass.warningColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),

        // New Password Field
        CustomTextField(
          labelText: "Change Password",
          isRequired: true,
          hintText: "Enter password",
          prefixIcon: Icons.lock,
          keyboardType: TextInputType.text,
          controller: _newPassword,
          isObscure: true,
          // maxLength: 10,
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
     
      
        SizedBox(height: 32.h),

        // Update Button
        CustomButton(
          text: "Update Password",
          onPressed: _changePassword,
          isLoading: _loading,
          icon: Icons.lock_reset,
        ),
      ],
    );
  }
}
