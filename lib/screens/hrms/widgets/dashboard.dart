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
                  title: leaveController.totalApplyLeave.value > 2 ? "Apply Leaves" : "Apply Leave",
                  icon: Icons.all_inbox,
                  color: Colors.blue,
                  value: leaveController.totalApplyLeave.value,
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Leave List
            Text("My Leave Requests", style: Theme.of(context).textTheme.titleLarge),

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
    Color? color,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(icon, size: 26.sp, color: color ?? Theme.of(context).primaryColor),
                Text(
                  value.toString(),
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 8.h),

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
    );
  }

  Widget _leaveCard(LeaveRequestModel leave) {
    Color statusColor = switch (leave.status) {
      "APPROVED" => Colors.green,
      "REJECTED" => Colors.red,
      _ => Colors.orange,
    };

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: leave.status == "APPROVED"
            ? Colors.green.shade100
            : leave.status == "REJECTED"
            ? Colors.red.shade100
            : Colors.orange.shade100,
        // color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.06),
            blurRadius: 10,
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
              Row(
                spacing: 15.w,
                children: [
                  Text(
                    leave.leaveTypeName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '(${leave.totalDays} days)',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  leave.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              Text(
                "${CommonFn.formatDate(leave.fromDate)} to ${CommonFn.formatDate(leave.toDate)}",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          if (leave.reason != null && leave.reason!.isNotEmpty)
            Text(
              leave.reason!,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
        ],
      ),
    );
  }
}
