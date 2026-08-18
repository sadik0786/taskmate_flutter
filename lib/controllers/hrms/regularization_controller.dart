import 'package:get/get.dart';
import 'package:task_mate/services/hrms/regularization_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

class RegularizationController extends GetxController {
  var myRegularizations = <dynamic>[].obs;
  var pendingRegularizations = <dynamic>[].obs;
  RxBool isLoading = false.obs;

  Future<bool> applyRegularization({
    required String targetDate,
    required String reason,
    String? reqIn,
    String? reqOut,
  }) async {
    try {
      isLoading.value = true;
      final res = await RegularizationService.applyRegularization(
        targetDate: targetDate,
        reason: reason,
        requestedCheckIn: reqIn,
        requestedCheckOut: reqOut,
      );
      if (res["success"] == true) {
        CustomSnackBar.success("Regularization request submitted");
        fetchMyRegularizations();
        return true;
      } else {
        throw res["message"] ?? "Failed to apply";
      }
    } catch (e) {
      CustomSnackBar.error("Error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyRegularizations() async {
    try {
      isLoading.value = true;
      final data = await RegularizationService.getMyRegularizations();
      myRegularizations.assignAll(data);
    } catch (e) {
      CustomSnackBar.error("Failed to fetch my regularizations: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingRegularizations() async {
    try {
      isLoading.value = true;
      final data = await RegularizationService.getPendingRegularizations();
      pendingRegularizations.assignAll(data);
    } catch (e) {
      CustomSnackBar.error("Failed to fetch pending regularizations: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateRegularizationStatus(
    int reqId,
    String status,
    String hrReason,
  ) async {
    try {
      isLoading.value = true;
      final res = await RegularizationService.updateRegularizationStatus(
        reqId,
        status,
        hrReason,
      );
      if (res["success"] == true) {
        CustomSnackBar.success("Status updated to $status");
        fetchPendingRegularizations();
        return true;
      } else {
        throw res["message"] ?? "Failed to update status";
      }
    } catch (e) {
      CustomSnackBar.error("Error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
