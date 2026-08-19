import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/widgets/no_data.dart';
import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/utils/common_fn.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/screens/hrms/admin/carry_forward_view.dart';
import 'package:task_mate/screens/hrms/admin/employee_leave_balance_view.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final LeaveController leaveController = Get.find<LeaveController>();
  String _userRole = "employee";

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = prefs.getString("role")?.toLowerCase() ?? "employee";
      });
    }
  }

  Widget _buildFloatingMenu() {
    final bool isHrOrAdmin = ["hr", "manager", "ceo"].contains(_userRole);
    if (!isHrOrAdmin) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: PopupMenuButton<int>(
        offset: const Offset(0, -120),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: ThemeClass.primaryGreen,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                const Text("Leave Balance"),
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Icon(
                  Icons.forward_to_inbox,
                  color: ThemeClass.primaryGreen,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                const Text("Carry Forward"),
              ],
            ),
          ),
        ],
        onSelected: (val) {
          if (val == 1) Get.to(() => const EmployeeLeaveBalanceView());
          if (val == 2) Get.to(() => const CarryForwardView());
        },
        child: Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: ThemeClass.primaryGreen,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.menu, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Obx(() {
          // Show loading for entire page
          if (leaveController.isLoading.value) {
            return Center(child: PageLoader());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // Financial Year Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Overview",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    height: 35.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: ThemeClass.primaryGreen.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: leaveController.selectedFinancialYearId.value,
                        isDense: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: ThemeClass.primaryGreen,
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        items: leaveController.financialYears.map((year) {
                          return DropdownMenuItem<int>(
                            value: year.id,
                            child: Text(year.yearString ?? ""),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            leaveController.changeFinancialYear(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Leave Summary
              Row(
                children: [
                  _compactSummaryCard(
                    title: "Pending",
                    color: ThemeClass.warningColor,
                    value: leaveController.pendingLeave.value,
                  ),
                  _compactSummaryCard(
                    title: "Approve",
                    color: ThemeClass.primaryGreen,
                    value: leaveController.approvedLeave.value,
                  ),
                  _compactSummaryCard(
                    title: "Total",
                    color: Colors.blue,
                    value: leaveController.totalApplyLeave.value,
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // Leave Balances
              if (leaveController.leaveTypes.isNotEmpty) ...[
                Text(
                  "Leave Balances",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: leaveController.leaveTypes.map((type) {
                      return Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).shadowColor.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.leaveName ?? "",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "${type.remainingLeaves ?? 0} Remaining",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 10.h),
              ],

              // Leave List
              Text(
                "My Leave Requests",
                style: Theme.of(context).textTheme.titleMedium,
              ),

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
      ),
      floatingActionButton: _buildFloatingMenu(),
    );
  }

  Widget _compactSummaryCard({
    required String title,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _leaveCard(LeaveRequestModel leave) {
    final bool isApproved = leave.status == "APPROVED";
    final bool isRejected = leave.status == "REJECTED";

    final Color statusColor = isApproved
        ? Colors.green
        : isRejected
        ? Colors.red
        : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -4),
              tilePadding: EdgeInsets.only(left: 6.w, right: 10.w),
              leading: Container(
                width: 55.w,
                padding: EdgeInsets.symmetric(vertical: 0.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(DateTime.parse(leave.fromDate)),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'EEE, MMM',
                      ).format(DateTime.parse(leave.fromDate)),
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                leave.leaveTypeName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${leave.totalDays} Days',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              childrenPadding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 14.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "${CommonFn.formatDate(leave.fromDate)} to ${CommonFn.formatDate(leave.toDate)}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                if (leave.reason != null && leave.reason!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes,
                        size: 14.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          leave.reason!,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (leave.approvedBy != null && leave.status != 'PENDING') ...[
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person,
                        size: 14.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          "${leave.approvedBy!} has ${leave.status.toLowerCase()} your leave.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (leave.status == 'PENDING') ...[
                  SizedBox(height: 16.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              "Cancel Leave",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            content: const Text(
                              "Are you sure you want to cancel this leave request?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("No"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  leaveController.cancelLeave(leave.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  "Yes, Cancel",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          "Cancel Leave",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.r),
                ),
              ),
              child: Text(
                leave.status,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
