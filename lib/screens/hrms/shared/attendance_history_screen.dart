import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/controllers/hrms/attendance_controller.dart';
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
  final AttendanceController controller = Get.put(AttendanceController());
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
    controller.fetchAttendanceHistory(startStr, endStr);
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
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Filter History",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 20.h),
              _buildFilterOption(context, "Today", () {
                Navigator.pop(ctx);
                setState(() {
                  startDate = DateTime.now();
                  endDate = DateTime.now();
                });
                _fetchData();
              }),
              _buildFilterOption(context, "Last 7 Days", () {
                Navigator.pop(ctx);
                setState(() {
                  endDate = DateTime.now();
                  startDate = endDate!.subtract(const Duration(days: 7));
                });
                _fetchData();
              }),
              _buildFilterOption(context, "Last 30 Days", () {
                Navigator.pop(ctx);
                setState(() {
                  endDate = DateTime.now();
                  startDate = endDate!.subtract(const Duration(days: 30));
                });
                _fetchData();
              }),
              _buildFilterOption(context, "Select Month", () {
                Navigator.pop(ctx);
                _showMonthYearPicker(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showMonthYearPicker(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> months = List.generate(12, (index) {
      return DateTime(now.year, now.month - index, 1);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  "Select Month",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    return ListTile(
                      title: Text(
                        DateFormat('MMMM yyyy').format(month),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).dividerColor,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          startDate = DateTime(month.year, month.month, 1);
                          endDate = DateTime(month.year, month.month + 1, 0);
                        });
                        _fetchData();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: ThemeClass.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () {
              Get.toNamed(Routes.regularizationRequest);
            },
            icon: const Icon(
              Icons.edit_calendar,
              color: Colors.white,
              size: 18,
            ),
            label: const Text(
              "Regularize",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
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
                              color: Theme.of(context).colorScheme.onSurface,
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
                if (controller.isLoading.value) {
                  return const PageLoader();
                }

                if (controller.attendanceHistory.isEmpty) {
                  return const NoTasksWidget(
                    message: "No attendance records found.",
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  itemCount: controller.attendanceHistory.length,
                  itemBuilder: (context, index) {
                    final item = controller.attendanceHistory[index];
                    final date = DateTime.tryParse(
                      item["AttendanceDate"] ?? "",
                    );

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

                    Color statusColor = Colors.green;
                    String statusText = (item["Status"] ?? "PRESENT")
                        .toString()
                        .toUpperCase();
                    if (statusText == 'ABSENT') statusColor = Colors.red;
                    if (statusText == 'HALF DAY') statusColor = Colors.orange;

                    return Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Date Box
                          Container(
                            width: 55.w,
                            padding: EdgeInsets.symmetric(vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date != null
                                      ? DateFormat('dd').format(date)
                                      : "--",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  date != null
                                      ? DateFormat('EEE, MMM').format(date)
                                      : "--",
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Times
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "In",
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      checkInTime,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 20.h,
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.2),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Out",
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      checkOutTime,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Status & Hours
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              if (hoursText.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  hoursText,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
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
}
