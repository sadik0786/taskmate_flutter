import 'dart:ui' as ui;
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
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/responsive_desktop_wrappers.dart';
import 'package:task_mate/widgets/responsive_layout.dart';

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
        offset: Offset(0, _userRole == 'hr' ? -120 : -70),
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
          if (_userRole == 'hr')
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
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.menu, color: ThemeClass.textWhite),
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
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: leaveController.isLoading.value
                ? const Center(child: PageLoader())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Financial Year Dropdown (Mobile only, Desktop moved to hrms_dashboard tab bar)
                      if (!ResponsiveLayout.isDesktop(context)) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 180.w,
                            child: CustomDropdownField<int>(
                              hintText: "Financial Year",
                              prefixIcon: Icons.calendar_today_rounded,
                              items: leaveController.financialYears
                                  .map(
                                    (year) => {
                                      'id': year.id,
                                      'year': year.yearString ?? "",
                                    },
                                  )
                                  .toList(),
                              valueKey: 'id',
                              labelKey: 'year',
                              value:
                                  leaveController.selectedFinancialYearId.value,
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  leaveController.changeFinancialYear(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // Desktop: Side by Side, Mobile: Stacked
                      if (ResponsiveLayout.isDesktop(context))
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Overview",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      _buildModernSummaryCard(
                                        title: "Pending",
                                        color: const Color(0xFFF59E0B),
                                        icon: Icons.pending_actions_rounded,
                                        value:
                                            leaveController.pendingLeave.value,
                                      ),
                                      _buildModernSummaryCard(
                                        title: "Approved",
                                        color: const Color(0xFF10B981),
                                        icon:
                                            Icons.check_circle_outline_rounded,
                                        value:
                                            leaveController.approvedLeave.value,
                                      ),
                                      _buildModernSummaryCard(
                                        title: "Total",
                                        color: const Color(0xFF3B82F6),
                                        icon: Icons.list_alt_rounded,
                                        value: leaveController
                                            .totalApplyLeave
                                            .value,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 24.w),
                            if (leaveController.leaveTypes.isNotEmpty)
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Leave Balances",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    SizedBox(height: 8.h),
                                    ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(
                                            dragDevices: {
                                              ui.PointerDeviceKind.touch,
                                              ui.PointerDeviceKind.mouse,
                                              ui.PointerDeviceKind.trackpad,
                                            },
                                          ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: leaveController.leaveTypes
                                              .map(
                                                (type) => Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8.h,
                                                  ),
                                                  child: _buildLeaveBalanceChip(
                                                    type,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Overview",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                _buildModernSummaryCard(
                                  title: "Pending",
                                  color: const Color(0xFFF59E0B),
                                  icon: Icons.pending_actions_rounded,
                                  value: leaveController.pendingLeave.value,
                                ),
                                _buildModernSummaryCard(
                                  title: "Approved",
                                  color: const Color(0xFF10B981),
                                  icon: Icons.check_circle_outline_rounded,
                                  value: leaveController.approvedLeave.value,
                                ),
                                _buildModernSummaryCard(
                                  title: "Total",
                                  color: const Color(0xFF3B82F6),
                                  icon: Icons.list_alt_rounded,
                                  value: leaveController.totalApplyLeave.value,
                                ),
                              ],
                            ),

                            if (leaveController.leaveTypes.isNotEmpty) ...[
                              Text(
                                "Leave Balances",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: 8.h),
                              ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(
                                      dragDevices: {
                                        ui.PointerDeviceKind.touch,
                                        ui.PointerDeviceKind.mouse,
                                        ui.PointerDeviceKind.trackpad,
                                      },
                                    ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: leaveController.leaveTypes
                                        .map(
                                          (type) =>
                                              _buildLeaveBalanceChip(type),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                      SizedBox(height: 24.h),

                      // Leave List
                      Text(
                        "My Leave Requests",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      SizedBox(height: 8.h),

                      Expanded(
                        child: leaveController.myLeaves.isEmpty
                            ? NoTasksWidget(message: "No Leaves Found")
                            : ResponsiveGridListWrapper(
                                itemCount: leaveController.myLeaves.length,
                                desktopChildAspectRatio: 3.5,
                                allowDynamicHeight: true,
                                itemBuilder: (context, index) {
                                  final leave = leaveController.myLeaves[index];
                                  // print("hellow ${leave}");
                                  return _leaveCard(leave);
                                },
                              ),
                      ),
                    ],
                  ),
          );
        }),
      ),
      floatingActionButton: _buildFloatingMenu(),
    );
  }

  Widget _buildLeaveBalanceChip(dynamic type) {
    return Container(
      margin: EdgeInsets.only(right: 10.w, top: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.05),
            Theme.of(context).primaryColor.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pie_chart_rounded,
            size: ResponsiveLayout.isDesktop(context) ? 30.sp : 24.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                type.leaveName ?? "",
                style: TextStyle(
                  fontSize: ResponsiveLayout.isDesktop(context) ? 14.sp : 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                "${type.remainingLeaves ?? 0} Left",
                style: TextStyle(
                  fontSize: ResponsiveLayout.isDesktop(context) ? 18.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernSummaryCard({
    required String title,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    bool isHovered = false;
    return Expanded(
      child: StatefulBuilder(
        builder: (context, setState) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              padding: EdgeInsets.all(12.w),
              transform: Matrix4.identity()
                ..translate(0.0, isHovered ? -4.0 : 0.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isHovered
                      ? color.withOpacity(0.5)
                      : Theme.of(context).dividerColor.withOpacity(0.05),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHovered
                        ? color.withOpacity(0.15)
                        : Theme.of(context).shadowColor.withOpacity(0.03),
                    blurRadius: isHovered ? 16 : 8,
                    offset: Offset(0, isHovered ? 8 : 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      icon,
                      size: ResponsiveLayout.isDesktop(context) ? 32.sp : 28.sp,
                      color: color,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveLayout.isDesktop(context) ? 12.w : 10.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: ResponsiveLayout.isDesktop(context)
                                ? 14.sp
                                : 12.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: ResponsiveLayout.isDesktop(context)
                                ? 28.sp
                                : 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _leaveCard(LeaveRequestModel leave) {
    final bool isApproved = leave.status == "APPROVED";
    final bool isRejected = leave.status == "REJECTED";

    final Color statusColor = isApproved
        ? ThemeClass.successColor
        : isRejected
        ? ThemeClass.errorColor
        : ThemeClass.warningColor;

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
            color: Theme.of(context).shadowColor.withOpacity(0.05),
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
                    Expanded(
                      child: Text(
                        "${CommonFn.formatDate(leave.fromDate)} to ${CommonFn.formatDate(leave.toDate)}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
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
                                  backgroundColor: ThemeClass.errorColor,
                                ),
                                child: Text(
                                  "Yes, Cancel",
                                  style: TextStyle(color: ThemeClass.textWhite),
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
                          color: ThemeClass.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: ThemeClass.errorColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          "Cancel Leave",
                          style: TextStyle(
                            color: ThemeClass.errorColor,
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
                  color: ThemeClass.textWhite,
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
