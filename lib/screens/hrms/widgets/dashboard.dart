import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/screens/no_data.dart';
import 'package:task_mate/screens/page_loader.dart';
import 'package:task_mate/utils/common_fn.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final LeaveController leaveController = Get.find<LeaveController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Obx(() {
        // Show loading for entire page
        if (leaveController.isLoading.value) {
          return Center(child: PageLoader());
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Leave Summary
            Row(
              children: [
                _summaryCard(
                  title: "Pending",
                  icon: Icons.pending_actions,
                  color: ThemeClass.warningColor,
                  value: leaveController.pendingLeave.value,
                ),
                _summaryCard(
                  title: "Approve",
                  icon: Icons.done_all,
                  color: ThemeClass.primaryGreen,
                  value: leaveController.approvedLeave.value,
                ),
                _summaryCard(
                  title: leaveController.totalApplyLeave.value > 2
                      ? "Apply Leaves"
                      : "Apply Leave",
                  icon: Icons.all_inbox,
                  color: Colors.blue,
                  value: leaveController.totalApplyLeave.value,
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Leave List
            Text(
              "My Leave Requests",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            SizedBox(height: 8.h),

            Expanded(
              child: leaveController.myLeaves.isEmpty
                  ? NoTasksWidget(message: "No Leaves Found")
                  : ListView.builder(
                      itemCount: leaveController.myLeaves.length,
                      itemBuilder: (context, index) {
                        final leave = leaveController.myLeaves[index];
                        // print("hellow ${leave}");
                        return _leaveCard(leave);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _summaryCard({
    required String title,
    required int value,
    IconData icon = Icons.calendar_today,
    required Color color,
  }) {
    return Expanded(
      child: StatefulBuilder(
        builder: (context, setState) {
          return MouseRegion(
            onEnter: (_) => setState(() as VoidCallback),
            onExit: (_) => setState(() as VoidCallback),
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).cardColor,
                      Theme.of(context).cardColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 28.sp, color: color),
                        ),
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _leaveCard(LeaveRequestModel leave) {
    final bool isApproved = leave.status == "APPROVED";
    final bool isRejected = leave.status == "REJECTED";

    final Color statusColor = isApproved
        ? Colors.green
        : isRejected
        ? Colors.red
        : Colors.orange;

    final Color bgColor = isApproved
        ? Colors.green.shade50
        : isRejected
        ? Colors.red.shade50
        : Colors.orange.shade50;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: bgColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isApproved
                          ? Icons.check_circle
                          : isRejected
                          ? Icons.cancel
                          : Icons.pending,
                      color: statusColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.leaveTypeName,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${leave.totalDays} Days',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  leave.status,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
            child: Divider(color: Colors.grey.shade200, height: 1),
          ),
          Row(
            children: [
              Icon(Icons.date_range, size: 16.sp, color: Colors.grey.shade600),
              SizedBox(width: 8.w),
              Text(
                "${CommonFn.formatDate(leave.fromDate)} to ${CommonFn.formatDate(leave.toDate)}",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
          if (leave.reason != null && leave.reason!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes, size: 16.sp, color: Colors.grey.shade600),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    leave.reason!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
