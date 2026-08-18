import 'package:get/get.dart';
import 'package:task_mate/services/hrms/attendance_service.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';

class AttendanceController extends GetxController {
  var todayAttendance = Rxn<Map<String, dynamic>>();
  var attendanceHistory = <dynamic>[].obs;
  var leaveDates = <String>[].obs;
  var holidayDates = <String>[].obs;
  RxBool isOnBreak = false.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodayAttendance();
  }

  Future<void> fetchTodayAttendance() async {
    try {
      final data = await AttendanceService.fetchTodayAttendance();
      todayAttendance.value = data;
      // Initialize break status if backend returns it
      if (data != null && data['isOnBreak'] != null) {
        isOnBreak.value = data['isOnBreak'];
      }
    } catch (e) {
      // Ignore or log error
    }
  }

  Future<void> punchIn() async {
    try {
      isLoading.value = true;
      final res = await AttendanceService.punchIn();
      if (res["success"] == true) {
        CustomSnackBar.success("Punched in successfully");
        fetchTodayAttendance();
      } else {
        throw res["message"] ?? "Failed to punch in";
      }
    } catch (err) {
      CustomSnackBar.error("Error - $err");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> punchOut() async {
    try {
      isLoading.value = true;
      final res = await AttendanceService.punchOut();
      if (res["success"] == true) {
        CustomSnackBar.success("Punched out successfully");
        fetchTodayAttendance();
      } else {
        throw res["message"] ?? "Failed to punch out";
      }
    } catch (err) {
      CustomSnackBar.error("Error - $err");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> takeBreak() async {
    try {
      isLoading.value = true;
      final res = await AttendanceService.takeBreak();
      if (res["success"] == true) {
        isOnBreak.value = true;
        CustomSnackBar.success("Break started");
        fetchTodayAttendance();
      } else {
        throw res["message"] ?? "Failed to take break";
      }
    } catch (err) {
      CustomSnackBar.error("Error - $err");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> endBreak() async {
    try {
      isLoading.value = true;
      final res = await AttendanceService.endBreak();
      if (res["success"] == true) {
        isOnBreak.value = false;
        CustomSnackBar.success("Break ended");
        fetchTodayAttendance();
      } else {
        throw res["message"] ?? "Failed to end break";
      }
    } catch (err) {
      CustomSnackBar.error("Error - $err");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAttendanceHistory(
    String? startDate,
    String? endDate,
  ) async {
    try {
      isLoading.value = true;
      final data = await AttendanceService.fetchAttendanceHistory(
        startDate,
        endDate,
      );
      attendanceHistory.assignAll(data["data"] ?? []);
      
      final summary = data["summary"];
      if (summary != null) {
        leaveDates.assignAll(List<String>.from(summary["leaveDates"] ?? []));
        holidayDates.assignAll(List<String>.from(summary["holidayDates"] ?? []));
      } else {
        leaveDates.clear();
        holidayDates.clear();
      }
    } catch (e) {
      CustomSnackBar.error("Failed to fetch history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
