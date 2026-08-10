import 'package:get/get.dart';
import 'package:task_mate/model/user_request_model.dart';
import 'package:task_mate/services/hrms/hrms_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

class UserController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<UserRequestModel> allEmployee = <UserRequestModel>[].obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getAllEmployee();
  }

  Future<void> getAllEmployee() async {
    try {
      isLoading.value = true;
      final data = await ApiHrmsService.allEmployee();
      allEmployee.assignAll(data);
    } catch (e) {
      CustomSnackBar.error("Error - $e");
    } finally {
      isLoading.value = false;
    }
  }
}
