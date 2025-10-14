// ignore_for_file: unused_element

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/controllers/theme_controller.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/screens/page_loader.dart';
import 'package:task_mate/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController _themeController = Get.find();
  String? avatarUrl;
  File? localAvatar;
  int? userID = 0;
  String? userName;
  String? email;
  String? mobile;
  List allTasks = [];
  bool isDarkMode = false;
  bool _isLoading = true;
  String? _savedPin;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadSavedPin();
  }

  Future<void> _loadSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString("appLockPin");
    });
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
      case 'superadmin':
        Get.offAllNamed(Routes.adminDashboard);
        break;
      case 'admin':
        Get.offAllNamed(Routes.adminDashboard);
        break;
      case 'employee':
        Get.offAllNamed(Routes.homeScreen);
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
      userFromServer = (await ApiService.getCurrentUserRole()) as Map<String, dynamic>?;
      if (userFromServer != null) {
        // Update local cache for offline usage
        await prefs.setInt("userId", userFromServer["ID"]);
        await prefs.setString("name", userFromServer["Name"] ?? "");
        await prefs.setString("email", userFromServer["Email"] ?? "");
        await prefs.setString("mobile", userFromServer["Mobile"] ?? "");
        await prefs.setString("role", userFromServer["RoleName"] ?? "");
        if (userFromServer["ProfileImage"] != null) {
          await prefs.setString("avatarUrl", userFromServer["ProfileImage"]);
        }
      }
    } catch (e) {
      // No internet or server error, fallback to SharedPreferences
      Get.snackbar(
        "Offline",
        "Showing cached data",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
    setState(() {
      userID = userFromServer?["ID"] ?? prefs.getInt("userId") ?? 0;
      userName = userFromServer?["Name"] ?? prefs.getString("name") ?? "";
      email = userFromServer?["Email"] ?? prefs.getString("email") ?? "";
      mobile = userFromServer?["Mobile"] ?? prefs.getString("mobile") ?? "";

      final avatarPath = userFromServer?["ProfileImage"] ?? prefs.getString("avatarUrl");
      if (avatarPath != null && avatarPath.isNotEmpty) {
        avatarUrl = avatarPath;
      }
      _isLoading = false;
    });
  }

  Future<void> _logOut() async {
    await ApiService.clearToken();
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile photo updated")));

      // Upload to server
      final url = await ApiService.uploadAvatar(file);
      if (url != null) {
        setState(() {
          avatarUrl = url;
          // Do NOT clear localAvatar yet
        });
        await prefs.setString("avatarUrl", url);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _updateMobile(String newMobile) async {
    try {
      // 🔹 Call API to update mobile in DB
      final success = await ApiService.updateMobile(newMobile);

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("mobile", newMobile);

        setState(() {
          mobile = newMobile;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Mobile updated successfully")));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to update mobile")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
            headers: ["No", "Project", "Mode", "Title", "Details", "Status", "Start", "End"],
            data: List.generate(allTasks.length, (i) {
              final t = allTasks[i];
              final startTime = (t["startTime"] != null && t["startTime"].isNotEmpty)
                  ? dateFormatter.format(DateTime.parse(t["startTime"]).toLocal())
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

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/${userName}_tasks.pdf");
    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);
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

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/${userName}_tasks.xlsx");
    await file.create(recursive: true);
    await file.writeAsBytes(excel.encode()!);

    await OpenFilex.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text("My Profile", style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () async {
              _checkAuthAndNavigate();
            },
          ),
        ],
      ),
      body: _isLoading
          ? PageLoader()
          : Column(
              children: [
                SizedBox(height: 50.h),
                // Avatar
                Center(
                  child: GestureDetector(
                    onTap: _uploadPhoto,
                    child: CircleAvatar(
                      radius: 60.r,
                      backgroundColor: Colors.blueGrey.shade300,
                      backgroundImage: localAvatar != null
                          ? FileImage(localAvatar!)
                          : (avatarUrl != null ? NetworkImage(avatarUrl!) : null),
                      child: (localAvatar == null && avatarUrl == null)
                          ? Text(
                              userName != null && userName!.isNotEmpty
                                  ? userName![0].toUpperCase()
                                  : "?",
                              style: TextStyle(
                                fontSize: 50.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Info card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem(context, "Name", userName),
                          _buildInfoItem(context, "Email", email),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildInfoItem(context, "Mobile", mobile, isMobile: true),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, size: 25.sp, color: Colors.blueAccent),
                                onPressed: _showUpdateMobileBottomSheet,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                // log out card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Light/Dark Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _themeController.isDarkMode.value ? "Dark Mode" : "Light Mode",
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    _themeController.isDarkMode.value
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                    color: Colors.blueAccent,
                                  ),
                                ],
                              ),
                              Switch(
                                value: _themeController.isDarkMode.value,
                                onChanged: (value) {
                                  _themeController.toggleTheme();
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          // Set App Lock PIN Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showSetPinBottomSheet,
                              icon: const Icon(Icons.lock, color: Colors.white),
                              label: Text(
                                _savedPin == null ? "Set App Lock PIN" : "Change App Lock PIN",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _logOut,
                              icon: const Icon(Icons.logout, color: Colors.white),
                              label: Text(
                                "Logout",
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
                    ),
                  ),
                ),

                Spacer(),
              ],
            ),
    );
  }

  void _showUpdateMobileBottomSheet() {
    final TextEditingController controller = TextEditingController(text: mobile);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 16.h,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Update Mobile", style: Theme.of(ctx).textTheme.titleMedium),
              SizedBox(height: 12.h),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Mobile Number",
                  prefixText: "+91 ",
                  counterText: "",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Mobile number is required";
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                    return "Enter a valid 10-digit number";
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final newMobile = controller.text.trim();
                    Navigator.pop(ctx); // close modal
                    _updateMobile(newMobile);
                  }
                },
                child: const Text("Save"),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String? value, {
    bool isMobile = false,
  }) {
    final displayValue = (value != null && value.isNotEmpty)
        ? (isMobile ? "+91 $value" : value)
        : "-";

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 4.h),
          Text(
            displayValue,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showSetPinBottomSheet() {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 24.h,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _savedPin == null ? "Set App Lock PIN" : "Change App Lock PIN",
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                labelText: "Set PIN",
                hintText: "Enter 4-digit",
                controller: pinController,
                keyboardType: TextInputType.number,
                isObscure: true,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) return "PIN required";
                  if (value.length != 4) return "PIN must be 4 digits";
                  return null;
                },
              ),
              // SizedBox(height: 12.h),
              CustomTextField(
                labelText: "Set Confirm PIN",
                hintText: "Enter 4-digit",
                controller: confirmController,
                keyboardType: TextInputType.number,
                isObscure: true,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Confirm your PIN";
                  if (value != pinController.text) return "PINs do not match";
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                // icon: Icon(Icons.check, color: ThemeClass.lightCardColor),
                label: Text(
                  _savedPin == null ? "Save PIN" : "Update PIN",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString("appLockPin", pinController.text);
                    setState(() {
                      _savedPin = pinController.text;
                    });
                    Navigator.pop(Get.context!);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _savedPin == null ? "PIN set successfully!" : "PIN updated successfully!",
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
