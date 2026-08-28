import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/services/admin/user_service.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/widgets/custom_text_field.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';

class EmployeeUpdateScreen extends StatefulWidget {
  const EmployeeUpdateScreen({super.key});

  @override
  State<EmployeeUpdateScreen> createState() => _EmployeeUpdateScreenState();
}

class _EmployeeUpdateScreenState extends State<EmployeeUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic> employee = {};

  // Controllers
  final _empIdCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _bloodGroupCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _dojCtrl = TextEditingController();
  final _empTypeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    employee = Get.arguments ?? {};
    _initializeFields();
  }

  void _initializeFields() {
    _empIdCtrl.text = employee["EmployeeID"] ?? "";
    _genderCtrl.text = employee["Gender"] ?? "";

    // Parse DB Date to dd-MMM-yyyy format
    if (employee["DateOfBirth"] != null &&
        employee["DateOfBirth"].toString().isNotEmpty) {
      try {
        final d = DateTime.parse(employee["DateOfBirth"].toString());
        _dobCtrl.text = DateFormat('dd-MMM-yyyy').format(d);
      } catch (e) {
        // Ignore parsing errors, keep default empty
      }
    }

    _bloodGroupCtrl.text = employee["BloodGroup"] ?? "";
    _emergencyCtrl.text = employee["EmergencyContact"] ?? "";
    _addressCtrl.text = employee["Address"] ?? "";

    // Autofill department from RoleName if empty
    String dep = employee["Department"] ?? "";
    if (dep.isEmpty && employee["RoleName"] != null) {
      dep = employee["RoleName"];
    }
    _departmentCtrl.text = dep;

    if (employee["DateOfJoining"] != null &&
        employee["DateOfJoining"].toString().isNotEmpty) {
      try {
        final d = DateTime.parse(employee["DateOfJoining"].toString());
        _dojCtrl.text = DateFormat('dd-MMM-yyyy').format(d);
      } catch (e) {
        // Ignore parsing errors, keep default empty
      }
    }

    _empTypeCtrl.text = employee["EmploymentType"] ?? "";
    _locationCtrl.text = employee["OfficeLocation"] ?? "";
    _salaryCtrl.text = employee["Salary"]?.toString() ?? "";
    _aadhaarCtrl.text = employee["AadhaarNumber"] ?? "";
    _panCtrl.text = employee["PANNumber"] ?? "";
    _bankCtrl.text = employee["BankDetails"] ?? "";
    _statusCtrl.text = employee["ProfileStatus"] ?? "Active";
  }

  @override
  void dispose() {
    _empIdCtrl.dispose();
    _genderCtrl.dispose();
    _dobCtrl.dispose();
    _bloodGroupCtrl.dispose();
    _emergencyCtrl.dispose();
    _addressCtrl.dispose();
    _departmentCtrl.dispose();
    _dojCtrl.dispose();
    _empTypeCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _aadhaarCtrl.dispose();
    _panCtrl.dispose();
    _bankCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Convert dd-MMM-yyyy to YYYY-MM-DD for backend
    String formatForBackend(String val) {
      if (val.isEmpty) return "";
      try {
        final d = DateFormat('dd-MMM-yyyy').parse(val);
        return DateFormat('yyyy-MM-dd').format(d);
      } catch (e) {
        // Ignore splitting errors, return original
      }
      return val;
    }

    final Map<String, dynamic> data = {
      "EmployeeID": _empIdCtrl.text.trim(),
      "Gender": _genderCtrl.text.trim(),
      "DateOfBirth": formatForBackend(_dobCtrl.text.trim()),
      "BloodGroup": _bloodGroupCtrl.text.trim(),
      "EmergencyContact": _emergencyCtrl.text.trim(),
      "Address": _addressCtrl.text.trim(),
      "Department": _departmentCtrl.text.trim(),
      "DateOfJoining": formatForBackend(_dojCtrl.text.trim()),
      "EmploymentType": _empTypeCtrl.text.trim(),
      "OfficeLocation": _locationCtrl.text.trim(),
      "Salary": _salaryCtrl.text.trim(),
      "AadhaarNumber": _aadhaarCtrl.text.trim(),
      "PANNumber": _panCtrl.text.trim(),
      "BankDetails": _bankCtrl.text.trim(),
      "ProfileStatus": _statusCtrl.text.trim(),
    };

    final success = await UserService.updateEmployeeDetails(
      employee["ID"],
      data,
    );

    setState(() => _isLoading = false);

    if (success) {
      Get.back(result: data);
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          "Success",
          "Details updated successfully!",
          backgroundColor: ThemeClass.successColor,
          colorText: ThemeClass.textWhite,
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } else {
      Get.snackbar(
        "Error",
        "Failed to update details.",
        backgroundColor: ThemeClass.errorColor,
        colorText: ThemeClass.textWhite,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Update Employee Details",
      child: _isLoading
          ? const PageLoader()
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSection("Personal Information", [
                      _buildTextField("Employee ID", _empIdCtrl),
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: CustomDropdownField<String>(
                          labelText: "Gender",
                          hintText: "Select Gender",
                          prefixIcon: Icons.person_outline,
                          items: const [
                            {"val": "Male", "lbl": "Male"},
                            {"val": "Female", "lbl": "Female"},
                            {"val": "Other", "lbl": "Other"},
                          ],
                          valueKey: "val",
                          labelKey: "lbl",
                          value: _genderCtrl.text.isEmpty
                              ? "Male"
                              : _genderCtrl.text,
                          onChanged: (val) {
                            if (val != null) _genderCtrl.text = val;
                          },
                        ),
                      ),
                      _buildDateField("Date of Birth (dd-MMM-yyyy)", _dobCtrl),
                      _buildTextField("Blood Group", _bloodGroupCtrl),
                    ]),
                    SizedBox(height: 16.h),
                    _buildSection("Contact & Address", [
                      _buildTextField("Emergency Contact", _emergencyCtrl),
                      _buildTextField("Address", _addressCtrl, maxLines: 3),
                    ]),
                    SizedBox(height: 16.h),
                    _buildSection("Professional Details", [
                      _buildTextField("Department", _departmentCtrl),
                      _buildDateField(
                        "Date of Joining (dd-MMM-yyyy)",
                        _dojCtrl,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: CustomDropdownField<String>(
                          labelText: "Employment Type",
                          hintText: "Select Type",
                          prefixIcon: Icons.work_outline,
                          items: const [
                            {"val": "Full-time", "lbl": "Full-time"},
                            {"val": "Part-time", "lbl": "Part-time"},
                            {"val": "Contract", "lbl": "Contract"},
                            {"val": "Intern", "lbl": "Intern"},
                            {"val": "Freelance", "lbl": "Freelance"},
                          ],
                          valueKey: "val",
                          labelKey: "lbl",
                          value: _empTypeCtrl.text.isEmpty
                              ? "Full-time"
                              : _empTypeCtrl.text,
                          onChanged: (val) {
                            if (val != null) _empTypeCtrl.text = val;
                          },
                        ),
                      ),
                      _buildTextField("Office Location", _locationCtrl),
                    ]),
                    SizedBox(height: 16.h),
                    _buildSection("Identity & Financial", [
                      _buildTextField("Aadhaar Number", _aadhaarCtrl),
                      _buildTextField("PAN Number", _panCtrl),
                      _buildTextField("Bank Details", _bankCtrl, maxLines: 3),
                      _buildTextField(
                        "Salary",
                        _salaryCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ]),
                    SizedBox(height: 16.h),
                    _buildSection("Status", [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: CustomDropdownField<String>(
                          labelText: "Profile Status",
                          hintText: "Select Status",
                          prefixIcon: Icons.toggle_on_outlined,
                          items: const [
                            {"val": "Active", "lbl": "Active"},
                            {"val": "Inactive", "lbl": "Inactive"},
                          ],
                          valueKey: "val",
                          labelKey: "lbl",
                          value: _statusCtrl.text.isEmpty
                              ? "Active"
                              : _statusCtrl.text,
                          onChanged: (val) {
                            if (val != null) _statusCtrl.text = val;
                          },
                        ),
                      ),
                    ]),
                    SizedBox(height: 24.h),
                    CustomButton(text: "Save Details", onPressed: _submit),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomTextField(
        controller: controller,
        hintText: label,
        maxLines: maxLines,
        keyboardType: keyboardType ?? TextInputType.text,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () async {
          final initialDate = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(1950),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text = DateFormat('dd-MMM-yyyy').format(picked);
          }
        },
        child: IgnorePointer(
          child: CustomTextField(controller: controller, hintText: label),
        ),
      ),
    );
  }
}
