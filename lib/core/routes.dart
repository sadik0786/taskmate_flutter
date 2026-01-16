import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/app_constants.dart';
import 'package:task_mate/screens/add_task_screen.dart';
import 'package:task_mate/screens/forgot_password.dart';
import 'package:task_mate/screens/home_screen.dart';
import 'package:task_mate/screens/hrms/hrms_dashboard.dart';
import 'package:task_mate/screens/hrms/widgets/apply_leave.dart';
import 'package:task_mate/screens/hrms/widgets/approve_leave.dart';
import 'package:task_mate/screens/hrms/widgets/dashboard.dart';
import 'package:task_mate/screens/login_screen.dart';
import 'package:task_mate/screens/profile_screen.dart';
import 'package:task_mate/screens/splash_screent.dart';
// for admin pages
import 'package:task_mate/screens/admin/admin_dashboard.dart';
import 'package:task_mate/screens/admin/employee_screen.dart';
import 'package:task_mate/screens/admin/project_screen.dart';
import 'package:task_mate/screens/admin/employee_task_screen.dart';
import 'package:task_mate/screens/admin/register_screen.dart';
import 'package:task_mate/screens/admin/reset_password.dart';
import 'package:task_mate/screens/task_screen.dart';

class Routes {
  static const String initialRoute = "/splash";
  static const String login = "/login";
  static const String homeScreen = "/homeScreen";
  static const String addTaskScreen = "/addTaskScreen";
  static const String addSubProjectScreen = "/addSubProjectScreen";
  static const String taskScreen = "/taskScreen";
  static const String forgotPasswordPage = "/forgotPasswordPage";
  static const String profileScreen = "/profileScreen";
  // for admin pages
  static const String adminDashboard = "/adminDashboard";
  static const String registerScreen = "/registerScreen";
  static const String employeeScreen = "/employeeScreen";
  static const String employeeTaskScreen = "/employeeTaskScreen";
  static const String projectScreen = "/projectScreen";
  static const String resetPasswordPage = "/resetPasswordPage";
  //hrms screen
  static const String hrmsDashboard = "/hrms_dashboard";
  static const String applyLeave = "/applyLeave";
  static const String dashboard = "/dashboard";
  static const String approveLeave = "/approveLeave";
}

const Duration transitionDuration = Duration(milliseconds: AppConstants.transitionDuration);

GetPage _getPage(String name, Widget page) => GetPage(
  name: name,
  page: () => page,
  transition: AppConstants.transition,
  fullscreenDialog: true,
  transitionDuration: transitionDuration,
);

List<GetPage> appPages() => [
  _getPage(Routes.initialRoute, SplashScreen()),
  _getPage(Routes.login, LoginScreen()),
  _getPage(Routes.homeScreen, HomeScreen()),
  _getPage(Routes.addTaskScreen, AddTaskScreen()),
  _getPage(Routes.taskScreen, TaskScreen()),
  _getPage(Routes.forgotPasswordPage, ForgotPasswordPage()),
  _getPage(Routes.profileScreen, ProfileScreen()),
  // for admin pages
  _getPage(Routes.registerScreen, RegisterScreen()),
  _getPage(Routes.adminDashboard, AdminDashboard()),
  _getPage(Routes.employeeScreen, EmployeeScreen()),
  _getPage(Routes.projectScreen, ProjectScreen()),
  _getPage(Routes.employeeTaskScreen, EmployeeTaskScreen()),
  _getPage(Routes.resetPasswordPage, ResetPasswordPage()),
  //hrms screen
  _getPage(Routes.hrmsDashboard, HrmsDashboard()),
  _getPage(Routes.applyLeave, ApplyLeave()),
  _getPage(Routes.dashboard, Dashboard()),
  _getPage(Routes.approveLeave, ApproveLeave()),
];
