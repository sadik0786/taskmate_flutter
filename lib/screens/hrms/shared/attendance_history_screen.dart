import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/controllers/hrms/attendance_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/widgets/no_data.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/widgets/responsive_desktop_wrappers.dart';

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
    endDate = DateTime.now();
    startDate = endDate!.subtract(const Duration(days: 30));
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
    return BaseLayout(
      title: "Attendance History",
      showBackButton: true,
      customActions: [
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
      child: SafeArea(
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
                    Theme.of(context).cardColor,
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
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
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
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Filter",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.onPrimary,
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

                // Build list of dates
                List<DateTime> allDates = [];
                if (startDate != null && endDate != null) {
                  final int days = endDate!.difference(startDate!).inDays;
                  for (int i = 0; i <= days; i++) {
                    allDates.add(endDate!.subtract(Duration(days: i)));
                  }
                } else if (controller.attendanceHistory.isNotEmpty) {
                  // Fallback if null
                  allDates.add(DateTime.now());
                }

                double presentDays = 0;
                double absentDays = 0;
                double approvedLeaves = 0;
                double holidays = 0;
                int weeklyOff = 0;
                int totalMins = 0;

                for (var date in allDates) {
                  String dateStr = DateFormat('yyyy-MM-dd').format(date);
                  final item = controller.attendanceHistory.firstWhere((e) {
                    if (e["AttendanceDate"] == null) return false;
                    return e["AttendanceDate"].toString().startsWith(dateStr);
                  }, orElse: () => null);

                  if (item != null) {
                    String status = (item["Status"] ?? "")
                        .toString()
                        .toUpperCase();
                    if (status == 'PRESENT') {
                      presentDays += 1;
                    } else if (status == 'HALF DAY') {
                      presentDays += 0.5;
                    } else if (status == 'ABSENT') {
                      absentDays += 1;
                    }
                    totalMins +=
                        ((item["TotalWorkedMinutes"] ?? 0) as int) +
                        ((item["TotalBreakMinutes"] ?? 0) as int);
                  } else {
                    if (controller.leaveDates.contains(dateStr)) {
                      approvedLeaves += 1;
                    } else if (controller.holidayDates.contains(dateStr)) {
                      holidays += 1;
                    } else if (date.weekday == DateTime.saturday ||
                        date.weekday == DateTime.sunday) {
                      weeklyOff += 1;
                    } else {
                      absentDays += 1;
                    }
                  }
                }

                int tHours = totalMins ~/ 60;
                int tMins = totalMins % 60;
                String totalHoursStr =
                    "$tHours:${tMins.toString().padLeft(2, '0')}";
                String monthName = startDate != null
                    ? DateFormat('MMMM yyyy').format(startDate!)
                    : "Summary";

                return Column(
                  children: [
                    _buildSummaryCard(
                      context,
                      monthName,
                      presentDays,
                      absentDays,
                      approvedLeaves,
                      holidays,
                      weeklyOff,
                      totalHoursStr,
                    ),
                    Expanded(
                      child: ResponsiveGridListWrapper(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        itemCount: allDates.length,
                        desktopChildAspectRatio: 5.0,
                        itemBuilder: (context, index) {
                          final date = allDates[index];
                          final dateString = DateFormat(
                            'yyyy-MM-dd',
                          ).format(date);

                          final item = controller.attendanceHistory.firstWhere((
                            e,
                          ) {
                            if (e["AttendanceDate"] == null) return false;
                            return e["AttendanceDate"].toString().startsWith(
                              dateString,
                            );
                          }, orElse: () => null);

                          String checkInTime = "--:--";
                          String checkOutTime = "--:--";
                          String hoursText = "";
                          String breakText = "";
                          Color statusColor = Colors.grey;
                          String statusText = "ABSENT";

                          if (item != null) {
                            if (item["CheckInTime"] != null) {
                              String raw = item["CheckInTime"]
                                  .toString()
                                  .replaceAll('Z', '');
                              final cIn = DateTime.parse(raw);
                              checkInTime = DateFormat('hh:mm a').format(cIn);
                            }

                            if (item["CheckOutTime"] != null) {
                              String raw = item["CheckOutTime"]
                                  .toString()
                                  .replaceAll('Z', '');
                              final cOut = DateTime.parse(raw);
                              checkOutTime = DateFormat('hh:mm a').format(cOut);
                            }

                            final int actualWorkedMins =
                                item["TotalWorkedMinutes"] ?? 0;
                            final int breakMins =
                                item["TotalBreakMinutes"] ?? 0;

                            final int totalItemMins =
                                actualWorkedMins + breakMins;

                            if (totalItemMins > 0) {
                              final int hrs = totalItemMins ~/ 60;
                              final int mins = totalItemMins % 60;
                              hoursText = "${hrs}h ${mins}m";
                            }

                            if (breakMins > 0) {
                              final int bHrs = breakMins ~/ 60;
                              final int bMins = breakMins % 60;
                              breakText = bHrs > 0
                                  ? "${bHrs}h ${bMins}m"
                                  : "${bMins}m";
                            }

                            statusColor = Colors.green;
                            statusText = (item["Status"] ?? "PRESENT")
                                .toString()
                                .toUpperCase();
                            if (statusText == 'ABSENT') {
                              statusColor = Colors.red;
                            }
                            if (statusText == 'HALF DAY') {
                              statusColor = Colors.orange;
                            }
                          } else {
                            // No record found
                            if (controller.leaveDates.contains(dateString)) {
                              statusText = "ON LEAVE";
                              statusColor = Colors.amber.shade700;
                            } else if (controller.holidayDates.contains(
                              dateString,
                            )) {
                              statusText = "HOLIDAY";
                              statusColor = Colors.teal;
                              if (date.weekday == DateTime.saturday ||
                                  date.weekday == DateTime.sunday) {
                                statusText = "HOLIDAY, WEEKLY OFF";
                              }
                            } else if (date.weekday == DateTime.saturday ||
                                date.weekday == DateTime.sunday) {
                              statusText = "WEEKLY OFF";
                              statusColor = Colors.orange.shade700;
                            } else {
                              statusText = "ABSENT";
                              statusColor = Colors.red;
                            }
                          }

                          return Container(
                            margin: EdgeInsets.only(bottom: 6.h),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color:
                                  (statusText == "WEEKLY OFF" ||
                                      statusText == "HOLIDAY, WEEKLY OFF")
                                  ? Colors.orange.withOpacity(0.15)
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color:
                                    (statusText == "WEEKLY OFF" ||
                                        statusText == "HOLIDAY, WEEKLY OFF")
                                    ? Colors.orange.withOpacity(0.6)
                                    : Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).shadowColor.withOpacity(0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 6.h,
                                  ),
                                  child: Row(
                                    children: [
                                      // Date Box
                                      Container(
                                        width: 55.w,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('dd').format(date),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                            ),
                                            Text(
                                              DateFormat(
                                                'EEE, MMM',
                                              ).format(date),
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
                                        child: ImageFiltered(
                                          imageFilter:
                                              ((date.weekday ==
                                                          DateTime.saturday ||
                                                      date.weekday ==
                                                          DateTime.sunday) &&
                                                  item == null)
                                              ? ImageFilter.blur(
                                                  sigmaX: 3,
                                                  sigmaY: 3,
                                                )
                                              : ImageFilter.blur(
                                                  sigmaX: 0,
                                                  sigmaY: 0,
                                                ),
                                          child: Opacity(
                                            opacity:
                                                ((date.weekday ==
                                                            DateTime.saturday ||
                                                        date.weekday ==
                                                            DateTime.sunday) &&
                                                    item == null)
                                                ? 0.4
                                                : 1.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "In",
                                                          style: TextStyle(
                                                            fontSize: 9.sp,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                          ),
                                                        ),
                                                        Text(
                                                          checkInTime,
                                                          style: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: 1,
                                                      height: 20.h,
                                                      color: Theme.of(context)
                                                          .dividerColor
                                                          .withOpacity(0.2),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Out",
                                                          style: TextStyle(
                                                            fontSize: 9.sp,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                          ),
                                                        ),
                                                        Text(
                                                          checkOutTime,
                                                          style: TextStyle(
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: 1,
                                                      height: 20.h,
                                                      color: Theme.of(context)
                                                          .dividerColor
                                                          .withOpacity(0.2),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Break",
                                                          style: TextStyle(
                                                            fontSize: 9.sp,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                          ),
                                                        ),
                                                        if (breakText
                                                            .isNotEmpty) ...[
                                                          Text(
                                                            breakText,
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .orangeAccent
                                                                  .shade700,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    Container(
                                                      width: 1,
                                                      height: 20.h,
                                                      color: Theme.of(context)
                                                          .dividerColor
                                                          .withOpacity(0.2),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Working Hrs.",
                                                          style: TextStyle(
                                                            fontSize: 9.sp,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                          ),
                                                        ),
                                                        if (hoursText
                                                            .isNotEmpty) ...[
                                                          Text(
                                                            hoursText,
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .onSurface
                                                                      .withOpacity(
                                                                        0.7,
                                                                      ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 6.h),
                                                Text(
                                                  "Shift Time: 09:30 AM - 06:00 PM",
                                                  style: TextStyle(
                                                    fontSize: 9.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12.r),
                                      ),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onError,
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String monthName,
    double presentDays,
    double absentDays,
    double approvedLeaves,
    double holidays,
    int weeklyOff,
    String totalHoursStr,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.15),
            Theme.of(context).primaryColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).primaryColor,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "$monthName Summary",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                context,
                "Present Days",
                presentDays.toString(),
                Colors.green,
              ),
              _buildSummaryItem(
                context,
                "Absent Days",
                absentDays.toString(),
                Colors.red,
              ),
              _buildSummaryItem(
                context,
                "Approved Leaves",
                approvedLeaves.toString(),
                Colors.amber.shade700,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                context,
                "Holidays",
                holidays.toString(),
                Colors.teal,
              ),
              _buildSummaryItem(
                context,
                "Weekly Off",
                weeklyOff.toString(),
                Colors.orange.shade700,
              ),
              _buildSummaryItem(
                context,
                "Total Hours",
                totalHoursStr,
                Theme.of(context).primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
