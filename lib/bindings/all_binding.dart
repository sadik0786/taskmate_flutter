import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/attendance_controller.dart';
import 'package:task_mate/controllers/hrms/admin_hrms_controller.dart';
import 'package:task_mate/controllers/hrms/regularization_controller.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/controllers/admin/employee_controller.dart';

class AllBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceController(), fenix: true);
    Get.lazyPut(() => AdminHrmsController(), fenix: true);
    Get.lazyPut(() => RegularizationController(), fenix: true);
    Get.lazyPut<LeaveController>(() => LeaveController(), fenix: true);
    Get.lazyPut<UserController>(() => UserController());
  }
}
