import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/auth/login_controller.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ), // Ensures login card doesn't stretch on wide screens
            child: SingleChildScrollView(
              padding: EdgeInsets.all(6.sp),
              child: Column(
                children: [
                  SizedBox(height: 50.h),
                  // Animated Logo
                  SlideTransition(
                    position: loginController.slideAnimation,
                    child: FadeTransition(
                      opacity: loginController.fadeAnimation,
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 40.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Task Mate",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            "Complete Employee Hub",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Login Card
                  Card(
                    margin: EdgeInsets.only(left: 10.w, right: 10.w),
                    color: Theme.of(context).cardColor,
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(14.w),
                      child: Form(
                        key: loginController.formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            CustomTextField(
                              isEnabled: true,
                              labelText: "Email ID",
                              isRequired: true,
                              hintText: "Enter username Id",
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              controller: loginController.email.value,
                              validator: loginController.validateEmail,
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              labelText: "Password",
                              isRequired: true,
                              hintText: "Enter password",
                              prefixIcon: Icons.lock,
                              controller: loginController.password.value,
                              isObscure: true,
                              validator: loginController.validatePassword,
                            ),
                            SizedBox(height: 30.h),
                            //  Login Button
                            CustomButton(
                              text: "Login",
                              onPressed: loginController.login,
                              isLoading: loginController.loading.value,
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
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
}
