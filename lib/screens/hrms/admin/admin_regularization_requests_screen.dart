import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/controllers/hrms/regularization_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/widgets/no_data.dart';

class AdminRegularizationRequestsScreen extends StatefulWidget {
  const AdminRegularizationRequestsScreen({super.key});

  @override
  State<AdminRegularizationRequestsScreen> createState() =>
      _AdminRegularizationRequestsScreenState();
}

class _AdminRegularizationRequestsScreenState
    extends State<AdminRegularizationRequestsScreen> {
  final RegularizationController controller = Get.put(RegularizationController());

  @override
  void initState() {
    super.initState();
    controller.fetchPendingRegularizations();
  }

  void _showActionDialog(dynamic item, String action) {
    final TextEditingController hrReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            "$action Request",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: action == "Approve" ? Colors.green : Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure you want to $action this regularization request?",
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: hrReasonController,
                decoration: InputDecoration(
                  labelText: "Reason (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final success = await controller.updateRegularizationStatus(
                  item["Id"],
                  action == "Approve" ? "Approved" : "Rejected",
                  hrReasonController.text,
                );
                if (success) {
                  navigator.pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: action == "Approve" ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text("Confirm", style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Pending Regularizations"),
        backgroundColor: ThemeClass.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.pendingRegularizations.isEmpty) {
          return const PageLoader();
        }

        if (controller.pendingRegularizations.isEmpty) {
          return const NoTasksWidget(message: "No pending requests found.");
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.pendingRegularizations.length,
          itemBuilder: (context, index) {
            final item = controller.pendingRegularizations[index];
            return _buildRequestCard(item);
          },
        );
      }),
    );
  }

  Widget _buildRequestCard(dynamic item) {
    final date = DateTime.tryParse(item["TargetDate"] ?? "");
    final dateStr = date != null ? DateFormat('EEEE, dd MMM yyyy').format(date) : "Unknown Date";

    String reqIn = "--:--";
    if (item["RequestedCheckInTime"] != null) {
      String raw = item["RequestedCheckInTime"].toString().replaceAll('Z', '');
      reqIn = DateFormat('hh:mm a').format(DateTime.parse(raw));
    }

    String reqOut = "--:--";
    if (item["RequestedCheckOutTime"] != null) {
      String raw = item["RequestedCheckOutTime"].toString().replaceAll('Z', '');
      reqOut = DateFormat('hh:mm a').format(DateTime.parse(raw));
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
                child: Text(
                  item["EmployeeName"] ?? "Unknown",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.textBlack,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "Pending",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
              SizedBox(width: 6.w),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTimeCol("Req In", reqIn, Icons.login, Colors.blue),
                ),
                Expanded(
                  child: _buildTimeCol("Req Out", reqOut, Icons.logout, Colors.orange),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Reason:",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            item["Reason"] ?? "No reason provided",
            style: TextStyle(
              fontSize: 13.sp,
              color: ThemeClass.textBlack,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showActionDialog(item, "Reject"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text("Reject"),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showActionDialog(item, "Approve"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text("Approve", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
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
