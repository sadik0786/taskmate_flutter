import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/widgets/no_data.dart';

class RegularizationRequestScreen extends StatefulWidget {
  const RegularizationRequestScreen({super.key});

  @override
  State<RegularizationRequestScreen> createState() =>
      _RegularizationRequestScreenState();
}

class _RegularizationRequestScreenState
    extends State<RegularizationRequestScreen> {
  final LeaveController leaveController = Get.find<LeaveController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      leaveController.fetchMyRegularizations();
    });
  }

  void _showApplyModal() {
    DateTime? selectedTargetDate;
    TimeOfDay? checkInTime;
    TimeOfDay? checkOutTime;
    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 16.h,
                left: 20.w,
                right: 20.w,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Request Regularization",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: ThemeClass.textBlack,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Date
                  _buildDatePickerRow(
                    "Target Date",
                    selectedTargetDate,
                    () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setModalState(() => selectedTargetDate = picked);
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePickerRow(
                          "Check In",
                          checkInTime,
                          () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 9, minute: 30),
                            );
                            if (picked != null) {
                              setModalState(() => checkInTime = picked);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTimePickerRow(
                          "Check Out",
                          checkOutTime,
                          () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 18, minute: 0),
                            );
                            if (picked != null) {
                              setModalState(() => checkOutTime = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Reason",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeClass.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () async {
                        if (selectedTargetDate == null ||
                            reasonController.text.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Please select date and provide reason",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // Combine date and time
                        String targetDateStr = DateFormat(
                          'yyyy-MM-dd',
                        ).format(selectedTargetDate!);
                        String? checkInStr;
                        String? checkOutStr;

                        if (checkInTime != null) {
                          final dt = DateTime(
                            selectedTargetDate!.year,
                            selectedTargetDate!.month,
                            selectedTargetDate!.day,
                            checkInTime!.hour,
                            checkInTime!.minute,
                          );
                          checkInStr = dt.toIso8601String();
                        }
                        if (checkOutTime != null) {
                          final dt = DateTime(
                            selectedTargetDate!.year,
                            selectedTargetDate!.month,
                            selectedTargetDate!.day,
                            checkOutTime!.hour,
                            checkOutTime!.minute,
                          );
                          checkOutStr = dt.toIso8601String();
                        }

                        final navigator = Navigator.of(ctx);
                        final success = await leaveController
                            .applyRegularization(
                              targetDateStr,
                              reasonController.text,
                              checkInStr,
                              checkOutStr,
                            );

                        if (success) {
                          navigator.pop();
                        }
                      },
                      child: Text(
                        "Submit Request",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDatePickerRow(
    String label,
    DateTime? selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selected != null
                  ? DateFormat('dd MMM yyyy').format(selected)
                  : label,
              style: TextStyle(
                fontSize: 14.sp,
                color: selected != null
                    ? ThemeClass.textBlack
                    : Colors.grey.shade600,
              ),
            ),
            Icon(Icons.calendar_today, size: 18.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerRow(
    String label,
    TimeOfDay? selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selected != null ? selected.format(context) : label,
              style: TextStyle(
                fontSize: 14.sp,
                color: selected != null
                    ? ThemeClass.textBlack
                    : Colors.grey.shade600,
              ),
            ),
            Icon(Icons.access_time, size: 18.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Regularizations"),
        backgroundColor: ThemeClass.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final role = prefs.getString("role")?.toLowerCase() ?? "employee";
              final adminRoles = [
                "superadmin",
                "admin",
                "hr",
                "ceo",
                "manager",
              ];
              if (adminRoles.contains(role)) {
                Get.offAllNamed(Routes.adminDashboard);
              } else {
                Get.offAllNamed(Routes.homeScreen);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyModal,
        backgroundColor: ThemeClass.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Request", style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (leaveController.isLoading.value &&
            leaveController.myRegularizations.isEmpty) {
          return const PageLoader();
        }

        if (leaveController.myRegularizations.isEmpty) {
          return const NoTasksWidget(
            message: "No regularization requests found.",
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: leaveController.myRegularizations.length,
          itemBuilder: (context, index) {
            final item = leaveController.myRegularizations[index];
            return _buildHistoryCard(item);
          },
        );
      }),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    final status = item["Status"] ?? "Pending";
    Color statusColor = Colors.orange;
    if (status == "Approved") statusColor = Colors.green;
    if (status == "Rejected") statusColor = Colors.red;

    final date = DateTime.tryParse(item["TargetDate"] ?? "");
    final dateStr = date != null
        ? DateFormat('EEEE, dd MMM yyyy').format(date)
        : "Unknown Date";

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
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: ThemeClass.textBlack,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
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
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeCol("Req In", reqIn, Icons.login, Colors.blue),
              ),
              Expanded(
                child: _buildTimeCol(
                  "Req Out",
                  reqOut,
                  Icons.logout,
                  Colors.orange,
                ),
              ),
            ],
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
            item["Reason"] ?? "-",
            style: TextStyle(fontSize: 13.sp, color: ThemeClass.textBlack),
          ),
          if (item["HrReason"] != null &&
              item["HrReason"].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              "HR Reply:",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              item["HrReason"],
              style: TextStyle(fontSize: 13.sp, color: statusColor),
            ),
          ],
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
