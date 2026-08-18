import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EventsWidget extends StatelessWidget {
  const EventsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaveController leaveController = Get.put(LeaveController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      leaveController.fetchTodayEvents();
    });

    return Obx(() {
      final events = leaveController.todayEvents;
      if (events.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Celebrations 🎉",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 140.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isBirthday = event["type"] == "Birthday";

                  return Container(
                    width: 200.w,
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isBirthday
                            ? [Colors.pink.shade300, Colors.pinkAccent]
                            : [
                                Colors.deepPurple.shade300,
                                Colors.deepPurpleAccent,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: (isBirthday ? Colors.pink : Colors.deepPurple)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: Theme.of(context).cardColor,
                          backgroundImage: event["image"] != null
                              ? NetworkImage(
                                  "${dotenv.env['baseApiUrl'] ?? ''}${event["image"]}",
                                )
                              : null,
                          child: event["image"] == null
                              ? Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 24.sp,
                                )
                              : null,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          event["name"] ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          isBirthday
                              ? "Happy Birthday!"
                              : "Happy ${event['years']} Year${event['years'] > 1 ? 's' : ''} Anniversary!",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
