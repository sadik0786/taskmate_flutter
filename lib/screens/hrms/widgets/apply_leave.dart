import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/model/leave_apply_request_model.dart';
import 'package:task_mate/services/hrms_service.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_date_field.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({super.key});

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  final LeaveController leaveController = Get.put(LeaveController());

  final TextEditingController reasonCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? selectedLeaveTypeId;
  int? selectedSessionId;

  DateTime? fromDate;
  DateTime? toDate;

  final List<Map<String, dynamic>> leaveSessions = [
    {"id": 1, "name": "Full Day"},
    {"id": 2, "name": "Half Day"},
  ];
  List<Map<String, dynamic>> leaveTypes = [];
  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          if (toDate != null && toDate!.isBefore(fromDate!)) {
            toDate = null;
          }
        } else {
          toDate = picked;
        }
      });
    }
  }

  double calculateLeaveDays() {
    if (fromDate == null || toDate == null) return 0;
    int days = toDate!.difference(fromDate!).inDays + 1;
    if (selectedSessionId == 2) {
      return 0.5;
    }
    return days.toDouble();
  }

  Future<void> onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedLeaveTypeId == null ||
        fromDate == null ||
        toDate == null ||
        selectedSessionId == null) {
      CustomSnackBar.error("Please fill all required fields");
      return;
    }

    if (selectedSessionId == 2 && fromDate != toDate) {
      CustomSnackBar.error("Half day allowed for single date only");
      return;
    }
    final totalDays = calculateLeaveDays();
    if (totalDays <= 0) {
      CustomSnackBar.error("Invalid leave duration");
      return;
    }
    // final userId = await ApiService.getLoggedInUserId();
    final request = LeaveApplyRequestModel(
      // userId: userId!,
      leaveTypeId: selectedLeaveTypeId!,
      fromDate: fromDate!.toIso8601String().split('T')[0],
      toDate: toDate!.toIso8601String().split('T')[0],
      days: totalDays,
      sessionDay: selectedSessionId!,
      reason: reasonCtrl.text.trim(),
    );
    final isSuccess = await leaveController.applyLeave(request);
    if (isSuccess) {
      _formKey.currentState!.reset();
      reasonCtrl.clear();

      selectedLeaveTypeId = null;
      selectedSessionId = null;
      fromDate = null;
      toDate = null;
      CustomSnackBar.show(
        message: "Leave applied successfully",
        backgroundColor: Colors.green,
        icon: Icons.done,
      );
      Get.toNamed(Routes.hrmsDashboard);
    }
  }

  Future<void> loadleaveTypes() async {
    try {
      final res = await ApiHrmsService.fetchAllLeaveTypes();
      setState(() {
        leaveTypes.clear();
        leaveTypes.addAll(res.map((p) => Map<String, dynamic>.from(p)));
      });
    } catch (e) {
      CustomSnackBar.info("Failed to load projects: $e");
    }
  }

  Map<String, dynamic>? selectedLeave() {
    if (selectedLeaveTypeId == null) return null;

    return leaveTypes.firstWhereOrNull((e) => e["Id"] == selectedLeaveTypeId);
  }

  void onLeaveTypeChanged(int? leaveId) {
    setState(() {
      selectedLeaveTypeId = leaveId;
    });
  }

  @override
  void initState() {
    super.initState();
    loadleaveTypes();
  }

  @override
  Widget build(BuildContext context) {
    final selected = selectedLeave();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ThemeClass.darkBgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected != null)
                leaveCard(
                  leaveName: selected["LeaveName"],
                  leaveBalance: selected["LeaveCount"]?.toDouble(),
                  isTotalDay: true,
                ),
              SizedBox(height: 20.h),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdownField<int>(
                      labelText: "Leave Type",
                      isRequired: true,
                      hintText: "Select leave type",
                      prefixIcon: Icons.event_note,
                      items: leaveTypes.map((p) {
                        return {"id": p["Id"], "name": p["LeaveName"]};
                      }).toList(),
                      valueKey: "id",
                      labelKey: "name",
                      value: selectedLeaveTypeId,
                      isEnabled: true,
                      onChanged: onLeaveTypeChanged,
                    ),
                    SizedBox(height: 10.h),
                    CustomDateField(
                      labelText: "From Date",
                      isRequired: true,
                      selectedDate: fromDate,
                      hintText: "Select from date",
                      prefixIcon: Icons.calendar_today,
                      onTap: () => _pickDate(true),
                    ),
                    SizedBox(height: 10.h),
                    CustomDateField(
                      labelText: "To Date",
                      isRequired: true,
                      selectedDate: toDate,
                      hintText: "Select to date",
                      prefixIcon: Icons.calendar_today,
                      onTap: () => _pickDate(false),
                    ),
                    SizedBox(height: 10.h),
                    CustomDropdownField<int>(
                      labelText: "Leave Session",
                      isRequired: true,
                      hintText: "Select session",
                      prefixIcon: Icons.access_time,
                      items: leaveSessions,
                      valueKey: "id",
                      labelKey: "name",
                      value: selectedSessionId,
                      isEnabled: true,
                      onChanged: (val) {
                        setState(() {
                          selectedSessionId = val;
                        });
                      },
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      labelText: "Reason",
                      hintText: "Enter Reason",
                      controller: reasonCtrl,
                      prefixIcon: Icons.description,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: CustomButton(icon: Icons.save, text: "Apply Leave", onPressed: onSubmit),
        ),
      ),
    );
  }

  Widget leaveCard({required String leaveName, double? leaveBalance, bool isTotalDay = false}) {
    return Card(
      color: ThemeClass.darkCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      elevation: 3,
      shadowColor: Colors.white54,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(leaveName, style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 4.h),
                Text(
                  leaveBalance != null ? leaveBalance.toString() : "0",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            if (isTotalDay)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Days Selected", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 4.h),
                  Text("${calculateLeaveDays()}", style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
