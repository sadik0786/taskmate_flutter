import 'package:get/get.dart';
import 'package:task_mate/model/leave_type_model.dart';
import 'package:task_mate/model/leave_apply_request_model.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/model/financial_year_model.dart';
import 'package:task_mate/services/hrms/leave_service.dart';
import 'package:task_mate/services/hrms/misc_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

class LeaveController extends GetxController {
  RxList<LeaveTypeModel> leaveTypes = <LeaveTypeModel>[].obs;
  RxList<LeaveRequestModel> myLeaves = <LeaveRequestModel>[].obs;
  RxList<FinancialYearModel> financialYears = <FinancialYearModel>[].obs;

  var holidays = <dynamic>[].obs;
  var myPayslips = <dynamic>[].obs;
  var todayEvents = <dynamic>[].obs;

  RxBool isLoading = false.obs;
  RxString userRole = "".obs;

  RxInt pendingLeave = 0.obs;
  RxInt approvedLeave = 0.obs;
  RxInt totalApplyLeave = 0.obs;
  
  Rxn<int> selectedFinancialYearId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await fetchFinancialYears();
    fetchLeaveTypes();
    fetchMyLeaves();
    fetchHolidays();
    fetchMyPayslips();
    fetchTodayEvents();
  }

  Future<void> fetchFinancialYears() async {
    try {
      final data = await MiscService.fetchFinancialYears();
      financialYears.assignAll(
        data.map((e) => FinancialYearModel.fromJson(e)).toList(),
      );
      if (financialYears.isNotEmpty) {
        // default to current year if exists, else first
        final current = financialYears.firstWhere((e) => e.isCurrent == true, orElse: () => financialYears.first);
        selectedFinancialYearId.value = current.id;
      }
    } catch (e) {
      // Ignore
    }
  }

  void changeFinancialYear(int id) {
    selectedFinancialYearId.value = id;
    fetchLeaveTypes();
    fetchMyLeaves();
  }

  Future<void> fetchLeaveTypes() async {
    try {
      isLoading.value = true;
      final data = await LeaveService.fetchAllLeaveTypes(
        financialYearId: selectedFinancialYearId.value,
      );
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
      final data = await LeaveService.fetchMyLeaves(
        financialYearId: selectedFinancialYearId.value,
      );
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

  Future<bool> applyLeave(LeaveApplyRequestModel request) async {
    try {
      isLoading.value = true;
      final res = await LeaveService.applyLeave(request);

      if (res["success"] == true) {
        fetchMyLeaves();
        return true;
      } else {
        throw res["message"] ?? "Failed";
      }
    } catch (err) {
      CustomSnackBar.error("Error - $err");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelLeave(int leaveId) async {
    try {
      isLoading.value = true;
      final res = await LeaveService.cancelLeave(leaveId);
      if (res["success"] == true) {
        CustomSnackBar.success("Leave cancelled successfully");
        fetchMyLeaves(); 
      } else {
        throw res["message"] ?? "Failed to cancel leave";
      }
    } catch (err) {
      CustomSnackBar.error("Error: $err");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHolidays() async {
    try {
      final data = await MiscService.fetchHolidays();
      holidays.assignAll(data);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> fetchMyPayslips() async {
    try {
      final data = await MiscService.fetchMyPayslips();
      myPayslips.assignAll(data);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> fetchTodayEvents() async {
    try {
      final data = await MiscService.fetchTodayEvents();
      todayEvents.assignAll(data);
    } catch (e) {
      // Ignore
    }
  }
}
