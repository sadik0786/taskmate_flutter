import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/screens/hrms/shared/attendance_history_screen.dart';

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({super.key});

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final LeaveController leaveController = Get.put(LeaveController());
  late Timer _clockTimer;
  String _currentTime = "";
  String _currentDate = "";

  void _updateClock() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm:ss a').format(now);
      _currentDate = DateFormat('EEE, dd MMM').format(now);
    });
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Set initial values directly without setState (widget not built yet)
    final now = DateTime.now();
    _currentTime = DateFormat('hh:mm:ss a').format(now);
    _currentDate = DateFormat('EEE, dd MMM').format(now);

    // Timer updates every second, safely guarded by mounted check
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateClock(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      leaveController.fetchTodayAttendance();
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Stack(
        children: [
          // Glowing Background Effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
            ),
          ),
          // Glassmorphic Card
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.9),
                      const Color(0xFF0D47A1).withOpacity(0.8), // Deep AI blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Obx(() {
                  final attendance = leaveController.todayAttendance.value;
                  final String currentPunchState =
                      attendance?["CurrentPunchState"] ?? "";

                  final bool isPunchedIn = currentPunchState == "IN";
                  final int workedMins = attendance?["TotalWorkedMinutes"] ?? 0;

                  String statusText = "Ready to Work";
                  if (isPunchedIn) {
                    statusText = "Actively Tracking";
                  } else if (workedMins > 0) {
                    statusText = "On Break / Done";
                  }

                  String hoursText = "";
                  if (workedMins > 0) {
                    final int hrs = workedMins ~/ 60;
                    final int mins = workedMins % 60;
                    hoursText = "${hrs}h ${mins}m logged today";
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentTime,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              _currentDate,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (hoursText.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                hoursText,
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            SizedBox(height: 12.h),
                            InkWell(
                              onTap: () =>
                                  Get.to(() => const AttendanceHistoryScreen()),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      color: Colors.white,
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "View Timeline",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action Button
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isPunchedIn ? _pulseAnimation.value : 1.0,
                            child: GestureDetector(
                              onTap: () {
                                if (isPunchedIn) {
                                  leaveController.punchOut();
                                } else {
                                  leaveController.punchIn();
                                }
                              },
                              child: Container(
                                width: 80.w,
                                height: 80.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: isPunchedIn
                                        ? [
                                            Colors.orangeAccent,
                                            Colors.deepOrange,
                                          ]
                                        : [Colors.greenAccent, Colors.teal],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isPunchedIn
                                                  ? Colors.orange
                                                  : Colors.green)
                                              .withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: leaveController.isLoading.value
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isPunchedIn
                                                ? Icons.stop_circle_outlined
                                                : Icons.play_circle_fill,
                                            color: Colors.white,
                                            size: 28.sp,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            isPunchedIn
                                                ? "PUNCH OUT"
                                                : "PUNCH IN",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
