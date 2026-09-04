import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/admin_hrms_controller.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/model/user_request_model.dart';
import 'package:task_mate/services/hrms/leave_service.dart';
import 'package:task_mate/services/hrms/misc_service.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/animated_desktop_split_view.dart';

class CarryForwardView extends StatefulWidget {
  const CarryForwardView({super.key});

  @override
  State<CarryForwardView> createState() => _CarryForwardViewState();
}

class _CarryForwardViewState extends State<CarryForwardView> {
  final AdminHrmsController adminController = Get.find<AdminHrmsController>();
  final LeaveController leaveController = Get.find<LeaveController>();

  bool _isLoading = false;
  bool _isFetchingLeaves = false;
  List<UserRequestModel> _employees = [];
  List<dynamic> _selectedUserLeaveTypes = [];

  int? _selectedEmployeeId;
  int? _selectedLeaveTypeId;
  int? _fromFinancialYearId;
  int? _toFinancialYearId;
  final TextEditingController _daysCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() => _isLoading = true);
    try {
      final res = await MiscService.allEmployee();
      setState(() {
        _employees = res;
      });
    } catch (e) {
      CustomSnackBar.error("Failed to load employees");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchEmployeeLeaves() async {
    if (_selectedEmployeeId == null || _fromFinancialYearId == null) return;

    setState(() => _isFetchingLeaves = true);
    try {
      final res = await LeaveService.fetchAllLeaveTypes(
        financialYearId: _fromFinancialYearId,
        employeeId: _selectedEmployeeId,
      );
      setState(() {
        _selectedUserLeaveTypes = res;
        _selectedLeaveTypeId = null; // reset selection on change
      });
    } catch (e) {
      CustomSnackBar.error("Failed to load employee leave balance");
    } finally {
      setState(() => _isFetchingLeaves = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedEmployeeId == null ||
        _selectedLeaveTypeId == null ||
        _fromFinancialYearId == null ||
        _toFinancialYearId == null ||
        _daysCtrl.text.isEmpty) {
      CustomSnackBar.error("Please fill all fields");
      return;
    }

    final days = int.tryParse(_daysCtrl.text);
    if (days == null || days <= 0) {
      CustomSnackBar.error("Invalid days count");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await LeaveService.carryForwardLeave(
        userId: _selectedEmployeeId!,
        leaveTypeId: _selectedLeaveTypeId!,
        fromFinancialYearId: _fromFinancialYearId!,
        toFinancialYearId: _toFinancialYearId!,
        carriedForwardDays: days,
      );
      if (res["success"] == true) {
        Get.back();
        CustomSnackBar.success(res["message"]);
      } else {
        CustomSnackBar.error(res["message"]);
      }
    } catch (e) {
      CustomSnackBar.error(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final financialYears = adminController.financialYears;

    return BaseLayout(
      title: "Carry Forward Leaves",
      showBackButton: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedDesktopSplitView(
              imageOnRight: true,
              title: "Carry Forward",
              subtitle:
                  "Easily carry forward employee leave balances across financial years.",
              icon: Icons.forward_to_inbox_rounded,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdownField<int>(
                      labelText: "Select Employee",
                      hintText: "Choose an employee",
                      prefixIcon: Icons.person,
                      value: _selectedEmployeeId,
                      valueKey: "id",
                      labelKey: "name",
                      items: _employees
                          .map((e) => {"id": e.id, "name": e.name})
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedEmployeeId = v);
                        _fetchEmployeeLeaves();
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomDropdownField<int>(
                      labelText: "From Financial Year",
                      hintText: "Choose from year",
                      prefixIcon: Icons.calendar_today,
                      value: _fromFinancialYearId,
                      valueKey: "Id",
                      labelKey: "YearString",
                      items: financialYears
                          .map((e) => e as Map<String, dynamic>)
                          .toList(),
                      onChanged: (v) {
                        setState(() => _fromFinancialYearId = v);
                        _fetchEmployeeLeaves();
                      },
                    ),
                    SizedBox(height: 16.h),
                    CustomDropdownField<int>(
                      labelText: "Select Leave Type",
                      hintText: "Choose a leave type",
                      prefixIcon: Icons.category,
                      value: _selectedLeaveTypeId,
                      valueKey: "id",
                      labelKey: "name",
                      items: _selectedUserLeaveTypes
                          .map((e) => {"id": e["Id"], "name": e["LeaveName"]})
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedLeaveTypeId = v),
                    ),
                    if (_isFetchingLeaves)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                        child: Text(
                          "Fetching leave balance...",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      )
                    else if (_selectedLeaveTypeId != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                        child: Builder(
                          builder: (context) {
                            final selectedLeave = _selectedUserLeaveTypes
                                .firstWhere(
                                  (e) => e["Id"] == _selectedLeaveTypeId,
                                  orElse: () => null,
                                );
                            if (selectedLeave != null) {
                              return Text(
                                "Available Balance: ${selectedLeave["LeaveCount"]} days",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    SizedBox(height: 16.h),
                    CustomDropdownField<int>(
                      labelText: "To Financial Year",
                      hintText: "Choose to year",
                      prefixIcon: Icons.calendar_today,
                      value: _toFinancialYearId,
                      valueKey: "Id",
                      labelKey: "YearString",
                      items: financialYears
                          .map((e) => e as Map<String, dynamic>)
                          .toList(),
                      onChanged: (v) => setState(() => _toFinancialYearId = v),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Days to Carry Forward",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      controller: _daysCtrl,
                      hintText: "Enter number of days",
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 32.h),

                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: "Submit Carry Forward",
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
