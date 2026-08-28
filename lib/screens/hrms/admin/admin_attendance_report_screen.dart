import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/controllers/hrms/admin_hrms_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/page_loader.dart';

class AdminAttendanceReportScreen extends StatefulWidget {
  const AdminAttendanceReportScreen({super.key});

  @override
  State<AdminAttendanceReportScreen> createState() =>
      _AdminAttendanceReportScreenState();
}

class _AdminAttendanceReportScreenState
    extends State<AdminAttendanceReportScreen> {
  final AdminHrmsController controller = Get.put(AdminHrmsController());
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  void _fetchReport() {
    controller.fetchAdminAttendanceReport(
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
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ThemeClass.primaryGreen,
            ),
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
    return BaseLayout(
      title: "Attendance Report",
      showBackButton: true,
      child: Column(
        children: [
          // Filter Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
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
                    color: Theme.of(context).colorScheme.onSurface,
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
              if (controller.isLoading.value) {
                return const PageLoader();
              }
              if (controller.adminAttendanceReport.isEmpty) {
                return Center(
                  child: Text(
                    "No attendance data found for this date.",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: controller.adminAttendanceReport.length,
                itemBuilder: (context, index) {
                  final record = controller.adminAttendanceReport[index];
                  return _buildEmployeeCard(record, context);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(dynamic item, BuildContext context) {
    final String status = item["Status"] ?? "ABSENT";
    Color statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
    if (status == "PRESENT") statusColor = ThemeClass.primaryGreen;
    if (status == "LATE") statusColor = Colors.orange; // Keeps logical warning semantics
    if (status == "ABSENT") statusColor = ThemeClass.errorColor;

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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item["Email"] ?? "",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  child: _buildTimeCol("Punch In", checkIn, Icons.login, Colors.blue, context),
                ),
                Expanded(
                  child: _buildTimeCol("Punch Out", checkOut, Icons.logout, Colors.orange, context),
                ),
                if (hoursText.isNotEmpty)
                  Expanded(
                    child: _buildTimeCol("Worked", hoursText, Icons.timer, ThemeClass.primaryGreen, context),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeCol(String label, String time, IconData icon, Color color, BuildContext context) {
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
