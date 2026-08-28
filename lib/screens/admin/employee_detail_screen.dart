import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/custom_button.dart';

class EmployeeDetailScreen extends StatefulWidget {
  const EmployeeDetailScreen({super.key});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late Map<String, dynamic> e;
  late String currentUserRole;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args = Get.arguments ?? {};
    e = args["employee"] ?? {};
    currentUserRole = args["currentUserRole"]?.toString().toLowerCase() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    String formatDate(String? dateString) {
      if (dateString == null ||
          dateString.isEmpty ||
          dateString == "Not specified") {
        return "Not specified";
      }
      try {
        final d = DateTime.parse(dateString);
        return DateFormat('dd-MMM-yyyy').format(d);
      } catch (_) {
        return dateString;
      }
    }

    // Data Extraction (with fallbacks since DB doesn't have all these yet)
    final String name = e["Name"]?.toString() ?? "Not specified";
    final String email = e["Email"]?.toString() ?? "Not specified";
    final String mobile = e["Mobile"]?.toString() ?? "Not specified";
    final String role = e["RoleName"]?.toString().toUpperCase() ?? "UNKNOWN";
    final String profileImage = e["ProfileImage"]?.toString() ?? "";
    final String reportingTo = e["AddedByName"]?.toString() ?? "None";
    final int id = (e["ID"] is int)
        ? e["ID"]
        : int.tryParse(e["ID"]?.toString() ?? "0") ?? 0;

    // Placeholder fields for future DB additions
    final String empId =
        e["EmployeeID"]?.toString() ?? "EMP-${id.toString().padLeft(4, '0')}";
    final String gender = e["Gender"]?.toString() ?? "Not specified";
    final String dob = formatDate(e["DateOfBirth"]?.toString());
    final String bloodGroup = e["BloodGroup"]?.toString() ?? "Not specified";
    final String emergencyContact =
        e["EmergencyContact"]?.toString() ?? "Not specified";
    final String address = e["Address"]?.toString() ?? "Not specified";

    final String department = e["Department"]?.toString() ?? "Not specified";
    final String designation = role; // using RoleName for Designation
    final String doj = formatDate(e["DateOfJoining"]?.toString());
    final String employmentType =
        e["EmploymentType"]?.toString() ?? "Full-time";
    final String officeLocation =
        e["OfficeLocation"]?.toString() ?? "Head Office";

    final String aadhaar = e["AadhaarNumber"]?.toString() ?? "Not specified";
    final String pan = e["PANNumber"]?.toString() ?? "Not specified";
    final String bankDetails = e["BankDetails"]?.toString() ?? "Not specified";
    final String salary = e["Salary"]?.toString() ?? "Not specified";

    final String profileStatus = e["ProfileStatus"]?.toString() ?? "Active";

    final bool isAdmin =
        currentUserRole == 'admin' ||
        currentUserRole == 'ceo' ||
        currentUserRole == 'superadmin';
    final bool isHR = currentUserRole == 'hr';

    return BaseLayout(
      title: "Employee Profile",
      customActions: isHR
          ? [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final updatedData = await Get.toNamed(
                    Routes.employeeUpdateScreen,
                    arguments: e,
                  );
                  if (updatedData != null &&
                      updatedData is Map<String, dynamic>) {
                    setState(() {
                      // Merge updated data into e
                      e.addAll(updatedData);
                    });
                  }
                },
              ),
            ]
          : null,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundColor: ThemeClass.primaryGreen.withOpacity(
                            0.1,
                          ),
                          backgroundImage: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : null,
                          child: profileImage.isEmpty
                              ? Text(
                                  name != "Not specified"
                                      ? name[0].toUpperCase()
                                      : "?",
                                  style: TextStyle(
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeClass.primaryGreen,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: profileStatus.toLowerCase() == 'active'
                              ? ThemeClass.successColor.withOpacity(0.2)
                              : ThemeClass.errorColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          profileStatus,
                          style: TextStyle(
                            color: profileStatus.toLowerCase() == 'active'
                                ? ThemeClass.successColor
                                : ThemeClass.errorColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    designation,
                    style: TextStyle(
                      color: ThemeClass.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Compact details in categories
            _buildSectionCard(context, "Personal Information", [
              _buildCompactRow(context, "Employee ID", empId, "Gender", gender),
              const Divider(height: 16),
              _buildCompactRow(
                context,
                "Date of Birth",
                dob,
                "Blood Group",
                bloodGroup,
              ),
            ]),
            SizedBox(height: 16.h),

            _buildSectionCard(context, "Contact & Address", [
              _buildCompactRow(context, "Mobile", mobile, "Email", email),
              const Divider(height: 16),
              _buildCompactRow(
                context,
                "Emergency",
                emergencyContact,
                "Address",
                address,
              ),
            ]),
            SizedBox(height: 16.h),

            _buildSectionCard(context, "Professional Details", [
              _buildCompactRow(
                context,
                "Department",
                department,
                "Reporting Manager",
                reportingTo,
              ),
              const Divider(height: 16),
              _buildCompactRow(
                context,
                "Date of Joining",
                doj,
                "Employment Type",
                employmentType,
              ),
              const Divider(height: 16),
              _buildCompactRow(
                context,
                "Office Location",
                officeLocation,
                "",
                "",
              ), // empty field for alignment
            ]),
            SizedBox(height: 16.h),

            _buildSectionCard(context, "Identity & Financial", [
              _buildCompactRow(
                context,
                "Aadhaar Number",
                aadhaar,
                "PAN Number",
                pan,
              ),
              const Divider(height: 16),
              if (isAdmin)
                _buildCompactRow(
                  context,
                  "Bank Details",
                  bankDetails,
                  "Salary",
                  salary,
                )
              else
                _buildCompactRow(context, "Bank Details", bankDetails, "", ""),
            ]),
            SizedBox(height: 24.h),

            // View Tasks Button
            CustomButton(
              text: "View Tasks",
              onPressed: () {
                Get.toNamed(
                  Routes.employeeTaskScreen,
                  arguments: {"empId": id, "empName": name},
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCompactRow(
    BuildContext context,
    String title1,
    String value1,
    String title2,
    String value2,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildInfoItem(context, title1, value1)),
        if (title2.isNotEmpty) ...[
          SizedBox(width: 16.w),
          Expanded(child: _buildInfoItem(context, title2, value2)),
        ],
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.7),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
