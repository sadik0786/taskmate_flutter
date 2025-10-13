import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/services/api_service.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter an email address")));
      return;
    }

    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a valid email address")));
      return;
    }

    setState(() => _loading = true);
    try {
      final exists = await ApiService.checkUserByEmail(email);
      if (!mounted) return;
      setState(() => _emailVerified = exists);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exists
                ? "Email verified. You can now set a new password."
                : "Email not found or you don't have permission",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPassword.text.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password must be at least 6 characters")));
      return;
    }

    setState(() => _loading = true);
    final res = await ApiService.changePassword(_email.text.trim(), _newPassword.text);
    setState(() => _loading = false);

    if (!mounted) return;
    if (res["success"] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password updated successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res["error"] ?? "Failed to update password")));
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
      backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
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
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: 40),
              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 40),
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
        Icon(Icons.lock_reset, size: 60, color: Theme.of(context).primaryColor.withOpacity(0.8)),
        const SizedBox(height: 10),
        Text(
          "Reset Employee Password",
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        Text(
          "Securely reset passwords for employees under your management",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600], height: 1.4),
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
        const Expanded(child: Divider(thickness: 2, color: Colors.grey)),
        _buildProgressStep(2, "Set Password", false),
      ],
    );
  }

  Widget _buildProgressStep(int stepNumber, String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? Theme.of(context).primaryColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      color: isCompleted ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isCompleted ? Theme.of(context).primaryColor : Colors.grey[600],
            fontSize: 12,
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
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter the email address of the employee whose password you want to reset",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Email Field
        TextFormField(
          controller: _email,
          decoration: InputDecoration(
            labelText: "Employee Email",
            // prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),

        // Verify Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _loading ? null : _checkEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Verify Email",
                        style: TextStyle(
                          fontSize: 16,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back button
        InkWell(
          onTap: _resetFlow,
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios_new, size: 16.sp, color: Theme.of(context).primaryColor),
              SizedBox(width: 4.w),
              Text(
                "Back to email verification",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
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
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        SizedBox(height: 8.h),
        Text(
          "Create a strong new password for ${_email.text}",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),

        // New Password Field
        TextFormField(
          controller: _newPassword,
          decoration: InputDecoration(
            labelText: "New Password",
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Password must be at least 6 characters long",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
        SizedBox(height: 32.h),

        // Update Button
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: _loading ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: _loading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_reset, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        "Update Password",
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
}
