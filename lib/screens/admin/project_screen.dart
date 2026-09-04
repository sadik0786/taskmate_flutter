import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/widgets/no_data.dart';
import 'package:task_mate/widgets/page_loader.dart';
import 'package:task_mate/services/admin/user_service.dart';
import 'package:task_mate/services/admin/project_service.dart';
import 'package:task_mate/widgets/custom_button.dart';
import 'package:task_mate/widgets/custom_dropdown_field.dart';
import 'package:task_mate/widgets/custom_snackbar.dart';
import 'package:task_mate/widgets/custom_text_field.dart';
import 'package:task_mate/widgets/base_layout.dart';
import 'package:task_mate/widgets/responsive_layout.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final _projectFormKey = GlobalKey<FormState>();
  final _subProjectFormKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _subProjectText = TextEditingController();

  bool _loading = false;
  String? userRole;

  List<dynamic> _projects = [];
  Map<String, dynamic>? _selectedProject;
  final List<Map<String, dynamic>> _projectslist = [];
  final List<Map<String, dynamic>> _allSubprojects = [];
  bool _loadingProjects = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadProjects();
  }

  Future<void> _loadUserRole() async {
    final res = await UserService.getCurrentUser();
    if (res["success"] == true && res["user"] != null) {
      final user = res["user"];
      setState(() {
        userRole = (user["RoleName"] ?? "employee").toString().toLowerCase();
      });
    } else {
      setState(() => userRole = "employee");
      CustomSnackBar.warning("Failed to fetch user role");
    }
  }

  Future<void> _loadProjects() async {
    setState(() => _loadingProjects = true);
    try {
      final res = await ProjectService.fetchProjects();
      final subRes = await ProjectService.fetchSubProjects();
      if (!mounted) return;
      setState(() {
        _projects.clear();
        _projectslist.clear();
        _allSubprojects.clear();

        _projects = res;
        _projectslist.addAll(res.map((p) => Map<String, dynamic>.from(p)));
        _allSubprojects.addAll(
          subRes.map((sp) => Map<String, dynamic>.from(sp)),
        );
      });
    } catch (e) {
      CustomSnackBar.error("Failed to load projects: $e");
    } finally {
      setState(() => _loadingProjects = false);
    }
  }

  Future<void> _addProject() async {
    if (!_projectFormKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final res = await ProjectService.addProject(_name.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res["success"] == true) {
      CustomSnackBar.success("Project added successfully");
      _name.clear();
      _loadProjects();
    } else {
      CustomSnackBar.error(res["error"] ?? "Failed to add project");
    }
  }

  Future<void> _saveSubProject() async {
    if (!_subProjectFormKey.currentState!.validate()) return;
    if (_selectedProject == null) {
      CustomSnackBar.error("Please select a main project");
      return;
    }

    setState(() => _loading = true);
    try {
      final projectId = int.tryParse(_selectedProject!["ProjectId"].toString());
      final res = await ProjectService.addSubProject(
        projectId: projectId!,
        subProjectName: _subProjectText.text.trim(),
      );

      if (res["success"] == true) {
        CustomSnackBar.success("Subproject added successfully!");
        _subProjectText.clear();
        setState(() => _selectedProject = null);
        _loadProjects();
      } else {
        CustomSnackBar.error("Failed to add subproject: ${res['error']}");
      }
    } catch (e) {
      CustomSnackBar.error("Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildForms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userRole == "admin") ...[
          Text("Add Project", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 16.h),
          Form(
            key: _projectFormKey,
            child: Column(
              children: [
                CustomTextField(
                  labelText: "Project Name",
                  isRequired: true,
                  hintText: "Enter project name",
                  prefixIcon: Icons.library_add,
                  controller: _name,
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Project cannot be empty"
                      : null,
                ),
                SizedBox(height: 16.h),
                CustomButton(
                  text: "Add Project",
                  onPressed: _addProject,
                  isLoading: _loading,
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Divider(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          SizedBox(height: 16.h),
        ],

        Text("Add SubProject", style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 16.h),
        Form(
          key: _subProjectFormKey,
          child: Column(
            children: [
              CustomDropdownField<int>(
                labelText: "Select Main Project",
                isRequired: true,
                hintText: "Select Main Project",
                prefixIcon: Icons.work,
                items: _projectslist
                    .map(
                      (p) => {
                        "ID": p["ProjectId"],
                        "Name": p["ProjectName"] ?? "",
                      },
                    )
                    .toList(),
                valueKey: "ID",
                labelKey: "Name",
                value: _selectedProject?["ProjectId"],
                onChanged: (value) {
                  setState(() {
                    _selectedProject = _projectslist.firstWhere(
                      (p) => p["ProjectId"] == value,
                    );
                  });
                },
                validator: (value) =>
                    value == null ? "Please select a project" : null,
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                labelText: "Sub project name",
                hintText: "Enter sub project name",
                controller: _subProjectText,
                isRequired: true,
                maxLength: 50,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? "Subproject is required"
                    : null,
              ),
              SizedBox(height: 12.h),
              CustomButton(
                text: "Add Sub Project",
                onPressed: _saveSubProject,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectList(bool isMobile) {
    if (_loadingProjects) return const PageLoader();
    if (_projects.isEmpty) {
      return const Center(child: NoTasksWidget(message: "No project added!"));
    }

    return ListView.separated(
      shrinkWrap: isMobile,
      physics: isMobile ? const NeverScrollableScrollPhysics() : null,
      itemCount: _projects.length,
      separatorBuilder: (_, _) => Divider(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
      itemBuilder: (context, index) {
        final project = _projects[index];
        final projectId = project["ProjectId"];
        final creatorName = project["creatorName"] ?? "Unknown";
        final createdAt = project["createdAt"] != null
            ? DateFormat(
                'dd/MM/yyyy hh:mm a',
              ).format(DateTime.parse(project["createdAt"]))
            : "";

        final subprojectsForProject = _allSubprojects
            .where((sp) => sp["ProjectId"] == projectId)
            .toList();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Icon(
                Icons.folder,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                "Project: ${project["ProjectName"].toString().toUpperCase()}",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Created by: $creatorName\nDate: $createdAt",
                style: TextStyle(color: ThemeClass.warningColor),
              ),
              children: [
                if (subprojectsForProject.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "No subprojects added yet.",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                else
                  ...subprojectsForProject.map(
                    (sp) => ListTile(
                      contentPadding: EdgeInsets.only(left: 48.w, right: 16.w),
                      leading: const Icon(
                        Icons.subdirectory_arrow_right,
                        size: 20,
                      ),
                      title: Text(
                        sp["SubProjectName"] ?? "Unknown",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        ResponsiveLayout.isDesktop(context) ||
        ResponsiveLayout.isTablet(context);

    return BaseLayout(
      title: userRole == "admin" ? "Manage Projects" : "Add Sub Projects",
      // customActions: [
      //   IconButton(
      //     icon: const Icon(Icons.home),
      //     onPressed: () {
      //       if (userRole == "admin") {
      //         Get.until(
      //           (route) =>
      //               route.settings.name == Routes.adminDashboard ||
      //               route.isFirst,
      //         );
      //       } else {
      //         Get.offNamed(Routes.homeScreen);
      //       }
      //     },
      //   ),
      // ],
      child: SafeArea(
        child: isDesktop
            ? Padding(
                padding: EdgeInsets.all(24.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side: Forms
                    Expanded(
                      flex: 4,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: SingleChildScrollView(child: _buildForms()),
                        ),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    // Right Side: List
                    Expanded(
                      flex: 6,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "All Projects & Subprojects",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 16.h),
                              Expanded(child: _buildProjectList(false)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildForms(),
                    SizedBox(height: 24.h),
                    Divider(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                    ),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "All Projects",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildProjectList(true),
                  ],
                ),
              ),
      ),
    );
  }
}
