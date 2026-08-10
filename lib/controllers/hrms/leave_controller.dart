import 'package:get/get.dart';
import 'package:task_mate/model/leave_type_model.dart';
import 'package:task_mate/model/leave_apply_request_model.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/services/hrms/hrms_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

class LeaveController extends GetxController {
  RxList<LeaveTypeModel> leaveTypes = <LeaveTypeModel>[].obs;
  RxList<LeaveRequestModel> myLeaves = <LeaveRequestModel>[].obs;
  RxList<LeaveRequestModel> otherLeavesRequest = <LeaveRequestModel>[].obs;

  // All leaves report for HR
  var allLeaveReport = <LeaveRequestModel>[].obs;
  var filteredLeaveReport = <LeaveRequestModel>[].obs;

  var todayLeaves = <LeaveRequestModel>[].obs;

  // Phase 2 & 3 State
  var holidays = <dynamic>[].obs;
  var myPayslips = <dynamic>[].obs;
  var todayEvents = <dynamic>[].obs;
  var todayAttendance = Rxn<Map<String, dynamic>>();
  var attendanceHistory = <dynamic>[].obs;

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
    fetchHolidays();
    fetchTodayAttendance();
    fetchMyPayslips();
  }

  Future<void> fetchLeaveTypes() async {
    try {
      isLoading.value = true;
      final data = await ApiHrmsService.fetchAllLeaveTypes();
      leaveTypes.assignAll(
        data.map((e) => LeaveTypeModel.fromJson(e)).toList(),
      );
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
    } catch (e) {
      CustomSnackBar.error("Failed to fetch other requests: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // approve leave by hr
  Future<void> updateLeaveStatus(
    int leaveId,
    String status,
    String hrReason,
  ) async {
    try {
      isLoading.value = true;

      final res = await ApiHrmsService.updateLeaveStatus(
        leaveId,
        status,
        hrReason: hrReason,
      );

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

  // Fetch all leaves report
  Future<void> fetchAllLeaveReport() async {
    try {
      isLoading.value = true;
      final data = await ApiHrmsService.fetchAllLeaveReport();
      allLeaveReport.assignAll(data);
      filteredLeaveReport.assignAll(data);
    } catch (e) {
      CustomSnackBar.error("Failed to fetch all leaves report: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Search and Filter logic
  void filterLeaveReport({String searchQuery = "", String status = "All"}) {
    List<LeaveRequestModel> result = allLeaveReport;

    if (searchQuery.isNotEmpty) {
      result = result.where((e) {
        final nameMatch = e.employeeName.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
        final typeMatch = e.leaveTypeName.toLowerCase().contains(
          searchQuery.toLowerCase(),
        );
        return nameMatch || typeMatch;
      }).toList();
    }

    if (status != "All") {
      result = result
          .where((e) => e.status.toUpperCase() == status.toUpperCase())
          .toList();
    }

    filteredLeaveReport.assignAll(result);
  }

  // cancel leave
  Future<void> cancelLeave(int leaveId) async {
    try {
      isLoading.value = true;
      final res = await ApiHrmsService.cancelLeave(leaveId);
      if (res["success"] == true) {
        CustomSnackBar.success("Leave cancelled successfully");
        fetchMyLeaves(); // refresh
      } else {
        throw res["error"] ?? "Failed to cancel leave";
      }
    } catch (e) {
      CustomSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // fetch today leaves
  Future<void> fetchTodayLeaves() async {
    try {
      final data = await ApiHrmsService.fetchTodayLeaves();
      todayLeaves.assignAll(data);
    } catch (e) {
      // Ignored for now
    }
  }

  // ======================== PHASE 2 & 3 ========================

  Future<void> fetchHolidays() async {
    try {
      final data = await ApiHrmsService.fetchHolidays();
      holidays.assignAll(data);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> fetchTodayAttendance() async {
    try {
      final data = await ApiHrmsService.fetchTodayAttendance();
      todayAttendance.value = data;
    } catch (e) {
      // Ignore
    }
  }

  Future<void> punchIn() async {
    try {
      isLoading.value = true;
      final res = await ApiHrmsService.punchIn();
      if (res["success"] == true) {
        CustomSnackBar.success("Punched in successfully");
        fetchTodayAttendance();
      } else {
        throw res["error"] ?? res["message"] ?? "Failed to punch in";
      }
    } catch (e) {
      CustomSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> punchOut() async {
    try {
      isLoading.value = true;
      final res = await ApiHrmsService.punchOut();
      if (res["success"] == true) {
        CustomSnackBar.success("Punched out successfully");
        fetchTodayAttendance();
      } else {
        throw res["error"] ?? res["message"] ?? "Failed to punch out";
      }
    } catch (e) {
      CustomSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyPayslips() async {
    try {
      final data = await ApiHrmsService.fetchMyPayslips();
      myPayslips.assignAll(data);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> fetchTodayEvents() async {
    try {
      final data = await ApiHrmsService.fetchTodayEvents();
      todayEvents.assignAll(data);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> fetchAttendanceHistory(
    String? startDate,
    String? endDate,
  ) async {
    try {
      isLoading.value = true;
      final data = await ApiHrmsService.fetchAttendanceHistory(
        startDate,
        endDate,
      );
      attendanceHistory.assignAll(data);
    } catch (e) {
      CustomSnackBar.error("Error - $e");
    } finally {
      isLoading.value = false;
    }
  }
}
