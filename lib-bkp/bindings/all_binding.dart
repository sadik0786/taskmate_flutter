import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/controllers/user/user_controller.dart';

class AllBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveController>(() => LeaveController());
    Get.lazyPut<UserController>(() => UserController());
  }
}
