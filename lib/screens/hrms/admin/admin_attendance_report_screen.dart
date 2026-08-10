import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/page_loader.dart';

class AdminAttendanceReportScreen extends StatefulWidget {
  const AdminAttendanceReportScreen({super.key});

  @override
  State<AdminAttendanceReportScreen> createState() =>
      _AdminAttendanceReportScreenState();
}

class _AdminAttendanceReportScreenState
    extends State<AdminAttendanceReportScreen> {
  final LeaveController leaveController = Get.find<LeaveController>();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  void _fetchReport() {
    leaveController.fetchAdminAttendanceReport(
        DateFormat('yyyy-MM-dd').format(selectedDate));
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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
        selectedDate = picked;
      });
      _fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Attendance Report"),
        backgroundColor: ThemeClass.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.textBlack,
                  ),
                ),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeClass.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 16.sp,
                          color: ThemeClass.primaryGreen,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "Select Date",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: ThemeClass.primaryGreen,
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
          SizedBox(height: 12.h),

          // List
          Expanded(
            child: Obx(() {
              if (leaveController.isLoading.value) {
                return const PageLoader();
              }
              if (leaveController.adminAttendanceReport.isEmpty) {
                return Center(
                  child: Text(
                    "No attendance data found for this date.",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: leaveController.adminAttendanceReport.length,
                itemBuilder: (context, index) {
                  final item = leaveController.adminAttendanceReport[index];
                  return _buildEmployeeCard(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(dynamic item) {
    final String status = item["Status"] ?? "ABSENT";
    Color statusColor = Colors.grey;
    if (status == "PRESENT") statusColor = Colors.green;
    if (status == "LATE") statusColor = Colors.orange;
    if (status == "ABSENT") statusColor = Colors.red;

    String checkIn = "--:--";
    if (item["CheckInTime"] != null) {
      String raw = item["CheckInTime"].toString().replaceAll('Z', '');
      checkIn = DateFormat('hh:mm a').format(DateTime.parse(raw));
    }

    String checkOut = "--:--";
    if (item["CheckOutTime"] != null) {
      String raw = item["CheckOutTime"].toString().replaceAll('Z', '');
      checkOut = DateFormat('hh:mm a').format(DateTime.parse(raw));
    }

    final int workedMins = item["TotalWorkedMinutes"] ?? 0;
    String hoursText = "";
    if (workedMins > 0) {
      hoursText = "${workedMins ~/ 60}h ${workedMins % 60}m";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["Name"] ?? "Unknown",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: ThemeClass.textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item["Email"] ?? "",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (status != "ABSENT") ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildTimeCol("Punch In", checkIn, Icons.login, Colors.blue),
                ),
                Expanded(
                  child: _buildTimeCol("Punch Out", checkOut, Icons.logout, Colors.orange),
                ),
                if (hoursText.isNotEmpty)
                  Expanded(
                    child: _buildTimeCol("Worked", hoursText, Icons.timer, Colors.green),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeCol(String label, String time, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          time,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: ThemeClass.textBlack,
          ),
        ),
      ],
    );
  }
}
