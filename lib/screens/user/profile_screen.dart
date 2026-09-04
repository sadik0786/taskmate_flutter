// ignore_for_file: unused_element

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:task_mate/utils/file_download.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/services/base_api_service.dart';
import 'package:task_mate/services/auth/auth_service.dart';
import 'package:task_mate/services/admin/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/responsive_desktop_wrappers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // final ThemeController _themeController = Get.find();
  String? avatarUrl;
  File? localAvatar;
  int? userID = 0;
  String? userName;
  String? email;
  String? mobile;
  List allTasks = [];
  bool isDarkMode = false;
  bool _isLoading = true;
  Map<String, dynamic> userData = {};

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _checkAuthAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final role = prefs.getString("role")?.toLowerCase() ?? '';
    final userId = prefs.getInt("userId");
    if (token == null || token.isEmpty || userId == null) {
      Get.offAllNamed(Routes.login);
      return;
    }
    switch (role) {
      case 'manager':
        Get.until(
          (route) =>
              route.settings.name == Routes.adminDashboard || route.isFirst,
        );
        break;
      case 'admin':
        Get.until(
          (route) =>
              route.settings.name == Routes.adminDashboard || route.isFirst,
        );
        break;
      case 'ceo':
      case 'hr':
        Get.until(
          (route) =>
              route.settings.name == Routes.adminDashboard || route.isFirst,
        );
        break;
      case 'employee':
        Get.until(
          (route) => route.settings.name == Routes.homeScreen || route.isFirst,
        );
        break;
      default:
        // If role not recognized, clear data and go to login
        await prefs.clear();
        Get.offAllNamed(Routes.login);
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic>? userFromServer;
    try {
      // ✅ Try fetching latest user from server
      userFromServer = (await UserService.getCurrentUserRole());
      if (userFromServer != null) {
        // Update local cache for offline usage
        final int uId = userFromServer["id"] ?? 0;
        await prefs.setInt("userId", uId);
        await prefs.setString("name", userFromServer["name"] ?? "");
        await prefs.setString("email", userFromServer["email"] ?? "");
        await prefs.setString("mobile", userFromServer["mobile"] ?? "");
        await prefs.setString("role", userFromServer["roleName"] ?? "");
        if (userFromServer["profileImage"] != null) {
          await prefs.setString("avatarUrl", userFromServer["profileImage"]);
        }
      }
    } catch (e) {
      CustomSnackBar.warning("Offline - Showing cached data");
    }
    setState(() {
      userData = userFromServer ?? {};
      userID = userData["id"] ?? prefs.getInt("userId") ?? 0;
      userName = userData["name"] ?? prefs.getString("name") ?? "";
      email = userData["email"] ?? prefs.getString("email") ?? "";
      mobile = userData["mobile"] ?? prefs.getString("mobile") ?? "";

      final localPath = prefs.getString("localAvatarPath");
      if (localPath != null && localPath.isNotEmpty) {
        localAvatar = File(localPath); // show local picked photo
        avatarUrl = null; // optional: avoid showing old network image
      } else {
        final avatarPath =
            userFromServer?["ProfileImage"] ?? prefs.getString("avatarUrl");
        if (avatarPath != null && avatarPath.isNotEmpty) {
          avatarUrl = avatarPath;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _logOut() async {
    await BaseApiService.clearToken();
    if (!mounted) return;
    Get.offAllNamed(Routes.login);
  }

  Future<void> _uploadPhoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final file = File(picked.path);

      // Show selected image immediately
      setState(() {
        localAvatar = file;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("localAvatarPath", file.path);
      CustomSnackBar.success("Profile photo updated");

      // Upload to server
      final url = await UserService.uploadAvatar(file);
      if (url != null) {
        setState(() {
          avatarUrl = url;
        });
        await prefs.setString("avatarUrl", url);
      }
    } catch (e) {
      CustomSnackBar.success("Error: $e");
    }
  }

  Future<void> _updateMobile(String newMobile) async {
    try {
      // 🔹 Call API to update mobile in DB
      final success = await AuthService.updateMobile(newMobile);

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("mobile", newMobile);

        setState(() {
          mobile = newMobile;
        });
        CustomSnackBar.success("Mobile updated successfully");
      } else {
        CustomSnackBar.error("Failed to update mobile");
      }
    } catch (e) {
      CustomSnackBar.error("Error: $e");
    }
  }

  // 🔹 Export to PDF
  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat("dd/MM/yyyy hh:mm a");

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "All Tasks Report",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: [
              "No",
              "Project",
              "Mode",
              "Title",
              "Details",
              "Status",
              "Start",
              "End",
            ],
            data: List.generate(allTasks.length, (i) {
              final t = allTasks[i];
              final startTime =
                  (t["startTime"] != null && t["startTime"].isNotEmpty)
                  ? dateFormatter.format(
                      DateTime.parse(t["startTime"]).toLocal(),
                    )
                  : "";

              final endTime = (t["endTime"] != null && t["endTime"].isNotEmpty)
                  ? dateFormatter.format(DateTime.parse(t["endTime"]).toLocal())
                  : "";
              return [
                "${i + 1}",
                t["project"] ?? "",
                t["mode"] ?? "",
                t["title"] ?? "",
                t["description"] ?? "",
                t["status"] ?? "",
                startTime,
                endTime,
              ];
            }),
          ),
        ],
      ),
    );

    await saveAndLaunchFile(await pdf.save(), "${userName}_tasks.pdf");
  }

  // 🔹 Export to Excel
  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheetObject = excel['Tasks'];
    final dateFormatter = DateFormat("dd/MM/yyyy hh:mm a");

    sheetObject.appendRow([
      TextCellValue("Task No"),
      TextCellValue("Project"),
      TextCellValue("Mode"),
      TextCellValue("Title"),
      TextCellValue("Description"),
      TextCellValue("Status"),
      TextCellValue("Start Time"),
      TextCellValue("End Time"),
      TextCellValue("Created At"),
    ]);

    for (int i = 0; i < allTasks.length; i++) {
      final t = allTasks[i];
      sheetObject.appendRow([
        TextCellValue("${i + 1}"),
        TextCellValue(t["project"] ?? ""),
        TextCellValue(t["mode"] ?? ""),
        TextCellValue(t["title"] ?? ""),
        TextCellValue(t["description"] ?? ""),
        TextCellValue(t["status"] ?? ""),
        TextCellValue(
          t["startTime"] != null && t["startTime"].isNotEmpty
              ? dateFormatter.format(DateTime.parse(t["startTime"]).toLocal())
              : "",
        ),
        TextCellValue(
          t["endTime"] != null && t["endTime"].isNotEmpty
              ? dateFormatter.format(DateTime.parse(t["endTime"]).toLocal())
              : "",
        ),
        TextCellValue(
          t["createdAt"] != null && t["createdAt"].isNotEmpty
              ? dateFormatter.format(DateTime.parse(t["createdAt"]).toLocal())
              : "",
        ),
      ]);
    }

    await saveAndLaunchFile(excel.encode()!, "${userName}_tasks.xlsx");
  }

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

  @override
  Widget build(BuildContext context) {
    // Data Extraction (with fallbacks)
    final String reportingTo = userData["addedByName"]?.toString() ?? "None";
    final String empId =
        userData["employeeID"]?.toString() ??
        "EMP-${userID.toString().padLeft(4, '0')}";
    final String gender = userData["gender"]?.toString() ?? "Not specified";
    final String dob = formatDate(userData["dateOfBirth"]?.toString());
    final String bloodGroup =
        userData["bloodGroup"]?.toString() ?? "Not specified";
    final String emergencyContact =
        userData["emergencyContact"]?.toString() ?? "Not specified";
    final String address = userData["address"]?.toString() ?? "Not specified";

    final String department =
        userData["department"]?.toString() ?? "Not specified";
    final String role =
        userData["roleName"]?.toString().toUpperCase() ?? "UNKNOWN";
    final String designation = role;
    final String doj = formatDate(userData["dateOfJoining"]?.toString());
    final String employmentType =
        userData["employmentType"]?.toString() ?? "Full-time";
    final String officeLocation =
        userData["officeLocation"]?.toString() ?? "Head Office";

    final String aadhaar =
        userData["aadhaarNumber"]?.toString() ?? "Not specified";
    final String pan = userData["panNumber"]?.toString() ?? "Not specified";
    final String bankDetails =
        userData["bankDetails"]?.toString() ?? "Not specified";
    final String salary = userData["salary"]?.toString() ?? "Not specified";
    final String profileStatus =
        userData["profileStatus"]?.toString() ?? "Active";

    return BaseLayout(
      title: "My Profile",
      // customActions: [
      //   IconButton(
      //     icon: const Icon(Icons.home),
      //     onPressed: () async {
      //       _checkAuthAndNavigate();
      //     },
      //   ),
      // ],
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? const Center(child: PageLoader())
            : ResponsiveFormWrapper(
                title: "Profile",
                subtitle: "View and edit your details",
                maxWidth: 800,
                padding: EdgeInsets.zero,
                wrapInCardOnDesktop: false,
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
                              color: Theme.of(
                                context,
                              ).shadowColor.withOpacity(0.05),
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
                                  child: GestureDetector(
                                    onTap: _uploadPhoto,
                                    child: CircleAvatar(
                                      radius: 50.r,
                                      backgroundColor: ThemeClass.primaryGreen
                                          .withOpacity(0.1),
                                      backgroundImage: localAvatar != null
                                          ? FileImage(localAvatar!)
                                          : (avatarUrl != null
                                                ? NetworkImage(avatarUrl!)
                                                : null),
                                      child:
                                          (localAvatar == null &&
                                              avatarUrl == null)
                                          ? Text(
                                              userName != null &&
                                                      userName!.isNotEmpty
                                                  ? userName![0].toUpperCase()
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
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        profileStatus.toLowerCase() == 'active'
                                        ? ThemeClass.successColor.withOpacity(
                                            0.2,
                                          )
                                        : ThemeClass.errorColor.withOpacity(
                                            0.2,
                                          ),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    profileStatus,
                                    style: TextStyle(
                                      color:
                                          profileStatus.toLowerCase() ==
                                              'active'
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
                              userName ?? "Not specified",
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                        _buildCompactRow(
                          context,
                          "Employee ID",
                          empId,
                          "Gender",
                          gender,
                        ),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoItem(
                                    context,
                                    "Mobile",
                                    mobile ?? "",
                                  ),
                                  SizedBox(height: 4.h),
                                  GestureDetector(
                                    onTap: _showUpdateMobileBottomSheet,
                                    child: Text(
                                      "Edit Mobile",
                                      style: TextStyle(
                                        color: ThemeClass.warningColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildInfoItem(
                                context,
                                "Email",
                                email ?? "",
                              ),
                            ),
                          ],
                        ),
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
                        ),
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
                        _buildCompactRow(
                          context,
                          "Bank Details",
                          bankDetails,
                          "Salary",
                          salary,
                        ),
                      ]),
                      SizedBox(height: 24.h),

                      CustomButton(
                        backgroundColor: ThemeClass.errorColor,
                        icon: Icons.logout,
                        text: "Logout",
                        onPressed: _logOut,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _showUpdateMobileBottomSheet() {
    final TextEditingController controller = TextEditingController(
      text: mobile,
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 16.h,
        ),
        child: ResponsiveFormWrapper(
          maxWidth: 600,
          padding: EdgeInsets.zero,
          wrapInCardOnDesktop: false,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                Text("Update Number", style: Theme.of(ctx).textTheme.bodySmall),
                SizedBox(height: 20.h),
                CustomTextField(
                  labelText: "Add Your Number",
                  isRequired: false,
                  hintText: "Enter number",
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.number,
                  controller: controller,
                  maxLength: 10,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: "Update",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newMobile = controller.text.trim();
                      Navigator.pop(ctx); // close modal
                      _updateMobile(newMobile);
                    }
                  },
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
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
            color: Theme.of(context).shadowColor.withOpacity(0.05),
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
