// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:excel/excel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/screens/no_data.dart';
import 'package:task_mate/screens/page_loader.dart';
import 'package:task_mate/services/api_service.dart';
import 'package:intl/intl.dart';

class EmployeeTaskScreen extends StatefulWidget {
  const EmployeeTaskScreen({super.key});

  @override
  State<EmployeeTaskScreen> createState() => _EmployeeTaskScreenState();
}

class _EmployeeTaskScreenState extends State<EmployeeTaskScreen> {
  List employees = [];
  List allTasks = []; // all fetched tasks
  List tasks = []; // filtered tasks
  String? selectedEmp;
  String? selectedEmpName;
  bool loading = false;
  bool singleEmployeeMode = false;

  String selectedFilter = "today"; // all, today, week, month
  int? selectedMonth;
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    final args = Get.arguments;
    if (args != null && args["empId"] != null) {
      singleEmployeeMode = true;
      selectedEmp = args["empId"].toString();
      selectedEmpName = args["empName"] ?? "Employee";
      _loadTasksByEmployee(args["empId"]);
    } else {
      singleEmployeeMode = false;
      _loadAllTasksByEmployee();
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final data = await ApiService.fetchEmployees();

      if (!mounted) return;
      setState(() => employees = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load employees: $e")));
    }
  }

  Future<void> _loadTasksByEmployee(int empId) async {
    setState(() => loading = true);
    try {
      final data = await ApiService.fetchTasksByEmployee(empId);
      if (!mounted) return;
      setState(() {
        allTasks = data;
        selectedFilter = "today";
        _applyFilter();
        selectedEmp = empId.toString();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load tasks: $e")));
    }
  }

  Future<void> _loadAllTasksByEmployee() async {
    setState(() => loading = true);
    try {
      final data = await ApiService.fetchAllTasksByEmployee();
      if (!mounted) return;
      setState(() {
        allTasks = data;
        selectedFilter = "today";
        _applyFilter();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load tasks: $e")));
    }
  }

  void _applyFilter() {
    if (selectedFilter == "all") {
      setState(() => tasks = List.from(allTasks));
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      tasks = allTasks.where((t) {
        final createdAt = t["createdAt"] ?? t["CreatedAt"];
        if (createdAt == null) return false;
        try {
          final taskDate = DateTime.parse(createdAt.toString());

          switch (selectedFilter) {
            case "today":
              return taskDate.year == today.year &&
                  taskDate.month == today.month &&
                  taskDate.day == today.day;
            case "week":
              final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
              final endOfWeek = startOfWeek.add(const Duration(days: 6));
              return taskDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                  taskDate.isBefore(endOfWeek.add(const Duration(days: 1)));
            case "month":
              if (selectedMonth == null || selectedYear == null) return false;
              return taskDate.year == selectedYear && taskDate.month == selectedMonth;
          }
          return true;
        } catch (e) {
          return false;
        }
      }).toList();
    });
  }

  Future<void> _pickMonthYear() async {
    final now = DateTime.now();
    int tempYear = selectedYear ?? now.year;
    int tempMonth = selectedMonth ?? now.month;
    final currentYear = now.year;
    final currentMonth = now.month;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(15),
              child: Container(
                width: double.infinity,
                height: 400,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Select Month & Year",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Year selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setDialogState(() => tempYear--);
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "$tempYear",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: tempYear < currentYear
                              ? () => setDialogState(() => tempYear++)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Month grid
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 12,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 6,
                          childAspectRatio: 2.2,
                        ),
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isFutureMonth = (tempYear == currentYear && month > currentMonth);

                          return ChoiceChip(
                            label: Text(
                              DateFormat.MMM().format(DateTime(0, month)),
                              style: TextStyle(
                                color: isFutureMonth ? Colors.grey : Colors.black,
                                fontWeight: tempMonth == month
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: tempMonth == month,
                            onSelected: isFutureMonth
                                ? null
                                : (_) => setDialogState(() => tempMonth = month),
                            selectedColor: Colors.green.shade400,
                            backgroundColor: isFutureMonth
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx, {"month": tempMonth, "year": tempYear});
                          },
                          child: const Text("Select"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result != null && result is Map) {
        setState(() {
          selectedMonth = result["month"];
          selectedYear = result["year"];
          selectedFilter = "month";
          _applyFilter();
        });
      }
    });
  }

  String _calculateDuration(String start, String end) {
    if (start.isEmpty) return "N/A";

    final startTime = DateTime.parse(start);
    DateTime endTime;

    if (end.isEmpty || start == end) {
      endTime = startTime.add(const Duration(hours: 8));
    } else {
      endTime = DateTime.parse(end);
    }

    final difference = endTime.difference(startTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return "$hours h $minutes m";
    } else if (hours > 0) {
      return "$hours hours";
    } else {
      return "$minutes minutes";
    }
  }

  // 🔹 Export to Excel
  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheetObject = excel['Tasks'];
      final dateFormatter = DateFormat("dd/MM/yyyy hh:mm a");

      sheetObject.appendRow([
        TextCellValue("UserName"),
        TextCellValue("Task No"),
        TextCellValue("Project"),
        TextCellValue("Sub Project"),
        TextCellValue("Mode"),
        TextCellValue("Title"),
        TextCellValue("Description"),
        TextCellValue("Status"),
        TextCellValue("Start Time"),
        TextCellValue("End Time"),
        TextCellValue("Work Hour"),
        TextCellValue("Created At"),
      ]);

      for (int i = 0; i < allTasks.length; i++) {
        final t = allTasks[i];
        DateTime? start;
        DateTime? end;
        if (t["startTime"] != null && t["startTime"].isNotEmpty) {
          start = DateTime.tryParse(t["startTime"])?.toLocal();
        }
        if (t["endTime"] != null && t["endTime"].isNotEmpty) {
          end = DateTime.tryParse(t["endTime"])?.toLocal();
        }
        String workHour = "";
        if (start != null && end != null) {
          final diff = end.difference(start);
          final hours = diff.inHours;
          final minutes = diff.inMinutes % 60;
          workHour = "${hours}h ${minutes}m";
        }
        sheetObject.appendRow([
          TextCellValue(t["userName"]?.toString() ?? ""),
          TextCellValue("${i + 1}"),
          TextCellValue(t["project"] ?? ""),
          TextCellValue(t["subProject"] ?? ""),
          TextCellValue(t["mode"] ?? ""),
          TextCellValue(t["title"] ?? ""),
          TextCellValue(t["description"] ?? ""),
          TextCellValue(t["status"] ?? ""),
          TextCellValue(start != null ? dateFormatter.format(start) : ""),
          TextCellValue(end != null ? dateFormatter.format(end) : ""),
          TextCellValue(workHour),
          TextCellValue(
            t["startTime"] != null && t["startTime"].isNotEmpty
                ? dateFormatter.format(DateTime.parse(t["startTime"]).toLocal())
                : "",
          ),
        ]);
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          "${selectedEmpName ?? 'All'}_tasks_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      final file = File("${dir.path}/$fileName");
      await file.create(recursive: true);
      await file.writeAsBytes(excel.encode()!);

      await OpenFilex.open(file.path);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Excel file exported successfully!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to export: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = (selectedFilter == "month" && selectedMonth != null && selectedYear != null)
        ? "Month (${DateFormat.MMM().format(DateTime(0, selectedMonth!))} $selectedYear)"
        : "Month";
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          selectedEmpName != null && selectedEmpName!.isNotEmpty
              ? "Tasks - $selectedEmpName"
              : "Task Details",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          if (allTasks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: "Export to Excel",
              onPressed: _exportToExcel,
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
        child: Column(
          children: [
            if (!singleEmployeeMode)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: DropdownButtonFormField2<String>(
                  isExpanded: true,
                  value: selectedEmp,
                  items: [
                    const DropdownMenuItem<String>(value: "", child: Text("All Employees")),
                    ...employees
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e["ID"].toString(),
                            child: Text(e["Name"]?.toString() ?? "Unknown"),
                          ),
                        )
                        // ignore: unnecessary_to_list_in_spreads
                        .toList(),
                  ],
                  onChanged: (id) {
                    if (id == null || id.isEmpty) {
                      setState(() {
                        selectedEmp = null;
                        selectedEmpName = null;
                      });
                      _loadAllTasksByEmployee();
                    } else {
                      final emp = employees.firstWhere(
                        (e) => e["ID"].toString() == id,
                        orElse: () => {},
                      );
                      setState(() {
                        selectedEmp = id;
                        selectedEmpName = emp["Name"]?.toString() ?? "";
                      });
                      _loadTasksByEmployee(int.parse(id));
                    }
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Select Employee",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select an employee";
                    }
                    return null;
                  },
                  dropdownStyleData: DropdownStyleData(
                    padding: EdgeInsets.zero,
                    maxHeight: 300.h,
                    width: MediaQuery.of(context).size.width - 25.w,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  ),
                  buttonStyleData: ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0),
                    height: 20.h,
                    width: double.infinity,
                  ),
                ),
              ),

            // 🔹 Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text("All"),
                    selected: selectedFilter == "all",
                    onSelected: (_) {
                      setState(() => selectedFilter = "all");
                      _applyFilter();
                    },
                  ),
                  SizedBox(width: 8.w),
                  ChoiceChip(
                    label: const Text("Today"),
                    selected: selectedFilter == "today",
                    onSelected: (_) {
                      setState(() => selectedFilter = "today");
                      _applyFilter();
                    },
                  ),
                  SizedBox(width: 8.w),
                  ChoiceChip(
                    label: const Text("Week"),
                    selected: selectedFilter == "week",
                    onSelected: (_) {
                      setState(() => selectedFilter = "week");
                      _applyFilter();
                    },
                  ),
                  SizedBox(width: 8.w),
                  ChoiceChip(
                    label: Text(monthLabel),
                    selected: selectedFilter == "month",
                    onSelected: (_) {
                      _pickMonthYear();
                    },
                  ),
                ],
              ),
            ),

            // Task Table
            Expanded(
              child: loading
                  ? const PageLoader()
                  : tasks.isEmpty
                  ? const NoTasksWidget()
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final t = tasks[index];
                        final createdAt = t["createdAt"] ?? t["CreatedAt"];
                        final dateStr = createdAt != null
                            ? DateFormat("dd/MM/yyyy").format(DateTime.parse(createdAt.toString()))
                            : "";
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(color: Colors.grey.shade100),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Sr.No : ${index + 1}",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Mode :  ",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          t["mode"] ?? "",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(color: ThemeClass.textSecondaryLight),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Project : ",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          "${t["project"] ?? ""}",
                                          style: Theme.of(context).textTheme.labelMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Text(
                                      "Sub Project : ",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      "${t["subProject"] ?? ""}",
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Title :",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          " ${t["title"] ?? ""}",
                                          style: Theme.of(context).textTheme.labelMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Details :",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          " ${t["description"] ?? ""}",
                                          style: Theme.of(context).textTheme.labelMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(color: ThemeClass.textSecondaryLight),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "$dateStr |",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          _calculateDuration(t["startTime"], t["endTime"]),
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Status :",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        Text(
                                          " ${t["status"] ?? ""}",
                                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                            color: t["status"] == "Working"
                                                ? ThemeClass.warningColor
                                                : ThemeClass.successColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
