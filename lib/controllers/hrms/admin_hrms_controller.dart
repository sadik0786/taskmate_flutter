import 'package:get/get.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/services/hrms/attendance_service.dart';
import 'package:task_mate/services/hrms/leave_service.dart';
import 'package:task_mate/services/hrms/misc_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

class AdminHrmsController extends GetxController {
  var adminAttendanceReport = <dynamic>[].obs;
  var allLeaveReport = <LeaveRequestModel>[].obs;
  var filteredLeaveReport = <LeaveRequestModel>[].obs;
  var otherLeavesRequest = <LeaveRequestModel>[].obs;
  var todayLeaves = <LeaveRequestModel>[].obs;

  RxList<dynamic> financialYears = <dynamic>[].obs;
  Rxn<int> selectedFinancialYearId = Rxn<int>();

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await fetchFinancialYears();
    getOtherLeaveRequest();
    fetchTodayLeaves();
  }

  Future<void> fetchFinancialYears() async {
    try {
      final data = await MiscService.fetchFinancialYears();
      financialYears.assignAll(data);
      if (financialYears.isNotEmpty) {
        final current = financialYears.firstWhere(
          (e) => e["IsCurrent"] == true,
          orElse: () => financialYears.first,
        );
        selectedFinancialYearId.value = current["Id"];
      }
    } catch (e) {
      // Ignore
    }
  }

  void changeFinancialYear(int id) {
    selectedFinancialYearId.value = id;
    fetchAllLeaveReport();
  }

  Future<void> fetchAdminAttendanceReport(String? date) async {
    try {
      isLoading.value = true;
      final data = await AttendanceService.getAdminAttendanceReport(date);
      adminAttendanceReport.assignAll(data);
    } catch (e) {
      CustomSnackBar.error("Error fetching report: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getOtherLeaveRequest() async {
    try {
      isLoading.value = true;
      final data = await LeaveService.fetchOtherLeaveRequest(
        financialYearId: selectedFinancialYearId.value,
      );
      otherLeavesRequest.assignAll(data);
    } catch (e) {
      CustomSnackBar.error("Failed to fetch other requests: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateLeaveStatus(
    int leaveId,
    String status, {
    String? hrReason,
  }) async {
    try {
      isLoading.value = true;
      final res = await LeaveService.updateLeaveStatus(
        leaveId,
        status,
        hrReason: hrReason,
      );

      if (res["success"] == true) {
        CustomSnackBar.success("Status updated to $status");
        getOtherLeaveRequest(); // refresh list
        return true;
      } else {
        throw res["error"] ?? res["message"] ?? "Failed to update status";
      }
    } catch (err) {
      CustomSnackBar.error("Error: $err");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllLeaveReport() async {
    try {
      isLoading.value = true;
      final data = await LeaveService.fetchAllLeaveReport(
        financialYearId: selectedFinancialYearId.value,
      );
      allLeaveReport.assignAll(data);
      filteredLeaveReport.assignAll(data);
    } catch (e) {
      CustomSnackBar.error("Failed to fetch leaves report: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterLeaveReport({String searchQuery = "", String status = "All"}) {
    List<LeaveRequestModel> temp = allLeaveReport.toList();

    if (status != 'All') {
      temp = temp
          .where((l) => l.status.toUpperCase() == status.toUpperCase())
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      temp = temp
          .where(
            (l) =>
                l.employeeName.toLowerCase().contains(q) ||
                l.leaveTypeName.toLowerCase().contains(q),
          )
          .toList();
    }

    filteredLeaveReport.assignAll(temp);
  }

  Future<void> fetchTodayLeaves() async {
    try {
      final data = await LeaveService.fetchTodayLeaves();
      todayLeaves.assignAll(data);
    } catch (e) {
      // Ignored for now
    }
  }
}
