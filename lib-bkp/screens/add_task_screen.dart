import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/screens/task_screen.dart';
import 'package:task_mate/services/api_service.dart';
import 'package:task_mate/widgets/custom_date_field.dart';
import 'package:task_mate/widgets/custom_time_field.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

final GlobalKey<AddTaskScreenState> addTaskKey = GlobalKey<AddTaskScreenState>();

class AddTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;

  const AddTaskScreen({super.key, this.task}); // <- super.key here

  @override
  State<AddTaskScreen> createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();

  // Map<String, dynamic>? _selectedProject;
  // Map<String, dynamic>? _selectedSubProject;
  int? _selectedProjectId;
  int? _selectedSubProjectId;
  String? _selectedMode;
  String? _selectedStatus;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<Map<String, dynamic>> _projects = [];
  final List<Map<String, dynamic>> _allSubprojects = [];
  List<Map<String, dynamic>> _filteredSubprojects = [];

  final List<String> _modes = ["API", "Database", "UI", "Backend", "Others"];
  final List<String> _statuses = ["Working", "Complete"];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    loadAllSubProjects();
    if (widget.task != null) _prefillTask();
  }

  void _prefillTask() {
    final task = widget.task!;
    _title.text = task["title"] ?? "";
    _desc.text = task["description"] ?? "";
    _selectedProjectId = task["projectId"];
    _selectedSubProjectId = task["subProjectId"];
    _selectedMode = task["mode"];
    _selectedStatus = task["status"];

    if (task["startTime"] != null && task["startTime"].toString().isNotEmpty) {
      final startDT = DateTime.parse(task["startTime"]).toLocal(); // convert to local
      _selectedDate = DateTime(startDT.year, startDT.month, startDT.day);
      _startTime = TimeOfDay(hour: startDT.hour, minute: startDT.minute);
    }

    if (task["endTime"] != null && task["endTime"].toString().isNotEmpty) {
      final endDT = DateTime.parse(task["endTime"]).toLocal(); // convert to local
      _endTime = TimeOfDay(hour: endDT.hour, minute: endDT.minute);
    }

    // Optional: if startTime exists but _selectedDate is null, set _selectedDate from startTime
    if (_selectedDate == null && _startTime != null) {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
    }
  }

  Future<void> _loadProjects() async {
    try {
      final res = await ApiService.fetchProjects();
      setState(() {
        _projects.clear();
        _projects.addAll(res.map((p) => Map<String, dynamic>.from(p)));
      });
      _filterSubprojects();
    } catch (e) {
      CustomSnackBar.info("Failed to load projects: $e");
    }
  }

  // Future<void> _loadAllSubProjects() async {
  //   try {
  //     final res = await ApiService.fetchSubProjects();
  //     setState(() {
  //       _allSubprojects.clear();
  //       _allSubprojects.addAll(res.map((sp) => Map<String, dynamic>.from(sp)));
  //       _filterSubprojects(); // filter based on selected project
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       Get.context!,
  //     ).showSnackBar(SnackBar(content: Text("Failed to load subprojects: $e")));
  //   }
  // }

  Future<void> loadAllSubProjects() async {
    try {
      final res = await ApiService.fetchSubProjects();
      if (!mounted) return;

      setState(() {
        _allSubprojects.clear();
        _allSubprojects.addAll(res.map((sp) => Map<String, dynamic>.from(sp)));
        _filterSubprojects();
      });
    } catch (e) {
      CustomSnackBar.info("Failed to load subprojects: $e");
    }
  }

  void _filterSubprojects() {
    if (_selectedProjectId == null) {
      _filteredSubprojects = [];
    } else {
      _filteredSubprojects = _allSubprojects
          .where((s) => s["ProjectId"] == _selectedProjectId)
          .toList();
    }
  }

  void _onProjectChanged(int? projectId) {
    setState(() {
      _selectedProjectId = projectId;
      _selectedSubProjectId = null;
      _filterSubprojects();
    });
  }

  void _onSubProjectChanged(int? subProjectId) {
    setState(() => _selectedSubProjectId = subProjectId);
  }

  Future<void> _save() async {
    if (_selectedProjectId == null) {
      CustomSnackBar.error("Please select main project");
      return;
    }
    if (_selectedSubProjectId == null) {
      CustomSnackBar.error("Please select sub project");
      return;
    }
    if (_title.text.trim().isEmpty ||
        _desc.text.trim().isEmpty ||
        // _selectedProjectId == null ||
        // _selectedSubProjectId == null ||
        _selectedMode == null ||
        _selectedStatus == null ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      CustomSnackBar.error("Please fill all fields");
      return;
    }

    // Create DateTime objects and convert to UTC
    final startDateTimeLocal = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTimeLocal = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    final startDateTimeUTC = startDateTimeLocal.toUtc();
    final endDateTimeUTC = endDateTimeLocal.toUtc();

    final userId = await ApiService.getLoggedInUserId();

    if (userId == null) {
      CustomSnackBar.error("User not logged in");
      return;
    }

    Map<String, dynamic> res;
    if (widget.task == null) {
      // Add new task
      res = await ApiService.createTask(
        projectId: _selectedProjectId!,
        subProjectId: _selectedSubProjectId!,
        title: _title.text.trim(),
        taskDetails: _desc.text.trim(),
        mode: _selectedMode!,
        status: _selectedStatus!,
        startDate: startDateTimeUTC.toIso8601String(),
        endDate: endDateTimeUTC.toIso8601String(),
        createdBy: userId,
      );
    } else {
      // Update existing task
      final taskId = int.tryParse(widget.task!["id"].toString());
      res = await ApiService.updateTask(
        taskId: taskId!,
        projectId: _selectedProjectId!,
        subProjectId: _selectedSubProjectId!,
        title: _title.text.trim(),
        taskDetails: _desc.text.trim(),
        mode: _selectedMode!,
        status: _selectedStatus!,
        startDate: startDateTimeUTC.toIso8601String(),
        endDate: endDateTimeUTC.toIso8601String(),
      );
    }

    if (res["success"] == true) {
      CustomSnackBar.success("Task saved successfully!");
      Navigator.pushReplacement(
        Get.context!,
        MaterialPageRoute(builder: (_) => const TaskScreen()),
      );
    } else {
      CustomSnackBar.error("${res['error']}");
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: _endTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _endTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeClass.darkBgColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          widget.task == null ? "Add Task" : "Edit Task",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Get.toNamed(Routes.projectScreen);
            },
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              CustomDropdownField<int>(
                // fillColor: ThemeClass.darkBlue,
                labelText: "Select Main Project",
                isRequired: true,
                hintText: "Select Main Project",
                prefixIcon: Icons.work,
                items: _projects
                    .map((p) => {"ID": p["ProjectId"], "Name": p["ProjectName"] ?? ""})
                    .toList(),
                valueKey: "ID",
                labelKey: "Name",
                value: _selectedProjectId,
                isEnabled: true,
                onChanged: _onProjectChanged,
              ),
              SizedBox(height: 10.h),
              CustomDropdownField<int>(
                // fillColor: ThemeClass.darkBlue,
                labelText: _selectedProjectId == null
                    ? "Select Project First"
                    : "Select Sub Project",
                isRequired: true,
                hintText: "Select Sub Project",
                prefixIcon: Icons.work,
                items: _filteredSubprojects
                    .map(
                      (sp) => {"ID": sp["SubProjectId"], "Name": sp["SubProjectName"] ?? "Unknown"},
                    )
                    .toList(),
                valueKey: "ID",
                labelKey: "Name",
                value: _selectedSubProjectId,
                isEnabled: _selectedProjectId != null,
                onChanged: _onSubProjectChanged,
              ),
              SizedBox(height: 10.h),
              CustomDropdownField<String>(
                // fillColor: ThemeClass.darkBlue,
                labelText: "Task Type",
                isRequired: true,
                hintText: "Select Task Mode",
                prefixIcon: Icons.code,
                items: _modes.map((m) => {"ID": m, "Name": m}).toList(),
                valueKey: "ID",
                labelKey: "Name",
                value: _selectedMode,
                isEnabled: true,
                onChanged: (v) {
                  setState(() => _selectedMode = v);
                },
              ),
              SizedBox(height: 10.h),
              CustomTextField(
                labelText: "Task Title",
                isRequired: true,
                hintText: "Enter Task Title",
                prefixIcon: Icons.title,
                keyboardType: TextInputType.text,
                controller: _title,
                // fillColor: ThemeClass.darkBlue,
              ),
              SizedBox(height: 10.h),
              CustomTextField(
                labelText: "Task Details",
                isRequired: true,
                hintText: "Enter Task Details",
                prefixIcon: Icons.description,
                keyboardType: TextInputType.text,
                controller: _desc,
                maxLines: 2,
                // fillColor: ThemeClass.darkBlue,
              ),
              SizedBox(height: 10.h),
              CustomDropdownField<String>(
                // fillColor: ThemeClass.darkBlue,
                labelText: "Task Status",
                isRequired: true,
                hintText: "Select Task Status",
                prefixIcon: Icons.check_circle_outline,
                items: _statuses.map((s) => {"ID": s, "Name": s}).toList(),
                valueKey: "ID",
                labelKey: "Name",
                value: _selectedStatus,
                isEnabled: true,
                onChanged: (v) => setState(() => _selectedStatus = v),
              ),
              SizedBox(height: 10.h),
              CustomDateField(
                selectedDate: _selectedDate,
                onTap: _pickDate,
                labelText: "Select Date",
                isRequired: true,
                prefixIcon: Icons.calendar_today,
                hintText: "Select Date",
                // fillColor: ThemeClass.darkBlue,
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Flexible(
                    child: CustomTimeField(
                      // fillColor: ThemeClass.darkBlue,
                      selectedTime: _startTime,
                      onTap: _pickStartTime,
                      labelText: "Start Time",
                      isRequired: true,
                      prefixIcon: Icons.access_time,
                      hintText: "Start Time",
                      validator: (time) {
                        if (time == null) return "Start time is required";
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Flexible(
                    child: CustomTimeField(
                      // fillColor: ThemeClass.darkBlue,
                      selectedTime: _endTime,
                      onTap: _pickEndTime,
                      labelText: "End Time",
                      isRequired: true,
                      prefixIcon: Icons.timer_off,
                      hintText: "End Time",
                      validator: (time) {
                        if (time == null) return "End time is required";
                        return null;
                      },
                    ),
                  ),
                  // Expanded(
                  //   child: GestureDetector(
                  //     onTap: _pickStartTime,
                  //     child: AbsorbPointer(
                  //       child: TextField(
                  //         decoration: _inputDecoration(
                  //           _startTime == null ? "Start Time" : _startTime!.format(context),
                  //           Icons.access_time,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(width: 10.h),
                  // Expanded(
                  //   child: GestureDetector(
                  //     onTap: _pickEndTime,
                  //     child: AbsorbPointer(
                  //       child: TextField(
                  //         decoration: _inputDecoration(
                  //           _endTime == null ? "End Time" : _endTime!.format(context),
                  //           Icons.timer_off,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 24.h),
              CustomButton(icon: Icons.save, text: "Save Task", onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
