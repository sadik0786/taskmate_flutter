import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_mate/screens/task_screen.dart';
import 'package:task_mate/services/api_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
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
    _loadAllSubProjects();
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
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text("Failed to load projects: $e")));
    }
  }

  Future<void> _loadAllSubProjects() async {
    try {
      final res = await ApiService.fetchSubProjects();
      setState(() {
        _allSubprojects.clear();
        _allSubprojects.addAll(res.map((sp) => Map<String, dynamic>.from(sp)));
        _filterSubprojects(); // filter based on selected project
      });
    } catch (e) {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text("Failed to load subprojects: $e")));
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
    if (_title.text.trim().isEmpty ||
        _desc.text.trim().isEmpty ||
        _selectedProjectId == null ||
        _selectedSubProjectId == null ||
        _selectedMode == null ||
        _selectedStatus == null ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
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
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
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
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(const SnackBar(content: Text("Task saved successfully!")));
      Navigator.pushReplacement(
        Get.context!,
        MaterialPageRoute(builder: (_) => const TaskScreen()),
      );
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("${res['error']}")));
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xff00ca9d), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          widget.task == null ? "Add Task" : "Edit Task",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
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
              SizedBox(height: 10.h),
              DropdownButtonFormField2<int>(
                isExpanded: true,
                value: _selectedProjectId,
                items: _projects
                    .map(
                      (p) => DropdownMenuItem<int>(
                        value: p["ProjectId"],
                        child: Text(p["ProjectName"] ?? ""),
                      ),
                    )
                    .toList(),
                onChanged: _onProjectChanged,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: "Select Project",
                  prefixIcon: const Icon(Icons.work_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                dropdownStyleData: DropdownStyleData(
                  padding: EdgeInsets.zero,
                  maxHeight: 300.h,
                  width: MediaQuery.of(context).size.width - 25.w,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                ),
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0),
                  height: 20.h,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: 15.h),
              DropdownButtonFormField2<int>(
                isExpanded: true,
                value: _selectedSubProjectId,
                items: _filteredSubprojects
                    .map(
                      (sp) => DropdownMenuItem<int>(
                        value: sp["SubProjectId"],
                        child: Text(sp["SubProjectName"] ?? "Unknown"),
                      ),
                    )
                    .toList(),
                onChanged: _onSubProjectChanged,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: _selectedProjectId == null
                      ? "Select Project First"
                      : "Select Sub Project",
                  prefixIcon: const Icon(Icons.work_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                dropdownStyleData: DropdownStyleData(
                  padding: EdgeInsets.zero,
                  maxHeight: 300.h,
                  width: MediaQuery.of(context).size.width - 25.w,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                ),
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0),
                  height: 20.h,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: 15.h),
              DropdownButtonFormField2<String>(
                value: _selectedMode,
                items: _modes
                    .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedMode = v),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: "Task Mode",
                  prefixIcon: const Icon(Icons.code),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                dropdownStyleData: DropdownStyleData(
                  padding: EdgeInsets.zero,
                  maxHeight: 300.h,
                  width: MediaQuery.of(context).size.width - 25.w,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                ),
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0),
                  height: 20.h,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _title,
                decoration: _inputDecoration("Task Title", Icons.title),
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _desc,
                maxLines: 1,
                decoration: _inputDecoration("Task Details", Icons.description),
              ),
              SizedBox(height: 15.h),
              DropdownButtonFormField2<String>(
                value: _selectedStatus,
                items: _statuses
                    .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStatus = v),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: "Task Status",
                  prefixIcon: Icon(Icons.check_circle_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                dropdownStyleData: DropdownStyleData(
                  padding: EdgeInsets.zero,
                  maxHeight: 300.h,
                  width: MediaQuery.of(context).size.width - 25.w,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                ),
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0),
                  height: 20.h,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: 15.h),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextField(
                    decoration: _inputDecoration(
                      _selectedDate == null
                          ? "Select Date"
                          : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                      Icons.calendar_today,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickStartTime,
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: _inputDecoration(
                            _startTime == null ? "Start Time" : _startTime!.format(context),
                            Icons.access_time,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.h),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickEndTime,
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: _inputDecoration(
                            _endTime == null ? "End Time" : _endTime!.format(context),
                            Icons.timer_off,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text("Save Task", style: TextStyle(fontSize: 18.sp)),
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
