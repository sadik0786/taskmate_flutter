import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/routes.dart';
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

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 8.h,
            bottom: 24.h,
            left: 20.w,
            right: 20.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Filter History",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ThemeClass.textBlack,
                ),
              ),
              SizedBox(height: 20.h),
              _buildFilterOption("Today", () {
                Navigator.pop(ctx);
                setState(() {
                  startDate = DateTime.now();
                  endDate = DateTime.now();
                });
                _fetchData();
              }),
              _buildFilterOption("Last 7 Days", () {
                Navigator.pop(ctx);
                setState(() {
                  endDate = DateTime.now();
                  startDate = endDate!.subtract(const Duration(days: 7));
                });
                _fetchData();
              }),
              _buildFilterOption("Last 30 Days", () {
                Navigator.pop(ctx);
                setState(() {
                  endDate = DateTime.now();
                  startDate = endDate!.subtract(const Duration(days: 30));
                });
                _fetchData();
              }),
              _buildFilterOption("Custom Range", () async {
                Navigator.pop(ctx);
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: ThemeClass.primaryGreen,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                        dialogBackgroundColor: Colors.white,
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
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ThemeClass.textBlack,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: ThemeClass.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () {
              Get.toNamed(Routes.regularizationRequest);
            },
            icon: const Icon(Icons.edit_calendar, color: Colors.white, size: 18),
            label: const Text(
              "Regularize",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Filter Header
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.date_range,
                          color: Theme.of(context).primaryColor,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date Range",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            startDate != null && endDate != null
                                ? "${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}"
                                : "Last 30 Days",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: ThemeClass.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _showFilterModal(context),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Filter",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                      // Fix for time shift: parse the raw string, treating it as local time if it lacks 'Z'
                      // If it has 'Z' but was meant to be local, replacing 'Z' prevents UTC to Local conversion shifting
                      String raw = item["CheckInTime"].toString().replaceAll(
                        'Z',
                        '',
                      );
                      final cIn = DateTime.parse(raw);
                      checkInTime = DateFormat('hh:mm a').format(cIn);
                    }

                    String checkOutTime = "--:--";
                    if (item["CheckOutTime"] != null) {
                      String raw = item["CheckOutTime"].toString().replaceAll(
                        'Z',
                        '',
                      );
                      final cOut = DateTime.parse(raw);
                      checkOutTime = DateFormat('hh:mm a').format(cOut);
                    }

                    final int workedMins = item["TotalWorkedMinutes"] ?? 0;
                    String hoursText = "";
                    if (workedMins > 0) {
                      final int hrs = workedMins ~/ 60;
                      final int mins = workedMins % 60;
                      hoursText = "${hrs}h ${mins}m";
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
                              Row(
                                children: [
                                  if (hoursText.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.only(right: 8.w),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        hoursText,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
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
