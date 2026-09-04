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
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return _buildDesktopLayout(context);
            } else {
              return _buildMobileLayout(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ), // Ensures login card doesn't stretch on wide screens
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50.h),
              _buildAnimatedLogo(context),
              const SizedBox(height: 20),
              _buildLoginForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left Branding Panel
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/5nance-logo-white.png", height: 50.h),
                    SizedBox(height: 30.h),
                    Text(
                      "Task Mate",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Smart Attendance & Leave Manager",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    _buildFeatureItem(
                      Icon(Icons.touch_app, color: Colors.white70, size: 24.sp),
                      "Easy Clock In/Out",
                    ),
                    SizedBox(height: 15.h),
                    _buildFeatureItem(
                      Icon(
                        Icons.date_range,
                        color: Colors.white70,
                        size: 24.sp,
                      ),
                      "Manage Leaves Seamlessly",
                    ),
                    SizedBox(height: 15.h),
                    _buildFeatureItem(
                      Icon(
                        Icons.insert_chart,
                        color: Colors.white70,
                        size: 24.sp,
                      ),
                      "Real-time Reports",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Right Form Panel
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome Back",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please sign in to continue",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildLoginForm(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(Widget iconWidget, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(width: 10.w),
        Text(
          text,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLogo(BuildContext context) {
    return SlideTransition(
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
            Text("Task Mate", style: Theme.of(context).textTheme.bodySmall),
            Text(
              "Smart Attendance & Leave Manager",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      color: Theme.of(context).cardColor,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 40.w : 14.w),
        child: Form(
          key: loginController.formKey,
          child: Column(
            children: [
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
              SizedBox(height: isDesktop ? 40.h : 20.h),
              CustomTextField(
                labelText: "Password",
                isRequired: true,
                hintText: "Enter password",
                prefixIcon: Icons.lock,
                controller: loginController.password.value,
                isObscure: true,
                validator: loginController.validatePassword,
              ),
              SizedBox(height: isDesktop ? 50.h : 30.h),
              Obx(() => CustomButton(
                text: "Login",
                onPressed: loginController.login,
                isLoading: loginController.loading.value,
                padding: EdgeInsets.symmetric(vertical: 24.h),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
