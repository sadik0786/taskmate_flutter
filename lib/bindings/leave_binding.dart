import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';

class LeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveController>(() => LeaveController());
  }
}
