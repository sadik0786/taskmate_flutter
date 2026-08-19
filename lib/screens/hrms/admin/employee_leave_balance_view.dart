import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/admin_hrms_controller.dart';
import 'package:task_mate/model/user_request_model.dart';
import 'package:task_mate/services/hrms/leave_service.dart';
import 'package:task_mate/services/hrms/misc_service.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/core/theme.dart';

class EmployeeLeaveBalanceView extends StatefulWidget {
  const EmployeeLeaveBalanceView({super.key});

  @override
  State<EmployeeLeaveBalanceView> createState() =>
      _EmployeeLeaveBalanceViewState();
}

class _EmployeeLeaveBalanceViewState extends State<EmployeeLeaveBalanceView> {
  final AdminHrmsController adminController = Get.find<AdminHrmsController>();

  bool _isLoading = false;
  bool _isFetchingLeaves = false;
  List<UserRequestModel> _employees = [];
  List<dynamic> _selectedUserLeaveTypes = [];

  int? _selectedEmployeeId;
  int? _selectedFinancialYearId;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    if (adminController.financialYears.isNotEmpty) {
      final currentFy = adminController.financialYears.firstWhere(
        (e) => e["IsCurrent"] == true,
        orElse: () => adminController.financialYears.first,
      );
      _selectedFinancialYearId = currentFy["Id"];
    }
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
    if (_selectedEmployeeId == null || _selectedFinancialYearId == null) return;

    setState(() => _isFetchingLeaves = true);
    try {
      final res = await LeaveService.fetchAllLeaveTypes(
        financialYearId: _selectedFinancialYearId,
        employeeId: _selectedEmployeeId,
      );
      setState(() {
        _selectedUserLeaveTypes = res;
      });
    } catch (e) {
      CustomSnackBar.error("Failed to load employee leave balance");
    } finally {
      setState(() => _isFetchingLeaves = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final financialYears = adminController.financialYears;

    return BaseLayout(
      title: "Employee Leave Balance",
      showBackButton: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    labelText: "Financial Year",
                    hintText: "Choose year",
                    prefixIcon: Icons.calendar_today,
                    value: _selectedFinancialYearId,
                    valueKey: "Id",
                    labelKey: "YearString",
                    items: financialYears
                        .map((e) => e as Map<String, dynamic>)
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedFinancialYearId = v);
                      _fetchEmployeeLeaves();
                    },
                  ),
                  SizedBox(height: 24.h),
                  if (_selectedEmployeeId != null) ...[
                    Text(
                      "Leave Balances",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 12.h),
                    if (_isFetchingLeaves)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_selectedUserLeaveTypes.isEmpty)
                      Center(
                        child: Text(
                          "No leave types found for this employee.",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14.sp,
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: _selectedUserLeaveTypes.length,
                        itemBuilder: (context, index) {
                          final type = _selectedUserLeaveTypes[index];
                          return Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: ThemeClass.primaryGreen.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  type["LeaveName"] ?? "",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "${type["LeaveCount"] ?? 0}",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeClass.primaryGreen,
                                  ),
                                ),
                                Text(
                                  "Remaining",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
