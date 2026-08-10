import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/no_data.dart';
import 'package:task_mate/widgets/page_loader.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final LeaveController leaveController = Get.find<LeaveController>();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    // Default fetch for last 30 days
    _fetchData();
  }

  void _fetchData() {
    String? startStr;
    String? endStr;
    if (startDate != null && endDate != null) {
      startStr = DateFormat('yyyy-MM-dd').format(startDate!);
      endStr = DateFormat('yyyy-MM-dd').format(endDate!);
    }
    leaveController.fetchAttendanceHistory(startStr, endStr);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ThemeClass.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: ThemeClass.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    startDate != null && endDate != null
                        ? "${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}"
                        : "Last 30 Days",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  InkWell(
                    onTap: () => _selectDateRange(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: ThemeClass.primaryGreen),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 16.sp,
                            color: ThemeClass.primaryGreen,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Filter",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: ThemeClass.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // List of Attendance
            Expanded(
              child: Obx(() {
                if (leaveController.isLoading.value) {
                  return const PageLoader();
                }

                if (leaveController.attendanceHistory.isEmpty) {
                  return const NoTasksWidget(
                    message: "No attendance records found.",
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: leaveController.attendanceHistory.length,
                  itemBuilder: (context, index) {
                    final item = leaveController.attendanceHistory[index];
                    final date = DateTime.tryParse(
                      item["AttendanceDate"] ?? "",
                    );
                    final dateStr = date != null
                        ? DateFormat('EEE, dd MMM yyyy').format(date)
                        : "Unknown Date";

                    String checkInTime = "--:--";
                    if (item["CheckInTime"] != null) {
                      final cIn = DateTime.parse(item["CheckInTime"]).toLocal();
                      checkInTime = DateFormat('hh:mm a').format(cIn);
                    }

                    String checkOutTime = "--:--";
                    if (item["CheckOutTime"] != null) {
                      final cOut = DateTime.parse(
                        item["CheckOutTime"],
                      ).toLocal();
                      checkOutTime = DateFormat('hh:mm a').format(cOut);
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: ThemeClass.textBlack,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  item["Status"] ?? "PRESENT",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeBox(
                                  "Punch In",
                                  checkInTime,
                                  Icons.login,
                                  Colors.blue,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildTimeBox(
                                  "Punch Out",
                                  checkOutTime,
                                  Icons.logout,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(String title, String time, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: ThemeClass.textBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
