import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/controllers/hrms/leave_controller.dart';
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
  final LeaveController leaveController = Get.put(LeaveController());
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      leaveController.fetchAllLeaveReport();
      leaveController.fetchTodayLeaves(); // Fetch today leaves
    });
  }

  void _onSearchOrFilterChanged() {
    leaveController.filterLeaveReport(
      searchQuery: _searchCtrl.text,
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Text(
            "All Leaves Report",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 12.h),

          // Who is on leave today
          Obx(() {
            if (leaveController.todayLeaves.isEmpty) {
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
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: leaveController.todayLeaves.map((leave) {
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
                                  color: Colors.white,
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
                                    color: Colors.grey.shade600,
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
          SizedBox(height: 16.h),

          // List of Leaves
          Expanded(
            child: Obx(() {
              if (leaveController.isLoading.value) {
                return const Center(child: PageLoader());
              }

              final leaves = leaveController.filteredLeaveReport;

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
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.employeeName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "${leave.employeeRole} | ${leave.leaveTypeName}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  leave.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: const Divider(height: 1),
          ),
          Row(
            children: [
              Icon(Icons.calendar_month, size: 16.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                "${formatDate(leave.fromDate)}  to  ${formatDate(leave.toDate)}",
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  "${leave.totalDays} Days",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (leave.reason != null && leave.reason!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.subject, size: 16.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    leave.reason!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "APPROVED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      case "PENDING":
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
