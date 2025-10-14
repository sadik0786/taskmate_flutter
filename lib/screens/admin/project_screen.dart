import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/core/routes.dart';
import 'package:task_mate/screens/add_task_screen.dart';
import 'package:task_mate/screens/no_data.dart';
import 'package:task_mate/screens/page_loader.dart';
import 'package:task_mate/services/api_service.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_text_field.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final addtask = AddTaskScreen();
  final TextEditingController _name = TextEditingController();
  bool _loading = false;
  String? userName;
  String? userRole;

  List<dynamic> _projects = [];
  Map<String, dynamic>? _selectedProject;
  final List<Map<String, dynamic>> _projectslist = [];
  bool _loadingProjects = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadProjects();
  }

  Future<void> _loadUserRole() async {
    final res = await ApiService.getCurrentUser();
    // print("🔍 getCurrentUser response: $res");

    if (res["success"] == true && res["user"] != null) {
      final user = res["user"];
      setState(() {
        userRole = (user["RoleName"] ?? "employee").toString().toLowerCase();
      });
      // print("✅ User role set to: $userRole");
    } else {
      setState(() {
        userRole = "employee";
      });
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text("Failed to fetch user role: ${res['error'] ?? 'Unknown error'}")),
      );
    }
  }

  Future<void> _loadProjects() async {
    setState(() => _loadingProjects = true);
    try {
      final res = await ApiService.fetchProjects();
      if (!mounted) return;
      setState(() {
        _projects.clear();
        _projectslist.clear();
        _projects = res;
        _projectslist.addAll(res.map((p) => Map<String, dynamic>.from(p)));
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load projects: $e")));
    } finally {
      setState(() => _loadingProjects = false);
    }
  }

  Future<void> _addProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final res = await ApiService.addProject(_name.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res["success"] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Project added successfully")));
      _name.clear();
      _loadProjects();
    } else {
      final error = res["error"] ?? "Failed to add project";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _saveSubProject(TextEditingController subProjectText) async {
    try {
      if (_selectedProject == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please select a main project")));
        return;
      }

      if (subProjectText.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please enter subproject name")));
        return;
      }

      final userId = await ApiService.getLoggedInUserId();
      if (userId == null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }
      final projectId = int.tryParse(_selectedProject!["ProjectId"].toString());
      if (projectId == null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text("Invalid project selected")));
        return;
      }
      final subProjectName = subProjectText.text.trim();
      final res = await ApiService.addSubProject(
        projectId: projectId,
        subProjectName: subProjectName,
      );

      if (res["success"] == true) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text("Subproject added successfully!")));

        // Clear input and reset dropdown
        subProjectText.clear();
        setState(() {
          _selectedProject = null;
        });
        // Refresh the list to show updated data
        _loadProjects();
      } else {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text("Failed to add subproject: ${res['error']}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          userRole == "admin" ? "Manage Projects" : "Add Sub Projects",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              if (userRole == "admin") {
                Get.offAllNamed(Routes.adminDashboard);
              } else {
                Get.offNamed(Routes.homeScreen);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10.h),
                if (userRole == "admin") ...[
                  CustomTextField(
                    labelText: "Project Name",
                    isRequired: true,
                    hintText: "Enter project name",
                    prefixIcon: Icons.library_add,
                    controller: _name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Project cannot be empty";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  CustomButton(text: "Add Project", onPressed: _addProject, isLoading: _loading),

                  SizedBox(height: 20.h),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Projects",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      OutlinedButton.icon(
                        onPressed: _showAddSubProjectBottomSheet,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          side: BorderSide(color: Colors.grey.shade600, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          minimumSize: const Size(0, 32),
                        ),
                        icon: Icon(Icons.add, size: 16.sp, color: Colors.black87),
                        label: Text(
                          "SubProject",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: _loadingProjects
                      ? const PageLoader()
                      : _projects.isEmpty
                      ? Center(child: NoTasksWidget(message: "No project added!"))
                      : ListView.separated(
                          itemCount: _projects.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: Theme.of(context).colorScheme.primary),
                          itemBuilder: (context, index) {
                            final project = _projects[index];
                            final creatorName = project["creatorName"] ?? "Unknown";
                            final createdAt = project["createdAt"] != null
                                ? DateFormat(
                                    'dd/MM/yyyy hh:mm a',
                                  ).format(DateTime.parse(project["createdAt"]))
                                : "";
                            return ListTile(
                              dense: true,
                              minTileHeight: 10.0.h,
                              minVerticalPadding: 0,
                              leading: Icon(
                                Icons.folder,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                "Project: ${project["ProjectName"].toString().toUpperCase()}",
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Created by: $creatorName"),
                                  Text("Date: $createdAt"),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownButtonFormField2<Map<String, dynamic>> dropDownList(BuildContext context) {
    return DropdownButtonFormField2<Map<String, dynamic>>(
      isExpanded: true,
      value: _selectedProject,
      items: _projectslist
          .map(
            (p) => DropdownMenuItem<Map<String, dynamic>>(
              value: p,
              child: Text(p["ProjectName"] ?? ""),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedProject = value;
          // print("✅ Selected project: $_selectedProject");
        });
      },
      decoration: InputDecoration(
        labelText: "Select Main Project*",
        // prefixIcon: const Icon(Icons.work),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null) {
          return "Please select a project";
        }
        return null;
      },
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300.h,
        width: MediaQuery.of(context).size.width - 40.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      ),
      buttonStyleData: ButtonStyleData(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        height: 20.h,
        width: double.infinity,
      ),
    );
  }

  void _showAddSubProjectBottomSheet() {
    final TextEditingController subProjectText = TextEditingController();
    final formKey = GlobalKey<FormState>();
    // Reset dropdown when opening modal
    setState(() {
      _selectedProject = null;
    });
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Add SubProject", style: Theme.of(ctx).textTheme.titleLarge),
                SizedBox(height: 20.h),
                dropDownList(ctx),
                SizedBox(height: 12.h),
                CustomTextField(
                  labelText: "Sub project name",
                  hintText: "Enter sub project name",
                  controller: subProjectText,
                  isRequired: true,
                  keyboardType: TextInputType.text,
                  maxLength: 50,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Subproject is required";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                CustomButton(
                  text: "Add",
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await _saveSubProject(subProjectText);
                      Get.back(result: () => AddTaskScreen(key: addTaskKey));
                      addTaskKey.currentState?.loadAllSubProjects();
                      Navigator.pop(Get.context!);
                    } else {
                      setState(() {
                        _selectedProject = null;
                      });
                    }
                  },
                  isLoading: _loading,
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
