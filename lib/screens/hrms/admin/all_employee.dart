import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/admin_hrms_controller.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/model/leave_request_model.dart';
import 'package:task_mate/widgets/custom_text_field.dart';
import 'package:task_mate/widgets/custom_choice_chip.dart';
import 'package:task_mate/widgets/no_data.dart';
import 'package:task_mate/widgets/page_loader.dart';
import 'package:intl/intl.dart';

class AllLeavesReport extends StatefulWidget {
  const AllLeavesReport({super.key});

  @override
  State<AllLeavesReport> createState() => _AllLeavesReportState();
}

class _AllLeavesReportState extends State<AllLeavesReport> {
  final AdminHrmsController controller = Get.put(AdminHrmsController());
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllLeaveReport();
      controller.fetchTodayLeaves(); // Fetch today leaves
    });
  }

  void _onSearchOrFilterChanged() {
    controller.filterLeaveReport(
      searchQuery: _searchCtrl.text,
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                if (controller.financialYears.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
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
                      value: controller.selectedFinancialYearId.value,
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
                      items: controller.financialYears.map((year) {
                        return DropdownMenuItem<int>(
                          value: year["Id"],
                          child: Text(year["YearString"]),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          controller.changeFinancialYear(newValue);
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 12.h),
          // Who is on leave today
          Obx(() {
            if (controller.todayLeaves.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "On Leave Today",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.todayLeaves.map((leave) {
                      return Container(
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14.r,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                leave.employeeName.isNotEmpty
                                    ? leave.employeeName[0].toUpperCase()
                                    : "?",
                                style: TextStyle(
                                  color: ThemeClass.textWhite,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leave.employeeName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  leave.leaveTypeName,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            );
          }),

          // Search Bar
          CustomTextField(
            controller: _searchCtrl,
            hintText: "Search Employee or Leave Type",
            prefixIcon: Icons.search,
            onChanged: (val) => _onSearchOrFilterChanged(),
          ),
          SizedBox(height: 12.h),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8.w,
              children: ["All", "PENDING", "APPROVED", "REJECTED"].map((
                String status,
              ) {
                final isSelected = _selectedStatus == status;
                return CustomChoiceChip(
                  label: status,
                  selected: isSelected,
                  onSelected: () {
                    if (!isSelected) {
                      setState(() => _selectedStatus = status);
                      _onSearchOrFilterChanged();
                    }
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 12.h),

          // List of Leaves
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: PageLoader());
              }

              final leaves = controller.filteredLeaveReport;

              if (leaves.isEmpty) {
                return const NoTasksWidget(message: "No Leaves Found");
              }

              return ListView.builder(
                itemCount: leaves.length,
                itemBuilder: (context, index) {
                  return _buildLeaveCard(leaves[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequestModel leave) {
    final statusColor = _getStatusColor(leave.status);

    String formatDate(String dateStr) {
      try {
        final d = DateTime.parse(dateStr);
        return DateFormat('dd MMM yyyy').format(d);
      } catch (_) {
        return dateStr;
      }
    }

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
                leave.employeeName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${leave.employeeRole} | ${leave.leaveTypeName}",
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
                      "${formatDate(leave.fromDate)} to ${formatDate(leave.toDate)} (${leave.totalDays} Days)",
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
                          "${leave.approvedBy!} has ${leave.status.toLowerCase()} this leave.",
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "APPROVED":
        return ThemeClass.successColor;
      case "REJECTED":
        return ThemeClass.errorColor;
      case "PENDING":
        return ThemeClass.warningColor;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}
