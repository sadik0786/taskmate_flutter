import 'package:get/get.dart';
import 'package:task_mate/model/leave_type_model.dart';
import 'package:task_mate/model/leave_apply_request_model.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/services/hrms_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

class LeaveController extends GetxController {
  RxList<LeaveTypeModel> leaveTypes = <LeaveTypeModel>[].obs;
  RxList<LeaveRequestModel> myLeaves = <LeaveRequestModel>[].obs;
  RxList<LeaveRequestModel> otherLeavesRequest = <LeaveRequestModel>[].obs;

  RxBool isLoading = false.obs;
  RxString userRole = "".obs;
  
  // Stats counts (observable properties)
  RxInt pendingLeave = 0.obs;
  RxInt approvedLeave = 0.obs;
  RxInt totalApplyLeave = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaveTypes();
    fetchMyLeaves();
    getOtherLeaveRequest();
  }

  Future<void> fetchLeaveTypes() async {
    try {
      isLoading.value = true;
      final data = await ApiHrmsService.fetchAllLeaveTypes();
      leaveTypes.assignAll(data.map((e) => LeaveTypeModel.fromJson(e)).toList());
      leaveTypes.refresh();
    } catch (e) {
      CustomSnackBar.error("Error - $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyLeaves() async {
    try {
      isLoading.value = true;
      final data = await ApiHrmsService.fetchMyLeaves();
      myLeaves.assignAll(data);
      _calculateMyStats();
      myLeaves.refresh();
    } catch (e) {
      CustomSnackBar.error("Failed to fetch leaves: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateMyStats() {
    pendingLeave.value = myLeaves.where((e) => e.status == "PENDING").length;
    approvedLeave.value = myLeaves.where((e) => e.status == "APPROVED").length;
    totalApplyLeave.value = myLeaves.length;
  }

  // apply leave for all
  Future<bool> applyLeave(LeaveApplyRequestModel request) async {
    try {
      isLoading.value = true;
      final res = await ApiHrmsService.applyLeave(request);

      if (res["success"] == true) {
        fetchMyLeaves();
        return true;
      } else {
        throw res["message"] ?? "Failed";
      }
    } catch (err) {
      CustomSnackBar.error("Error - $err");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  //show other leave request
  Future<void> getOtherLeaveRequest() async {
    try {
      isLoading.value = true;
      final data = await ApiHrmsService.fetchOtherLeaveRequest();
      otherLeavesRequest.assignAll(data);
      pendingLeave.value = data.where((e) => e.status == "PENDING").length;
      approvedLeave.value = data.where((e) => e.status == "APPROVED").length;
      totalApplyLeave.value = data.length;
    } catch (e) {
      CustomSnackBar.error("Failed to fetch other requests: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // approve leave by hr
  Future<void> updateLeaveStatus(int leaveId, String status, String hrReason) async {
    try {
      isLoading.value = true;

      final res = await ApiHrmsService.updateLeaveStatus(leaveId, status, hrReason: hrReason);

      if (res["success"] == true) {
        fetchMyLeaves();
        CustomSnackBar.success("Leave $status");
        await getOtherLeaveRequest();
      } else {
        throw res["message"] ?? res["error"];
      }
    } catch (e) {
      CustomSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
