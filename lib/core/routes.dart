import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/app_constants.dart';
import 'package:task_mate/screens/admin/add_task_screen.dart';
import 'package:task_mate/screens/auth/forgot_password.dart';
import 'package:task_mate/screens/user/home_screen.dart';
import 'package:task_mate/screens/hrms/hrms_dashboard.dart';
import 'package:task_mate/screens/hrms/admin/all_employee.dart';
import 'package:task_mate/screens/hrms/user/apply_leave.dart';
import 'package:task_mate/screens/hrms/user/dashboard.dart';
import 'package:task_mate/screens/auth/login_screen.dart';
import 'package:task_mate/screens/user/profile_screen.dart';
import 'package:task_mate/screens/splash_screent.dart';
// for admin pages
import 'package:task_mate/screens/admin/admin_dashboard.dart';
import 'package:task_mate/screens/admin/employee_screen.dart';
import 'package:task_mate/screens/admin/employee_detail_screen.dart';
import 'package:task_mate/screens/admin/employee_update_screen.dart';
import 'package:task_mate/screens/admin/project_screen.dart';
import 'package:task_mate/screens/admin/employee_task_screen.dart';
import 'package:task_mate/screens/auth/register_screen.dart';
import 'package:task_mate/screens/auth/reset_password.dart';
import 'package:task_mate/screens/user/task_screen.dart';
import 'package:task_mate/screens/hrms/admin/admin_attendance_report_screen.dart';
import 'package:task_mate/screens/hrms/admin/admin_regularization_requests_screen.dart';
import 'package:task_mate/screens/hrms/user/regularization_request_screen.dart';

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
  static const String employeeDetail = "/employeeDetail";
  static const String employeeUpdateScreen = "/employeeUpdateScreen";
  static const String employeeTaskScreen = "/employeeTaskScreen";
  static const String projectScreen = "/projectScreen";
  static const String resetPasswordPage = "/resetPasswordPage";
  //hrms screen
  static const String hrmsDashboard = "/hrms_dashboard";
  static const String applyLeave = "/applyLeave";
  static const String dashboard = "/dashboard";
  static const String approveLeave = "/approveLeave";
  static const String addEmployee = "/addEmployee";
  static const String allEmployee = "/allEmployee";
  // Attendance & Regularization
  static const String adminAttendanceReport = "/adminAttendanceReport";
  static const String adminRegularizationRequests = "/adminRegularizationRequests";
  static const String regularizationRequest = "/regularizationRequest";
}

const Duration transitionDuration = Duration(
  milliseconds: AppConstants.transitionDuration,
);

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
  _getPage(Routes.employeeDetail, EmployeeDetailScreen()),
  _getPage(Routes.employeeUpdateScreen, EmployeeUpdateScreen()),
  _getPage(Routes.projectScreen, ProjectScreen()),
  _getPage(Routes.employeeTaskScreen, EmployeeTaskScreen()),
  _getPage(Routes.resetPasswordPage, ResetPasswordPage()),
  //hrms screen
  _getPage(Routes.hrmsDashboard, HrmsDashboard()),
  _getPage(Routes.applyLeave, ApplyLeave()),
  _getPage(Routes.dashboard, Dashboard()),
  _getPage(Routes.allEmployee, AllLeavesReport()),
  // Attendance & Regularization
  _getPage(Routes.adminAttendanceReport, AdminAttendanceReportScreen()),
  _getPage(Routes.adminRegularizationRequests, AdminRegularizationRequestsScreen()),
  _getPage(Routes.regularizationRequest, RegularizationRequestScreen()),
];
