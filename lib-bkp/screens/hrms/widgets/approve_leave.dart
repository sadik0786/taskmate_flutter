import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/screens/no_data.dart';
import 'package:task_mate/screens/page_loader.dart';
import 'package:task_mate/utils/common_fn.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class ApproveLeave extends StatefulWidget {
  const ApproveLeave({super.key});

  @override
  State<ApproveLeave> createState() => _ApproveLeaveState();
}

class _ApproveLeaveState extends State<ApproveLeave> {
  final LeaveController leaveController = Get.put(LeaveController());
  Map<int, bool> hrApprovalMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Obx(() {
          if (leaveController.isLoading.value) {
            return PageLoader();
          }

          final pendingLeaves = leaveController.otherLeavesRequest
              .where((e) => e.status == "PENDING")
              .toList();

          if (pendingLeaves.isEmpty) {
            return NoTasksWidget(message: "No pending leave requests");
          }

          return ListView.builder(
            itemCount: pendingLeaves.length,
            itemBuilder: (context, index) {
              return _approvalCard(pendingLeaves[index]);
            },
          );
        }),
      ),
    );
  }

  /// ---------------- APPROVAL CARD ----------------
  Widget _approvalCard(LeaveRequestModel leave) {
    final isHr = leaveController.userRole.value == "hr";

    // ensure default value exists
    hrApprovalMap.putIfAbsent(leave.id, () => false);

    return Card(
      margin: EdgeInsets.only(bottom: 14.h),
      color: ThemeClass.tealGreen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.white, width: 1.2),
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(leave.employeeName, style: Theme.of(context).textTheme.titleMedium),
                _statusChip("${leave.totalDays} days"),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(leave.leaveTypeName, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  "${CommonFn.formatDate(leave.fromDate)} to ${CommonFn.formatDate(leave.toDate)}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 6.h),
            if (leave.reason != null && leave.reason!.isNotEmpty)
              Text(leave.reason ?? "", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: isHr ? 0.h : 10.h),

            // ✅ SHOW CHECKBOX ONLY FOR HR
            if (isHr)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showHrReasonBottomSheet(leave.id, isReject: false);
                    hrApprovalMap[leave.id] = !(hrApprovalMap[leave.id] ?? false);
                  });
                },
                child: Row(
                  spacing: 5,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: hrApprovalMap[leave.id] ?? false,
                        checkColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity(horizontal: -4.w, vertical: 4.h),
                        onChanged: (val) {
                          setState(() {
                            _showHrReasonBottomSheet(leave.id, isReject: false);
                            hrApprovalMap[leave.id] = val!;
                          });
                        },
                      ),
                    ),
                    Text("Approve as HR with reason", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),

            // ACTION BUTTONS
            SwipeApproveReject(leave: leave),
          ],
        ),
      ),
    );
  }

  /// ---------------- STATUS CHIP ----------------
  Widget _statusChip(String status) {
    Color color = switch (status) {
      "APPROVED" => Colors.green,
      "REJECTED" => Colors.red,
      _ => Colors.orange,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12.sp),
      ),
    );
  }

  ///
  void _showHrReasonBottomSheet(int leaveId, {bool isReject = false}) {
    final TextEditingController reasonCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isReject ? "Reject Reason" : "HR Approval Reason",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            CustomTextField(
              hintText: "Enter reason here...",
              keyboardType: TextInputType.text,
              controller: reasonCtrl,
              maxLines: 2,
            ),

            SizedBox(height: 12.h),
            CustomButton(
              text: isReject ? "Reject" : "Approve",
              onPressed: () {
                if (reasonCtrl.text.trim().isEmpty) {
                  CustomSnackBar.error("Reason required");
                  return;
                }

                final status = isReject ? "REJECTED" : "APPROVED";

                leaveController.updateLeaveStatus(leaveId, status, reasonCtrl.text.trim());

                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  ///
}

class SwipeApproveReject extends StatefulWidget {
  final LeaveRequestModel leave;
  const SwipeApproveReject({super.key, required this.leave});

  @override
  State<SwipeApproveReject> createState() => _SwipeApproveRejectState();
}

class _SwipeApproveRejectState extends State<SwipeApproveReject> {
  double dragPosition = 0.0; // -1 = left, 0 = center, 1 = right
  bool isCompleted = false; // to lock thumb after decision
  final LeaveController leaveController = Get.find<LeaveController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        color: isCompleted
            ? (dragPosition == 1.0 ? Colors.green.shade200 : Colors.red.shade200)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // LEFT TEXT (Reject)
          Positioned(
            left: 20.w,
            child: Text(
              isCompleted ? (dragPosition == -1.0 ? "REJECT" : "APPROVE") : "REJECT",
              style: TextStyle(
                color: isCompleted ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // RIGHT TEXT (Approve)
          Positioned(
            right: 20.w,
            child: Text(
              isCompleted ? (dragPosition == 1.0 ? "APPROVE" : "REJECT") : "APPROVE",
              style: TextStyle(
                color: isCompleted ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // DRAGGABLE THUMB
          Align(
            alignment: Alignment(dragPosition, 0),
            child: GestureDetector(
              onHorizontalDragUpdate: isCompleted
                  ? null // stop dragging after decision
                  : (details) {
                      setState(() {
                        dragPosition += details.delta.dx / 150;
                        dragPosition = dragPosition.clamp(-1.0, 1.0); // limit range
                      });
                    },
              onHorizontalDragEnd: (details) {
                if (dragPosition > 0.5) {
                  // APPROVE
                  setState(() {
                    dragPosition = 1.0; // lock to right
                    isCompleted = true;
                  });

                  // print("Approved");
                  leaveController.updateLeaveStatus(widget.leave.id, "APPROVED", "");
                } else if (dragPosition < -0.5) {
                  // REJECT
                  setState(() {
                    dragPosition = -1.0; // lock to left
                    isCompleted = true;
                  });

                  // print("Rejected");
                  leaveController.updateLeaveStatus(
                    widget.leave.id,
                    "REJECTED",
                    "Rejected via swipe",
                  );
                }
              },
              child: Container(
                margin: EdgeInsets.only(left: isCompleted ? 4 : 0, right: isCompleted ? 4 : 0),
                width: 100.w,
                height: 35.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(Icons.swap_horiz, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
