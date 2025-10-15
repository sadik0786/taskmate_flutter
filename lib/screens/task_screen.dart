import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mate/core/theme.dart';
import 'package:task_mate/screens/no_data.dart';
import 'package:task_mate/screens/page_loader.dart';
import 'package:intl/intl.dart';
import 'package:task_mate/services/api_service.dart';
import 'add_task_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List allTasks = [];
  List tasks = [];
  String? userName;
  bool isLoading = true;

  String selectedFilter = "all"; // all, today, week, month
  int? selectedMonth;
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadTasks();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "Employee";
    });
  }

  Future<void> _loadTasks() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.fetchTasks();

      // print("📊 Total tasks loaded: ${data.length}");
      setState(() {
        allTasks = data;
        _applyFilter();
        isLoading = false;
      });
    } catch (e) {
      // print("❌ Error loading tasks: $e");
      setState(() {
        isLoading = false;
        allTasks = [];
        tasks = [];
      });
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      tasks = allTasks.where((t) {
        final startTime = t["startTime"];
        if (startTime == null) return false;
        final taskDate = DateTime.parse(startTime);

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
          default:
            return true; // all
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

  String getFormattedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "";
    try {
      return DateFormat("dd/MM/yyyy").format(DateTime.parse(dateString));
    } catch (e) {
      return "Invalid Date";
    }
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
        TextCellValue("${i + 1}"),
        TextCellValue(t["project"] ?? ""),
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
    final file = File("${dir.path}/${userName}_tasks.xlsx");
    await file.create(recursive: true);
    await file.writeAsBytes(excel.encode()!);

    await OpenFilex.open(file.path);
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
        title: Text("Task Detail", style: Theme.of(context).textTheme.titleLarge),
        actions: [
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(vertical: 8.h),
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
              Divider(),
              Expanded(
                child: isLoading
                    ? PageLoader()
                    : tasks.isEmpty
                    ? NoTasksWidget()
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final t = tasks[index];
                          // print("Task $index: $t");
                          final createdAt = t["startTime"];
                          final dateStr = createdAt != null
                              ? DateFormat("dd/MM/yyyy").format(DateTime.parse(createdAt))
                              : "";
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade100),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Sr.No : ${index + 1}",
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => AddTaskScreen(task: t),
                                                ),
                                              );
                                              _loadTasks();
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              size: 20.sp,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          SizedBox(width: 30.w),
                                          GestureDetector(
                                            child: Icon(
                                              Icons.delete,
                                              size: 20.sp,
                                              color: Colors.red,
                                            ),
                                            onTap: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                    "Delete Task",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  content: const Text(
                                                    "Are you sure you want to delete this task?",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(ctx, false),
                                                      child: const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(ctx, true),
                                                      child: const Text(
                                                        "Delete",
                                                        style: TextStyle(color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                final taskId = t["id"] is int
                                                    ? t["id"] as int
                                                    : int.tryParse(t["id"].toString());

                                                if (taskId == null) {
                                                  Get.snackbar(
                                                    "Error",
                                                    "Invalid task ID",
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white,
                                                  );
                                                  return;
                                                }

                                                // Show loading
                                                Get.dialog(
                                                  const Center(child: CircularProgressIndicator()),
                                                  barrierDismissible: false,
                                                );

                                                try {
                                                  final result = await ApiService.deleteTask(
                                                    taskId,
                                                  );

                                                  Get.back();

                                                  if (result["success"] == true) {
                                                    setState(() {
                                                      tasks.removeAt(index);
                                                    });

                                                    Get.snackbar(
                                                      "Success",
                                                      "Task deleted successfully",
                                                      backgroundColor: Colors.green,
                                                      colorText: Colors.white,
                                                      snackPosition: SnackPosition.BOTTOM,
                                                    );
                                                    _loadTasks();
                                                  } else {
                                                    Get.snackbar(
                                                      "Error",
                                                      result["error"] ?? "Failed to delete task",
                                                      backgroundColor: Colors.red,
                                                      colorText: Colors.white,
                                                      snackPosition: SnackPosition.BOTTOM,
                                                    );
                                                  }
                                                } catch (e) {
                                                  Get.back();
                                                  Get.snackbar(
                                                    "Error",
                                                    "Network error: ${e.toString()}",
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white,
                                                    snackPosition: SnackPosition.BOTTOM,
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(color: ThemeClass.lightBgColor),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  Divider(color: ThemeClass.lightBgColor),
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
                                            style: Theme.of(context).textTheme.labelMedium!
                                                .copyWith(
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
      ),
    );
  }
}
