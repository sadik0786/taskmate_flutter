import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/screens/hrms/shared/attendance_history_screen.dart';

class AttendanceWidget extends StatelessWidget {
  const AttendanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // We assume LeaveController is already put by HrmsDashboard or we put it here
    final LeaveController leaveController = Get.put(LeaveController());

    // Fetch initial state if not done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      leaveController.fetchTodayAttendance();
    });

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final attendance = leaveController.todayAttendance.value;
        final bool isPunchedIn =
            attendance != null && attendance["CheckInTime"] != null;
        final bool isPunchedOut =
            attendance != null && attendance["CheckOutTime"] != null;

        String statusText = "Not Punched In";
        if (isPunchedOut) {
          statusText = "Punched Out";
        } else if (isPunchedIn) {
          statusText = "Working";
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Attendance",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                InkWell(
                  onTap: () {
                    Get.to(() => const AttendanceHistoryScreen());
                  },
                  child: Text(
                    "View History >",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  statusText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (!isPunchedOut)
              ElevatedButton(
                onPressed: () {
                  if (isPunchedIn) {
                    leaveController.punchOut();
                  } else {
                    leaveController.punchIn();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
                child: leaveController.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isPunchedIn ? "Punch Out" : "Punch In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
              ),
          ],
        );
      }),
    );
  }
}
